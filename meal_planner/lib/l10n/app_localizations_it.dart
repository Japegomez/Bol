// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Böl';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageBasque => 'Basco';

  @override
  String get languageCatalan => 'Catalano';

  @override
  String get languageGalician => 'Galiziano';

  @override
  String get languagePortuguese => 'Portoghese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSystemDefault => 'Predefinita del sistema';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get confirm => 'Conferma';

  @override
  String get add => 'Aggiungi';

  @override
  String get edit => 'Modifica';

  @override
  String get remove => 'Rimuovi';

  @override
  String get clear => 'Svuota';

  @override
  String get retry => 'Riprova';

  @override
  String get understood => 'Capito';

  @override
  String get optional => 'Opzionale';

  @override
  String get requiredField => 'Obbligatorio';

  @override
  String errorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get navExplore => 'Esplora';

  @override
  String get navRecipeBook => 'Ricette';

  @override
  String get navPlanner => 'Agenda';

  @override
  String get navShopping => 'Spesa';

  @override
  String get navProfile => 'Profilo';

  @override
  String get exploreUnavailableOffline => 'Esplora non è disponibile offline';

  @override
  String get loginTagline => 'Pianifica i tuoi pasti settimanali';

  @override
  String get sessionExpiredMessage =>
      'La tua sessione è scaduta. Accedi di nuovo.';

  @override
  String get supabaseNotConfigured =>
      'Supabase non configurato. Copia dart_defines.example.json in dart_defines.json e aggiungi SUPABASE_URL / SUPABASE_ANON_KEY.';

  @override
  String get captchaRequired => 'Completa la verifica';

  @override
  String get captchaFailed => 'Verifica non riuscita. Riprova.';

  @override
  String get turnstileNotConfigured =>
      'La verifica non è disponibile al momento. Riprova più tardi.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get enterEmail => 'Inserisci la tua email';

  @override
  String get enterPassword => 'Inserisci la tua password';

  @override
  String get signIn => 'Accedi';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get googleSignInFailed => 'Impossibile accedere con Google. Riprova.';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get forgotPasswordLink => 'Password dimenticata?';

  @override
  String get noAccountRegister => 'Non hai un account? Registrati';

  @override
  String get createAccountTitle => 'Crea account';

  @override
  String registerInApp(String appName) {
    return 'Iscriviti a $appName';
  }

  @override
  String get usernameLabel => 'Nome utente';

  @override
  String get enterUsername => 'Inserisci il tuo nome utente';

  @override
  String get minTwoCharacters => 'Minimo 2 caratteri';

  @override
  String get invalidEmail => 'Email non valida';

  @override
  String get enterPasswordRegister => 'Inserisci una password';

  @override
  String get minSixCharacters => 'Minimo 6 caratteri';

  @override
  String get passwordTooShort => 'La password deve avere almeno 8 caratteri';

  @override
  String get passwordTooWeak =>
      'La password deve includere una lettera minuscola, una maiuscola, un numero e un simbolo';

  @override
  String get confirmPasswordLabel => 'Conferma password';

  @override
  String get confirmYourPassword => 'Conferma la tua password';

  @override
  String get passwordsDoNotMatch => 'Le password non coincidono';

  @override
  String get changePasswordTitle => 'Cambia password';

  @override
  String get currentPasswordLabel => 'Password attuale';

  @override
  String get newPasswordLabel => 'Nuova password';

  @override
  String get enterCurrentPassword => 'Inserisci la password attuale';

  @override
  String get passwordChanged => 'Password aggiornata';

  @override
  String get currentPasswordIncorrect => 'La password attuale non è corretta';

  @override
  String get passwordSameAsCurrent =>
      'La nuova password deve essere diversa da quella attuale';

  @override
  String get mustAcceptTerms => 'Devi accettare i Termini e la Privacy';

  @override
  String get acceptTermsPrefix => 'Accetto i';

  @override
  String get termsLink => 'Termini';

  @override
  String get andThe => 'e la';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get alreadyHaveAccount => 'Hai già un account? Accedi';

  @override
  String get checkYourEmail => 'Controlla la tua email';

  @override
  String confirmationEmailSent(String email) {
    return 'Abbiamo inviato un link di conferma a $email. Conferma il tuo account prima di accedere.';
  }

  @override
  String get goToSignIn => 'Vai al login';

  @override
  String get recoverPasswordTitle => 'Recupera password';

  @override
  String get forgotPasswordInstructions =>
      'Inserisci la tua email e ti invieremo un link per reimpostare la password.';

  @override
  String get sendResetLink => 'Invia link';

  @override
  String get backToSignIn => 'Torna al login';

  @override
  String get emailSent => 'Email inviata';

  @override
  String resetEmailSentIfExists(String email) {
    return 'Se esiste un account con $email, riceverai un link per reimpostare la password.';
  }

  @override
  String get showPassword => 'Mostra password';

  @override
  String get hidePassword => 'Nascondi password';

  @override
  String get recipeBookTitle => 'Ricettario';

  @override
  String get cookingGlossaryTooltip => 'Glossario culinario';

  @override
  String get newRecipeTooltip => 'Nuova ricetta';

  @override
  String get searchByName => 'Cerca per nome';

  @override
  String get noRecipesFoundForSearch =>
      'Nessuna ricetta trovata. Creala tu stesso.';

  @override
  String get noRecipesYet => 'Nessuna ricetta ancora';

  @override
  String get createFirstRecipe => 'Crea la prima ricetta';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porzioni',
      one: '1 porzione',
    );
    return '$_temp0';
  }

  @override
  String servingsCountShort(int count) {
    return '$count porz.';
  }

  @override
  String get deleteRecipeTitle => 'Elimina ricetta';

  @override
  String deleteRecipeConfirm(String title) {
    return 'Eliminare davvero \"$title\"?';
  }

  @override
  String get publishRecipeTitle => 'Pubblica ricetta';

  @override
  String publishRecipeMessage(String appName) {
    return 'Questa ricetta sarà visibile a tutti gli utenti di $appName. Puoi rimuoverla in qualsiasi momento.';
  }

  @override
  String get makeRecipePrivateTitle => 'Rendi ricetta privata';

  @override
  String get makeRecipePrivateMessageDetail =>
      'La ricetta non sarà più visibile in Esplora. Le valutazioni esistenti vengono conservate.';

  @override
  String get makeRecipePrivateMessageForm =>
      'La ricetta non sarà più visibile in Esplora.';

  @override
  String get publish => 'Pubblica';

  @override
  String get makePrivate => 'Rendi privata';

  @override
  String visibilityChangeError(String error) {
    return 'Errore nel cambio visibilità: $error';
  }

  @override
  String get publicBadge => 'Pubblica';

  @override
  String prepTimeMin(int minutes) {
    return 'Preparazione: $minutes min';
  }

  @override
  String cookTimeMin(int minutes) {
    return 'Cottura: $minutes min';
  }

  @override
  String get forkedRecipeTitle => 'Ricetta salvata da un altro utente';

  @override
  String get forkedRecipeCannotPublish =>
      'Le ricette salvate da altri non possono essere pubblicate in Esplora.';

  @override
  String get publicRecipeSwitch => 'Ricetta pubblica';

  @override
  String get visibleInExplore => 'Visibile in Esplora per tutti gli utenti';

  @override
  String get onlyInRecipeBook => 'Visibile solo nel tuo ricettario';

  @override
  String get ingredientsSection => 'Ingredienti';

  @override
  String get noIngredients => 'Nessun ingrediente';

  @override
  String get preparationSection => 'Preparazione';

  @override
  String get noSteps => 'Nessun passaggio';

  @override
  String get tipsSection => 'Consigli';

  @override
  String get nutritionPerServing => 'Valori nutrizionali (per porzione)';

  @override
  String get calories => 'Calorie';

  @override
  String get protein => 'Proteine';

  @override
  String get carbohydrates => 'Carboidrati';

  @override
  String get fat => 'Grassi';

  @override
  String get fiber => 'Fibre';

  @override
  String nutritionChip(String label, String value) {
    return '$label: $value';
  }

  @override
  String get newRecipeTitle => 'Nuova ricetta';

  @override
  String get editRecipeTitle => 'Modifica ricetta';

  @override
  String get photoRequiresConnection =>
      'Connessione necessaria per aggiungere o cambiare la foto della ricetta';

  @override
  String get householdEditRequiresConnection =>
      'Offline: la modifica in modalità famiglia richiede connessione';

  @override
  String get nameLabel => 'Nome';

  @override
  String get servingsLabel => 'Porzioni';

  @override
  String get minOneServing => 'Minimo 1';

  @override
  String get prepMinLabel => 'Prep (min)';

  @override
  String get cookMinLabel => 'Cottura (min)';

  @override
  String get tagsSection => 'Tag';

  @override
  String get customTagLabel => 'Tag personalizzato';

  @override
  String get stepsSection => 'Passaggi';

  @override
  String get tipsLabel => 'Consigli';

  @override
  String get tipsHint => 'Trucchi, varianti o note utili';

  @override
  String get visibleInExploreShort => 'Visibile a tutti gli utenti in Esplora';

  @override
  String get addIngredient => 'Aggiungi ingrediente';

  @override
  String get addStep => 'Aggiungi passaggio';

  @override
  String stepLabel(int number) {
    return 'Passaggio $number';
  }

  @override
  String get optionalStepPrefix => 'Opzionale:';

  @override
  String get checkingImage => 'Verifica immagine...';

  @override
  String get choosePhoto => 'Scegli foto';

  @override
  String get caloriesKcal => 'Calorie (kcal)';

  @override
  String get proteinG => 'Proteine (g)';

  @override
  String get carbohydratesG => 'Carboidrati (g)';

  @override
  String get fatG => 'Grassi (g)';

  @override
  String get fiberG => 'Fibre (g)';

  @override
  String get householdLoadError => 'Impossibile caricare la famiglia. Riprova.';

  @override
  String get ingredientLabel => 'Ingrediente';

  @override
  String get removeIngredientTooltip => 'Rimuovi ingrediente';

  @override
  String get quantityLabel => 'Quantità';

  @override
  String get enterValidNumber => 'Inserisci un numero valido';

  @override
  String get unitLabel => 'Unità';

  @override
  String get customUnitLabel => 'Unità personalizzata';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get toTaste => 'Q.b.';

  @override
  String get toTasteShoppingHint =>
      'Non aggiunto alla lista della spesa (es. sale, pepe)';

  @override
  String get optionalIngredientHint =>
      'Puoi includerlo o escluderlo nella scheda ricetta';

  @override
  String get clearTags => 'Svuota';

  @override
  String get cookingGlossaryTitle => 'Glossario culinario';

  @override
  String get addTermTooltip => 'Aggiungi termine';

  @override
  String get newGlossaryEntry => 'Nuova voce';

  @override
  String get termLabel => 'Termine';

  @override
  String get enterTerm => 'Inserisci un termine';

  @override
  String get definitionLabel => 'Definizione';

  @override
  String get enterDefinition => 'Inserisci una definizione';

  @override
  String get duplicateGlossaryTerm => 'Quel termine esiste già nel glossario';

  @override
  String get searchTermOrDefinition => 'Cerca termine o definizione';

  @override
  String get noGlossaryEntries => 'Nessuna voce nel glossario';

  @override
  String get noGlossaryTermsFound => 'Nessun termine trovato';

  @override
  String get deleteEntryTooltip => 'Elimina voce';

  @override
  String get deleteGlossaryEntryTitle => 'Elimina voce';

  @override
  String deleteGlossaryEntryConfirm(String term) {
    return 'Rimuovere \"$term\" dal glossario?';
  }

  @override
  String get autoTranslatedBadge => 'Tradotto automaticamente';

  @override
  String get viewOriginal => 'Vedi originale';

  @override
  String get viewTranslation => 'Vedi traduzione';

  @override
  String get translatingRecipe => 'Traduzione in corso...';

  @override
  String get translationFailed => 'Impossibile tradurre questa ricetta';

  @override
  String get plannerTitle => 'Pianificatore';

  @override
  String get sharePlannerTooltip => 'Condividi pianificatore';

  @override
  String get copyPlannerTooltip => 'Copia pianificatore';

  @override
  String get plannerCopied => 'Pianificatore copiato negli appunti';

  @override
  String get plannerShareLeftoverLabel => 'avanzi';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get today => 'Oggi';

  @override
  String get showRecipeBookTooltip => 'Mostra ricettario';

  @override
  String get removeMealTitle => 'Rimuovi pasto';

  @override
  String removeMealConfirm(String title) {
    return 'Rimuovere \"$title\" dal pianificatore?';
  }

  @override
  String get dropHere => 'Trascina qui';

  @override
  String get dragOrTap => 'Trascina o tocca';

  @override
  String get servingsTitle => 'Porzioni';

  @override
  String get servingsCountLabel => 'Numero di porzioni';

  @override
  String get addTextTitle => 'Aggiungi testo';

  @override
  String get mealNameLabel => 'Nome (es. Takeaway)';

  @override
  String get enterMealName => 'Inserisci un nome per il pasto';

  @override
  String get fewerServingsTooltip => 'Meno porzioni';

  @override
  String get moreServingsTooltip => 'Più porzioni';

  @override
  String get leftovers => 'Sono avanzi';

  @override
  String get leftoversShoppingHint =>
      'Gli ingredienti non saranno aggiunti alla lista della spesa';

  @override
  String get pastMealPlanTitle => 'Pasto passato';

  @override
  String get pastMealPlanMessage =>
      'Stai pianificando un pasto per un giorno già trascorso. Gli ingredienti non saranno aggiunti alla lista della spesa.';

  @override
  String get recipeBookPanel => 'Ricettario';

  @override
  String get closeTooltip => 'Chiudi';

  @override
  String get searchHint => 'Cerca...';

  @override
  String get noResults => 'Nessun risultato';

  @override
  String get noRecipesCreateInBook => 'Non hai ricette. Creale nel ricettario.';

  @override
  String get chooseRecipe => 'Scegli ricetta';

  @override
  String get searchRecipeHint => 'Cerca ricetta...';

  @override
  String get addFreeText => 'Aggiungi testo libero';

  @override
  String get noRecipeExample =>
      'Senza ricetta (es. takeaway, fuori casa, ecc.)';

  @override
  String get clearListTitle => 'Svuota lista';

  @override
  String get clearListConfirm =>
      'Eliminare tutti gli elementi dalla lista della spesa?';

  @override
  String get shoppingListTitle => 'Lista della spesa';

  @override
  String get shareListTooltip => 'Condividi lista';

  @override
  String get shareRecipeTooltip => 'Condividi ricetta';

  @override
  String shareRecipeMessage(String title, String url) {
    return '$url\n\nGuarda questa ricetta su Böl: $title';
  }

  @override
  String get shareLinkExpired => 'Questo link è scaduto';

  @override
  String get shareLinkInvalid => 'Questo link non è valido';

  @override
  String get revokeShareLink => 'Revoca link di condivisione';

  @override
  String get revokeShareLinkConfirm =>
      'Questo invaliderà il link privato attuale. Chiunque abbia il link non potrà più aprire questa ricetta.';

  @override
  String get revoke => 'Revoca';

  @override
  String get shareLinkRevoked => 'Link revocato';

  @override
  String get noActiveShareLink => 'Nessun link attivo da revocare';

  @override
  String get clearListTooltip => 'Svuota lista';

  @override
  String shoppingListLoadError(String error) {
    return 'Impossibile caricare la lista: $error';
  }

  @override
  String get shoppingListEmpty => 'La tua lista è vuota';

  @override
  String get shoppingListEmptyHint =>
      'Aggiungi ricette al pianificatore o elementi manualmente con il pulsante +.';

  @override
  String get addItemTooltip => 'Aggiungi elemento';

  @override
  String get deleteItemTitle => 'Elimina elemento';

  @override
  String deleteItemConfirm(String name) {
    return 'Rimuovere \"$name\" dalla lista?';
  }

  @override
  String get editItem => 'Modifica elemento';

  @override
  String get addItem => 'Aggiungi elemento';

  @override
  String get nameRequired => 'Il nome è obbligatorio';

  @override
  String get othersCategory => 'Altro';

  @override
  String get feedTitle => 'Feed';

  @override
  String get mostRecent => 'Più recente';

  @override
  String sortedBy(String label) {
    return 'Ordinato per: $label';
  }

  @override
  String get noRecipesWithTags => 'Nessuna ricetta con questi tag';

  @override
  String get feedEmpty => 'Il tuo feed è vuoto';

  @override
  String get tryOtherTags => 'Prova altri tag o rimuovi il filtro.';

  @override
  String get followUsersHint =>
      'Segui altri utenti dai loro profili per vedere le loro ricette pubbliche qui.';

  @override
  String get exploreTitle => 'Esplora';

  @override
  String get feedTooltip => 'Feed';

  @override
  String get searchPublicRecipes => 'Cerca ricette pubbliche';

  @override
  String get recent => 'Recenti';

  @override
  String get topRated => 'Più votate';

  @override
  String get noPublicRecipesYet => 'Nessuna ricetta pubblica ancora';

  @override
  String get publishToExploreHint =>
      'Pubblica una ricetta dal tuo ricettario perché altri la scoprano.';

  @override
  String get publicProfileTitle => 'Profilo pubblico';

  @override
  String publicRecipesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricette pubbliche',
      one: '1 ricetta pubblica',
    );
    return '$_temp0';
  }

  @override
  String get unfollow => 'Smetti di seguire';

  @override
  String get follow => 'Segui';

  @override
  String get noPublicRecipes => 'Nessuna ricetta pubblica';

  @override
  String get recipeSavedToBook => 'Ricetta salvata nel tuo ricettario';

  @override
  String get saveToMyRecipeBookTooltip => 'Salva nel mio ricettario';

  @override
  String get recipeCreatedBy => 'Ricetta creata da';

  @override
  String get recipeCreatedByName => 'Creata da';

  @override
  String get you => 'te';

  @override
  String get yourRating => 'La tua valutazione';

  @override
  String get optionalIngredientSuffix => '(opzionale)';

  @override
  String get saveToMyRecipeBook => 'Salva nel mio ricettario';

  @override
  String get optionalIngredientsTitle => 'Ingredienti opzionali';

  @override
  String get optionalIngredientsMessage =>
      'Questa ricetta contiene ingredienti opzionali. Aggiungili o rimuovili nella tua ricetta.';

  @override
  String get editRecipe => 'Modifica ricetta';

  @override
  String get inviteCodeCopied => 'Codice copiato negli appunti';

  @override
  String get regenerateCodeTitle => 'Rigenera codice';

  @override
  String get regenerateCodeMessage =>
      'Il codice precedente smetterà di funzionare. Generarne uno nuovo?';

  @override
  String get regenerate => 'Rigenera';

  @override
  String get codeRegenerated => 'Codice rigenerato';

  @override
  String get kickMemberTitle => 'Rimuovi membro';

  @override
  String kickMemberConfirm(String username) {
    return 'Rimuovere $username dalla famiglia?';
  }

  @override
  String get kick => 'Rimuovi';

  @override
  String get leaveHouseholdTitle => 'Abbandona famiglia';

  @override
  String get leaveHouseholdMessage =>
      'Il pianificatore e la lista della famiglia verranno copiati nella tua modalità individuale (settimana corrente e future). Continuare?';

  @override
  String get leave => 'Abbandona';

  @override
  String get myHouseholdTitle => 'La mia famiglia';

  @override
  String get inviteCode => 'Codice invito';

  @override
  String get inviteViaWhatsApp => 'Invita via WhatsApp';

  @override
  String inviteWhatsAppHouseholdMessage(String appName, String url) {
    return 'Ciao! Unisciti alla mia famiglia su $appName:\n$url';
  }

  @override
  String get copyTooltip => 'Copia';

  @override
  String get members => 'Membri';

  @override
  String get leaveHousehold => 'Abbandona famiglia';

  @override
  String get noSharedHousehold => 'Nessuna famiglia condivisa';

  @override
  String get individualModeDescription =>
      'In modalità individuale usi il tuo pianificatore e lista della spesa. Crea una famiglia o unisciti con un codice per condividerli con altri.';

  @override
  String get createHousehold => 'Crea famiglia';

  @override
  String get joinWithCode => 'Unisciti con codice';

  @override
  String currentUserSuffix(String username) {
    return '$username (tu)';
  }

  @override
  String get admin => 'Amministratore';

  @override
  String get member => 'Membro';

  @override
  String get joinHouseholdTitle => 'Unisciti a una famiglia';

  @override
  String get joinCodeInstructions =>
      'Inserisci il codice di 6 o 8 caratteri condiviso da un membro della famiglia.';

  @override
  String get invalidInviteCode => 'Codice invito non valido';

  @override
  String get alreadyMember => 'Appartieni già a questa famiglia';

  @override
  String get tooManyAttempts => 'Troppi tentativi. Riprova tra qualche minuto.';

  @override
  String get pleaseWaitMoment => 'Attendi un momento prima di riprovare.';

  @override
  String get genericErrorMessage => 'Qualcosa è andato storto. Riprova.';

  @override
  String get codeMustBeSixOrEightChars =>
      'Il codice deve avere 6 o 8 caratteri';

  @override
  String get join => 'Unisciti';

  @override
  String get createHouseholdDescription =>
      'Dai un nome alla tua famiglia condivisa. Potrai invitare altri membri con un codice.';

  @override
  String get householdNameLabel => 'Nome famiglia';

  @override
  String get enterName => 'Inserisci un nome';

  @override
  String get signOutTitle => 'Esci';

  @override
  String get signOutConfirm => 'Sicuro di voler uscire?';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get defaultUsername => 'Utente';

  @override
  String get individualModeNoHousehold =>
      'Modalità individuale (senza famiglia)';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get myHousehold => 'La mia famiglia';

  @override
  String get createOrJoinHousehold => 'Crea o unisciti a una famiglia';

  @override
  String get termsAndConditions => 'Termini e Condizioni';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get rateYourApp => 'Valuta l\'app';

  @override
  String get rateYourAppSubtitle => 'Lascia una recensione sullo store';

  @override
  String get rateAppUnavailable =>
      'La valutazione non è disponibile su questo dispositivo.';

  @override
  String get sendFeedback => 'Invia feedback';

  @override
  String get adminControlPanel => 'Pannello di controllo';

  @override
  String get adminFeedbackTitle => 'Feedback';

  @override
  String get feedbackWhatAbout => 'Cosa vuoi dirci?';

  @override
  String get feedbackCategoryIssue => 'Problema o bug';

  @override
  String get feedbackCategoryFeature => 'Suggerimento funzione';

  @override
  String get feedbackCategoryOther => 'Altro';

  @override
  String get feedbackTypeLabel => 'Tipo';

  @override
  String get feedbackYourMessage => 'Il tuo messaggio';

  @override
  String get feedbackMessageHint =>
      'Descrivi il problema o l\'idea nel modo più dettagliato possibile…';

  @override
  String get feedbackMinCharsHint => 'Minimo 10 caratteri';

  @override
  String get feedbackMessageTooShort =>
      'Il messaggio deve contenere almeno 10 caratteri.';

  @override
  String get feedbackSentSuccess =>
      'Grazie per il feedback. Lo esamineremo per migliorare l\'app.';

  @override
  String get feedbackSendError => 'Impossibile inviare il feedback. Riprova.';

  @override
  String get feedbackCategoryFilter => 'Categoria';

  @override
  String get feedbackStatusFilter => 'Stato';

  @override
  String get feedbackFilterAll => 'Tutti';

  @override
  String get feedbackStatusPending => 'In attesa';

  @override
  String get feedbackStatusResolved => 'Risolto';

  @override
  String get feedbackStatusIgnored => 'Ignorato';

  @override
  String get feedbackMarkResolved => 'Segna come risolto';

  @override
  String get feedbackMarkIgnored => 'Segna come ignorato';

  @override
  String get feedbackMarkedResolved => 'Feedback segnato come risolto.';

  @override
  String get feedbackMarkedIgnored => 'Feedback segnato come ignorato.';

  @override
  String get feedbackStatusUpdateError =>
      'Impossibile aggiornare lo stato del feedback.';

  @override
  String get adminFeedbackEmpty => 'Nessun feedback con questi filtri.';

  @override
  String get adminFeedbackLoadError => 'Impossibile caricare il feedback.';

  @override
  String get back => 'Indietro';

  @override
  String get send => 'Invia';

  @override
  String get signOut => 'Esci';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteAccountConfirmTitle => 'Eliminare l\'account?';

  @override
  String get deleteAccountConfirmMessage =>
      'Questa azione è permanente. Verranno eliminati il tuo profilo, le ricette, il pianificatore personale e le liste associate.';

  @override
  String get deletePermanently => 'Elimina definitivamente';

  @override
  String get gdprRightToErasure => 'Diritto alla cancellazione (GDPR)';

  @override
  String get deleteAccountBulletsIntro =>
      'Eliminando il tuo account verranno eliminati definitivamente:';

  @override
  String get deleteBulletProfile => 'Il tuo profilo e avatar';

  @override
  String get deleteBulletRecipes => 'Tutte le tue ricette e immagini associate';

  @override
  String get deleteBulletPlans =>
      'I tuoi piani e liste della spesa in modalità individuale';

  @override
  String get deleteBulletMembership =>
      'La tua appartenenza alle famiglie condivise';

  @override
  String get soleAdminWarning =>
      'Se sei l\'unico amministratore di una famiglia con altri membri, trasferisci il ruolo di amministratore o chiedi ai membri di uscire prima di eliminare l\'account.';

  @override
  String get deleteAcknowledgement =>
      'Capisco che questa azione è irreversibile e voglio eliminare il mio account.';

  @override
  String get typeDeleteToConfirm => 'Scrivi ELIMINA per confermare';

  @override
  String accountEmail(String email) {
    return 'Account: $email';
  }

  @override
  String get deleteMyAccount => 'Elimina il mio account';

  @override
  String get gallery => 'Galleria';

  @override
  String get camera => 'Fotocamera';

  @override
  String get changePhoto => 'Cambia foto';

  @override
  String get removeProfilePhoto => 'Rimuovi foto';

  @override
  String get couldNotOpenDocument => 'Impossibile aprire il documento';

  @override
  String get openInBrowser => 'Apri nel browser';

  @override
  String get noConnection => 'Nessuna connessione';

  @override
  String get offlineModeTitle => 'Modalità offline';

  @override
  String get offlineHouseholdMessage =>
      'Sei offline. Puoi consultare l\'ultima versione salvata del ricettario, pianificatore e lista della spesa, ma la modifica non è disponibile in modalità famiglia offline (per evitare conflitti con altri membri). Esplora non è disponibile.';

  @override
  String get offlineIndividualMessage =>
      'Sei offline. Puoi consultare e modificare il tuo ricettario, pianificatore e lista della spesa; le modifiche si sincronizzeranno al ripristino della connessione. Le foto delle ricette e la scheda Esplora non sono disponibili offline.';

  @override
  String get imageNotAllowedTitle => 'Immagine non consentita';

  @override
  String get imageNotAllowedMessage =>
      'L\'immagine selezionata contiene contenuti per adulti o espliciti non consentiti. Scegli un\'altra immagine.';

  @override
  String get imageCheckFailedTitle => 'Impossibile verificare l\'immagine';

  @override
  String get imageCheckFailedRetry =>
      'Impossibile verificare l\'immagine. Riprova.';

  @override
  String get mealBreakfast => 'Colazione';

  @override
  String get mealLunch => 'Pranzo';

  @override
  String get mealDinner => 'Cena';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Gio';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sab';

  @override
  String get daySun => 'Dom';

  @override
  String get categoryMeatFish => 'Carne e pesce';

  @override
  String get categoryVegetables => 'Verdure';

  @override
  String get categoryFruits => 'Frutta';

  @override
  String get categoryDairy => 'Latticini';

  @override
  String get categoryGrains => 'Cereali';

  @override
  String get categoryLegumes => 'Legumi';

  @override
  String get categorySpices => 'Spezie';

  @override
  String get categoryOilsVinegars => 'Oli e aceti';

  @override
  String get categoryCanned => 'Conserve';

  @override
  String get categoryNuts => 'Frutta secca';

  @override
  String get categoryBeverages => 'Bevande';

  @override
  String get categoryBaking => 'Pasticceria';

  @override
  String get categoryFrozen => 'Surgelati';

  @override
  String get categorySauces => 'Salse e condimenti';

  @override
  String get categoryOther => 'Altro';

  @override
  String get unitCustomOption => 'Altro';

  @override
  String get unitCount => 'unità';

  @override
  String get unitPinch => 'pizzico';

  @override
  String get unitTeaspoon => 'cucchiaino';

  @override
  String get unitTablespoon => 'cucchiaio';

  @override
  String get unitGlass => 'bicchiere';

  @override
  String get unitCup => 'tazza';

  @override
  String get unitHandful => 'manciata';

  @override
  String get unitLeaf => 'foglia';

  @override
  String get unitClove => 'spicchio';

  @override
  String get unitSplash => 'goccio';

  @override
  String get unitSlice => 'fetta';

  @override
  String get unitSprig => 'rametto';

  @override
  String get unitPiece => 'pezzo';

  @override
  String get unitFillet => 'filetto';

  @override
  String get unitRound => 'rondella';

  @override
  String get unitCan => 'lattina';

  @override
  String get unitJar => 'vasetto';

  @override
  String get unitPackage => 'confezione';

  @override
  String get unitSachet => 'bustina';

  @override
  String get tagStarter => 'antipasto';

  @override
  String get tagMainCourse => 'piatto principale';

  @override
  String get tagDessert => 'dolce';

  @override
  String get tagVegetarian => 'vegetariana';

  @override
  String get tagVegan => 'vegana';

  @override
  String get tagPescatarian => 'pescetariana';

  @override
  String get tagGlutenFree => 'senza glutine';

  @override
  String get tagLactoseFree => 'senza lattosio';

  @override
  String get tagEggFree => 'senza uova';

  @override
  String get tagNutFree => 'senza frutta secca';

  @override
  String get tagSoyFree => 'senza soia';

  @override
  String get tagShellfishFree => 'senza crostacei';

  @override
  String get tagSugarFree => 'senza zucchero';

  @override
  String get tagHighProtein => 'ricca di proteine';

  @override
  String get tagLowCalorie => 'poche calorie';

  @override
  String get tagLowCarb => 'pochi carboidrati';

  @override
  String get tagHighFiber => 'ricca di fibre';

  @override
  String get tagMediterranean => 'mediterranea';

  @override
  String get tagQuick => 'veloce';

  @override
  String get tagBudget => 'economica';

  @override
  String get tagBatchCooking => 'batch cooking';

  @override
  String get tagFreezerFriendly => 'da congelare';

  @override
  String get tagSpicy => 'piccante';

  @override
  String get tagKidFriendly => 'per bambini';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingPrevious => 'Indietro';

  @override
  String get onboardingFinish => 'Fine';

  @override
  String get onboardingStep0Title => 'Benvenuto in Böl!';

  @override
  String get onboardingStep0Body =>
      'Ti mostriamo come funziona l\'app in circa un minuto. Puoi saltare questo tutorial in qualsiasi momento.';

  @override
  String get onboardingStep1Title => 'Pianificatore settimanale';

  @override
  String get onboardingStep1Body =>
      'Vedi tutti i giorni con i loro pasti. Le frecce ‹ › cambiano settimana. Oggi è evidenziato in verde.';

  @override
  String get onboardingStep2Title => 'Aggiungi pasti al piano';

  @override
  String get onboardingStep2Body =>
      'Tocca uno slot vuoto per assegnare una ricetta. Puoi anche toccare l\'icona del libro per aprire il pannello laterale e trascinare le ricette su un giorno.';

  @override
  String get onboardingStep3Title => 'Il tuo ricettario';

  @override
  String get onboardingStep3Body =>
      'Tutte le tue ricette a colpo d\'occhio. La lente cerca per nome e l\'icona del libro apre il glossario culinario.';

  @override
  String get onboardingStep4Title => 'Crea una ricetta';

  @override
  String get onboardingStep4Body =>
      'Il pulsante + apre il modulo: foto, ingredienti con quantità, passaggi, nutrizione e tag. Puoi pubblicarla perché altri la scoprano.';

  @override
  String get onboardingStep5Title => 'Lista della spesa';

  @override
  String get onboardingStep5Body =>
      'Quando pianifichi i pasti, gli ingredienti compaiono qui automaticamente raggruppati per categoria. Spunta gli elementi mentre fai la spesa.';

  @override
  String get onboardingStep6Title => 'Aggiungi ingredienti';

  @override
  String get onboardingStep6Body =>
      'Tocca il pulsante + per aggiungere ingredienti manualmente alla lista della spesa.';

  @override
  String get onboardingStep7Title => 'Condividi la lista';

  @override
  String get onboardingStep7Body =>
      'L\'icona di condivisione crea un testo pronto da inviare via WhatsApp o altre app.';

  @override
  String get onboardingStep8Title => 'Scopri la community';

  @override
  String get onboardingStep8Body =>
      'Cerca ricette di altri utenti per nome o tag. Valutale e salvale nel tuo ricettario.';

  @override
  String get onboardingStep9Title => 'Il tuo feed di cuochi';

  @override
  String get onboardingStep9Body =>
      'Segui i tuoi cuochi preferiti dal loro profilo e vedi le loro ultime ricette toccando il pulsante feed.';

  @override
  String get onboardingStep10Title => 'Il tuo profilo e famiglia';

  @override
  String get onboardingStep10Body =>
      'Modifica nome e foto. Nella sezione La mia famiglia puoi pianificare con la tua famiglia in tempo reale. Da qui cambi anche lingua e modalità scura.';

  @override
  String get createRecipeOptionsTitle => 'Crea ricetta';

  @override
  String get createRecipeManual => 'Crea manualmente';

  @override
  String get createRecipeManualSubtitle =>
      'Compila tu stesso tutti i campi della ricetta';

  @override
  String get createRecipeWithAssistant => 'Crea con assistente IA';

  @override
  String get createRecipeWithAssistantSubtitle =>
      'Descrivi il piatto e l\'IA creerà la scheda ricetta';

  @override
  String get recipeAssistantTitle => 'Assistente ricette';

  @override
  String get recipeAssistantDescription =>
      'Dimmi cosa ti va, cosa hai in frigo, incolla una ricetta, allega una foto o detta con il microfono.';

  @override
  String get recipeAssistantPromptHint =>
      'Es.: frittata di patate per 4 con cipolla...';

  @override
  String get recipeAssistantImagePromptHint =>
      'Indica all\'assistente cosa fare con la foto (es.: ricreare questo piatto, estrarre la ricetta...)';

  @override
  String get recipeAssistantSameRecipePhotosHint =>
      'Se alleghi più foto, devono essere della stessa ricetta.';

  @override
  String get recipeAssistantListening => 'In ascolto…';

  @override
  String get recipeAssistantDictate => 'Detta';

  @override
  String get recipeAssistantStopDictation => 'Interrompi dettatura';

  @override
  String get recipeAssistantSpeechUnavailable =>
      'Il riconoscimento vocale non è disponibile. Attivalo nelle Impostazioni oppure digita la richiesta.';

  @override
  String get recipeAssistantSpeechFailed =>
      'Impossibile riconoscere la voce. Riprova oppure digita la richiesta.';

  @override
  String get recipeAssistantGenerate => 'Genera ricetta';

  @override
  String get recipeAssistantGenerating => 'Generazione in corso...';

  @override
  String get recipeAssistantBlockingRecipe =>
      'L\'assistente sta creando la tua ricetta…';

  @override
  String get recipeAssistantBlockingNutrition =>
      'Calcolo dei valori nutrizionali…';

  @override
  String get recipeAssistantNotRecipeRequest =>
      'Posso aiutarti solo a creare ricette. Descrivi un piatto o una ricetta.';

  @override
  String get recipeAssistantRateLimited =>
      'Limite d\'uso raggiunto. Riprova più tardi.';

  @override
  String get recipeAssistantFailed =>
      'Impossibile generare la risposta. Riprova.';

  @override
  String get recipeAssistantOffline =>
      'Connessione internet necessaria per usare l\'assistente.';

  @override
  String get recipeAssistantNotConfigured =>
      'L\'assistente IA non è ancora configurato.';

  @override
  String get recipeAssistantTimeout =>
      'La richiesta ha impiegato troppo tempo. Riprova.';

  @override
  String get recipeAssistantPromptTooLong =>
      'La descrizione della ricetta non può superare i 3.000 caratteri.';

  @override
  String get recipeAssistantMissingInput =>
      'Scrivi una descrizione o allega una foto della ricetta.';

  @override
  String get recipeAssistantImageTooLarge =>
      'L\'immagine è troppo grande. Prova un\'altra foto o scattane una nuova.';

  @override
  String get recipeAssistantInvalidImage =>
      'Impossibile usare quell\'immagine. Prova un\'altra foto.';

  @override
  String get recipeAssistantDailyLimitReached =>
      'Hai raggiunto il limite giornaliero dell\'assistente. Torna domani.';

  @override
  String get recipeAssistantTooFast =>
      'Attendi un momento prima di usare di nuovo l\'assistente.';

  @override
  String get recipeAssistantServiceAtCapacity =>
      'L\'assistente è al completo in questo momento. Riprova più tardi.';

  @override
  String get completeNutritionWithAssistant => 'Completa con IA';

  @override
  String get recipeAssistantNutritionSaved => 'Valori nutrizionali completati';

  @override
  String get cookRecipeButton => 'Cucina la ricetta';

  @override
  String get continueCookingButton => 'Continua a cucinare';

  @override
  String get checkIngredientsStep => 'Controlla ingredienti';

  @override
  String stepXofY(int current, int total) {
    return 'Passaggio $current di $total';
  }

  @override
  String get completeStepButton => 'Completa passaggio';

  @override
  String get finishCookingButton => 'Finisci';

  @override
  String get cookingPausedLabel => 'In pausa';

  @override
  String get cookingPauseTooltip => 'Metti in pausa';

  @override
  String get cookingResumeTooltip => 'Riprendi';

  @override
  String get finishCookingTitle => 'Finire la ricetta?';

  @override
  String finishCookingConfirm(String title) {
    return 'Vuoi finire di cucinare \"$title\"?';
  }

  @override
  String get cookingFinishedTitle => 'Ricetta terminata!';

  @override
  String get cookingFinishedMessage => 'Buon appetito!';

  @override
  String get cookingInProgressTitle => 'Ricetta in corso';

  @override
  String cookingInProgressMessage(String title) {
    return 'Stai già cucinando \"$title\". Iniziare una nuova ricetta?';
  }

  @override
  String get cookingReplaceButton => 'Nuova ricetta';

  @override
  String get previousStep => 'Passaggio precedente';

  @override
  String get nextStep => 'Passaggio successivo';

  @override
  String get minimize => 'Minimizza';

  @override
  String get expandCookingSession => 'Espandi';

  @override
  String get cookingNotificationChannelName => 'Sessione di cucina';

  @override
  String get cookingNotificationChannelDescription =>
      'Sessione di cucina in corso';
}
