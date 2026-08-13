import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_eu.dart';
import 'app_localizations_gl.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
    Locale('eu'),
    Locale('gl'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Böl'**
  String get appName;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageBasque.
  ///
  /// In en, this message translates to:
  /// **'Basque'**
  String get languageBasque;

  /// No description provided for @languageCatalan.
  ///
  /// In en, this message translates to:
  /// **'Catalan'**
  String get languageCatalan;

  /// No description provided for @languageGalician.
  ///
  /// In en, this message translates to:
  /// **'Galician'**
  String get languageGalician;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navRecipeBook.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get navRecipeBook;

  /// No description provided for @navPlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get navPlanner;

  /// No description provided for @navShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @exploreUnavailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Explore is unavailable offline'**
  String get exploreUnavailableOffline;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Plan your weekly meals'**
  String get loginTagline;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpiredMessage;

  /// No description provided for @supabaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Supabase is not configured. Copy dart_defines.example.json to dart_defines.json and add SUPABASE_URL / SUPABASE_ANON_KEY.'**
  String get supabaseNotConfigured;

  /// No description provided for @captchaRequired.
  ///
  /// In en, this message translates to:
  /// **'Complete the verification challenge'**
  String get captchaRequired;

  /// No description provided for @captchaFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Please try again.'**
  String get captchaFailed;

  /// No description provided for @turnstileNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Verification is temporarily unavailable. Please try again later.'**
  String get turnstileNotConfigured;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in with Google. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordLink;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccountRegister;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountTitle;

  /// No description provided for @registerInApp.
  ///
  /// In en, this message translates to:
  /// **'Sign up for {appName}'**
  String registerInApp(String appName);

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @minTwoCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 2 characters'**
  String get minTwoCharacters;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @enterPasswordRegister.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterPasswordRegister;

  /// No description provided for @minSixCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minSixCharacters;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password must include a lowercase letter, an uppercase letter, a number, and a symbol'**
  String get passwordTooWeak;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordChanged;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get currentPasswordIncorrect;

  /// No description provided for @passwordSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'The new password must be different from the current one'**
  String get passwordSameAsCurrent;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms and Privacy Policy'**
  String get mustAcceptTerms;

  /// No description provided for @acceptTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the'**
  String get acceptTermsPrefix;

  /// No description provided for @termsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsLink;

  /// No description provided for @andThe.
  ///
  /// In en, this message translates to:
  /// **'and the'**
  String get andThe;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @confirmationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to {email}. Confirm your account before signing in.'**
  String confirmationEmailSent(String email);

  /// No description provided for @goToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get goToSignIn;

  /// No description provided for @recoverPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get recoverPasswordTitle;

  /// No description provided for @forgotPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordInstructions;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendResetLink;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get emailSent;

  /// No description provided for @resetEmailSentIfExists.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, you will receive a link to reset your password.'**
  String resetEmailSentIfExists(String email);

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @recipeBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe book'**
  String get recipeBookTitle;

  /// No description provided for @cookingGlossaryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cooking glossary'**
  String get cookingGlossaryTooltip;

  /// No description provided for @newRecipeTooltip.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get newRecipeTooltip;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// No description provided for @noRecipesFoundForSearch.
  ///
  /// In en, this message translates to:
  /// **'No recipe matched your search. Create it yourself.'**
  String get noRecipesFoundForSearch;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// No description provided for @sortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get sortAlphabetical;

  /// No description provided for @alphabeticalOrder.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical order'**
  String get alphabeticalOrder;

  /// No description provided for @favoritesFilter.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesFilter;

  /// No description provided for @favoriteRecipeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favoriteRecipeTooltip;

  /// No description provided for @unfavoriteRecipeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get unfavoriteRecipeTooltip;

  /// No description provided for @noFavoriteRecipes.
  ///
  /// In en, this message translates to:
  /// **'No favorite recipes yet. Mark recipes with the star to find them here.'**
  String get noFavoriteRecipes;

  /// No description provided for @createFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create first recipe'**
  String get createFirstRecipe;

  /// No description provided for @servingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 serving} other{{count} servings}}'**
  String servingsCount(int count);

  /// No description provided for @servingsCountShort.
  ///
  /// In en, this message translates to:
  /// **'{count} srv.'**
  String servingsCountShort(int count);

  /// No description provided for @deleteRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get deleteRecipeTitle;

  /// No description provided for @deleteRecipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteRecipeConfirm(String title);

  /// No description provided for @publishRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish recipe'**
  String get publishRecipeTitle;

  /// No description provided for @publishRecipeMessage.
  ///
  /// In en, this message translates to:
  /// **'This recipe will be visible to all {appName} users. You can unpublish it at any time.'**
  String publishRecipeMessage(String appName);

  /// No description provided for @makeRecipePrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Make recipe private'**
  String get makeRecipePrivateTitle;

  /// No description provided for @makeRecipePrivateMessageDetail.
  ///
  /// In en, this message translates to:
  /// **'The recipe will no longer be visible in Explore. Existing ratings will be kept.'**
  String get makeRecipePrivateMessageDetail;

  /// No description provided for @makeRecipePrivateMessageForm.
  ///
  /// In en, this message translates to:
  /// **'The recipe will no longer be visible in Explore.'**
  String get makeRecipePrivateMessageForm;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @makePrivate.
  ///
  /// In en, this message translates to:
  /// **'Make private'**
  String get makePrivate;

  /// No description provided for @visibilityChangeError.
  ///
  /// In en, this message translates to:
  /// **'Error changing visibility: {error}'**
  String visibilityChangeError(String error);

  /// No description provided for @publicBadge.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicBadge;

  /// No description provided for @prepTimeMin.
  ///
  /// In en, this message translates to:
  /// **'Prep: {minutes} min'**
  String prepTimeMin(int minutes);

  /// No description provided for @cookTimeMin.
  ///
  /// In en, this message translates to:
  /// **'Cook: {minutes} min'**
  String cookTimeMin(int minutes);

  /// No description provided for @forkedRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe saved from another user'**
  String get forkedRecipeTitle;

  /// No description provided for @forkedRecipeCannotPublish.
  ///
  /// In en, this message translates to:
  /// **'Forked recipes cannot be published in Explore.'**
  String get forkedRecipeCannotPublish;

  /// No description provided for @publicRecipeSwitch.
  ///
  /// In en, this message translates to:
  /// **'Public recipe'**
  String get publicRecipeSwitch;

  /// No description provided for @visibleInExplore.
  ///
  /// In en, this message translates to:
  /// **'Visible in Explore for all users'**
  String get visibleInExplore;

  /// No description provided for @onlyInRecipeBook.
  ///
  /// In en, this message translates to:
  /// **'Only visible in your recipe book'**
  String get onlyInRecipeBook;

  /// No description provided for @ingredientsSection.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsSection;

  /// No description provided for @noIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients'**
  String get noIngredients;

  /// No description provided for @preparationSection.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get preparationSection;

  /// No description provided for @noSteps.
  ///
  /// In en, this message translates to:
  /// **'No steps'**
  String get noSteps;

  /// No description provided for @tipsSection.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tipsSection;

  /// No description provided for @nutritionPerServing.
  ///
  /// In en, this message translates to:
  /// **'Nutrition (per serving)'**
  String get nutritionPerServing;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydrates;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @fiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// No description provided for @nutritionChip.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String nutritionChip(String label, String value);

  /// No description provided for @newRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get newRecipeTitle;

  /// No description provided for @editRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editRecipeTitle;

  /// No description provided for @photoRequiresConnection.
  ///
  /// In en, this message translates to:
  /// **'You need a connection to add or change the recipe photo'**
  String get photoRequiresConnection;

  /// No description provided for @householdEditRequiresConnection.
  ///
  /// In en, this message translates to:
  /// **'Offline: editing in household mode requires a connection'**
  String get householdEditRequiresConnection;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servingsLabel;

  /// No description provided for @minOneServing.
  ///
  /// In en, this message translates to:
  /// **'Minimum 1'**
  String get minOneServing;

  /// No description provided for @prepMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Prep (min)'**
  String get prepMinLabel;

  /// No description provided for @cookMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Cook (min)'**
  String get cookMinLabel;

  /// No description provided for @tagsSection.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsSection;

  /// No description provided for @customTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom tag'**
  String get customTagLabel;

  /// No description provided for @stepsSection.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsSection;

  /// No description provided for @tipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tipsLabel;

  /// No description provided for @tipsHint.
  ///
  /// In en, this message translates to:
  /// **'Tricks, variations, or useful notes'**
  String get tipsHint;

  /// No description provided for @visibleInExploreShort.
  ///
  /// In en, this message translates to:
  /// **'Visible to all users in Explore'**
  String get visibleInExploreShort;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get addStep;

  /// No description provided for @stepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String stepLabel(int number);

  /// No description provided for @optionalStepPrefix.
  ///
  /// In en, this message translates to:
  /// **'Optional:'**
  String get optionalStepPrefix;

  /// No description provided for @checkingImage.
  ///
  /// In en, this message translates to:
  /// **'Checking image...'**
  String get checkingImage;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcal;

  /// No description provided for @proteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @carbohydratesG.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates (g)'**
  String get carbohydratesG;

  /// No description provided for @fatG.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatG;

  /// No description provided for @fiberG.
  ///
  /// In en, this message translates to:
  /// **'Fiber (g)'**
  String get fiberG;

  /// No description provided for @householdLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your household. Try again.'**
  String get householdLoadError;

  /// No description provided for @ingredientLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get ingredientLabel;

  /// No description provided for @removeIngredientTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove ingredient'**
  String get removeIngredientTooltip;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @customUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom unit'**
  String get customUnitLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @toTaste.
  ///
  /// In en, this message translates to:
  /// **'To taste'**
  String get toTaste;

  /// No description provided for @toTasteShoppingHint.
  ///
  /// In en, this message translates to:
  /// **'Not added to the shopping list (e.g. salt, pepper)'**
  String get toTasteShoppingHint;

  /// No description provided for @optionalIngredientHint.
  ///
  /// In en, this message translates to:
  /// **'You can include or exclude it on the recipe page'**
  String get optionalIngredientHint;

  /// No description provided for @clearTags.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearTags;

  /// No description provided for @cookingGlossaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooking glossary'**
  String get cookingGlossaryTitle;

  /// No description provided for @addTermTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add term'**
  String get addTermTooltip;

  /// No description provided for @newGlossaryEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newGlossaryEntry;

  /// No description provided for @termLabel.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get termLabel;

  /// No description provided for @enterTerm.
  ///
  /// In en, this message translates to:
  /// **'Enter a term'**
  String get enterTerm;

  /// No description provided for @definitionLabel.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get definitionLabel;

  /// No description provided for @enterDefinition.
  ///
  /// In en, this message translates to:
  /// **'Enter a definition'**
  String get enterDefinition;

  /// No description provided for @duplicateGlossaryTerm.
  ///
  /// In en, this message translates to:
  /// **'That term already exists in the glossary'**
  String get duplicateGlossaryTerm;

  /// No description provided for @searchTermOrDefinition.
  ///
  /// In en, this message translates to:
  /// **'Search term or definition'**
  String get searchTermOrDefinition;

  /// No description provided for @noGlossaryEntries.
  ///
  /// In en, this message translates to:
  /// **'No glossary entries'**
  String get noGlossaryEntries;

  /// No description provided for @noGlossaryTermsFound.
  ///
  /// In en, this message translates to:
  /// **'No terms found'**
  String get noGlossaryTermsFound;

  /// No description provided for @deleteEntryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteEntryTooltip;

  /// No description provided for @deleteGlossaryEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteGlossaryEntryTitle;

  /// No description provided for @deleteGlossaryEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove \"{term}\" from the glossary?'**
  String deleteGlossaryEntryConfirm(String term);

  /// No description provided for @autoTranslatedBadge.
  ///
  /// In en, this message translates to:
  /// **'Automatically translated'**
  String get autoTranslatedBadge;

  /// No description provided for @viewOriginal.
  ///
  /// In en, this message translates to:
  /// **'View original'**
  String get viewOriginal;

  /// No description provided for @viewTranslation.
  ///
  /// In en, this message translates to:
  /// **'View translation'**
  String get viewTranslation;

  /// No description provided for @translatingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Translating recipe...'**
  String get translatingRecipe;

  /// No description provided for @translationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not translate this recipe'**
  String get translationFailed;

  /// No description provided for @plannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get plannerTitle;

  /// No description provided for @sharePlannerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share planner'**
  String get sharePlannerTooltip;

  /// No description provided for @copyPlannerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy planner'**
  String get copyPlannerTooltip;

  /// No description provided for @plannerCopied.
  ///
  /// In en, this message translates to:
  /// **'Planner copied to clipboard'**
  String get plannerCopied;

  /// No description provided for @plannerShareLeftoverLabel.
  ///
  /// In en, this message translates to:
  /// **'leftovers'**
  String get plannerShareLeftoverLabel;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @showRecipeBookTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show recipe book'**
  String get showRecipeBookTooltip;

  /// No description provided for @removeMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove meal'**
  String get removeMealTitle;

  /// No description provided for @removeMealConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" from the planner?'**
  String removeMealConfirm(String title);

  /// No description provided for @dropHere.
  ///
  /// In en, this message translates to:
  /// **'Drop here'**
  String get dropHere;

  /// No description provided for @dragOrTap.
  ///
  /// In en, this message translates to:
  /// **'Drag or tap'**
  String get dragOrTap;

  /// No description provided for @servingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servingsTitle;

  /// No description provided for @servingsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of servings'**
  String get servingsCountLabel;

  /// No description provided for @addTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Add text'**
  String get addTextTitle;

  /// No description provided for @mealNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Takeout)'**
  String get mealNameLabel;

  /// No description provided for @enterMealName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the meal'**
  String get enterMealName;

  /// No description provided for @fewerServingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fewer servings'**
  String get fewerServingsTooltip;

  /// No description provided for @moreServingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More servings'**
  String get moreServingsTooltip;

  /// No description provided for @leftovers.
  ///
  /// In en, this message translates to:
  /// **'These are leftovers'**
  String get leftovers;

  /// No description provided for @leftoversShoppingHint.
  ///
  /// In en, this message translates to:
  /// **'Ingredients will not be added to the shopping list'**
  String get leftoversShoppingHint;

  /// No description provided for @pastMealPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Past meal'**
  String get pastMealPlanTitle;

  /// No description provided for @pastMealPlanMessage.
  ///
  /// In en, this message translates to:
  /// **'You are planning a meal for a day that has already passed. Ingredients will not be added to the shopping list.'**
  String get pastMealPlanMessage;

  /// No description provided for @recipeBookPanel.
  ///
  /// In en, this message translates to:
  /// **'Recipe book'**
  String get recipeBookPanel;

  /// No description provided for @closeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTooltip;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noRecipesCreateInBook.
  ///
  /// In en, this message translates to:
  /// **'You have no recipes. Create them in the recipe book.'**
  String get noRecipesCreateInBook;

  /// No description provided for @chooseRecipe.
  ///
  /// In en, this message translates to:
  /// **'Choose recipe'**
  String get chooseRecipe;

  /// No description provided for @searchRecipeHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipe...'**
  String get searchRecipeHint;

  /// No description provided for @addFreeText.
  ///
  /// In en, this message translates to:
  /// **'Add free text'**
  String get addFreeText;

  /// No description provided for @noRecipeExample.
  ///
  /// In en, this message translates to:
  /// **'No recipe (e.g. takeout, eating out, etc.)'**
  String get noRecipeExample;

  /// No description provided for @clearListTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear list'**
  String get clearListTitle;

  /// No description provided for @clearListConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all items from the shopping list?'**
  String get clearListConfirm;

  /// No description provided for @shoppingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingListTitle;

  /// No description provided for @shareListTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share list'**
  String get shareListTooltip;

  /// No description provided for @shareRecipeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share recipe'**
  String get shareRecipeTooltip;

  /// No description provided for @shareRecipeMessage.
  ///
  /// In en, this message translates to:
  /// **'{url}\n\nCheck out this recipe on Böl: {title}'**
  String shareRecipeMessage(String title, String url);

  /// No description provided for @shareLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'This share link has expired'**
  String get shareLinkExpired;

  /// No description provided for @shareLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'This share link is invalid'**
  String get shareLinkInvalid;

  /// No description provided for @revokeShareLink.
  ///
  /// In en, this message translates to:
  /// **'Revoke share link'**
  String get revokeShareLink;

  /// No description provided for @revokeShareLinkConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will invalidate the current private share link. Anyone who has the link will no longer be able to open this recipe.'**
  String get revokeShareLinkConfirm;

  /// No description provided for @revoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revoke;

  /// No description provided for @shareLinkRevoked.
  ///
  /// In en, this message translates to:
  /// **'Share link revoked'**
  String get shareLinkRevoked;

  /// No description provided for @noActiveShareLink.
  ///
  /// In en, this message translates to:
  /// **'No active share link to revoke'**
  String get noActiveShareLink;

  /// No description provided for @clearListTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear list'**
  String get clearListTooltip;

  /// No description provided for @shoppingListLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the list: {error}'**
  String shoppingListLoadError(String error);

  /// No description provided for @shoppingListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your list is empty'**
  String get shoppingListEmpty;

  /// No description provided for @shoppingListEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add recipes to the planner or items manually with the + button.'**
  String get shoppingListEmptyHint;

  /// No description provided for @addItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItemTooltip;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the list?'**
  String deleteItemConfirm(String name);

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @othersCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get othersCategory;

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get feedTitle;

  /// No description provided for @mostRecent.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get mostRecent;

  /// No description provided for @sortedBy.
  ///
  /// In en, this message translates to:
  /// **'Sorted by: {label}'**
  String sortedBy(String label);

  /// No description provided for @noRecipesWithTags.
  ///
  /// In en, this message translates to:
  /// **'No recipes with these tags'**
  String get noRecipesWithTags;

  /// No description provided for @feedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recipes from people you follow'**
  String get feedEmpty;

  /// No description provided for @tryOtherTags.
  ///
  /// In en, this message translates to:
  /// **'Try other tags or remove the filter.'**
  String get tryOtherTags;

  /// No description provided for @followUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Follow other users from their profiles to see their public recipes here.'**
  String get followUsersHint;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @feedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get feedTooltip;

  /// No description provided for @searchPublicRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search public recipes'**
  String get searchPublicRecipes;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get topRated;

  /// No description provided for @noPublicRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No public recipes yet'**
  String get noPublicRecipesYet;

  /// No description provided for @publishToExploreHint.
  ///
  /// In en, this message translates to:
  /// **'Publish a recipe from your recipe book so others can discover it.'**
  String get publishToExploreHint;

  /// No description provided for @publicProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get publicProfileTitle;

  /// No description provided for @publicRecipesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 public recipe} other{{count} public recipes}}'**
  String publicRecipesCount(int count);

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @noPublicRecipes.
  ///
  /// In en, this message translates to:
  /// **'No public recipes'**
  String get noPublicRecipes;

  /// No description provided for @recipeSavedToBook.
  ///
  /// In en, this message translates to:
  /// **'Recipe saved to your recipe book'**
  String get recipeSavedToBook;

  /// No description provided for @saveToMyRecipeBookTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save to my recipe book'**
  String get saveToMyRecipeBookTooltip;

  /// No description provided for @recipeCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Recipe created by'**
  String get recipeCreatedBy;

  /// No description provided for @recipeCreatedByName.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get recipeCreatedByName;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get you;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @optionalIngredientSuffix.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optionalIngredientSuffix;

  /// No description provided for @saveToMyRecipeBook.
  ///
  /// In en, this message translates to:
  /// **'Save to my recipe book'**
  String get saveToMyRecipeBook;

  /// No description provided for @optionalIngredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional ingredients'**
  String get optionalIngredientsTitle;

  /// No description provided for @optionalIngredientsMessage.
  ///
  /// In en, this message translates to:
  /// **'This recipe contains optional ingredients. Add or remove them in your recipe.'**
  String get optionalIngredientsMessage;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editRecipe;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get inviteCodeCopied;

  /// No description provided for @regenerateCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate code'**
  String get regenerateCodeTitle;

  /// No description provided for @regenerateCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'The previous code will stop working. Generate a new one?'**
  String get regenerateCodeMessage;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @codeRegenerated.
  ///
  /// In en, this message translates to:
  /// **'Code regenerated'**
  String get codeRegenerated;

  /// No description provided for @kickMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get kickMemberTitle;

  /// No description provided for @kickMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {username} from the household?'**
  String kickMemberConfirm(String username);

  /// No description provided for @kick.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get kick;

  /// No description provided for @leaveHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave household'**
  String get leaveHouseholdTitle;

  /// No description provided for @leaveHouseholdMessage.
  ///
  /// In en, this message translates to:
  /// **'The household planner and shopping list will be copied to your individual mode (current and future weeks). Continue?'**
  String get leaveHouseholdMessage;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @myHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'My household'**
  String get myHouseholdTitle;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invitation code'**
  String get inviteCode;

  /// No description provided for @inviteViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Invite via WhatsApp'**
  String get inviteViaWhatsApp;

  /// No description provided for @inviteWhatsAppHouseholdMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi! Join my household on {appName}:\n{url}'**
  String inviteWhatsAppHouseholdMessage(String appName, String url);

  /// No description provided for @copyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyTooltip;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @leaveHousehold.
  ///
  /// In en, this message translates to:
  /// **'Leave household'**
  String get leaveHousehold;

  /// No description provided for @noSharedHousehold.
  ///
  /// In en, this message translates to:
  /// **'No shared household'**
  String get noSharedHousehold;

  /// No description provided for @individualModeDescription.
  ///
  /// In en, this message translates to:
  /// **'In individual mode you use your own planner and shopping list. Create a household or join with a code to share them with others.'**
  String get individualModeDescription;

  /// No description provided for @createHousehold.
  ///
  /// In en, this message translates to:
  /// **'Create household'**
  String get createHousehold;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with code'**
  String get joinWithCode;

  /// No description provided for @currentUserSuffix.
  ///
  /// In en, this message translates to:
  /// **'{username} (you)'**
  String currentUserSuffix(String username);

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @joinHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a household'**
  String get joinHouseholdTitle;

  /// No description provided for @joinCodeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6- or 8-character code shared by a household member.'**
  String get joinCodeInstructions;

  /// No description provided for @invalidInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid invitation code'**
  String get invalidInviteCode;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You already belong to this household'**
  String get alreadyMember;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again in a few minutes.'**
  String get tooManyAttempts;

  /// No description provided for @pleaseWaitMoment.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment before trying again.'**
  String get pleaseWaitMoment;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericErrorMessage;

  /// No description provided for @codeMustBeSixOrEightChars.
  ///
  /// In en, this message translates to:
  /// **'The code must be 6 or 8 characters'**
  String get codeMustBeSixOrEightChars;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @createHouseholdDescription.
  ///
  /// In en, this message translates to:
  /// **'Give your shared household a name. You can invite other members with a code.'**
  String get createHouseholdDescription;

  /// No description provided for @householdNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Household name'**
  String get householdNameLabel;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutTitle;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @defaultUsername.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUsername;

  /// No description provided for @individualModeNoHousehold.
  ///
  /// In en, this message translates to:
  /// **'Individual mode (no household)'**
  String get individualModeNoHousehold;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @myHousehold.
  ///
  /// In en, this message translates to:
  /// **'My household'**
  String get myHousehold;

  /// No description provided for @createOrJoinHousehold.
  ///
  /// In en, this message translates to:
  /// **'Create or join a household'**
  String get createOrJoinHousehold;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @rateYourApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Your App'**
  String get rateYourApp;

  /// No description provided for @rateYourAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leave a review on the store'**
  String get rateYourAppSubtitle;

  /// No description provided for @rateAppUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rating is not available on this device right now.'**
  String get rateAppUnavailable;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @adminControlPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin control panel'**
  String get adminControlPanel;

  /// No description provided for @adminFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get adminFeedbackTitle;

  /// No description provided for @feedbackWhatAbout.
  ///
  /// In en, this message translates to:
  /// **'What do you want to tell us?'**
  String get feedbackWhatAbout;

  /// No description provided for @feedbackCategoryIssue.
  ///
  /// In en, this message translates to:
  /// **'Problem or bug'**
  String get feedbackCategoryIssue;

  /// No description provided for @feedbackCategoryFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature suggestion'**
  String get feedbackCategoryFeature;

  /// No description provided for @feedbackCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get feedbackCategoryOther;

  /// No description provided for @feedbackTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get feedbackTypeLabel;

  /// No description provided for @feedbackYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get feedbackYourMessage;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem or idea in as much detail as possible…'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackMinCharsHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 10 characters'**
  String get feedbackMinCharsHint;

  /// No description provided for @feedbackMessageTooShort.
  ///
  /// In en, this message translates to:
  /// **'The message must be at least 10 characters.'**
  String get feedbackMessageTooShort;

  /// No description provided for @feedbackSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback. We\'ll review it to improve the app.'**
  String get feedbackSentSuccess;

  /// No description provided for @feedbackSendError.
  ///
  /// In en, this message translates to:
  /// **'Could not send feedback. Please try again.'**
  String get feedbackSendError;

  /// No description provided for @feedbackCategoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get feedbackCategoryFilter;

  /// No description provided for @feedbackStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get feedbackStatusFilter;

  /// No description provided for @feedbackFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get feedbackFilterAll;

  /// No description provided for @feedbackStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get feedbackStatusPending;

  /// No description provided for @feedbackStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get feedbackStatusResolved;

  /// No description provided for @feedbackStatusIgnored.
  ///
  /// In en, this message translates to:
  /// **'Ignored'**
  String get feedbackStatusIgnored;

  /// No description provided for @feedbackMarkResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark as resolved'**
  String get feedbackMarkResolved;

  /// No description provided for @feedbackMarkIgnored.
  ///
  /// In en, this message translates to:
  /// **'Mark as ignored'**
  String get feedbackMarkIgnored;

  /// No description provided for @feedbackMarkedResolved.
  ///
  /// In en, this message translates to:
  /// **'Feedback marked as resolved.'**
  String get feedbackMarkedResolved;

  /// No description provided for @feedbackMarkedIgnored.
  ///
  /// In en, this message translates to:
  /// **'Feedback marked as ignored.'**
  String get feedbackMarkedIgnored;

  /// No description provided for @feedbackStatusUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update feedback status.'**
  String get feedbackStatusUpdateError;

  /// No description provided for @adminFeedbackEmpty.
  ///
  /// In en, this message translates to:
  /// **'No feedback with these filters.'**
  String get adminFeedbackEmpty;

  /// No description provided for @adminFeedbackLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load feedback.'**
  String get adminFeedbackLoadError;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. Your profile, recipes, personal planner, and associated lists will be deleted.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @gdprRightToErasure.
  ///
  /// In en, this message translates to:
  /// **'Right to erasure (GDPR)'**
  String get gdprRightToErasure;

  /// No description provided for @deleteAccountBulletsIntro.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will permanently delete:'**
  String get deleteAccountBulletsIntro;

  /// No description provided for @deleteBulletProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile and avatar'**
  String get deleteBulletProfile;

  /// No description provided for @deleteBulletRecipes.
  ///
  /// In en, this message translates to:
  /// **'All your recipes and associated images'**
  String get deleteBulletRecipes;

  /// No description provided for @deleteBulletPlans.
  ///
  /// In en, this message translates to:
  /// **'Your plans and shopping lists in individual mode'**
  String get deleteBulletPlans;

  /// No description provided for @deleteBulletMembership.
  ///
  /// In en, this message translates to:
  /// **'Your membership in shared households'**
  String get deleteBulletMembership;

  /// No description provided for @soleAdminWarning.
  ///
  /// In en, this message translates to:
  /// **'If you are the only admin of a household with other members, transfer the admin role or ask members to leave before deleting your account.'**
  String get soleAdminWarning;

  /// No description provided for @deleteAcknowledgement.
  ///
  /// In en, this message translates to:
  /// **'I understand this action is irreversible and I want to delete my account.'**
  String get deleteAcknowledgement;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Account: {email}'**
  String accountEmail(String email);

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @removeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removeProfilePhoto;

  /// No description provided for @couldNotOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Could not open the document'**
  String get couldNotOpenDocument;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get openInBrowser;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get noConnection;

  /// No description provided for @offlineModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineModeTitle;

  /// No description provided for @offlineHouseholdMessage.
  ///
  /// In en, this message translates to:
  /// **'You are offline. You can view the last saved version of your recipe book, planner, and shopping list, but editing is not available in household mode offline (to avoid conflicts with other members). Explore is also unavailable.'**
  String get offlineHouseholdMessage;

  /// No description provided for @offlineIndividualMessage.
  ///
  /// In en, this message translates to:
  /// **'You are offline. You can view and edit your recipe book, planner, and shopping list; changes will sync when you reconnect. Recipe photos and the Explore tab are unavailable offline.'**
  String get offlineIndividualMessage;

  /// No description provided for @imageNotAllowedTitle.
  ///
  /// In en, this message translates to:
  /// **'Image not allowed'**
  String get imageNotAllowedTitle;

  /// No description provided for @imageNotAllowedMessage.
  ///
  /// In en, this message translates to:
  /// **'The selected image contains adult or explicit content that is not allowed. Please choose another image.'**
  String get imageNotAllowedMessage;

  /// No description provided for @imageCheckFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not verify image'**
  String get imageCheckFailedTitle;

  /// No description provided for @imageCheckFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not verify the image. Please try again.'**
  String get imageCheckFailedRetry;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @categoryMeatFish.
  ///
  /// In en, this message translates to:
  /// **'Meat and fish'**
  String get categoryMeatFish;

  /// No description provided for @categoryVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get categoryVegetables;

  /// No description provided for @categoryFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get categoryFruits;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoryDairy;

  /// No description provided for @categoryGrains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get categoryGrains;

  /// No description provided for @categoryLegumes.
  ///
  /// In en, this message translates to:
  /// **'Legumes'**
  String get categoryLegumes;

  /// No description provided for @categorySpices.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get categorySpices;

  /// No description provided for @categoryOilsVinegars.
  ///
  /// In en, this message translates to:
  /// **'Oils and vinegars'**
  String get categoryOilsVinegars;

  /// No description provided for @categoryCanned.
  ///
  /// In en, this message translates to:
  /// **'Canned goods'**
  String get categoryCanned;

  /// No description provided for @categoryNuts.
  ///
  /// In en, this message translates to:
  /// **'Nuts'**
  String get categoryNuts;

  /// No description provided for @categoryBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get categoryBeverages;

  /// No description provided for @categoryBaking.
  ///
  /// In en, this message translates to:
  /// **'Baking'**
  String get categoryBaking;

  /// No description provided for @categoryFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get categoryFrozen;

  /// No description provided for @categorySauces.
  ///
  /// In en, this message translates to:
  /// **'Sauces and condiments'**
  String get categorySauces;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @unitCustomOption.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get unitCustomOption;

  /// No description provided for @unitCount.
  ///
  /// In en, this message translates to:
  /// **'unit'**
  String get unitCount;

  /// No description provided for @unitPinch.
  ///
  /// In en, this message translates to:
  /// **'pinch'**
  String get unitPinch;

  /// No description provided for @unitTeaspoon.
  ///
  /// In en, this message translates to:
  /// **'teaspoon'**
  String get unitTeaspoon;

  /// No description provided for @unitTablespoon.
  ///
  /// In en, this message translates to:
  /// **'tablespoon'**
  String get unitTablespoon;

  /// No description provided for @unitGlass.
  ///
  /// In en, this message translates to:
  /// **'glass'**
  String get unitGlass;

  /// No description provided for @unitCup.
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get unitCup;

  /// No description provided for @unitHandful.
  ///
  /// In en, this message translates to:
  /// **'handful'**
  String get unitHandful;

  /// No description provided for @unitLeaf.
  ///
  /// In en, this message translates to:
  /// **'leaf'**
  String get unitLeaf;

  /// No description provided for @unitClove.
  ///
  /// In en, this message translates to:
  /// **'clove'**
  String get unitClove;

  /// No description provided for @unitSplash.
  ///
  /// In en, this message translates to:
  /// **'splash'**
  String get unitSplash;

  /// No description provided for @unitSlice.
  ///
  /// In en, this message translates to:
  /// **'slice'**
  String get unitSlice;

  /// No description provided for @unitSprig.
  ///
  /// In en, this message translates to:
  /// **'sprig'**
  String get unitSprig;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get unitPiece;

  /// No description provided for @unitFillet.
  ///
  /// In en, this message translates to:
  /// **'fillet'**
  String get unitFillet;

  /// No description provided for @unitRound.
  ///
  /// In en, this message translates to:
  /// **'round slice'**
  String get unitRound;

  /// No description provided for @unitCan.
  ///
  /// In en, this message translates to:
  /// **'can'**
  String get unitCan;

  /// No description provided for @unitJar.
  ///
  /// In en, this message translates to:
  /// **'jar'**
  String get unitJar;

  /// No description provided for @unitPackage.
  ///
  /// In en, this message translates to:
  /// **'package'**
  String get unitPackage;

  /// No description provided for @unitSachet.
  ///
  /// In en, this message translates to:
  /// **'sachet'**
  String get unitSachet;

  /// No description provided for @tagStarter.
  ///
  /// In en, this message translates to:
  /// **'starter'**
  String get tagStarter;

  /// No description provided for @tagMainCourse.
  ///
  /// In en, this message translates to:
  /// **'main course'**
  String get tagMainCourse;

  /// No description provided for @tagDessert.
  ///
  /// In en, this message translates to:
  /// **'dessert'**
  String get tagDessert;

  /// No description provided for @tagVegetarian.
  ///
  /// In en, this message translates to:
  /// **'vegetarian'**
  String get tagVegetarian;

  /// No description provided for @tagVegan.
  ///
  /// In en, this message translates to:
  /// **'vegan'**
  String get tagVegan;

  /// No description provided for @tagPescatarian.
  ///
  /// In en, this message translates to:
  /// **'pescatarian'**
  String get tagPescatarian;

  /// No description provided for @tagGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'gluten-free'**
  String get tagGlutenFree;

  /// No description provided for @tagLactoseFree.
  ///
  /// In en, this message translates to:
  /// **'lactose-free'**
  String get tagLactoseFree;

  /// No description provided for @tagEggFree.
  ///
  /// In en, this message translates to:
  /// **'egg-free'**
  String get tagEggFree;

  /// No description provided for @tagNutFree.
  ///
  /// In en, this message translates to:
  /// **'nut-free'**
  String get tagNutFree;

  /// No description provided for @tagSoyFree.
  ///
  /// In en, this message translates to:
  /// **'soy-free'**
  String get tagSoyFree;

  /// No description provided for @tagShellfishFree.
  ///
  /// In en, this message translates to:
  /// **'shellfish-free'**
  String get tagShellfishFree;

  /// No description provided for @tagSugarFree.
  ///
  /// In en, this message translates to:
  /// **'sugar-free'**
  String get tagSugarFree;

  /// No description provided for @tagHighProtein.
  ///
  /// In en, this message translates to:
  /// **'high protein'**
  String get tagHighProtein;

  /// No description provided for @tagLowCalorie.
  ///
  /// In en, this message translates to:
  /// **'low calorie'**
  String get tagLowCalorie;

  /// No description provided for @tagLowCarb.
  ///
  /// In en, this message translates to:
  /// **'low carb'**
  String get tagLowCarb;

  /// No description provided for @tagHighFiber.
  ///
  /// In en, this message translates to:
  /// **'high fiber'**
  String get tagHighFiber;

  /// No description provided for @tagMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get tagMediterranean;

  /// No description provided for @tagQuick.
  ///
  /// In en, this message translates to:
  /// **'quick'**
  String get tagQuick;

  /// No description provided for @tagBudget.
  ///
  /// In en, this message translates to:
  /// **'budget-friendly'**
  String get tagBudget;

  /// No description provided for @tagBatchCooking.
  ///
  /// In en, this message translates to:
  /// **'batch cooking'**
  String get tagBatchCooking;

  /// No description provided for @tagFreezerFriendly.
  ///
  /// In en, this message translates to:
  /// **'freezer-friendly'**
  String get tagFreezerFriendly;

  /// No description provided for @tagSpicy.
  ///
  /// In en, this message translates to:
  /// **'spicy'**
  String get tagSpicy;

  /// No description provided for @tagKidFriendly.
  ///
  /// In en, this message translates to:
  /// **'kid-friendly'**
  String get tagKidFriendly;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingPrevious.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingPrevious;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// No description provided for @onboardingStep0Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Böl!'**
  String get onboardingStep0Title;

  /// No description provided for @onboardingStep0Body.
  ///
  /// In en, this message translates to:
  /// **'We\'ll show you how the app works in about a minute. You can skip this tutorial at any time.'**
  String get onboardingStep0Body;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Weekly planner'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Body.
  ///
  /// In en, this message translates to:
  /// **'See all days with their meals. The ‹ › arrows change the week. Today is highlighted in green.'**
  String get onboardingStep1Body;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Add meals to your plan'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Tap an empty slot to assign a recipe. You can also tap the book icon to open the side recipe panel and drag recipes onto a day.'**
  String get onboardingStep2Body;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Your recipe book'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Body.
  ///
  /// In en, this message translates to:
  /// **'All your recipes at a glance. The search icon finds recipes by name and the book icon opens the cooking glossary.'**
  String get onboardingStep3Body;

  /// No description provided for @onboardingStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Create a recipe'**
  String get onboardingStep4Title;

  /// No description provided for @onboardingStep4Body.
  ///
  /// In en, this message translates to:
  /// **'The + button opens the form: photo, ingredients with quantities, steps, nutrition and tags. You can publish it so others can discover it.'**
  String get onboardingStep4Body;

  /// No description provided for @onboardingStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get onboardingStep5Title;

  /// No description provided for @onboardingStep5Body.
  ///
  /// In en, this message translates to:
  /// **'When you plan meals, ingredients appear here automatically grouped by category. Check items off as you shop.'**
  String get onboardingStep5Body;

  /// No description provided for @onboardingStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients'**
  String get onboardingStep6Title;

  /// No description provided for @onboardingStep6Body.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add ingredients manually to your shopping list.'**
  String get onboardingStep6Body;

  /// No description provided for @onboardingStep7Title.
  ///
  /// In en, this message translates to:
  /// **'Share your list'**
  String get onboardingStep7Title;

  /// No description provided for @onboardingStep7Body.
  ///
  /// In en, this message translates to:
  /// **'The share icon creates text ready to send via WhatsApp or other apps.'**
  String get onboardingStep7Body;

  /// No description provided for @onboardingStep8Title.
  ///
  /// In en, this message translates to:
  /// **'Discover the community'**
  String get onboardingStep8Title;

  /// No description provided for @onboardingStep8Body.
  ///
  /// In en, this message translates to:
  /// **'Search other users\' recipes by name or tags. Rate them and save them to your recipe book.'**
  String get onboardingStep8Body;

  /// No description provided for @onboardingStep9Title.
  ///
  /// In en, this message translates to:
  /// **'Your followed cooks'**
  String get onboardingStep9Title;

  /// No description provided for @onboardingStep9Body.
  ///
  /// In en, this message translates to:
  /// **'Follow your favourite cooks from their profile and see their latest recipes by tapping the Following button.'**
  String get onboardingStep9Body;

  /// No description provided for @onboardingStep10Title.
  ///
  /// In en, this message translates to:
  /// **'Your profile and household'**
  String get onboardingStep10Title;

  /// No description provided for @onboardingStep10Body.
  ///
  /// In en, this message translates to:
  /// **'Edit your name and photo. In the My household section you can plan with your family in real time. You can also change language and dark mode here.'**
  String get onboardingStep10Body;

  /// No description provided for @createRecipeOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Create recipe'**
  String get createRecipeOptionsTitle;

  /// No description provided for @createRecipeManual.
  ///
  /// In en, this message translates to:
  /// **'Create manually'**
  String get createRecipeManual;

  /// No description provided for @createRecipeManualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in all recipe fields yourself'**
  String get createRecipeManualSubtitle;

  /// No description provided for @createRecipeWithAssistant.
  ///
  /// In en, this message translates to:
  /// **'Create with AI assistant'**
  String get createRecipeWithAssistant;

  /// No description provided for @createRecipeWithAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Describe the dish and AI will build the recipe card'**
  String get createRecipeWithAssistantSubtitle;

  /// No description provided for @recipeAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe assistant'**
  String get recipeAssistantTitle;

  /// No description provided for @recipeAssistantDescription.
  ///
  /// In en, this message translates to:
  /// **'Tell me what you\'re craving, what\'s in your fridge, paste a recipe, attach a photo, or dictate with the microphone.'**
  String get recipeAssistantDescription;

  /// No description provided for @recipeAssistantPromptHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Spanish potato omelette for 4 with onion...'**
  String get recipeAssistantPromptHint;

  /// No description provided for @recipeAssistantImagePromptHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the assistant what to do with the photo (e.g. recreate this dish, extract the recipe...)'**
  String get recipeAssistantImagePromptHint;

  /// No description provided for @recipeAssistantSameRecipePhotosHint.
  ///
  /// In en, this message translates to:
  /// **'If you attach more than one photo, they should all be of the same recipe.'**
  String get recipeAssistantSameRecipePhotosHint;

  /// No description provided for @recipeAssistantListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get recipeAssistantListening;

  /// No description provided for @recipeAssistantDictate.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get recipeAssistantDictate;

  /// No description provided for @recipeAssistantStopDictation.
  ///
  /// In en, this message translates to:
  /// **'Stop dictation'**
  String get recipeAssistantStopDictation;

  /// No description provided for @recipeAssistantSpeechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available. Enable it in Settings or type your request.'**
  String get recipeAssistantSpeechUnavailable;

  /// No description provided for @recipeAssistantSpeechFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not recognize speech. Please try again or type your request.'**
  String get recipeAssistantSpeechFailed;

  /// No description provided for @recipeAssistantGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate recipe'**
  String get recipeAssistantGenerate;

  /// No description provided for @recipeAssistantGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get recipeAssistantGenerating;

  /// No description provided for @recipeAssistantBlockingRecipe.
  ///
  /// In en, this message translates to:
  /// **'The assistant is creating your recipe…'**
  String get recipeAssistantBlockingRecipe;

  /// No description provided for @recipeAssistantBlockingNutrition.
  ///
  /// In en, this message translates to:
  /// **'Calculating nutritional information…'**
  String get recipeAssistantBlockingNutrition;

  /// No description provided for @recipeAssistantNotRecipeRequest.
  ///
  /// In en, this message translates to:
  /// **'I can only help you create recipes. Describe a dish or a recipe.'**
  String get recipeAssistantNotRecipeRequest;

  /// No description provided for @recipeAssistantRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Usage limit reached. Please try again later.'**
  String get recipeAssistantRateLimited;

  /// No description provided for @recipeAssistantFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a response. Please try again.'**
  String get recipeAssistantFailed;

  /// No description provided for @recipeAssistantOffline.
  ///
  /// In en, this message translates to:
  /// **'An internet connection is required to use the assistant.'**
  String get recipeAssistantOffline;

  /// No description provided for @recipeAssistantNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'The AI assistant is not configured yet.'**
  String get recipeAssistantNotConfigured;

  /// No description provided for @recipeAssistantTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get recipeAssistantTimeout;

  /// No description provided for @recipeAssistantPromptTooLong.
  ///
  /// In en, this message translates to:
  /// **'The recipe description cannot exceed 3,000 characters.'**
  String get recipeAssistantPromptTooLong;

  /// No description provided for @recipeAssistantMissingInput.
  ///
  /// In en, this message translates to:
  /// **'Write a description or attach a recipe photo.'**
  String get recipeAssistantMissingInput;

  /// No description provided for @recipeAssistantImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The image is too large. Try another photo or take a new one.'**
  String get recipeAssistantImageTooLarge;

  /// No description provided for @recipeAssistantInvalidImage.
  ///
  /// In en, this message translates to:
  /// **'Could not use that image. Try another photo.'**
  String get recipeAssistantInvalidImage;

  /// No description provided for @recipeAssistantDailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached your daily assistant limit. Come back tomorrow.'**
  String get recipeAssistantDailyLimitReached;

  /// No description provided for @recipeAssistantTooFast.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment before using the assistant again.'**
  String get recipeAssistantTooFast;

  /// No description provided for @recipeAssistantServiceAtCapacity.
  ///
  /// In en, this message translates to:
  /// **'The assistant is currently at capacity. Please try again later.'**
  String get recipeAssistantServiceAtCapacity;

  /// No description provided for @completeNutritionWithAssistant.
  ///
  /// In en, this message translates to:
  /// **'Complete with AI'**
  String get completeNutritionWithAssistant;

  /// No description provided for @recipeAssistantNutritionSaved.
  ///
  /// In en, this message translates to:
  /// **'Nutrition information completed'**
  String get recipeAssistantNutritionSaved;

  /// No description provided for @cookRecipeButton.
  ///
  /// In en, this message translates to:
  /// **'Cook Recipe'**
  String get cookRecipeButton;

  /// No description provided for @continueCookingButton.
  ///
  /// In en, this message translates to:
  /// **'Continue Cooking'**
  String get continueCookingButton;

  /// No description provided for @checkIngredientsStep.
  ///
  /// In en, this message translates to:
  /// **'Check Ingredients'**
  String get checkIngredientsStep;

  /// No description provided for @stepXofY.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepXofY(int current, int total);

  /// No description provided for @completeStepButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Step'**
  String get completeStepButton;

  /// No description provided for @finishCookingButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishCookingButton;

  /// No description provided for @cookingPausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get cookingPausedLabel;

  /// No description provided for @cookingPauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get cookingPauseTooltip;

  /// No description provided for @cookingResumeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get cookingResumeTooltip;

  /// No description provided for @finishCookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish cooking?'**
  String get finishCookingTitle;

  /// No description provided for @finishCookingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to finish cooking \"{title}\"?'**
  String finishCookingConfirm(String title);

  /// No description provided for @cookingFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe finished!'**
  String get cookingFinishedTitle;

  /// No description provided for @cookingFinishedMessage.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your meal!'**
  String get cookingFinishedMessage;

  /// No description provided for @cookingInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe in progress'**
  String get cookingInProgressTitle;

  /// No description provided for @cookingInProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'You are already cooking \"{title}\". Start a new recipe?'**
  String cookingInProgressMessage(String title);

  /// No description provided for @cookingReplaceButton.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get cookingReplaceButton;

  /// No description provided for @previousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get previousStep;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get nextStep;

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @expandCookingSession.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expandCookingSession;

  /// No description provided for @cookingNotificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Cooking session'**
  String get cookingNotificationChannelName;

  /// No description provided for @cookingNotificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'In-progress cooking session'**
  String get cookingNotificationChannelDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ca',
    'en',
    'es',
    'eu',
    'gl',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'eu':
      return AppLocalizationsEu();
    case 'gl':
      return AppLocalizationsGl();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
