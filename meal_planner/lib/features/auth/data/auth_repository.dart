import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meal_planner/core/auth/session_background.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/auth/data/auth_error_mapper.dart';
import 'package:meal_planner/features/auth/domain/auth_exception.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState, AuthException;

class AuthRepository {
  var _googleInitialized = false;
  bool _manualSignOut = false;

  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize(
      serverClientId: Env.googleWebClientId,
      clientId: _googleClientId,
    );
    _googleInitialized = true;
  }

  String? get _googleClientId {
    if (kIsWeb) return Env.googleWebClientId;
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        Env.googleIosClientId.isNotEmpty) {
      return Env.googleIosClientId;
    }
    return null;
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
    String? captchaToken,
  }) async {
    try {
      return await supabase.auth.signInWithPassword(
        email: email,
        password: password,
        captchaToken: captchaToken,
      );
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String? captchaToken,
  }) async {
    try {
      return await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
        captchaToken: captchaToken,
      );
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  Future<void> sendPasswordResetEmail(
    String email, {
    String? captchaToken,
  }) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        captchaToken: captchaToken,
      );
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    if (!Env.hasGoogleSignIn) {
      throw const AuthConfigurationException(
        'GOOGLE_WEB_CLIENT_ID is not configured',
      );
    }

    try {
      await _ensureGoogleInitialized();
      final googleUser = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile', 'openid'],
      );
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthProviderException(
          'Google Sign-In returned no id token',
        );
      }

      String? accessToken;
      try {
        final authorization = await _googleSignIn.authorizationClient
            .authorizationForScopes(const ['email', 'profile', 'openid']);
        accessToken = authorization?.accessToken;
      } catch (_) {
        // idToken is enough for Supabase; access token is best-effort.
      }

      try {
        final response = await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        final userId = response.user?.id;
        final photoUrl = googleUser.photoUrl;
        if (userId != null && photoUrl != null && photoUrl.isNotEmpty) {
          await _maybeImportGoogleAvatar(userId, photoUrl);
        }
        return response;
      } on AuthException {
        rethrow;
      } catch (e) {
        throw mapAuthError(e);
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      throw mapGoogleSignInError(e) ??
          AuthProviderException(e.description ?? e.code.name);
    } on PlatformException catch (e) {
      throw mapGoogleSignInError(e) ??
          AuthProviderException(e.message ?? e.code);
    } on AuthException {
      rethrow;
    }
  }

  Future<AuthResponse> signInWithApple() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      throw const AuthConfigurationException(
        'Sign in with Apple is only available on Apple platforms',
      );
    }

    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthProviderException('Apple Sign-In returned no id token');
    }

    try {
      return await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  Future<void> signOut({
    bool manual = false,
    SignOutScope scope = SignOutScope.global,
  }) async {
    _manualSignOut = manual;
    if (_signedInWithGoogle) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Best-effort; Supabase sign-out still runs below.
      }
    }
    try {
      await SessionBackground.clearMarker();
    } catch (_) {
      // Best-effort; auth sign-out still runs below.
    }
    await supabase.auth.signOut(scope: scope);
  }

  bool get _signedInWithGoogle {
    final identities = supabase.auth.currentUser?.identities;
    if (identities == null) return false;
    return identities.any((identity) => identity.provider == 'google');
  }

  Future<void> deleteAccount() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthProviderException('No authenticated user');
    }

    await _deleteUserAvatar(userId);
    await supabase.rpc<void>('delete_user_account');
    await signOut(manual: true);
  }

  bool get hasEmailPassword {
    final identities = supabase.auth.currentUser?.identities;
    if (identities == null) return false;
    return identities.any((identity) => identity.provider == 'email');
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword, currentPassword: currentPassword),
      );
    } catch (e) {
      final mapped = mapAuthError(e);
      if (mapped is AuthInvalidCredentialsException) {
        throw const AuthInvalidCurrentPasswordException();
      }
      throw mapped;
    }
  }

  Future<void> _deleteUserAvatar(String userId) async {
    try {
      await supabase.storage.from('avatars').remove(['$userId/avatar.jpg']);
    } catch (_) {
      // Best-effort cleanup before account deletion.
    }
  }

  /// Imports Google profile photo using atomic RPC.
  /// Only imports if user has no avatar, or their avatar source is 'google'.
  /// Will NOT overwrite user-uploaded or explicitly deleted avatars.
  Future<void> _maybeImportGoogleAvatar(String userId, String photoUrl) async {
    try {
      // For new users, wait briefly for handle_new_user trigger.
      final data = await supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }

      // Use atomic RPC to conditionally import avatar
      await supabase.rpc<void>(
        'import_google_avatar',
        params: {'user_id': userId, 'photo_url': photoUrl},
      );
    } catch (_) {
      // Best-effort; login must not fail if avatar import fails.
    }
  }

  Session? get currentSession => supabase.auth.currentSession;

  /// Maps Supabase auth events into app [AuthState].
  ///
  /// Errors on [GoTrueClient.onAuthStateChange] (e.g. failed deeplink session
  /// recovery) must not terminate this stream — otherwise the UI stays on login
  /// while a valid session remains in secure storage until cold start.
  Stream<AuthState> get authStateChanges {
    return Stream.multi((multi) {
      var wasAuthenticated = false;
      String? lastUserId;

      void emitAuthenticated(User user, {AuthChangeEvent? event}) {
        final userId = user.id;
        if (wasAuthenticated &&
            lastUserId == userId &&
            event == AuthChangeEvent.tokenRefreshed) {
          return;
        }
        wasAuthenticated = true;
        lastUserId = userId;
        multi.add(AuthAuthenticated(user));
      }

      void emitUnauthenticated() {
        final sessionExpired = wasAuthenticated && !_manualSignOut;
        wasAuthenticated = false;
        lastUserId = null;
        _manualSignOut = false;
        multi.add(AuthUnauthenticated(sessionExpired: sessionExpired));
      }

      final session = supabase.auth.currentSession;
      if (session != null) {
        wasAuthenticated = true;
        lastUserId = session.user.id;
        multi.add(AuthAuthenticated(session.user));
      } else {
        multi.add(const AuthUnauthenticated());
      }

      final subscription = supabase.auth.onAuthStateChange.listen(
        (event) {
          final nextSession = event.session;
          if (nextSession != null) {
            emitAuthenticated(nextSession.user, event: event.event);
          } else {
            emitUnauthenticated();
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          // Recover from current session instead of ending the provider stream.
          // Do not treat deeplink failures as sign-out when no session exists.
          final current = supabase.auth.currentSession;
          final user = current?.user ?? supabase.auth.currentUser;
          if (current != null && user != null) {
            emitAuthenticated(user);
          }
        },
        cancelOnError: false,
      );

      multi.onCancel = () => subscription.cancel();
    });
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
