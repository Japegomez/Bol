// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appName => 'Böl';

  @override
  String get languageEnglish => 'Anglès';

  @override
  String get languageSpanish => 'Castellà';

  @override
  String get languageBasque => 'Basc';

  @override
  String get languageCatalan => 'Català';

  @override
  String get languageGalician => 'Gallec';

  @override
  String get languagePortuguese => 'Portuguès';

  @override
  String get languageItalian => 'Italià';

  @override
  String get languageSystemDefault => 'Idioma del sistema';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get save => 'Desar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get add => 'Afegir';

  @override
  String get edit => 'Editar';

  @override
  String get remove => 'Treure';

  @override
  String get clear => 'Netejar';

  @override
  String get retry => 'Tornar a provar';

  @override
  String get understood => 'Entesos';

  @override
  String get optional => 'Opcional';

  @override
  String get requiredField => 'Obligatori';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get navExplore => 'Explorar';

  @override
  String get navRecipeBook => 'Receptari';

  @override
  String get navPlanner => 'Planificador';

  @override
  String get navShopping => 'Compra';

  @override
  String get navProfile => 'Perfil';

  @override
  String get exploreUnavailableOffline =>
      'Explorar no està disponible sense connexió';

  @override
  String get loginTagline => 'Planifica els teus àpats setmanals';

  @override
  String get sessionExpiredMessage =>
      'La teva sessió ha caducat. Inicia sessió de nou.';

  @override
  String get supabaseNotConfigured => 'Supabase no està configurat.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Contrasenya';

  @override
  String get enterEmail => 'Introdueix el teu email';

  @override
  String get enterPassword => 'Introdueix la teva contrasenya';

  @override
  String get signIn => 'Iniciar sessió';

  @override
  String get continueWithGoogle => 'Continuar amb Google';

  @override
  String get continueWithApple => 'Continuar amb Apple';

  @override
  String get forgotPasswordLink => 'Has oblidat la contrasenya?';

  @override
  String get noAccountRegister => 'No tens compte? Registra\'t';

  @override
  String get createAccountTitle => 'Crear compte';

  @override
  String registerInApp(String appName) {
    return 'Registra\'t a $appName';
  }

  @override
  String get usernameLabel => 'Nom d\'usuari';

  @override
  String get enterUsername => 'Introdueix el teu nom d\'usuari';

  @override
  String get minTwoCharacters => 'Mínim 2 caràcters';

  @override
  String get invalidEmail => 'Email no vàlid';

  @override
  String get enterPasswordRegister => 'Introdueix una contrasenya';

  @override
  String get minSixCharacters => 'Mínim 6 caràcters';

  @override
  String get confirmPasswordLabel => 'Confirmar contrasenya';

  @override
  String get confirmYourPassword => 'Confirma la teva contrasenya';

  @override
  String get passwordsDoNotMatch => 'Les contrasenyes no coincideixen';

  @override
  String get mustAcceptTerms =>
      'Has d\'acceptar els Termes i la Política de Privacitat';

  @override
  String get acceptTermsPrefix => 'Accepto els';

  @override
  String get termsLink => 'Termes';

  @override
  String get andThe => 'i la';

  @override
  String get privacyPolicyLink => 'Política de Privacitat';

  @override
  String get alreadyHaveAccount => 'Ja tens compte? Inicia sessió';

  @override
  String get checkYourEmail => 'Revisa el teu email';

  @override
  String confirmationEmailSent(String email) {
    return 'Hem enviat un enllaç de confirmació a $email.';
  }

  @override
  String get goToSignIn => 'Anar a l\'inici de sessió';

  @override
  String get recoverPasswordTitle => 'Recuperar contrasenya';

  @override
  String get forgotPasswordInstructions =>
      'Introdueix el teu email i t\'enviarem un enllaç per restablir la contrasenya.';

  @override
  String get sendResetLink => 'Enviar enllaç';

  @override
  String get backToSignIn => 'Tornar a l\'inici de sessió';

  @override
  String get emailSent => 'Email enviat';

  @override
  String resetEmailSentIfExists(String email) {
    return 'Si existeix un compte amb $email, rebràs un enllaç per restablir la contrasenya.';
  }

  @override
  String get showPassword => 'Mostrar contrasenya';

  @override
  String get hidePassword => 'Amagar contrasenya';

  @override
  String get recipeBookTitle => 'Receptari';

  @override
  String get cookingGlossaryTooltip => 'Glossari culinari';

  @override
  String get newRecipeTooltip => 'Nova recepta';

  @override
  String get searchByName => 'Cercar per nom';

  @override
  String get noRecipesFoundForSearch =>
      'No s\'ha trobat cap recepta relacionada amb la cerca.';

  @override
  String get noRecipesYet => 'Encara no hi ha receptes';

  @override
  String get createFirstRecipe => 'Crear primera recepta';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count racions',
      one: '1 ració',
    );
    return '$_temp0';
  }

  @override
  String servingsCountShort(int count) {
    return '$count r.';
  }

  @override
  String get deleteRecipeTitle => 'Eliminar recepta';

  @override
  String deleteRecipeConfirm(String title) {
    return 'Segur que vols eliminar \"$title\"?';
  }

  @override
  String get publishRecipeTitle => 'Publicar recepta';

  @override
  String publishRecipeMessage(String appName) {
    return 'Aquesta recepta serà visible per a tots els usuaris de $appName.';
  }

  @override
  String get makeRecipePrivateTitle => 'Fer recepta privada';

  @override
  String get makeRecipePrivateMessageDetail =>
      'La recepta deixarà de ser visible a Explorar.';

  @override
  String get makeRecipePrivateMessageForm =>
      'La recepta deixarà de ser visible a Explorar.';

  @override
  String get publish => 'Publicar';

  @override
  String get makePrivate => 'Fer privada';

  @override
  String visibilityChangeError(String error) {
    return 'Error en canviar la visibilitat: $error';
  }

  @override
  String get publicBadge => 'Pública';

  @override
  String prepTimeMin(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String cookTimeMin(int minutes) {
    return 'Cocció: $minutes min';
  }

  @override
  String get forkedRecipeTitle => 'Recepta guardada d\'un altre usuari';

  @override
  String get forkedRecipeCannotPublish =>
      'Les receptes forkejades no es poden publicar a Explorar.';

  @override
  String get publicRecipeSwitch => 'Recepta pública';

  @override
  String get visibleInExplore => 'Visible a Explorar per a tots els usuaris';

  @override
  String get onlyInRecipeBook => 'Només visible al teu receptari';

  @override
  String get ingredientsSection => 'Ingredients';

  @override
  String get noIngredients => 'Sense ingredients';

  @override
  String get preparationSection => 'Elaboració';

  @override
  String get noSteps => 'Sense passos';

  @override
  String get tipsSection => 'Consells';

  @override
  String get nutritionPerServing => 'Nutrició (per ració)';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Proteïnes';

  @override
  String get carbohydrates => 'Carbohidrats';

  @override
  String get fat => 'Greixos';

  @override
  String get fiber => 'Fibra';

  @override
  String nutritionChip(String label, String value) {
    return '$label: $value';
  }

  @override
  String get newRecipeTitle => 'Nova recepta';

  @override
  String get editRecipeTitle => 'Editar recepta';

  @override
  String get photoRequiresConnection =>
      'Necessites connexió per afegir o canviar la foto de la recepta';

  @override
  String get householdEditRequiresConnection =>
      'Sense connexió: l\'edició en mode llar requereix connexió';

  @override
  String get nameLabel => 'Nom';

  @override
  String get servingsLabel => 'Racions';

  @override
  String get minOneServing => 'Mínim 1';

  @override
  String get prepMinLabel => 'Prep (min)';

  @override
  String get cookMinLabel => 'Cocció (min)';

  @override
  String get tagsSection => 'Etiquetes';

  @override
  String get customTagLabel => 'Etiqueta personalitzada';

  @override
  String get stepsSection => 'Passos';

  @override
  String get tipsLabel => 'Consells';

  @override
  String get tipsHint => 'Trucs, variacions o notes útils';

  @override
  String get visibleInExploreShort =>
      'Visible per a tots els usuaris a Explorar';

  @override
  String get addIngredient => 'Afegir ingredient';

  @override
  String get addStep => 'Afegir pas';

  @override
  String stepLabel(int number) {
    return 'Pas $number';
  }

  @override
  String get optionalStepPrefix => 'Opcional:';

  @override
  String get checkingImage => 'Comprovant imatge...';

  @override
  String get choosePhoto => 'Triar foto';

  @override
  String get caloriesKcal => 'Calories (kcal)';

  @override
  String get proteinG => 'Proteïnes (g)';

  @override
  String get carbohydratesG => 'Carbohidrats (g)';

  @override
  String get fatG => 'Greixos (g)';

  @override
  String get fiberG => 'Fibra (g)';

  @override
  String get householdLoadError =>
      'No s\'ha pogut carregar la teva llar. Torna-ho a provar.';

  @override
  String get ingredientLabel => 'Ingredient';

  @override
  String get removeIngredientTooltip => 'Eliminar ingredient';

  @override
  String get quantityLabel => 'Quantitat';

  @override
  String get enterValidNumber => 'Introdueix un nombre vàlid';

  @override
  String get unitLabel => 'Unitat';

  @override
  String get customUnitLabel => 'Unitat personalitzada';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get toTaste => 'Al gust';

  @override
  String get toTasteShoppingHint => 'No s\'afegeix a la llista de la compra';

  @override
  String get optionalIngredientHint =>
      'Pots incloure\'l o excloure\'l a la fitxa de la recepta';

  @override
  String get clearTags => 'Netejar';

  @override
  String get cookingGlossaryTitle => 'Glossari culinari';

  @override
  String get addTermTooltip => 'Afegir terme';

  @override
  String get newGlossaryEntry => 'Nova entrada';

  @override
  String get termLabel => 'Terme';

  @override
  String get enterTerm => 'Introdueix un terme';

  @override
  String get definitionLabel => 'Definició';

  @override
  String get enterDefinition => 'Introdueix una definició';

  @override
  String get duplicateGlossaryTerm => 'Aquest terme ja existeix al glossari';

  @override
  String get searchTermOrDefinition => 'Cercar terme o definició';

  @override
  String get noGlossaryEntries => 'No hi ha entrades al glossari';

  @override
  String get noGlossaryTermsFound => 'No s\'han trobat termes';

  @override
  String get deleteEntryTooltip => 'Eliminar entrada';

  @override
  String get deleteGlossaryEntryTitle => 'Eliminar entrada';

  @override
  String deleteGlossaryEntryConfirm(String term) {
    return 'Vols eliminar \"$term\" del glossari?';
  }

  @override
  String get autoTranslatedBadge => 'Traduït automàticament';

  @override
  String get viewOriginal => 'Veure original';

  @override
  String get viewTranslation => 'Veure traducció';

  @override
  String get translatingRecipe => 'Traduint recepta...';

  @override
  String get translationFailed => 'No s\'ha pogut traduir aquesta recepta';

  @override
  String get plannerTitle => 'Planificador';

  @override
  String get sharePlannerTooltip => 'Compartir planificador';

  @override
  String get copyPlannerTooltip => 'Copiar planificador';

  @override
  String get plannerCopied => 'Planificador copiat al porta-retalls';

  @override
  String get plannerShareLeftoverLabel => 'sobrants';

  @override
  String get thisWeek => 'Aquesta setmana';

  @override
  String get today => 'Avui';

  @override
  String get showRecipeBookTooltip => 'Mostrar receptari';

  @override
  String get removeMealTitle => 'Treure àpat';

  @override
  String removeMealConfirm(String title) {
    return 'Treure \"$title\" del planificador?';
  }

  @override
  String get dropHere => 'Deixa anar aquí';

  @override
  String get dragOrTap => 'Arrossega o prem';

  @override
  String get servingsTitle => 'Racions';

  @override
  String get servingsCountLabel => 'Nombre de racions';

  @override
  String get addTextTitle => 'Afegir text';

  @override
  String get mealNameLabel => 'Nom (p. ex. Comanda a domicili)';

  @override
  String get enterMealName => 'Escriu un nom per a l\'àpat';

  @override
  String get fewerServingsTooltip => 'Menys racions';

  @override
  String get moreServingsTooltip => 'Més racions';

  @override
  String get leftovers => 'Són restes';

  @override
  String get leftoversShoppingHint =>
      'No s\'afegiran ingredients a la llista de la compra';

  @override
  String get recipeBookPanel => 'Receptari';

  @override
  String get closeTooltip => 'Tancar';

  @override
  String get searchHint => 'Cercar...';

  @override
  String get noResults => 'Sense resultats';

  @override
  String get noRecipesCreateInBook =>
      'No tens receptes. Crea-les al receptari.';

  @override
  String get chooseRecipe => 'Triar recepta';

  @override
  String get searchRecipeHint => 'Cercar recepta...';

  @override
  String get addFreeText => 'Afegir text lliure';

  @override
  String get noRecipeExample => 'Sense recepta (p. ex. comanda, fora, etc.)';

  @override
  String get clearListTitle => 'Netejar llista';

  @override
  String get clearListConfirm =>
      'Eliminar tots els ítems de la llista de la compra?';

  @override
  String get shoppingListTitle => 'Llista de la compra';

  @override
  String get shareListTooltip => 'Compartir llista';

  @override
  String get shareRecipeTooltip => 'Compartir recepta';

  @override
  String shareRecipeMessage(String title, String url) {
    return '$url\n\nMira aquesta recepta a Böl: $title';
  }

  @override
  String get shareLinkExpired => 'Aquest enllaç ha caducat';

  @override
  String get shareLinkInvalid => 'Aquest enllaç no és vàlid';

  @override
  String get clearListTooltip => 'Netejar llista';

  @override
  String shoppingListLoadError(String error) {
    return 'No s\'ha pogut carregar la llista: $error';
  }

  @override
  String get shoppingListEmpty => 'La teva llista està buida';

  @override
  String get shoppingListEmptyHint =>
      'Afegeix receptes al planificador o ítems manualment amb el botó +.';

  @override
  String get addItemTooltip => 'Afegir ítem';

  @override
  String get deleteItemTitle => 'Eliminar ítem';

  @override
  String deleteItemConfirm(String name) {
    return 'Eliminar «$name» de la llista?';
  }

  @override
  String get editItem => 'Editar ítem';

  @override
  String get addItem => 'Afegir ítem';

  @override
  String get nameRequired => 'El nom és obligatori';

  @override
  String get othersCategory => 'Altres';

  @override
  String get feedTitle => 'Feed';

  @override
  String get mostRecent => 'Més recent';

  @override
  String sortedBy(String label) {
    return 'Ordenat per: $label';
  }

  @override
  String get noRecipesWithTags => 'Sense receptes amb aquestes etiquetes';

  @override
  String get feedEmpty => 'El teu feed està buit';

  @override
  String get tryOtherTags => 'Prova amb altres etiquetes o treu el filtre.';

  @override
  String get followUsersHint =>
      'Segueix altres usuaris des dels seus perfils per veure les seves receptes públiques aquí.';

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get feedTooltip => 'Feed';

  @override
  String get searchPublicRecipes => 'Cercar receptes públiques';

  @override
  String get recent => 'Recents';

  @override
  String get topRated => 'Millor valorades';

  @override
  String get noPublicRecipesYet => 'Encara no hi ha receptes públiques';

  @override
  String get publishToExploreHint =>
      'Publica una recepta des del teu receptari perquè altres la descobreixin.';

  @override
  String get publicProfileTitle => 'Perfil públic';

  @override
  String publicRecipesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receptes públiques',
      one: '1 recepta pública',
    );
    return '$_temp0';
  }

  @override
  String get unfollow => 'Deixar de seguir';

  @override
  String get follow => 'Seguir';

  @override
  String get noPublicRecipes => 'Sense receptes públiques';

  @override
  String get recipeSavedToBook => 'Recepta guardada al teu receptari';

  @override
  String get saveToMyRecipeBookTooltip => 'Guardar al meu receptari';

  @override
  String get recipeCreatedBy => 'Recepta creada per';

  @override
  String get you => 'tu';

  @override
  String get yourRating => 'La teva valoració';

  @override
  String get optionalIngredientSuffix => '(opcional)';

  @override
  String get saveToMyRecipeBook => 'Guardar al meu receptari';

  @override
  String get optionalIngredientsTitle => 'Ingredients opcionals';

  @override
  String get optionalIngredientsMessage =>
      'Aquesta recepta conté ingredients opcionals.';

  @override
  String get editRecipe => 'Editar recepta';

  @override
  String get inviteCodeCopied => 'Codi copiat al porta-retalls';

  @override
  String get regenerateCodeTitle => 'Regenerar codi';

  @override
  String get regenerateCodeMessage =>
      'El codi anterior deixarà de funcionar. Vols generar-ne un de nou?';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get codeRegenerated => 'Codi regenerat';

  @override
  String get kickMemberTitle => 'Expulsar membre';

  @override
  String kickMemberConfirm(String username) {
    return 'Expulsar $username de la llar?';
  }

  @override
  String get kick => 'Expulsar';

  @override
  String get leaveHouseholdTitle => 'Abandonar llar';

  @override
  String get leaveHouseholdMessage =>
      'Es copiarà el planificador i la llista de la llar al teu mode individual (la setmana actual i les futures). Continuar?';

  @override
  String get leave => 'Abandonar';

  @override
  String get myHouseholdTitle => 'La meva llar';

  @override
  String get inviteCode => 'Codi d\'invitació';

  @override
  String get inviteViaWhatsApp => 'Convidar per WhatsApp';

  @override
  String inviteWhatsAppHouseholdMessage(String appName, String code) {
    return 'Hola! Uneix-te a la meva llar a $appName. Usa aquest codi: $code';
  }

  @override
  String get copyTooltip => 'Copiar';

  @override
  String get members => 'Membres';

  @override
  String get leaveHousehold => 'Abandonar llar';

  @override
  String get noSharedHousehold => 'Sense llar compartida';

  @override
  String get individualModeDescription =>
      'En mode individual uses el teu propi planificador i llista de la compra.';

  @override
  String get createHousehold => 'Crear llar';

  @override
  String get joinWithCode => 'Unir-se amb codi';

  @override
  String currentUserSuffix(String username) {
    return '$username (tu)';
  }

  @override
  String get admin => 'Administrador';

  @override
  String get member => 'Membre';

  @override
  String get joinHouseholdTitle => 'Unir-se a una llar';

  @override
  String get joinCodeInstructions =>
      'Introdueix el codi de 6 caràcters que t\'ha compartit un membre de la llar.';

  @override
  String get invalidInviteCode => 'Codi d\'invitació no vàlid';

  @override
  String get alreadyMember => 'Ja pertanyes a aquesta llar';

  @override
  String get codeMustBeSixChars => 'El codi ha de tenir 6 caràcters';

  @override
  String get join => 'Unir-se';

  @override
  String get createHouseholdDescription =>
      'Posa nom a la teva llar compartida.';

  @override
  String get householdNameLabel => 'Nom de la llar';

  @override
  String get enterName => 'Introdueix un nom';

  @override
  String get signOutTitle => 'Tancar sessió';

  @override
  String get signOutConfirm => 'Segur que vols tancar sessió?';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get defaultUsername => 'Usuari';

  @override
  String get individualModeNoHousehold => 'Mode individual (sense llar)';

  @override
  String get darkMode => 'Mode fosc';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get myHousehold => 'La meva llar';

  @override
  String get createOrJoinHousehold => 'Crear o unir-se a una llar';

  @override
  String get termsAndConditions => 'Termes i Condicions';

  @override
  String get privacyPolicy => 'Política de Privacitat';

  @override
  String get rateYourApp => 'Valora l\'app';

  @override
  String get rateYourAppSubtitle => 'Deixa una ressenya a la botiga';

  @override
  String get rateAppUnavailable =>
      'La valoració no està disponible en aquest dispositiu ara mateix.';

  @override
  String get sendFeedback => 'Enviar feedback';

  @override
  String get adminControlPanel => 'Panell de control';

  @override
  String get adminFeedbackTitle => 'Feedback';

  @override
  String get feedbackWhatAbout => 'Què ens vols explicar?';

  @override
  String get feedbackCategoryIssue => 'Problema o error';

  @override
  String get feedbackCategoryFeature => 'Suggeriment de funció';

  @override
  String get feedbackCategoryOther => 'Altre';

  @override
  String get feedbackTypeLabel => 'Tipus';

  @override
  String get feedbackYourMessage => 'El teu missatge';

  @override
  String get feedbackMessageHint =>
      'Descriu el problema o la teva idea amb el màxim detall possible…';

  @override
  String get feedbackMinCharsHint => 'Mínim 10 caràcters';

  @override
  String get feedbackMessageTooShort =>
      'El missatge ha de tenir almenys 10 caràcters.';

  @override
  String get feedbackSentSuccess =>
      'Gràcies pel teu missatge. El revisarem per millorar l\'app.';

  @override
  String get feedbackSendError =>
      'No s\'ha pogut enviar el feedback. Torna-ho a provar.';

  @override
  String get feedbackCategoryFilter => 'Categoria';

  @override
  String get feedbackStatusFilter => 'Estat';

  @override
  String get feedbackFilterAll => 'Totes';

  @override
  String get feedbackStatusPending => 'Pendent';

  @override
  String get feedbackStatusResolved => 'Resolt';

  @override
  String get feedbackStatusIgnored => 'Ignorat';

  @override
  String get feedbackMarkResolved => 'Marcar com a resolt';

  @override
  String get feedbackMarkIgnored => 'Marcar com a ignorat';

  @override
  String get feedbackMarkedResolved => 'Feedback marcat com a resolt.';

  @override
  String get feedbackMarkedIgnored => 'Feedback marcat com a ignorat.';

  @override
  String get feedbackStatusUpdateError =>
      'No s\'ha pogut actualitzar l\'estat del feedback.';

  @override
  String get adminFeedbackEmpty => 'No hi ha feedback amb aquests filtres.';

  @override
  String get adminFeedbackLoadError => 'No s\'ha pogut carregar el feedback.';

  @override
  String get back => 'Enrere';

  @override
  String get send => 'Enviar';

  @override
  String get signOut => 'Tancar sessió';

  @override
  String get deleteAccount => 'Eliminar compte';

  @override
  String get deleteAccountConfirmTitle => 'Eliminar compte?';

  @override
  String get deleteAccountConfirmMessage => 'Aquesta acció és permanent.';

  @override
  String get deletePermanently => 'Eliminar definitivament';

  @override
  String get gdprRightToErasure => 'Dret de supressió (RGPD)';

  @override
  String get deleteAccountBulletsIntro =>
      'En eliminar el teu compte s\'eliminarà permanentment:';

  @override
  String get deleteBulletProfile => 'El teu perfil i avatar';

  @override
  String get deleteBulletRecipes =>
      'Totes les teves receptes i imatges associades';

  @override
  String get deleteBulletPlans =>
      'Els teus plans i llistes de la compra en mode individual';

  @override
  String get deleteBulletMembership => 'La teva pertinença a llars compartides';

  @override
  String get soleAdminWarning =>
      'Si ets l\'únic administrador d\'una llar amb altres membres, has de transferir el rol o demanar que abandonin la llar.';

  @override
  String get deleteAcknowledgement =>
      'Entenc que aquesta acció és irreversible i vull eliminar el meu compte.';

  @override
  String get typeDeleteToConfirm => 'Escriu ELIMINAR per confirmar';

  @override
  String accountEmail(String email) {
    return 'Compte: $email';
  }

  @override
  String get deleteMyAccount => 'Eliminar el meu compte';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Càmera';

  @override
  String get changePhoto => 'Canviar foto';

  @override
  String get couldNotOpenDocument => 'No s\'ha pogut obrir el document';

  @override
  String get openInBrowser => 'Obrir al navegador';

  @override
  String get noConnection => 'Sense connexió';

  @override
  String get offlineModeTitle => 'Mode sense connexió';

  @override
  String get offlineHouseholdMessage =>
      'Estàs sense connexió. Pots consultar l\'última versió guardada, però l\'edició no està disponible en mode llar sense connexió.';

  @override
  String get offlineIndividualMessage =>
      'Estàs sense connexió. Pots consultar i editar el teu receptari, planificador i llista de la compra.';

  @override
  String get imageNotAllowedTitle => 'Imatge no permesa';

  @override
  String get imageNotAllowedMessage =>
      'La imatge seleccionada conté contingut adult o explícit que no està permès. Si us plau, tria una altra imatge.';

  @override
  String get imageCheckFailedTitle => 'No s\'ha pogut comprovar la imatge';

  @override
  String get imageCheckFailedRetry =>
      'No s\'ha pogut comprovar la imatge. Torna-ho a provar.';

  @override
  String get mealBreakfast => 'Esmorzar';

  @override
  String get mealLunch => 'Dinar';

  @override
  String get mealDinner => 'Sopar';

  @override
  String get dayMon => 'Dll';

  @override
  String get dayTue => 'Dmt';

  @override
  String get dayWed => 'Dmc';

  @override
  String get dayThu => 'Dij';

  @override
  String get dayFri => 'Div';

  @override
  String get daySat => 'Diss';

  @override
  String get daySun => 'Dium';

  @override
  String get categoryMeatFish => 'Carns i peixos';

  @override
  String get categoryVegetables => 'Verdures';

  @override
  String get categoryFruits => 'Fruites';

  @override
  String get categoryDairy => 'Làctics';

  @override
  String get categoryGrains => 'Cereals';

  @override
  String get categoryLegumes => 'Llegums';

  @override
  String get categorySpices => 'Espècies';

  @override
  String get categoryOilsVinegars => 'Olis i vinagres';

  @override
  String get categoryCanned => 'Conserves';

  @override
  String get categoryNuts => 'Fruits secs';

  @override
  String get categoryBeverages => 'Begudes';

  @override
  String get categoryBaking => 'Rebosteria';

  @override
  String get categoryFrozen => 'Congelats';

  @override
  String get categorySauces => 'Salses i condiments';

  @override
  String get categoryOther => 'Altres';

  @override
  String get unitCustomOption => 'Altra';

  @override
  String get unitCount => 'unitat';

  @override
  String get unitPinch => 'pessic';

  @override
  String get unitTeaspoon => 'culleradeta';

  @override
  String get unitTablespoon => 'cullerada';

  @override
  String get unitGlass => 'got';

  @override
  String get unitCup => 'tassa';

  @override
  String get unitHandful => 'grapat';

  @override
  String get unitLeaf => 'fulla';

  @override
  String get unitClove => 'dent';

  @override
  String get unitSplash => 'rajolí';

  @override
  String get unitSlice => 'llesca';

  @override
  String get unitSprig => 'branca';

  @override
  String get unitPiece => 'tros';

  @override
  String get unitFillet => 'filet';

  @override
  String get unitRound => 'rodanxa';

  @override
  String get unitCan => 'llauna';

  @override
  String get unitJar => 'pot';

  @override
  String get unitPackage => 'paquet';

  @override
  String get unitSachet => 'sobre';

  @override
  String get tagStarter => 'entrant';

  @override
  String get tagMainCourse => 'plat principal';

  @override
  String get tagDessert => 'postre';

  @override
  String get tagVegetarian => 'vegetariana';

  @override
  String get tagVegan => 'vegà';

  @override
  String get tagPescatarian => 'pescetariana';

  @override
  String get tagGlutenFree => 'sense gluten';

  @override
  String get tagLactoseFree => 'sense lactosa';

  @override
  String get tagEggFree => 'sense ou';

  @override
  String get tagNutFree => 'sense fruits secs';

  @override
  String get tagSoyFree => 'sense soja';

  @override
  String get tagShellfishFree => 'sense marisc';

  @override
  String get tagSugarFree => 'sense sucre';

  @override
  String get tagHighProtein => 'alt en proteïnes';

  @override
  String get tagLowCalorie => 'baixa en calories';

  @override
  String get tagLowCarb => 'baixa en carbohidrats';

  @override
  String get tagHighFiber => 'alta en fibra';

  @override
  String get tagMediterranean => 'mediterrània';

  @override
  String get tagQuick => 'ràpida';

  @override
  String get tagBudget => 'econòmica';

  @override
  String get tagBatchCooking => 'batch cooking';

  @override
  String get tagFreezerFriendly => 'per congelar';

  @override
  String get tagSpicy => 'picant';

  @override
  String get tagKidFriendly => 'per a nens';

  @override
  String get onboardingSkip => 'Ometre';

  @override
  String get onboardingNext => 'Següent';

  @override
  String get onboardingPrevious => 'Anterior';

  @override
  String get onboardingFinish => 'Finalitzar';

  @override
  String get onboardingStep0Title => 'Benvingut/da a Böl!';

  @override
  String get onboardingStep0Body =>
      'Et mostrem com funciona l\'app en un minut. Pots ometre aquest tutorial quan vulguis.';

  @override
  String get onboardingStep1Title => 'Planificador setmanal';

  @override
  String get onboardingStep1Body =>
      'Veu tots els dies amb els seus àpats. Les fletxes ‹ › canvien de setmana. El dia d\'avui apareix ressaltat en verd.';

  @override
  String get onboardingStep2Title => 'Afegeix àpats al pla';

  @override
  String get onboardingStep2Body =>
      'Toca un slot buit per assignar una recepta. També pots prémer la icona de llibre per obrir el receptari lateral i arrossegar receptes directament al dia.';

  @override
  String get onboardingStep3Title => 'El teu receptari';

  @override
  String get onboardingStep3Body =>
      'Totes les teves receptes d\'un cop d\'ull. La lupa cerca per nom i la icona de llibre obre el glossari culinari.';

  @override
  String get onboardingStep4Title => 'Crea una recepta';

  @override
  String get onboardingStep4Body =>
      'El botó + obre el formulari: foto, ingredients amb quantitats, passos d\'elaboració, nutrició i etiquetes. Pots publicar-la perquè altres la descobreixin.';

  @override
  String get onboardingStep5Title => 'Llista de la compra';

  @override
  String get onboardingStep5Body =>
      'Quan planifiques àpats, els ingredients apareixen aquí automàticament agrupats per categoria. Marca els ítems en comprar-los.';

  @override
  String get onboardingStep6Title => 'Afegeix ingredients';

  @override
  String get onboardingStep6Body =>
      'Prem el botó + per afegir ingredients manualment a la teva llista de la compra.';

  @override
  String get onboardingStep7Title => 'Comparteix la teva llista';

  @override
  String get onboardingStep7Body =>
      'La icona de compartir genera un text llest per enviar per WhatsApp o altres apps.';

  @override
  String get onboardingStep8Title => 'Descobreix la comunitat';

  @override
  String get onboardingStep8Body =>
      'Cerca receptes d\'altres usuaris per nom o etiquetes. Valora-les i guarda-les al teu receptari.';

  @override
  String get onboardingStep9Title => 'El teu feed de cuiners';

  @override
  String get onboardingStep9Body =>
      'Segueix els teus cuiners preferits des del seu perfil i consulta les seves últimes receptes prement el botó del feed.';

  @override
  String get onboardingStep10Title => 'El teu perfil i llar';

  @override
  String get onboardingStep10Body =>
      'Edita el teu nom i foto. A la secció La meva llar pots planificar amb la teva família en temps real. Des d\'aquí també canvies l\'idioma i el mode fosc.';

  @override
  String get createRecipeOptionsTitle => 'Crear recepta';

  @override
  String get createRecipeManual => 'Crear manualment';

  @override
  String get createRecipeManualSubtitle =>
      'Omple tu mateix tots els camps de la recepta';

  @override
  String get createRecipeWithAssistant => 'Crear amb assistent d\'IA';

  @override
  String get createRecipeWithAssistantSubtitle =>
      'Descriu el plat i la IA elaborarà la fitxa';

  @override
  String get recipeAssistantTitle => 'Assistent de receptes';

  @override
  String get recipeAssistantDescription =>
      'Digues-me què et ve de gust, què tens a la nevera o descriu una recepta detallada amb ingredients i passos.';

  @override
  String get recipeAssistantPromptHint =>
      'Ex.: truita de patates per a 4 persones amb ceba...';

  @override
  String get recipeAssistantGenerate => 'Generar recepta';

  @override
  String get recipeAssistantGenerating => 'Generant...';

  @override
  String get recipeAssistantBlockingRecipe =>
      'L\'assistent està elaborant la teva recepta…';

  @override
  String get recipeAssistantBlockingNutrition =>
      'Calculant la informació nutricional…';

  @override
  String get recipeAssistantNotRecipeRequest =>
      'Només puc ajudar-te a elaborar receptes. Descriu un plat o una recepta.';

  @override
  String get recipeAssistantRateLimited =>
      'Límit d\'ús assolit. Torna-ho a provar més tard.';

  @override
  String get recipeAssistantFailed =>
      'No s\'ha pogut generar la resposta. Torna-ho a provar.';

  @override
  String get recipeAssistantOffline =>
      'Es requereix connexió a internet per usar l\'assistent.';

  @override
  String get recipeAssistantNotConfigured =>
      'L\'assistent d\'IA encara no està configurat.';

  @override
  String get recipeAssistantTimeout =>
      'La sol·licitud ha trigat massa. Torna-ho a provar.';

  @override
  String get recipeAssistantPromptTooLong =>
      'La descripció de la recepta no pot superar els 3.000 caràcters.';

  @override
  String get recipeAssistantDailyLimitReached =>
      'Has assolit el límit diari de l\'assistent. Torna demà.';

  @override
  String get recipeAssistantTooFast =>
      'Espera un moment abans de tornar a usar l\'assistent.';

  @override
  String get recipeAssistantServiceAtCapacity =>
      'L\'assistent està saturat en aquest moment. Torna-ho a provar més tard.';

  @override
  String get completeNutritionWithAssistant => 'Completar amb IA';

  @override
  String get recipeAssistantNutritionSaved => 'Fitxa nutricional completada';

  @override
  String get cookRecipeButton => 'Cuinar recepta';

  @override
  String get continueCookingButton => 'Continuar cuinant';

  @override
  String get checkIngredientsStep => 'Comprovar ingredients';

  @override
  String stepXofY(int current, int total) {
    return 'Pas $current de $total';
  }

  @override
  String get completeStepButton => 'Completar pas';

  @override
  String get finishCookingButton => 'Acabar';

  @override
  String get cookingPausedLabel => 'Pausada';

  @override
  String get cookingPauseTooltip => 'Pausar';

  @override
  String get cookingResumeTooltip => 'Continuar';

  @override
  String get finishCookingTitle => 'Acabar la recepta?';

  @override
  String finishCookingConfirm(String title) {
    return 'Vols acabar de cuinar \"$title\"?';
  }

  @override
  String get cookingFinishedTitle => 'Recepta acabada!';

  @override
  String get cookingFinishedMessage => 'Que et aprofiti!';

  @override
  String get cookingInProgressTitle => 'Recepta en curs';

  @override
  String cookingInProgressMessage(String title) {
    return 'Ja estàs cuinant \"$title\". Vols començar una nova recepta?';
  }

  @override
  String get cookingReplaceButton => 'Nova recepta';

  @override
  String get previousStep => 'Pas anterior';

  @override
  String get nextStep => 'Pas següent';

  @override
  String get minimize => 'Minimitzar';

  @override
  String get expandCookingSession => 'Expandir';

  @override
  String get cookingNotificationChannelName => 'Sessió de cuina';

  @override
  String get cookingNotificationChannelDescription => 'Sessió de cuina en curs';
}
