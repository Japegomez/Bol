// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Böl';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageBasque => 'Basque';

  @override
  String get languageCatalan => 'Catalan';

  @override
  String get languageGalician => 'Galician';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageTitle => 'Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get clear => 'Clear';

  @override
  String get retry => 'Retry';

  @override
  String get understood => 'Got it';

  @override
  String get optional => 'Optional';

  @override
  String get requiredField => 'Required';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get navExplore => 'Explore';

  @override
  String get navRecipeBook => 'Recipe book';

  @override
  String get navPlanner => 'Planner';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navProfile => 'Profile';

  @override
  String get exploreUnavailableOffline => 'Explore is unavailable offline';

  @override
  String get loginTagline => 'Plan your weekly meals';

  @override
  String get sessionExpiredMessage =>
      'Your session has expired. Please sign in again.';

  @override
  String get supabaseNotConfigured =>
      'Supabase is not configured. Copy dart_defines.example.json to dart_defines.json and add SUPABASE_URL / SUPABASE_ANON_KEY.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get signIn => 'Sign in';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get forgotPasswordLink => 'Forgot your password?';

  @override
  String get noAccountRegister => 'Don\'t have an account? Sign up';

  @override
  String get createAccountTitle => 'Create account';

  @override
  String registerInApp(String appName) {
    return 'Sign up for $appName';
  }

  @override
  String get usernameLabel => 'Username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get minTwoCharacters => 'Minimum 2 characters';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get enterPasswordRegister => 'Enter a password';

  @override
  String get minSixCharacters => 'Minimum 6 characters';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get mustAcceptTerms => 'You must accept the Terms and Privacy Policy';

  @override
  String get acceptTermsPrefix => 'I accept the';

  @override
  String get termsLink => 'Terms';

  @override
  String get andThe => 'and the';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String confirmationEmailSent(String email) {
    return 'We sent a confirmation link to $email. Confirm your account before signing in.';
  }

  @override
  String get goToSignIn => 'Go to sign in';

  @override
  String get recoverPasswordTitle => 'Recover password';

  @override
  String get forgotPasswordInstructions =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get emailSent => 'Email sent';

  @override
  String resetEmailSentIfExists(String email) {
    return 'If an account exists for $email, you will receive a link to reset your password.';
  }

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get recipeBookTitle => 'Recipe book';

  @override
  String get cookingGlossaryTooltip => 'Cooking glossary';

  @override
  String get newRecipeTooltip => 'New recipe';

  @override
  String get searchByName => 'Search by name';

  @override
  String get noRecipesFoundForSearch =>
      'No recipe matched your search. Create it yourself.';

  @override
  String get noRecipesYet => 'No recipes yet';

  @override
  String get createFirstRecipe => 'Create first recipe';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '1 serving',
    );
    return '$_temp0';
  }

  @override
  String servingsCountShort(int count) {
    return '$count srv.';
  }

  @override
  String get deleteRecipeTitle => 'Delete recipe';

  @override
  String deleteRecipeConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get publishRecipeTitle => 'Publish recipe';

  @override
  String publishRecipeMessage(String appName) {
    return 'This recipe will be visible to all $appName users. You can unpublish it at any time.';
  }

  @override
  String get makeRecipePrivateTitle => 'Make recipe private';

  @override
  String get makeRecipePrivateMessageDetail =>
      'The recipe will no longer be visible in Explore. Existing ratings will be kept.';

  @override
  String get makeRecipePrivateMessageForm =>
      'The recipe will no longer be visible in Explore.';

  @override
  String get publish => 'Publish';

  @override
  String get makePrivate => 'Make private';

  @override
  String visibilityChangeError(String error) {
    return 'Error changing visibility: $error';
  }

  @override
  String get publicBadge => 'Public';

  @override
  String prepTimeMin(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String cookTimeMin(int minutes) {
    return 'Cook: $minutes min';
  }

  @override
  String get forkedRecipeTitle => 'Recipe saved from another user';

  @override
  String get forkedRecipeCannotPublish =>
      'Forked recipes cannot be published in Explore.';

  @override
  String get publicRecipeSwitch => 'Public recipe';

  @override
  String get visibleInExplore => 'Visible in Explore for all users';

  @override
  String get onlyInRecipeBook => 'Only visible in your recipe book';

  @override
  String get ingredientsSection => 'Ingredients';

  @override
  String get noIngredients => 'No ingredients';

  @override
  String get preparationSection => 'Preparation';

  @override
  String get noSteps => 'No steps';

  @override
  String get tipsSection => 'Tips';

  @override
  String get nutritionPerServing => 'Nutrition (per serving)';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbohydrates => 'Carbohydrates';

  @override
  String get fat => 'Fat';

  @override
  String get fiber => 'Fiber';

  @override
  String nutritionChip(String label, String value) {
    return '$label: $value';
  }

  @override
  String get newRecipeTitle => 'New recipe';

  @override
  String get editRecipeTitle => 'Edit recipe';

  @override
  String get photoRequiresConnection =>
      'You need a connection to add or change the recipe photo';

  @override
  String get householdEditRequiresConnection =>
      'Offline: editing in household mode requires a connection';

  @override
  String get nameLabel => 'Name';

  @override
  String get servingsLabel => 'Servings';

  @override
  String get minOneServing => 'Minimum 1';

  @override
  String get prepMinLabel => 'Prep (min)';

  @override
  String get cookMinLabel => 'Cook (min)';

  @override
  String get tagsSection => 'Tags';

  @override
  String get customTagLabel => 'Custom tag';

  @override
  String get stepsSection => 'Steps';

  @override
  String get tipsLabel => 'Tips';

  @override
  String get tipsHint => 'Tricks, variations, or useful notes';

  @override
  String get visibleInExploreShort => 'Visible to all users in Explore';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get addStep => 'Add step';

  @override
  String stepLabel(int number) {
    return 'Step $number';
  }

  @override
  String get optionalStepPrefix => 'Optional:';

  @override
  String get checkingImage => 'Checking image...';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get caloriesKcal => 'Calories (kcal)';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String get carbohydratesG => 'Carbohydrates (g)';

  @override
  String get fatG => 'Fat (g)';

  @override
  String get fiberG => 'Fiber (g)';

  @override
  String get householdLoadError => 'Could not load your household. Try again.';

  @override
  String get ingredientLabel => 'Ingredient';

  @override
  String get removeIngredientTooltip => 'Remove ingredient';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get unitLabel => 'Unit';

  @override
  String get customUnitLabel => 'Custom unit';

  @override
  String get categoryLabel => 'Category';

  @override
  String get toTaste => 'To taste';

  @override
  String get toTasteShoppingHint =>
      'Not added to the shopping list (e.g. salt, pepper)';

  @override
  String get optionalIngredientHint =>
      'You can include or exclude it on the recipe page';

  @override
  String get clearTags => 'Clear';

  @override
  String get cookingGlossaryTitle => 'Cooking glossary';

  @override
  String get addTermTooltip => 'Add term';

  @override
  String get newGlossaryEntry => 'New entry';

  @override
  String get termLabel => 'Term';

  @override
  String get enterTerm => 'Enter a term';

  @override
  String get definitionLabel => 'Definition';

  @override
  String get enterDefinition => 'Enter a definition';

  @override
  String get duplicateGlossaryTerm =>
      'That term already exists in the glossary';

  @override
  String get searchTermOrDefinition => 'Search term or definition';

  @override
  String get noGlossaryEntries => 'No glossary entries';

  @override
  String get noGlossaryTermsFound => 'No terms found';

  @override
  String get deleteEntryTooltip => 'Delete entry';

  @override
  String get deleteGlossaryEntryTitle => 'Delete entry';

  @override
  String deleteGlossaryEntryConfirm(String term) {
    return 'Do you want to remove \"$term\" from the glossary?';
  }

  @override
  String get autoTranslatedBadge => 'Automatically translated';

  @override
  String get viewOriginal => 'View original';

  @override
  String get viewTranslation => 'View translation';

  @override
  String get translatingRecipe => 'Translating recipe...';

  @override
  String get translationFailed => 'Could not translate this recipe';

  @override
  String get plannerTitle => 'Planner';

  @override
  String get sharePlannerTooltip => 'Share planner';

  @override
  String get copyPlannerTooltip => 'Copy planner';

  @override
  String get plannerCopied => 'Planner copied to clipboard';

  @override
  String get plannerShareLeftoverLabel => 'leftovers';

  @override
  String get thisWeek => 'This week';

  @override
  String get today => 'Today';

  @override
  String get showRecipeBookTooltip => 'Show recipe book';

  @override
  String get removeMealTitle => 'Remove meal';

  @override
  String removeMealConfirm(String title) {
    return 'Remove \"$title\" from the planner?';
  }

  @override
  String get dropHere => 'Drop here';

  @override
  String get dragOrTap => 'Drag or tap';

  @override
  String get servingsTitle => 'Servings';

  @override
  String get servingsCountLabel => 'Number of servings';

  @override
  String get addTextTitle => 'Add text';

  @override
  String get mealNameLabel => 'Name (e.g. Takeout)';

  @override
  String get enterMealName => 'Enter a name for the meal';

  @override
  String get fewerServingsTooltip => 'Fewer servings';

  @override
  String get moreServingsTooltip => 'More servings';

  @override
  String get leftovers => 'These are leftovers';

  @override
  String get leftoversShoppingHint =>
      'Ingredients will not be added to the shopping list';

  @override
  String get recipeBookPanel => 'Recipe book';

  @override
  String get closeTooltip => 'Close';

  @override
  String get searchHint => 'Search...';

  @override
  String get noResults => 'No results';

  @override
  String get noRecipesCreateInBook =>
      'You have no recipes. Create them in the recipe book.';

  @override
  String get chooseRecipe => 'Choose recipe';

  @override
  String get searchRecipeHint => 'Search recipe...';

  @override
  String get addFreeText => 'Add free text';

  @override
  String get noRecipeExample => 'No recipe (e.g. takeout, eating out, etc.)';

  @override
  String get clearListTitle => 'Clear list';

  @override
  String get clearListConfirm => 'Delete all items from the shopping list?';

  @override
  String get shoppingListTitle => 'Shopping list';

  @override
  String get shareListTooltip => 'Share list';

  @override
  String get shareRecipeTooltip => 'Share recipe';

  @override
  String shareRecipeMessage(String title, String url) {
    return '$url\n\nCheck out this recipe on Böl: $title';
  }

  @override
  String get shareLinkExpired => 'This share link has expired';

  @override
  String get shareLinkInvalid => 'This share link is invalid';

  @override
  String get clearListTooltip => 'Clear list';

  @override
  String shoppingListLoadError(String error) {
    return 'Could not load the list: $error';
  }

  @override
  String get shoppingListEmpty => 'Your list is empty';

  @override
  String get shoppingListEmptyHint =>
      'Add recipes to the planner or items manually with the + button.';

  @override
  String get addItemTooltip => 'Add item';

  @override
  String get deleteItemTitle => 'Delete item';

  @override
  String deleteItemConfirm(String name) {
    return 'Remove \"$name\" from the list?';
  }

  @override
  String get editItem => 'Edit item';

  @override
  String get addItem => 'Add item';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get othersCategory => 'Other';

  @override
  String get feedTitle => 'Feed';

  @override
  String get mostRecent => 'Most recent';

  @override
  String sortedBy(String label) {
    return 'Sorted by: $label';
  }

  @override
  String get noRecipesWithTags => 'No recipes with these tags';

  @override
  String get feedEmpty => 'Your feed is empty';

  @override
  String get tryOtherTags => 'Try other tags or remove the filter.';

  @override
  String get followUsersHint =>
      'Follow other users from their profiles to see their public recipes here.';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get feedTooltip => 'Feed';

  @override
  String get searchPublicRecipes => 'Search public recipes';

  @override
  String get recent => 'Recent';

  @override
  String get topRated => 'Top rated';

  @override
  String get noPublicRecipesYet => 'No public recipes yet';

  @override
  String get publishToExploreHint =>
      'Publish a recipe from your recipe book so others can discover it.';

  @override
  String get publicProfileTitle => 'Public profile';

  @override
  String publicRecipesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count public recipes',
      one: '1 public recipe',
    );
    return '$_temp0';
  }

  @override
  String get unfollow => 'Unfollow';

  @override
  String get follow => 'Follow';

  @override
  String get noPublicRecipes => 'No public recipes';

  @override
  String get recipeSavedToBook => 'Recipe saved to your recipe book';

  @override
  String get saveToMyRecipeBookTooltip => 'Save to my recipe book';

  @override
  String get recipeCreatedBy => 'Recipe created by';

  @override
  String get you => 'you';

  @override
  String get yourRating => 'Your rating';

  @override
  String get optionalIngredientSuffix => '(optional)';

  @override
  String get saveToMyRecipeBook => 'Save to my recipe book';

  @override
  String get optionalIngredientsTitle => 'Optional ingredients';

  @override
  String get optionalIngredientsMessage =>
      'This recipe contains optional ingredients. Add or remove them in your recipe.';

  @override
  String get editRecipe => 'Edit recipe';

  @override
  String get inviteCodeCopied => 'Code copied to clipboard';

  @override
  String get regenerateCodeTitle => 'Regenerate code';

  @override
  String get regenerateCodeMessage =>
      'The previous code will stop working. Generate a new one?';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get codeRegenerated => 'Code regenerated';

  @override
  String get kickMemberTitle => 'Remove member';

  @override
  String kickMemberConfirm(String username) {
    return 'Remove $username from the household?';
  }

  @override
  String get kick => 'Remove';

  @override
  String get leaveHouseholdTitle => 'Leave household';

  @override
  String get leaveHouseholdMessage =>
      'The household planner and shopping list will be copied to your individual mode (current and future weeks). Continue?';

  @override
  String get leave => 'Leave';

  @override
  String get myHouseholdTitle => 'My household';

  @override
  String get inviteCode => 'Invitation code';

  @override
  String get inviteViaWhatsApp => 'Invite via WhatsApp';

  @override
  String inviteWhatsAppHouseholdMessage(String appName, String code) {
    return 'Hi! Join my household on $appName. Use this code: $code';
  }

  @override
  String get copyTooltip => 'Copy';

  @override
  String get members => 'Members';

  @override
  String get leaveHousehold => 'Leave household';

  @override
  String get noSharedHousehold => 'No shared household';

  @override
  String get individualModeDescription =>
      'In individual mode you use your own planner and shopping list. Create a household or join with a code to share them with others.';

  @override
  String get createHousehold => 'Create household';

  @override
  String get joinWithCode => 'Join with code';

  @override
  String currentUserSuffix(String username) {
    return '$username (you)';
  }

  @override
  String get admin => 'Admin';

  @override
  String get member => 'Member';

  @override
  String get joinHouseholdTitle => 'Join a household';

  @override
  String get joinCodeInstructions =>
      'Enter the 6-character code shared by a household member.';

  @override
  String get invalidInviteCode => 'Invalid invitation code';

  @override
  String get alreadyMember => 'You already belong to this household';

  @override
  String get codeMustBeSixChars => 'The code must be 6 characters';

  @override
  String get join => 'Join';

  @override
  String get createHouseholdDescription =>
      'Give your shared household a name. You can invite other members with a code.';

  @override
  String get householdNameLabel => 'Household name';

  @override
  String get enterName => 'Enter a name';

  @override
  String get signOutTitle => 'Sign out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileTitle => 'Profile';

  @override
  String get defaultUsername => 'User';

  @override
  String get individualModeNoHousehold => 'Individual mode (no household)';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get myHousehold => 'My household';

  @override
  String get createOrJoinHousehold => 'Create or join a household';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get rateYourApp => 'Rate Your App';

  @override
  String get rateYourAppSubtitle => 'Leave a review on the store';

  @override
  String get rateAppUnavailable =>
      'Rating is not available on this device right now.';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get adminControlPanel => 'Admin control panel';

  @override
  String get adminFeedbackTitle => 'Feedback';

  @override
  String get feedbackWhatAbout => 'What do you want to tell us?';

  @override
  String get feedbackCategoryIssue => 'Problem or bug';

  @override
  String get feedbackCategoryFeature => 'Feature suggestion';

  @override
  String get feedbackCategoryOther => 'Other';

  @override
  String get feedbackTypeLabel => 'Type';

  @override
  String get feedbackYourMessage => 'Your message';

  @override
  String get feedbackMessageHint =>
      'Describe the problem or idea in as much detail as possible…';

  @override
  String get feedbackMinCharsHint => 'Minimum 10 characters';

  @override
  String get feedbackMessageTooShort =>
      'The message must be at least 10 characters.';

  @override
  String get feedbackSentSuccess =>
      'Thanks for your feedback. We\'ll review it to improve the app.';

  @override
  String get feedbackSendError => 'Could not send feedback. Please try again.';

  @override
  String get feedbackCategoryFilter => 'Category';

  @override
  String get feedbackStatusFilter => 'Status';

  @override
  String get feedbackFilterAll => 'All';

  @override
  String get feedbackStatusPending => 'Pending';

  @override
  String get feedbackStatusResolved => 'Resolved';

  @override
  String get feedbackStatusIgnored => 'Ignored';

  @override
  String get feedbackMarkResolved => 'Mark as resolved';

  @override
  String get feedbackMarkIgnored => 'Mark as ignored';

  @override
  String get feedbackMarkedResolved => 'Feedback marked as resolved.';

  @override
  String get feedbackMarkedIgnored => 'Feedback marked as ignored.';

  @override
  String get feedbackStatusUpdateError => 'Could not update feedback status.';

  @override
  String get adminFeedbackEmpty => 'No feedback with these filters.';

  @override
  String get adminFeedbackLoadError => 'Could not load feedback.';

  @override
  String get back => 'Back';

  @override
  String get send => 'Send';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirmTitle => 'Delete account?';

  @override
  String get deleteAccountConfirmMessage =>
      'This action is permanent. Your profile, recipes, personal planner, and associated lists will be deleted.';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get gdprRightToErasure => 'Right to erasure (GDPR)';

  @override
  String get deleteAccountBulletsIntro =>
      'Deleting your account will permanently delete:';

  @override
  String get deleteBulletProfile => 'Your profile and avatar';

  @override
  String get deleteBulletRecipes => 'All your recipes and associated images';

  @override
  String get deleteBulletPlans =>
      'Your plans and shopping lists in individual mode';

  @override
  String get deleteBulletMembership => 'Your membership in shared households';

  @override
  String get soleAdminWarning =>
      'If you are the only admin of a household with other members, transfer the admin role or ask members to leave before deleting your account.';

  @override
  String get deleteAcknowledgement =>
      'I understand this action is irreversible and I want to delete my account.';

  @override
  String get typeDeleteToConfirm => 'Type DELETE to confirm';

  @override
  String accountEmail(String email) {
    return 'Account: $email';
  }

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get removeProfilePhoto => 'Remove photo';

  @override
  String get couldNotOpenDocument => 'Could not open the document';

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String get noConnection => 'No connection';

  @override
  String get offlineModeTitle => 'Offline mode';

  @override
  String get offlineHouseholdMessage =>
      'You are offline. You can view the last saved version of your recipe book, planner, and shopping list, but editing is not available in household mode offline (to avoid conflicts with other members). Explore is also unavailable.';

  @override
  String get offlineIndividualMessage =>
      'You are offline. You can view and edit your recipe book, planner, and shopping list; changes will sync when you reconnect. Recipe photos and the Explore tab are unavailable offline.';

  @override
  String get imageNotAllowedTitle => 'Image not allowed';

  @override
  String get imageNotAllowedMessage =>
      'The selected image contains adult or explicit content that is not allowed. Please choose another image.';

  @override
  String get imageCheckFailedTitle => 'Could not verify image';

  @override
  String get imageCheckFailedRetry =>
      'Could not verify the image. Please try again.';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get categoryMeatFish => 'Meat and fish';

  @override
  String get categoryVegetables => 'Vegetables';

  @override
  String get categoryFruits => 'Fruits';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryGrains => 'Grains';

  @override
  String get categoryLegumes => 'Legumes';

  @override
  String get categorySpices => 'Spices';

  @override
  String get categoryOilsVinegars => 'Oils and vinegars';

  @override
  String get categoryCanned => 'Canned goods';

  @override
  String get categoryNuts => 'Nuts';

  @override
  String get categoryBeverages => 'Beverages';

  @override
  String get categoryBaking => 'Baking';

  @override
  String get categoryFrozen => 'Frozen';

  @override
  String get categorySauces => 'Sauces and condiments';

  @override
  String get categoryOther => 'Other';

  @override
  String get unitCustomOption => 'Other';

  @override
  String get unitCount => 'unit';

  @override
  String get unitPinch => 'pinch';

  @override
  String get unitTeaspoon => 'teaspoon';

  @override
  String get unitTablespoon => 'tablespoon';

  @override
  String get unitGlass => 'glass';

  @override
  String get unitCup => 'cup';

  @override
  String get unitHandful => 'handful';

  @override
  String get unitLeaf => 'leaf';

  @override
  String get unitClove => 'clove';

  @override
  String get unitSplash => 'splash';

  @override
  String get unitSlice => 'slice';

  @override
  String get unitSprig => 'sprig';

  @override
  String get unitPiece => 'piece';

  @override
  String get unitFillet => 'fillet';

  @override
  String get unitRound => 'round slice';

  @override
  String get unitCan => 'can';

  @override
  String get unitJar => 'jar';

  @override
  String get unitPackage => 'package';

  @override
  String get unitSachet => 'sachet';

  @override
  String get tagStarter => 'starter';

  @override
  String get tagMainCourse => 'main course';

  @override
  String get tagDessert => 'dessert';

  @override
  String get tagVegetarian => 'vegetarian';

  @override
  String get tagVegan => 'vegan';

  @override
  String get tagPescatarian => 'pescatarian';

  @override
  String get tagGlutenFree => 'gluten-free';

  @override
  String get tagLactoseFree => 'lactose-free';

  @override
  String get tagEggFree => 'egg-free';

  @override
  String get tagNutFree => 'nut-free';

  @override
  String get tagSoyFree => 'soy-free';

  @override
  String get tagShellfishFree => 'shellfish-free';

  @override
  String get tagSugarFree => 'sugar-free';

  @override
  String get tagHighProtein => 'high protein';

  @override
  String get tagLowCalorie => 'low calorie';

  @override
  String get tagLowCarb => 'low carb';

  @override
  String get tagHighFiber => 'high fiber';

  @override
  String get tagMediterranean => 'Mediterranean';

  @override
  String get tagQuick => 'quick';

  @override
  String get tagBudget => 'budget-friendly';

  @override
  String get tagBatchCooking => 'batch cooking';

  @override
  String get tagFreezerFriendly => 'freezer-friendly';

  @override
  String get tagSpicy => 'spicy';

  @override
  String get tagKidFriendly => 'kid-friendly';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingPrevious => 'Back';

  @override
  String get onboardingFinish => 'Finish';

  @override
  String get onboardingStep0Title => 'Welcome to Böl!';

  @override
  String get onboardingStep0Body =>
      'We\'ll show you how the app works in about a minute. You can skip this tutorial at any time.';

  @override
  String get onboardingStep1Title => 'Weekly planner';

  @override
  String get onboardingStep1Body =>
      'See all days with their meals. The ‹ › arrows change the week. Today is highlighted in green.';

  @override
  String get onboardingStep2Title => 'Add meals to your plan';

  @override
  String get onboardingStep2Body =>
      'Tap an empty slot to assign a recipe. You can also tap the book icon to open the side recipe panel and drag recipes onto a day.';

  @override
  String get onboardingStep3Title => 'Your recipe book';

  @override
  String get onboardingStep3Body =>
      'All your recipes at a glance. The search icon finds recipes by name and the book icon opens the cooking glossary.';

  @override
  String get onboardingStep4Title => 'Create a recipe';

  @override
  String get onboardingStep4Body =>
      'The + button opens the form: photo, ingredients with quantities, steps, nutrition and tags. You can publish it so others can discover it.';

  @override
  String get onboardingStep5Title => 'Shopping list';

  @override
  String get onboardingStep5Body =>
      'When you plan meals, ingredients appear here automatically grouped by category. Check items off as you shop.';

  @override
  String get onboardingStep6Title => 'Add ingredients';

  @override
  String get onboardingStep6Body =>
      'Tap the + button to add ingredients manually to your shopping list.';

  @override
  String get onboardingStep7Title => 'Share your list';

  @override
  String get onboardingStep7Body =>
      'The share icon creates text ready to send via WhatsApp or other apps.';

  @override
  String get onboardingStep8Title => 'Discover the community';

  @override
  String get onboardingStep8Body =>
      'Search other users\' recipes by name or tags. Rate them and save them to your recipe book.';

  @override
  String get onboardingStep9Title => 'Your cooks feed';

  @override
  String get onboardingStep9Body =>
      'Follow your favourite cooks from their profile and see their latest recipes by tapping the feed button.';

  @override
  String get onboardingStep10Title => 'Your profile and household';

  @override
  String get onboardingStep10Body =>
      'Edit your name and photo. In the My household section you can plan with your family in real time. You can also change language and dark mode here.';

  @override
  String get createRecipeOptionsTitle => 'Create recipe';

  @override
  String get createRecipeManual => 'Create manually';

  @override
  String get createRecipeManualSubtitle => 'Fill in all recipe fields yourself';

  @override
  String get createRecipeWithAssistant => 'Create with AI assistant';

  @override
  String get createRecipeWithAssistantSubtitle =>
      'Describe the dish and AI will build the recipe card';

  @override
  String get recipeAssistantTitle => 'Recipe assistant';

  @override
  String get recipeAssistantDescription =>
      'Tell me what you\'re craving, what\'s in your fridge, or describe a detailed recipe with ingredients and steps.';

  @override
  String get recipeAssistantPromptHint =>
      'E.g.: Spanish potato omelette for 4 with onion...';

  @override
  String get recipeAssistantGenerate => 'Generate recipe';

  @override
  String get recipeAssistantGenerating => 'Generating...';

  @override
  String get recipeAssistantBlockingRecipe =>
      'The assistant is creating your recipe…';

  @override
  String get recipeAssistantBlockingNutrition =>
      'Calculating nutritional information…';

  @override
  String get recipeAssistantNotRecipeRequest =>
      'I can only help you create recipes. Describe a dish or a recipe.';

  @override
  String get recipeAssistantRateLimited =>
      'Usage limit reached. Please try again later.';

  @override
  String get recipeAssistantFailed =>
      'Could not generate a response. Please try again.';

  @override
  String get recipeAssistantOffline =>
      'An internet connection is required to use the assistant.';

  @override
  String get recipeAssistantNotConfigured =>
      'The AI assistant is not configured yet.';

  @override
  String get recipeAssistantTimeout =>
      'The request took too long. Please try again.';

  @override
  String get recipeAssistantPromptTooLong =>
      'The recipe description cannot exceed 3,000 characters.';

  @override
  String get recipeAssistantDailyLimitReached =>
      'You have reached your daily assistant limit. Come back tomorrow.';

  @override
  String get recipeAssistantTooFast =>
      'Please wait a moment before using the assistant again.';

  @override
  String get recipeAssistantServiceAtCapacity =>
      'The assistant is currently at capacity. Please try again later.';

  @override
  String get completeNutritionWithAssistant => 'Complete with AI';

  @override
  String get recipeAssistantNutritionSaved => 'Nutrition information completed';

  @override
  String get cookRecipeButton => 'Cook Recipe';

  @override
  String get continueCookingButton => 'Continue Cooking';

  @override
  String get checkIngredientsStep => 'Check Ingredients';

  @override
  String stepXofY(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get completeStepButton => 'Complete Step';

  @override
  String get finishCookingButton => 'Finish';

  @override
  String get cookingPausedLabel => 'Paused';

  @override
  String get cookingPauseTooltip => 'Pause';

  @override
  String get cookingResumeTooltip => 'Resume';

  @override
  String get finishCookingTitle => 'Finish cooking?';

  @override
  String finishCookingConfirm(String title) {
    return 'Do you want to finish cooking \"$title\"?';
  }

  @override
  String get cookingFinishedTitle => 'Recipe finished!';

  @override
  String get cookingFinishedMessage => 'Enjoy your meal!';

  @override
  String get cookingInProgressTitle => 'Recipe in progress';

  @override
  String cookingInProgressMessage(String title) {
    return 'You are already cooking \"$title\". Start a new recipe?';
  }

  @override
  String get cookingReplaceButton => 'New recipe';

  @override
  String get previousStep => 'Previous step';

  @override
  String get nextStep => 'Next step';

  @override
  String get minimize => 'Minimize';

  @override
  String get expandCookingSession => 'Expand';

  @override
  String get cookingNotificationChannelName => 'Cooking session';

  @override
  String get cookingNotificationChannelDescription =>
      'In-progress cooking session';
}
