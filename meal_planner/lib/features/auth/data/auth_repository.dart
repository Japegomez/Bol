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
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState, AuthException;

class AuthRepository {
  GoogleSignIn? _googleSignInInstance;
  bool _manualSignOut = false;

  GoogleSignIn? get _googleSignIn {
    if (!Env.hasGoogleSignIn) return null;
    return _googleSignInInstance ??= GoogleSignIn(
      serverClientId: Env.googleWebClientId,
      clientId: _googleClientId,
      scopes: const ['email', 'profile', 'openid'],
    );
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
  }) async {
    try {
      return await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      return await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw mapAuthError(e);
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = _googleSignIn;
    if (googleSignIn == null) {
      throw const AuthConfigurationException(
        'GOOGLE_WEB_CLIENT_ID is not configured',
      );
    }

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthCancelledException();
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const AuthProviderException('Google Sign-In returned no id token');
      }

      try {
        return await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: googleAuth.accessToken,
        );
      } on AuthException {
        rethrow;
      } catch (e) {
        throw mapAuthError(e);
      }
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
        await _googleSignIn?.signOut();
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

  Future<void> _deleteUserAvatar(String userId) async {
    try {
      await supabase.storage.from('avatars').remove(['$userId/avatar.jpg']);
    } catch (_) {
      // Best-effort cleanup before account deletion.
    }
  }

  Session? get currentSession => supabase.auth.currentSession;

  Stream<AuthState> get authStateChanges async* {
    var wasAuthenticated = supabase.auth.currentSession != null;
    String? lastUserId = supabase.auth.currentUser?.id;

    yield wasAuthenticated
        ? AuthAuthenticated(supabase.auth.currentUser!)
        : const AuthUnauthenticated();

    await for (final event in supabase.auth.onAuthStateChange) {
      final session = event.session;
      if (session != null) {
        final userId = session.user.id;
        // Skip token-refresh emissions that would recreate the router / reload
        // providers with an equivalent AuthAuthenticated state.
        if (wasAuthenticated &&
            lastUserId == userId &&
            event.event == AuthChangeEvent.tokenRefreshed) {
          continue;
        }
        wasAuthenticated = true;
        lastUserId = userId;
        yield AuthAuthenticated(session.user);
      } else {
        final sessionExpired = wasAuthenticated && !_manualSignOut;
        wasAuthenticated = false;
        lastUserId = null;
        _manualSignOut = false;
        yield AuthUnauthenticated(sessionExpired: sessionExpired);
      }
    }
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
