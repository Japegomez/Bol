// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get appName => 'MealPlanner';

  @override
  String get languageEnglish => 'Ingelesa';

  @override
  String get languageSpanish => 'Gaztelania';

  @override
  String get languageBasque => 'Euskara';

  @override
  String get languageCatalan => 'Katalana';

  @override
  String get languageGalician => 'Galiziera';

  @override
  String get languagePortuguese => 'Portugesa';

  @override
  String get languageSystemDefault => 'Sistemaren hizkuntza';

  @override
  String get languageTitle => 'Hizkuntza';

  @override
  String get cancel => 'Utzi';

  @override
  String get save => 'Gorde';

  @override
  String get delete => 'Ezabatu';

  @override
  String get confirm => 'Berretsi';

  @override
  String get add => 'Gehitu';

  @override
  String get edit => 'Editatu';

  @override
  String get remove => 'Kendu';

  @override
  String get clear => 'Garbitu';

  @override
  String get retry => 'Saiatu berriro';

  @override
  String get understood => 'Ulertuta';

  @override
  String get optional => 'Aukerakoa';

  @override
  String get requiredField => 'Beharrezkoa';

  @override
  String errorWithMessage(String message) {
    return 'Errorea: $message';
  }

  @override
  String get navExplore => 'Arakatu';

  @override
  String get navRecipeBook => 'Errezeta-liburua';

  @override
  String get navPlanner => 'Planifikatzailea';

  @override
  String get navShopping => 'Erosketa';

  @override
  String get navProfile => 'Profila';

  @override
  String get exploreUnavailableOffline =>
      'Arakatu ez dago erabilgarri konexiorik gabe';

  @override
  String get loginTagline => 'Planifikatu zure asteko otorduak';

  @override
  String get sessionExpiredMessage =>
      'Zure saioa iraungi da. Hasi saioa berriro.';

  @override
  String get supabaseNotConfigured => 'Supabase ez dago konfiguratuta.';

  @override
  String get emailLabel => 'Emaila';

  @override
  String get passwordLabel => 'Pasahitza';

  @override
  String get enterEmail => 'Sartu zure emaila';

  @override
  String get enterPassword => 'Sartu zure pasahitza';

  @override
  String get signIn => 'Hasi saioa';

  @override
  String get continueWithGoogle => 'Jarraitu Google-rekin';

  @override
  String get continueWithApple => 'Jarraitu Apple-rekin';

  @override
  String get forgotPasswordLink => 'Pasahitza ahaztu duzu?';

  @override
  String get noAccountRegister => 'Ez duzu konturik? Erregistratu';

  @override
  String get createAccountTitle => 'Kontua sortu';

  @override
  String registerInApp(String appName) {
    return 'Erregistratu $appName-en';
  }

  @override
  String get usernameLabel => 'Erabiltzaile-izena';

  @override
  String get enterUsername => 'Sartu zure erabiltzaile-izena';

  @override
  String get minTwoCharacters => 'Gutxienez 2 karaktere';

  @override
  String get invalidEmail => 'Email baliogabea';

  @override
  String get enterPasswordRegister => 'Sartu pasahitz bat';

  @override
  String get minSixCharacters => 'Gutxienez 6 karaktere';

  @override
  String get confirmPasswordLabel => 'Berretsi pasahitza';

  @override
  String get confirmYourPassword => 'Berretsi zure pasahitza';

  @override
  String get passwordsDoNotMatch => 'Pasahitzak ez datoz bat';

  @override
  String get mustAcceptTerms =>
      'Baldintzak eta pribatutasun-politika onartu behar dituzu';

  @override
  String get acceptTermsPrefix => 'Onartzen ditut';

  @override
  String get termsLink => 'Baldintzak';

  @override
  String get andThe => 'eta';

  @override
  String get privacyPolicyLink => 'Pribatutasun-politika';

  @override
  String get alreadyHaveAccount => 'Baduzu kontua? Hasi saioa';

  @override
  String get checkYourEmail => 'Egiaztatu zure emaila';

  @override
  String confirmationEmailSent(String email) {
    return 'Berrespen-esteka bat bidali dugu $email-era.';
  }

  @override
  String get goToSignIn => 'Joan saio-hasierara';

  @override
  String get recoverPasswordTitle => 'Pasahitza berreskuratu';

  @override
  String get forgotPasswordInstructions =>
      'Sartu zure emaila eta pasahitza berrezartzeko esteka bidaliko dizugu.';

  @override
  String get sendResetLink => 'Bidali esteka';

  @override
  String get backToSignIn => 'Itzuli saio-hasierara';

  @override
  String get emailSent => 'Emaila bidalita';

  @override
  String resetEmailSentIfExists(String email) {
    return '$email kontua badago, pasahitza berrezartzeko esteka jasoko duzu.';
  }

  @override
  String get showPassword => 'Erakutsi pasahitza';

  @override
  String get hidePassword => 'Ezkutatu pasahitza';

  @override
  String get recipeBookTitle => 'Errezeta-liburua';

  @override
  String get cookingGlossaryTooltip => 'Sukaldaritza-glosarioa';

  @override
  String get newRecipeTooltip => 'Errezeta berria';

  @override
  String get searchByName => 'Bilatu izenaren arabera';

  @override
  String get noRecipesFoundForSearch =>
      'Ez da errezetarik aurkitu bilaketarekin.';

  @override
  String get noRecipesYet => 'Oraindik ez dago errezetarik';

  @override
  String get createFirstRecipe => 'Sortu lehen errezeta';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porzio',
      one: '1 porzio',
    );
    return '$_temp0';
  }

  @override
  String get deleteRecipeTitle => 'Ezabatu errezeta';

  @override
  String deleteRecipeConfirm(String title) {
    return 'Ziur zaude \"$title\" ezabatu nahi duzula?';
  }

  @override
  String get publishRecipeTitle => 'Argitaratu errezeta';

  @override
  String publishRecipeMessage(String appName) {
    return 'Errezeta hau $appName erabiltzaile guztientzat ikusgai egongo da.';
  }

  @override
  String get makeRecipePrivateTitle => 'Egin errezeta pribatua';

  @override
  String get makeRecipePrivateMessageDetail =>
      'Errezeta ez da gehiago Arakatu atalean ikusgai egongo.';

  @override
  String get makeRecipePrivateMessageForm =>
      'Errezeta ez da gehiago Arakatu atalean ikusgai egongo.';

  @override
  String get publish => 'Argitaratu';

  @override
  String get makePrivate => 'Egin pribatua';

  @override
  String visibilityChangeError(String error) {
    return 'Errorea ikusgarritasuna aldatzean: $error';
  }

  @override
  String get publicBadge => 'Publikoa';

  @override
  String prepTimeMin(int minutes) {
    return 'Prest.: $minutes min';
  }

  @override
  String cookTimeMin(int minutes) {
    return 'Sukald.: $minutes min';
  }

  @override
  String get forkedRecipeTitle => 'Beste erabiltzaile baten errezeta gordeta';

  @override
  String get forkedRecipeCannotPublish =>
      'Fork-errezetak ezin dira Arakatu atalean argitaratu.';

  @override
  String get publicRecipeSwitch => 'Errezeta publikoa';

  @override
  String get visibleInExplore =>
      'Arakatu atalean ikusgai erabiltzaile guztientzat';

  @override
  String get onlyInRecipeBook => 'Zure errezeta-liburuan soilik ikusgai';

  @override
  String get ingredientsSection => 'Osagaiak';

  @override
  String get noIngredients => 'Osagairik gabe';

  @override
  String get preparationSection => 'Prestaketa';

  @override
  String get noSteps => 'Urratsik gabe';

  @override
  String get tipsSection => 'Aholkuak';

  @override
  String get nutritionPerServing => 'Nutrizioa (porzioko)';

  @override
  String get calories => 'Kaloriak';

  @override
  String get protein => 'Proteinak';

  @override
  String get carbohydrates => 'Karbohidratuak';

  @override
  String get fat => 'Koipeak';

  @override
  String get fiber => 'Zuntza';

  @override
  String nutritionChip(String label, String value) {
    return '$label: $value';
  }

  @override
  String get newRecipeTitle => 'Errezeta berria';

  @override
  String get editRecipeTitle => 'Editatu errezeta';

  @override
  String get photoRequiresConnection =>
      'Konexioa behar duzu errezetaren argazkia gehitzeko edo aldatzeko';

  @override
  String get householdEditRequiresConnection =>
      'Konexiorik gabe: etxeko moduan edizioak konexioa behar du';

  @override
  String get nameLabel => 'Izena';

  @override
  String get servingsLabel => 'Porzioak';

  @override
  String get minOneServing => 'Gutxienez 1';

  @override
  String get prepMinLabel => 'Prest. (min)';

  @override
  String get cookMinLabel => 'Sukald. (min)';

  @override
  String get tagsSection => 'Etiketak';

  @override
  String get customTagLabel => 'Etiketa pertsonalizatua';

  @override
  String get stepsSection => 'Urratsak';

  @override
  String get tipsLabel => 'Aholkuak';

  @override
  String get tipsHint => 'Trikimailuak, aldaerak edo oharrak';

  @override
  String get visibleInExploreShort =>
      'Arakatu atalean ikusgai erabiltzaile guztientzat';

  @override
  String get addIngredient => 'Gehitu osagaia';

  @override
  String get addStep => 'Gehitu urratsa';

  @override
  String stepLabel(int number) {
    return '$number. urratsa';
  }

  @override
  String get optionalStepPrefix => 'Aukerakoa:';

  @override
  String get checkingImage => 'Irudia egiaztatzen...';

  @override
  String get choosePhoto => 'Aukeratu argazkia';

  @override
  String get caloriesKcal => 'Kaloriak (kcal)';

  @override
  String get proteinG => 'Proteinak (g)';

  @override
  String get carbohydratesG => 'Karbohidratuak (g)';

  @override
  String get fatG => 'Koipeak (g)';

  @override
  String get fiberG => 'Zuntza (g)';

  @override
  String get householdLoadError =>
      'Ezin izan da zure etxea kargatu. Saiatu berriro.';

  @override
  String get ingredientLabel => 'Osagaia';

  @override
  String get removeIngredientTooltip => 'Kendu osagaia';

  @override
  String get quantityLabel => 'Kantitatea';

  @override
  String get enterValidNumber => 'Sartu zenbaki baliodun bat';

  @override
  String get unitLabel => 'Unitatea';

  @override
  String get customUnitLabel => 'Unitate pertsonalizatua';

  @override
  String get categoryLabel => 'Kategoria';

  @override
  String get toTaste => 'Gustura';

  @override
  String get toTasteShoppingHint => 'Ez da erosketa-zerrendara gehitzen';

  @override
  String get optionalIngredientHint =>
      'Errezetaren orrian sartu edo baztertu dezakezu';

  @override
  String get clearTags => 'Garbitu';

  @override
  String get cookingGlossaryTitle => 'Sukaldaritza-glosarioa';

  @override
  String get addTermTooltip => 'Gehitu terminoa';

  @override
  String get newGlossaryEntry => 'Sarrera berria';

  @override
  String get termLabel => 'Terminoa';

  @override
  String get enterTerm => 'Sartu termino bat';

  @override
  String get definitionLabel => 'Definizioa';

  @override
  String get enterDefinition => 'Sartu definizio bat';

  @override
  String get duplicateGlossaryTerm =>
      'Termino hori dagoeneko badago glosarioan';

  @override
  String get searchTermOrDefinition => 'Bilatu terminoa edo definizioa';

  @override
  String get noGlossaryEntries => 'Ez dago sarrerarik glosarioan';

  @override
  String get noGlossaryTermsFound => 'Ez da terminorik aurkitu';

  @override
  String get deleteEntryTooltip => 'Ezabatu sarrera';

  @override
  String get deleteGlossaryEntryTitle => 'Ezabatu sarrera';

  @override
  String deleteGlossaryEntryConfirm(String term) {
    return '\"$term\" glosariotik kendu nahi duzu?';
  }

  @override
  String get autoTranslatedBadge => 'Automatikoki itzulia';

  @override
  String get viewOriginal => 'Ikusi jatorrizkoa';

  @override
  String get viewTranslation => 'Ikusi itzulpena';

  @override
  String get translatingRecipe => 'Errezeta itzultzen...';

  @override
  String get translationFailed => 'Ezin izan da errezeta hau itzuli';

  @override
  String get plannerTitle => 'Planifikatzailea';

  @override
  String get thisWeek => 'Aste honetan';

  @override
  String get today => 'Gaur';

  @override
  String get showRecipeBookTooltip => 'Erakutsi errezeta-liburua';

  @override
  String get removeMealTitle => 'Kendu otordua';

  @override
  String removeMealConfirm(String title) {
    return '\"$title\" planifikatzailetik kendu?';
  }

  @override
  String get dropHere => 'Jaregin hemen';

  @override
  String get dragOrTap => 'Arrastatu edo sakatu';

  @override
  String get servingsTitle => 'Porzioak';

  @override
  String get servingsCountLabel => 'Porzio kopurua';

  @override
  String get addTextTitle => 'Gehitu testua';

  @override
  String get mealNameLabel => 'Izena (adib. etxera ekarria)';

  @override
  String get enterMealName => 'Sartu otorduaren izena';

  @override
  String get fewerServingsTooltip => 'Porzio gutxiago';

  @override
  String get moreServingsTooltip => 'Porzio gehiago';

  @override
  String get leftovers => 'Sobrak dira';

  @override
  String get leftoversShoppingHint =>
      'Osagaiak ez dira erosketa-zerrendara gehituko';

  @override
  String get recipeBookPanel => 'Errezeta-liburua';

  @override
  String get closeTooltip => 'Itxi';

  @override
  String get searchHint => 'Bilatu...';

  @override
  String get noResults => 'Emaitzarik gabe';

  @override
  String get noRecipesCreateInBook =>
      'Ez duzu errezetarik. Sortu itzazu errezeta-liburuan.';

  @override
  String get chooseRecipe => 'Aukeratu errezeta';

  @override
  String get searchRecipeHint => 'Bilatu errezeta...';

  @override
  String get addFreeText => 'Gehitu testu librea';

  @override
  String get noRecipeExample => 'Errezetarik gabe (adib. etxera ekarria)';

  @override
  String get clearListTitle => 'Garbitu zerrenda';

  @override
  String get clearListConfirm =>
      'Erosketa-zerrendako elementu guztiak ezabatu?';

  @override
  String get shoppingListTitle => 'Erosketa-zerrenda';

  @override
  String get shareListTooltip => 'Partekatu zerrenda';

  @override
  String get shareRecipeTooltip => 'Partekatu errezeta';

  @override
  String shareRecipeMessage(String title, String url) {
    return '$title\n$url';
  }

  @override
  String get shareLinkExpired => 'Esteka hau iraungi da';

  @override
  String get shareLinkInvalid => 'Esteka hau ez da baliozkoa';

  @override
  String get clearListTooltip => 'Garbitu zerrenda';

  @override
  String shoppingListLoadError(String error) {
    return 'Ezin izan da zerrenda kargatu: $error';
  }

  @override
  String get shoppingListEmpty => 'Zure zerrenda hutsik dago';

  @override
  String get shoppingListEmptyHint =>
      'Gehitu errezetak planifikatzailean edo elementuak eskuz + botoiarekin.';

  @override
  String get addItemTooltip => 'Gehitu elementua';

  @override
  String get deleteItemTitle => 'Ezabatu elementua';

  @override
  String deleteItemConfirm(String name) {
    return '\"$name\" zerrendatik kendu?';
  }

  @override
  String get editItem => 'Editatu elementua';

  @override
  String get addItem => 'Gehitu elementua';

  @override
  String get nameRequired => 'Izena beharrezkoa da';

  @override
  String get othersCategory => 'Besteak';

  @override
  String get feedTitle => 'Jarioa';

  @override
  String get mostRecent => 'Berriena';

  @override
  String sortedBy(String label) {
    return 'Ordenatuta: $label';
  }

  @override
  String get noRecipesWithTags => 'Ez dago errezetarik etiketa hauekin';

  @override
  String get feedEmpty => 'Zure jarioa hutsik dago';

  @override
  String get tryOtherTags => 'Saiatu beste etiketekin edo kendu iragazkia.';

  @override
  String get followUsersHint =>
      'Jarraitu beste erabiltzaileei beren profil publikoetatik.';

  @override
  String get exploreTitle => 'Arakatu';

  @override
  String get feedTooltip => 'Jarioa';

  @override
  String get searchPublicRecipes => 'Bilatu errezeta publikoak';

  @override
  String get recent => 'Azkenak';

  @override
  String get topRated => 'Onen baloratuak';

  @override
  String get noPublicRecipesYet => 'Oraindik ez dago errezeta publikorik';

  @override
  String get publishToExploreHint =>
      'Argitaratu errezeta bat zure errezeta-liburutik.';

  @override
  String get publicProfileTitle => 'Profil publikoa';

  @override
  String publicRecipesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errezeta publiko',
      one: '1 errezeta publiko',
    );
    return '$_temp0';
  }

  @override
  String get unfollow => 'Utzi jarraitzeari';

  @override
  String get follow => 'Jarraitu';

  @override
  String get noPublicRecipes => 'Errezeta publikorik gabe';

  @override
  String get recipeSavedToBook => 'Errezeta zure errezeta-liburuan gordeta';

  @override
  String get saveToMyRecipeBookTooltip => 'Gorde nire errezeta-liburuan';

  @override
  String get recipeCreatedBy => 'Errezeta sortzailea';

  @override
  String get you => 'zu';

  @override
  String get yourRating => 'Zure balorazioa';

  @override
  String get optionalIngredientSuffix => '(aukerakoa)';

  @override
  String get saveToMyRecipeBook => 'Gorde nire errezeta-liburuan';

  @override
  String get optionalIngredientsTitle => 'Osagai aukerakoak';

  @override
  String get optionalIngredientsMessage =>
      'Errezeta honek osagai aukerakoak ditu.';

  @override
  String get editRecipe => 'Editatu errezeta';

  @override
  String get inviteCodeCopied => 'Kodea arbelean kopiatu da';

  @override
  String get regenerateCodeTitle => 'Berregin kodea';

  @override
  String get regenerateCodeMessage =>
      'Aurreko kodeak ez du gehiago funtzionatuko. Berria sortu?';

  @override
  String get regenerate => 'Berregin';

  @override
  String get codeRegenerated => 'Kodea berrgeneratua';

  @override
  String get kickMemberTitle => 'Kendu kidea';

  @override
  String kickMemberConfirm(String username) {
    return '$username etxetik kendu?';
  }

  @override
  String get kick => 'Kendu';

  @override
  String get leaveHouseholdTitle => 'Utzi etxea';

  @override
  String get leaveHouseholdMessage =>
      'Etxeko planifikatzailea eta erosketa-zerrenda zure banakako modura kopiatuko dira (oraingo astea eta etorkizunekoak). Jarraitu?';

  @override
  String get leave => 'Utzi';

  @override
  String get myHouseholdTitle => 'Nire etxea';

  @override
  String get inviteCode => 'Gonbidapen-kodea';

  @override
  String get copyTooltip => 'Kopiatu';

  @override
  String get members => 'Kideak';

  @override
  String get leaveHousehold => 'Utzi etxea';

  @override
  String get noSharedHousehold => 'Etxe partekaturik gabe';

  @override
  String get individualModeDescription =>
      'Modu indibidualean zure planifikatzailea eta erosketa-zerrenda erabiltzen dituzu.';

  @override
  String get createHousehold => 'Sortu etxea';

  @override
  String get joinWithCode => 'Bat egin kodearekin';

  @override
  String currentUserSuffix(String username) {
    return '$username (zu)';
  }

  @override
  String get admin => 'Administratzailea';

  @override
  String get member => 'Kidea';

  @override
  String get joinHouseholdTitle => 'Bat egin etxe batekin';

  @override
  String get joinCodeInstructions =>
      'Sartu etxe-kide batek partekatu duen 6 karaktere-kodea.';

  @override
  String get invalidInviteCode => 'Gonbidapen-kode baliogabea';

  @override
  String get alreadyMember => 'Dagoeneko etxe honetakoa zara';

  @override
  String get codeMustBeSixChars => 'Kodeak 6 karaktere izan behar ditu';

  @override
  String get join => 'Bat egin';

  @override
  String get createHouseholdDescription => 'Eman izena zure etxe partekatuari.';

  @override
  String get householdNameLabel => 'Etxearen izena';

  @override
  String get enterName => 'Sartu izena';

  @override
  String get signOutTitle => 'Itxi saioa';

  @override
  String get signOutConfirm => 'Ziur zaude saioa itxi nahi duzula?';

  @override
  String get profileTitle => 'Profila';

  @override
  String get defaultUsername => 'Erabiltzailea';

  @override
  String get individualModeNoHousehold => 'Modu indibiduala (etxe gabe)';

  @override
  String get darkMode => 'Modu iluna';

  @override
  String get editProfile => 'Editatu profila';

  @override
  String get myHousehold => 'Nire etxea';

  @override
  String get createOrJoinHousehold => 'Sortu edo bat egin etxe batekin';

  @override
  String get termsAndConditions => 'Baldintzak';

  @override
  String get privacyPolicy => 'Pribatutasun-politika';

  @override
  String get signOut => 'Itxi saioa';

  @override
  String get deleteAccount => 'Ezabatu kontua';

  @override
  String get deleteAccountConfirmTitle => 'Kontua ezabatu?';

  @override
  String get deleteAccountConfirmMessage => 'Ekintza hau betirako da.';

  @override
  String get deletePermanently => 'Ezabatu betirako';

  @override
  String get gdprRightToErasure => 'Ezabatzeko eskubidea (GDPR)';

  @override
  String get deleteAccountBulletsIntro =>
      'Kontua ezabatzean betirako ezabatuko da:';

  @override
  String get deleteBulletProfile => 'Zure profila eta abatarra';

  @override
  String get deleteBulletRecipes => 'Zure errezeta guztiak eta irudiak';

  @override
  String get deleteBulletPlans =>
      'Zure planak eta erosketa-zerrendak modu indibidualean';

  @override
  String get deleteBulletMembership => 'Etxe partekatuetako kidetza';

  @override
  String get soleAdminWarning =>
      'Etxe bateko administratzaile bakarra bazara, rola transferitu edo kideek etxea utzi dezaten eskatu.';

  @override
  String get deleteAcknowledgement =>
      'Ulertzen dut ekintza hau atzeraezina dela eta nire kontua ezabatu nahi dudala.';

  @override
  String get typeDeleteToConfirm => 'Idatzi EZABATU berresteko';

  @override
  String accountEmail(String email) {
    return 'Kontua: $email';
  }

  @override
  String get deleteMyAccount => 'Ezabatu nire kontua';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Kamera';

  @override
  String get changePhoto => 'Aldatu argazkia';

  @override
  String get couldNotOpenDocument => 'Ezin izan da dokumentua ireki';

  @override
  String get openInBrowser => 'Ireki nabigatzailean';

  @override
  String get noConnection => 'Konexiorik gabe';

  @override
  String get offlineModeTitle => 'Konexiorik gabeko modua';

  @override
  String get offlineHouseholdMessage =>
      'Konexiorik gabe zaude. Azken bertsio gordeta ikus dezakezu, baina etxeko moduan edizioa ez dago erabilgarri.';

  @override
  String get offlineIndividualMessage =>
      'Konexiorik gabe zaude. Zure errezeta-liburua, planifikatzailea eta erosketa-zerrenda editatu ditzakezu.';

  @override
  String get imageNotAllowedTitle => 'Irudia ez da onartzen';

  @override
  String get imageNotAllowedMessage =>
      'Hautatutako irudiak eduki heldu edo esplizitua dauka, eta hori ez da onartzen. Mesedez, aukeratu beste irudi bat.';

  @override
  String get imageCheckFailedTitle => 'Ezin izan da irudia egiaztatu';

  @override
  String get imageCheckFailedRetry =>
      'Ezin izan da irudia egiaztatu. Saiatu berriro.';

  @override
  String get mealBreakfast => 'Gosaria';

  @override
  String get mealLunch => 'Bazkaria';

  @override
  String get mealDinner => 'Afaria';

  @override
  String get dayMon => 'Al';

  @override
  String get dayTue => 'Ar';

  @override
  String get dayWed => 'Az';

  @override
  String get dayThu => 'Og';

  @override
  String get dayFri => 'Or';

  @override
  String get daySat => 'Lr';

  @override
  String get daySun => 'Ig';

  @override
  String get categoryMeatFish => 'Haragiak eta arrainak';

  @override
  String get categoryVegetables => 'Barazkiak';

  @override
  String get categoryFruits => 'Fruta';

  @override
  String get categoryDairy => 'Esnekiak';

  @override
  String get categoryGrains => 'Gariak';

  @override
  String get categoryLegumes => 'Legumeak';

  @override
  String get categorySpices => 'Espeziak';

  @override
  String get categoryOilsVinegars => 'Olioak eta vinagreak';

  @override
  String get categoryCanned => 'Konservak';

  @override
  String get categoryNuts => 'Fruitu lehorrak';

  @override
  String get categoryBeverages => 'Edariak';

  @override
  String get categoryBaking => 'Gozogintza';

  @override
  String get categoryFrozen => 'Izoztuak';

  @override
  String get categorySauces => 'Saltsak eta ongarriak';

  @override
  String get categoryOther => 'Besteak';

  @override
  String get unitCustomOption => 'Bestea';

  @override
  String get unitCount => 'unitate';

  @override
  String get unitPinch => 'atximur';

  @override
  String get unitTeaspoon => 'koilaratxo';

  @override
  String get unitTablespoon => 'koilarada';

  @override
  String get unitGlass => 'edalontzi';

  @override
  String get unitCup => 'katilu';

  @override
  String get unitHandful => 'eskutada';

  @override
  String get unitLeaf => 'orri';

  @override
  String get unitClove => 'baratxuri-dent';

  @override
  String get unitSplash => 'txorrota';

  @override
  String get unitSlice => 'zatia';

  @override
  String get unitSprig => 'zatia';

  @override
  String get unitPiece => 'zati';

  @override
  String get unitFillet => 'filete';

  @override
  String get unitRound => 'rodaja';

  @override
  String get unitCan => 'lata';

  @override
  String get unitJar => 'pote';

  @override
  String get unitPackage => 'paketea';

  @override
  String get unitSachet => 'poltsa';

  @override
  String get tagStarter => 'hasiera';

  @override
  String get tagMainCourse => 'plater nagusia';

  @override
  String get tagDessert => 'postrea';

  @override
  String get tagVegetarian => 'begetarianoa';

  @override
  String get tagVegan => 'beganoa';

  @override
  String get tagPescatarian => 'pesketarianoa';

  @override
  String get tagGlutenFree => 'glutenik gabe';

  @override
  String get tagLactoseFree => 'laktosarik gabe';

  @override
  String get tagEggFree => 'arrautzarik gabe';

  @override
  String get tagNutFree => 'frutu lehorrik gabe';

  @override
  String get tagSoyFree => 'sojarik gabe';

  @override
  String get tagShellfishFree => 'itsaski-ganbarik gabe';

  @override
  String get tagSugarFree => 'azukrerik gabe';

  @override
  String get tagHighProtein => 'proteina handia';

  @override
  String get tagLowCalorie => 'kaloria baxua';

  @override
  String get tagLowCarb => 'karbohidrato baxua';

  @override
  String get tagHighFiber => 'zuntz handia';

  @override
  String get tagMediterranean => 'mediterraneoa';

  @override
  String get tagQuick => 'azkarra';

  @override
  String get tagBudget => 'ekonomikoa';

  @override
  String get tagBatchCooking => 'batch cooking';

  @override
  String get tagFreezerFriendly => 'izozteko';

  @override
  String get tagSpicy => 'min';

  @override
  String get tagKidFriendly => 'haurrentzat';

  @override
  String get onboardingSkip => 'Saltatu';

  @override
  String get onboardingNext => 'Hurrengoa';

  @override
  String get onboardingPrevious => 'Aurrekoa';

  @override
  String get onboardingFinish => 'Amaitu';

  @override
  String get onboardingStep0Title => 'Ongi etorri Receteara!';

  @override
  String get onboardingStep0Body =>
      'Aplikazioak nola funtzionatzen duen erakutsiko dizugu minutu batean. Tutorial hau edozein unetan saltatu dezakezu.';

  @override
  String get onboardingStep1Title => 'Asteko planifikatzailea';

  @override
  String get onboardingStep1Body =>
      'Egun guztiak ikusten dituzu beren otorduekin. ‹ › geziak astea aldatzen dute. Gaurko eguna berdez nabarmenduta agertzen da.';

  @override
  String get onboardingStep2Title => 'Gehitu otorduak planera';

  @override
  String get onboardingStep2Body =>
      'Sakatu hutsik dagoen tarte bat errezeta bat esleitzeko. Liburuaren ikonoa ere sakatu dezakezu alboko errezeta-panela irekitzeko eta errezetak egunera zuzenean arrastatzeko.';

  @override
  String get onboardingStep3Title => 'Zure errezeta-liburua';

  @override
  String get onboardingStep3Body =>
      'Zure errezeta guztiak begi-bistan. Bilaketa izenaren arabera bilatzen du eta liburuaren ikonoak sukaldaritza-glosarioa irekitzen du.';

  @override
  String get onboardingStep4Title => 'Sortu errezeta bat';

  @override
  String get onboardingStep4Body =>
      '+ botoiak formularioa irekitzen du: argazkia, osagaiak kantitateekin, prestaketa-pausoak, nutrizioa eta etiketak. Argitaratu dezakezu besteek aurkitzeko.';

  @override
  String get onboardingStep5Title => 'Erosketa-zerrenda';

  @override
  String get onboardingStep5Body =>
      'Otorduak planifikatzen dituzunean, osagaiak hemen agertzen dira automatikoki kategoriaren arabera taldekatuta. Markatu elementuak erosten dituzunean.';

  @override
  String get onboardingStep6Title => 'Gehitu osagaiak';

  @override
  String get onboardingStep6Body =>
      'Sakatu + botoia osagaiak eskuz gehitzeko zure erosketa-zerrendan.';

  @override
  String get onboardingStep7Title => 'Partekatu zure zerrenda';

  @override
  String get onboardingStep7Body =>
      'Partekatzeko ikonoak WhatsApp edo beste aplikazioetara bidaltzeko testua sortzen du.';

  @override
  String get onboardingStep8Title => 'Aurkitu komunitatea';

  @override
  String get onboardingStep8Body =>
      'Bilatu beste erabiltzaileen errezetak izenaren edo etiketen arabera. Baloratu eta gorde zure liburuan.';

  @override
  String get onboardingStep9Title => 'Zure sukaldarien feed-a';

  @override
  String get onboardingStep9Body =>
      'Jarraitu zure sukaldari gogokoenak haien profiletik eta kontsultatu beraien azken errezetak feed botoia sakatuz.';

  @override
  String get onboardingStep10Title => 'Zure profila eta etxea';

  @override
  String get onboardingStep10Body =>
      'Editatu zure izena eta argazkia. Nire etxea atalean zure familiarekin denbora errealean planifikatu dezakezu. Hemen hizkuntza eta modu iluna ere aldatzen dituzu.';

  @override
  String get createRecipeOptionsTitle => 'Errezeta sortu';

  @override
  String get createRecipeManual => 'Eskuz sortu';

  @override
  String get createRecipeManualSubtitle => 'Errezetaren eremu guztiak zuk bete';

  @override
  String get createRecipeWithAssistant => 'IA laguntzailearekin sortu';

  @override
  String get createRecipeWithAssistantSubtitle =>
      'Deskribatu platera eta IAk fitxa osatuko du';

  @override
  String get recipeAssistantTitle => 'Errezeta laguntzailea';

  @override
  String get recipeAssistantDescription =>
      'Deskribatu sortu nahi duzun platera: izena bakarrik edo osagai eta urratsekin errezeta zehatza.';

  @override
  String get recipeAssistantPromptHint =>
      'Adib.: patata tortilla 4 pertsonentzat tipulaarekin...';

  @override
  String get recipeAssistantGenerate => 'Errezeta sortu';

  @override
  String get recipeAssistantGenerating => 'Sortzen...';

  @override
  String get recipeAssistantBlockingRecipe =>
      'Laguntzailea zure errezeta prestatzen ari da…';

  @override
  String get recipeAssistantBlockingNutrition =>
      'Nutrizio-informazioa kalkulatzen…';

  @override
  String get recipeAssistantNotRecipeRequest =>
      'Errezetak sortzen lagun zaitzaket soilik. Deskribatu plater edo errezeta bat.';

  @override
  String get recipeAssistantRateLimited =>
      'Erabilera muga gaindituta. Saiatu berriro geroago.';

  @override
  String get recipeAssistantFailed =>
      'Ezin izan da erantzuna sortu. Saiatu berriro.';

  @override
  String get recipeAssistantOffline =>
      'Laguntzailea erabiltzeko internet konexioa behar da.';

  @override
  String get recipeAssistantNotConfigured =>
      'IA laguntzailea oraindik ez dago konfiguratuta.';

  @override
  String get recipeAssistantTimeout =>
      'Eskaerak denbora gehiegi hartu du. Saiatu berriro.';

  @override
  String get recipeAssistantDailyLimitReached =>
      'Laguntzailearen eguneroko muga gainditu duzu. Itzuli bihar.';

  @override
  String get recipeAssistantTooFast =>
      'Itxoin une bat laguntzailea berriro erabili aurretik.';

  @override
  String get recipeAssistantServiceAtCapacity =>
      'Laguntzailea momentu honetan gainezka dago. Saiatu geroago.';

  @override
  String get completeNutritionWithAssistant => 'IA-rekin osatu';

  @override
  String get recipeAssistantNutritionSaved => 'Nutrizio fitxa osatuta';

  @override
  String get cookRecipeButton => 'Errezeta egosi';

  @override
  String get continueCookingButton => 'Sukaldaritza jarraitu';

  @override
  String get checkIngredientsStep => 'Osagaiak egiaztatu';

  @override
  String stepXofY(int current, int total) {
    return '$current. urratsa ${total}etik';
  }

  @override
  String get completeStepButton => 'Urratsa osatu';

  @override
  String get finishCookingButton => 'Amaitu';

  @override
  String get cookingPausedLabel => 'Pausatuta';

  @override
  String get cookingPauseTooltip => 'Pausatu';

  @override
  String get cookingResumeTooltip => 'Jarraitu';

  @override
  String get finishCookingTitle => 'Sukaldaritza amaitu?';

  @override
  String finishCookingConfirm(String title) {
    return '\"$title\" egostea amaitu nahi duzu?';
  }

  @override
  String get cookingFinishedTitle => 'Errezeta amaituta!';

  @override
  String get cookingFinishedMessage => 'On egin!';

  @override
  String get cookingInProgressTitle => 'Errezeta egiten';

  @override
  String cookingInProgressMessage(String title) {
    return '\"$title\" egiten ari zara. Errezeta berria hasi?';
  }

  @override
  String get cookingReplaceButton => 'Errezeta berria';

  @override
  String get previousStep => 'Aurreko urratsa';

  @override
  String get nextStep => 'Hurrengo urratsa';

  @override
  String get minimize => 'Txikitu';

  @override
  String get expandCookingSession => 'Zabaldu';

  @override
  String get cookingNotificationChannelName => 'Sukaldaritza saioa';

  @override
  String get cookingNotificationChannelDescription =>
      'Sukaldaritza saioa martxan';
}
