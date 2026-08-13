// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get appName => 'Böl';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Castelán';

  @override
  String get languageBasque => 'Euskera';

  @override
  String get languageCatalan => 'Catalán';

  @override
  String get languageGalician => 'Galego';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSystemDefault => 'Idioma do sistema';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Gardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get add => 'Engadir';

  @override
  String get edit => 'Editar';

  @override
  String get remove => 'Quitar';

  @override
  String get clear => 'Limpar';

  @override
  String get retry => 'Reintentar';

  @override
  String get understood => 'Entendido';

  @override
  String get optional => 'Opcional';

  @override
  String get requiredField => 'Obrigatorio';

  @override
  String errorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get navExplore => 'Explorar';

  @override
  String get navRecipeBook => 'Receitas';

  @override
  String get navPlanner => 'Plan';

  @override
  String get navShopping => 'Compra';

  @override
  String get navProfile => 'Perfil';

  @override
  String get exploreUnavailableOffline =>
      'Explorar non está dispoñible sen conexión';

  @override
  String get loginTagline => 'Planifica as túas comidas semanais';

  @override
  String get sessionExpiredMessage =>
      'A túa sesión caducou. Inicia sesión de novo.';

  @override
  String get supabaseNotConfigured =>
      'Supabase non configurado. Copia dart_defines.example.json a dart_defines.json e engade SUPABASE_URL / SUPABASE_ANON_KEY.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Contrasinal';

  @override
  String get enterEmail => 'Introduce o teu email';

  @override
  String get enterPassword => 'Introduce o teu contrasinal';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get captchaRequired => 'Completa a verificación';

  @override
  String get captchaFailed => 'A verificación fallou. Téntao de novo.';

  @override
  String get turnstileNotConfigured =>
      'Turnstile non está configurado. Engade TURNSTILE_SITE_KEY a dart_defines.json.';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get forgotPasswordLink => 'Esqueciches o contrasinal?';

  @override
  String get noAccountRegister => 'Non tes conta? Rexístrate';

  @override
  String get createAccountTitle => 'Crear conta';

  @override
  String registerInApp(String appName) {
    return 'Rexístrate en $appName';
  }

  @override
  String get usernameLabel => 'Nome de usuario';

  @override
  String get enterUsername => 'Introduce o teu nome de usuario';

  @override
  String get minTwoCharacters => 'Mínimo 2 caracteres';

  @override
  String get invalidEmail => 'Email non válido';

  @override
  String get enterPasswordRegister => 'Introduce un contrasinal';

  @override
  String get minSixCharacters => 'Mínimo 6 caracteres';

  @override
  String get passwordTooShort =>
      'O contrasinal debe ter polo menos 8 caracteres';

  @override
  String get passwordTooWeak => 'O contrasinal debe incluír letras e números';

  @override
  String get confirmPasswordLabel => 'Confirmar contrasinal';

  @override
  String get confirmYourPassword => 'Confirma o teu contrasinal';

  @override
  String get passwordsDoNotMatch => 'Os contrasinais non coinciden';

  @override
  String get mustAcceptTerms =>
      'Debes aceptar os Termos e a Política de Privacidade';

  @override
  String get acceptTermsPrefix => 'Acepto os';

  @override
  String get termsLink => 'Termos';

  @override
  String get andThe => 'e a';

  @override
  String get privacyPolicyLink => 'Política de Privacidade';

  @override
  String get alreadyHaveAccount => 'Xa tes conta? Inicia sesión';

  @override
  String get checkYourEmail => 'Revisa o teu email';

  @override
  String confirmationEmailSent(String email) {
    return 'Enviamos unha ligazón de confirmación a $email. Confirma a túa conta antes de iniciar sesión.';
  }

  @override
  String get goToSignIn => 'Ir ao inicio de sesión';

  @override
  String get recoverPasswordTitle => 'Recuperar contrasinal';

  @override
  String get forgotPasswordInstructions =>
      'Introduce o teu email e enviarémosche unha ligazón para restablecer o contrasinal.';

  @override
  String get sendResetLink => 'Enviar ligazón';

  @override
  String get backToSignIn => 'Volver ao inicio de sesión';

  @override
  String get emailSent => 'Email enviado';

  @override
  String resetEmailSentIfExists(String email) {
    return 'Se existe unha conta con $email, recibirás unha ligazón para restablecer o contrasinal.';
  }

  @override
  String get showPassword => 'Mostrar contrasinal';

  @override
  String get hidePassword => 'Ocultar contrasinal';

  @override
  String get recipeBookTitle => 'Receitar';

  @override
  String get cookingGlossaryTooltip => 'Glosario culinario';

  @override
  String get newRecipeTooltip => 'Nova receita';

  @override
  String get searchByName => 'Buscar por nome';

  @override
  String get noRecipesFoundForSearch =>
      'Non se atopou ningunha receita relacionada coa busca. Créaa ti mesmo.';

  @override
  String get noRecipesYet => 'Aínda non hai receitas';

  @override
  String get createFirstRecipe => 'Crear primeira receita';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count racións',
      one: '1 ración',
    );
    return '$_temp0';
  }

  @override
  String servingsCountShort(int count) {
    return '$count r.';
  }

  @override
  String get deleteRecipeTitle => 'Eliminar receita';

  @override
  String deleteRecipeConfirm(String title) {
    return 'Seguro que queres eliminar \"$title\"?';
  }

  @override
  String get publishRecipeTitle => 'Publicar receita';

  @override
  String publishRecipeMessage(String appName) {
    return 'Esta receita será visible para todos os usuarios de $appName. Poderás despublicala en calquera momento.';
  }

  @override
  String get makeRecipePrivateTitle => 'Facer receita privada';

  @override
  String get makeRecipePrivateMessageDetail =>
      'A receita deixará de ser visible en Explorar. Conservaranse as valoracións existentes.';

  @override
  String get makeRecipePrivateMessageForm =>
      'A receita deixará de ser visible en Explorar.';

  @override
  String get publish => 'Publicar';

  @override
  String get makePrivate => 'Facer privada';

  @override
  String visibilityChangeError(String error) {
    return 'Erro ao cambiar a visibilidade: $error';
  }

  @override
  String get publicBadge => 'Pública';

  @override
  String prepTimeMin(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String cookTimeMin(int minutes) {
    return 'Cocción: $minutes min';
  }

  @override
  String get forkedRecipeTitle => 'Receita gardada doutro usuario';

  @override
  String get forkedRecipeCannotPublish =>
      'As receitas forkeadas non se poden publicar en Explorar.';

  @override
  String get publicRecipeSwitch => 'Receita pública';

  @override
  String get visibleInExplore => 'Visible en Explorar para todos os usuarios';

  @override
  String get onlyInRecipeBook => 'Só visible no teu receitar';

  @override
  String get ingredientsSection => 'Ingredientes';

  @override
  String get noIngredients => 'Sen ingredientes';

  @override
  String get preparationSection => 'Elaboración';

  @override
  String get noSteps => 'Sen pasos';

  @override
  String get tipsSection => 'Consellos';

  @override
  String get nutritionPerServing => 'Nutrición (por ración)';

  @override
  String get calories => 'Calorías';

  @override
  String get protein => 'Proteínas';

  @override
  String get carbohydrates => 'Hidratos de carbono';

  @override
  String get fat => 'Graxas';

  @override
  String get fiber => 'Fibra';

  @override
  String nutritionChip(String label, String value) {
    return '$label: $value';
  }

  @override
  String get newRecipeTitle => 'Nova receita';

  @override
  String get editRecipeTitle => 'Editar receita';

  @override
  String get photoRequiresConnection =>
      'Necesitas conexión para engadir ou cambiar a foto da receita';

  @override
  String get householdEditRequiresConnection =>
      'Sen conexión: a edición en modo fogar require conexión';

  @override
  String get nameLabel => 'Nome';

  @override
  String get servingsLabel => 'Racións';

  @override
  String get minOneServing => 'Mínimo 1';

  @override
  String get prepMinLabel => 'Prep (min)';

  @override
  String get cookMinLabel => 'Cocción (min)';

  @override
  String get tagsSection => 'Etiquetas';

  @override
  String get customTagLabel => 'Etiqueta personalizada';

  @override
  String get stepsSection => 'Pasos';

  @override
  String get tipsLabel => 'Consellos';

  @override
  String get tipsHint => 'Trucos, variacións ou notas útiles';

  @override
  String get visibleInExploreShort =>
      'Visible para todos os usuarios en Explorar';

  @override
  String get addIngredient => 'Engadir ingrediente';

  @override
  String get addStep => 'Engadir paso';

  @override
  String stepLabel(int number) {
    return 'Paso $number';
  }

  @override
  String get optionalStepPrefix => 'Opcional:';

  @override
  String get checkingImage => 'Comprobando imaxe...';

  @override
  String get choosePhoto => 'Elixir foto';

  @override
  String get caloriesKcal => 'Calorías (kcal)';

  @override
  String get proteinG => 'Proteínas (g)';

  @override
  String get carbohydratesG => 'Hidratos de carbono (g)';

  @override
  String get fatG => 'Graxas (g)';

  @override
  String get fiberG => 'Fibra (g)';

  @override
  String get householdLoadError =>
      'Non se puido cargar o teu fogar. Téntao de novo.';

  @override
  String get ingredientLabel => 'Ingrediente';

  @override
  String get removeIngredientTooltip => 'Eliminar ingrediente';

  @override
  String get quantityLabel => 'Cantidade';

  @override
  String get enterValidNumber => 'Introduce un número válido';

  @override
  String get unitLabel => 'Unidade';

  @override
  String get customUnitLabel => 'Unidade personalizada';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get toTaste => 'Ao gusto';

  @override
  String get toTasteShoppingHint =>
      'Non se engade á lista da compra (p. ex. sal, piemento)';

  @override
  String get optionalIngredientHint =>
      'Podes incluílo ou excluílo na ficha da receita';

  @override
  String get clearTags => 'Limpar';

  @override
  String get cookingGlossaryTitle => 'Glosario culinario';

  @override
  String get addTermTooltip => 'Engadir termo';

  @override
  String get newGlossaryEntry => 'Nova entrada';

  @override
  String get termLabel => 'Termo';

  @override
  String get enterTerm => 'Introduce un termo';

  @override
  String get definitionLabel => 'Definición';

  @override
  String get enterDefinition => 'Introduce unha definición';

  @override
  String get duplicateGlossaryTerm => 'Ese termo xa existe no glosario';

  @override
  String get searchTermOrDefinition => 'Buscar termo ou definición';

  @override
  String get noGlossaryEntries => 'Non hai entradas no glosario';

  @override
  String get noGlossaryTermsFound => 'Non se atoparon termos';

  @override
  String get deleteEntryTooltip => 'Eliminar entrada';

  @override
  String get deleteGlossaryEntryTitle => 'Eliminar entrada';

  @override
  String deleteGlossaryEntryConfirm(String term) {
    return 'Queres eliminar \"$term\" do glosario?';
  }

  @override
  String get autoTranslatedBadge => 'Traducido automaticamente';

  @override
  String get viewOriginal => 'Ver orixinal';

  @override
  String get viewTranslation => 'Ver tradución';

  @override
  String get translatingRecipe => 'Traducindo receita...';

  @override
  String get translationFailed => 'Non se puido traducir esta receita';

  @override
  String get plannerTitle => 'Planificador';

  @override
  String get sharePlannerTooltip => 'Compartir planificador';

  @override
  String get copyPlannerTooltip => 'Copiar planificador';

  @override
  String get plannerCopied => 'Planificador copiado ao portapapeis';

  @override
  String get plannerShareLeftoverLabel => 'sobras';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get today => 'Hoxe';

  @override
  String get showRecipeBookTooltip => 'Mostrar receitar';

  @override
  String get removeMealTitle => 'Quitar comida';

  @override
  String removeMealConfirm(String title) {
    return 'Quitar \"$title\" do planificador?';
  }

  @override
  String get dropHere => 'Soltar aquí';

  @override
  String get dragOrTap => 'Arrastra ou pulsa';

  @override
  String get servingsTitle => 'Racións';

  @override
  String get servingsCountLabel => 'Número de racións';

  @override
  String get addTextTitle => 'Engadir texto';

  @override
  String get mealNameLabel => 'Nome (p. ex. Pedido a domicilio)';

  @override
  String get enterMealName => 'Escribe un nome para a comida';

  @override
  String get fewerServingsTooltip => 'Menos racións';

  @override
  String get moreServingsTooltip => 'Máis racións';

  @override
  String get leftovers => 'Son sobras';

  @override
  String get leftoversShoppingHint =>
      'Non se engadirán ingredientes á lista da compra';

  @override
  String get pastMealPlanTitle => 'Comida pasada';

  @override
  String get pastMealPlanMessage =>
      'Estás a planificar unha comida dun día xa pasado. Os ingredientes non se engadirán á lista da compra.';

  @override
  String get recipeBookPanel => 'Receitar';

  @override
  String get closeTooltip => 'Pechar';

  @override
  String get searchHint => 'Buscar...';

  @override
  String get noResults => 'Sen resultados';

  @override
  String get noRecipesCreateInBook => 'Non tes receitas. Créaas no receitar.';

  @override
  String get chooseRecipe => 'Elixir receita';

  @override
  String get searchRecipeHint => 'Buscar receita...';

  @override
  String get addFreeText => 'Engadir texto libre';

  @override
  String get noRecipeExample => 'Sen receita (p. ex. pedido, fóra, etc.)';

  @override
  String get clearListTitle => 'Limpar lista';

  @override
  String get clearListConfirm =>
      'Eliminar todos os elementos da lista da compra?';

  @override
  String get shoppingListTitle => 'Lista da compra';

  @override
  String get shareListTooltip => 'Compartir lista';

  @override
  String get shareRecipeTooltip => 'Compartir receita';

  @override
  String shareRecipeMessage(String title, String url) {
    return '$url\n\nMira esta receita en Böl: $title';
  }

  @override
  String get shareLinkExpired => 'Esta ligazón caducou';

  @override
  String get shareLinkInvalid => 'Esta ligazón non é válida';

  @override
  String get revokeShareLink => 'Revogar enlace de compartir';

  @override
  String get revokeShareLinkConfirm =>
      'Isto invalidará o enlace privado actual. Quen teña o enlace xa non poderá abrir esta receita.';

  @override
  String get revoke => 'Revogar';

  @override
  String get shareLinkRevoked => 'Enlace revogado';

  @override
  String get noActiveShareLink => 'Non hai ningún enlace activo para revogar';

  @override
  String get clearListTooltip => 'Limpar lista';

  @override
  String shoppingListLoadError(String error) {
    return 'Non se puido cargar a lista: $error';
  }

  @override
  String get shoppingListEmpty => 'A túa lista está baleira';

  @override
  String get shoppingListEmptyHint =>
      'Engade receitas ao planificador ou elementos manualmente co botón +.';

  @override
  String get addItemTooltip => 'Engadir elemento';

  @override
  String get deleteItemTitle => 'Eliminar elemento';

  @override
  String deleteItemConfirm(String name) {
    return 'Eliminar «$name» da lista?';
  }

  @override
  String get editItem => 'Editar elemento';

  @override
  String get addItem => 'Engadir elemento';

  @override
  String get nameRequired => 'O nome é obrigatorio';

  @override
  String get othersCategory => 'Outros';

  @override
  String get feedTitle => 'Feed';

  @override
  String get mostRecent => 'Máis recente';

  @override
  String sortedBy(String label) {
    return 'Ordenado por: $label';
  }

  @override
  String get noRecipesWithTags => 'Sen receitas con estas etiquetas';

  @override
  String get feedEmpty => 'O teu feed está baleiro';

  @override
  String get tryOtherTags => 'Proba con outras etiquetas ou quita o filtro.';

  @override
  String get followUsersHint =>
      'Segue a outros usuarios desde os seus perfís para ver as súas receitas públicas aquí.';

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get feedTooltip => 'Feed';

  @override
  String get searchPublicRecipes => 'Buscar receitas públicas';

  @override
  String get recent => 'Recentes';

  @override
  String get topRated => 'Mellor valoradas';

  @override
  String get noPublicRecipesYet => 'Aínda non hai receitas públicas';

  @override
  String get publishToExploreHint =>
      'Publica unha receita desde o teu receitar para que outros a descubran.';

  @override
  String get publicProfileTitle => 'Perfil público';

  @override
  String publicRecipesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas públicas',
      one: '1 receita pública',
    );
    return '$_temp0';
  }

  @override
  String get unfollow => 'Deixar de seguir';

  @override
  String get follow => 'Seguir';

  @override
  String get noPublicRecipes => 'Sen receitas públicas';

  @override
  String get recipeSavedToBook => 'Receita gardada no teu receitar';

  @override
  String get saveToMyRecipeBookTooltip => 'Gardar no meu receitar';

  @override
  String get recipeCreatedBy => 'Receita creada por';

  @override
  String get recipeCreatedByName => 'Creada por';

  @override
  String get you => 'ti';

  @override
  String get yourRating => 'A túa valoración';

  @override
  String get optionalIngredientSuffix => '(opcional)';

  @override
  String get saveToMyRecipeBook => 'Gardar no meu receitar';

  @override
  String get optionalIngredientsTitle => 'Ingredientes opcionais';

  @override
  String get optionalIngredientsMessage =>
      'Esta receita contén ingredientes opcionais. Engádeos ou elimínaos na túa receita.';

  @override
  String get editRecipe => 'Editar receita';

  @override
  String get inviteCodeCopied => 'Código copiado ao portapapeis';

  @override
  String get regenerateCodeTitle => 'Rexenerar código';

  @override
  String get regenerateCodeMessage =>
      'O código anterior deixará de funcionar. Queres xerar un novo?';

  @override
  String get regenerate => 'Rexenerar';

  @override
  String get codeRegenerated => 'Código rexenerado';

  @override
  String get kickMemberTitle => 'Expulsar membro';

  @override
  String kickMemberConfirm(String username) {
    return 'Expulsar a $username do fogar?';
  }

  @override
  String get kick => 'Expulsar';

  @override
  String get leaveHouseholdTitle => 'Abandonar fogar';

  @override
  String get leaveHouseholdMessage =>
      'Copiarase o planificador e a lista do fogar ao teu modo individual (a semana actual e as futuras). Continuar?';

  @override
  String get leave => 'Abandonar';

  @override
  String get myHouseholdTitle => 'O meu fogar';

  @override
  String get inviteCode => 'Código de invitación';

  @override
  String get inviteViaWhatsApp => 'Convidar por WhatsApp';

  @override
  String inviteWhatsAppHouseholdMessage(String appName, String url) {
    return 'Ola! Únete ao meu fogar en $appName:\n$url';
  }

  @override
  String get copyTooltip => 'Copiar';

  @override
  String get members => 'Membros';

  @override
  String get leaveHousehold => 'Abandonar fogar';

  @override
  String get noSharedHousehold => 'Sen fogar compartido';

  @override
  String get individualModeDescription =>
      'En modo individual usas o teu propio planificador e lista da compra. Crea un fogar ou únete cun código para compartilos con outros.';

  @override
  String get createHousehold => 'Crear fogar';

  @override
  String get joinWithCode => 'Unirse con código';

  @override
  String currentUserSuffix(String username) {
    return '$username (ti)';
  }

  @override
  String get admin => 'Administrador';

  @override
  String get member => 'Membro';

  @override
  String get joinHouseholdTitle => 'Unirse a un fogar';

  @override
  String get joinCodeInstructions =>
      'Introduce o código de 6 caracteres que che compartiu un membro do fogar.';

  @override
  String get invalidInviteCode => 'Código de invitación non válido';

  @override
  String get alreadyMember => 'Xa pertences a este fogar';

  @override
  String get tooManyAttempts =>
      'Demasiados intentos. Téntao de novo nuns minutos.';

  @override
  String get pleaseWaitMoment => 'Espera un momento antes de tentar de novo.';

  @override
  String get genericErrorMessage => 'Algo saíu mal. Téntao de novo.';

  @override
  String get codeMustBeSixChars => 'O código debe ter 6 caracteres';

  @override
  String get join => 'Unirse';

  @override
  String get createHouseholdDescription =>
      'Ponlle un nome ao teu fogar compartido. Poderás invitar a outros membros cun código.';

  @override
  String get householdNameLabel => 'Nome do fogar';

  @override
  String get enterName => 'Introduce un nome';

  @override
  String get signOutTitle => 'Pechar sesión';

  @override
  String get signOutConfirm => 'Seguro que queres pechar sesión?';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get defaultUsername => 'Usuario';

  @override
  String get individualModeNoHousehold => 'Modo individual (sen fogar)';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get myHousehold => 'O meu fogar';

  @override
  String get createOrJoinHousehold => 'Crear ou unirse a un fogar';

  @override
  String get termsAndConditions => 'Termos e Condicións';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get rateYourApp => 'Valora a app';

  @override
  String get rateYourAppSubtitle => 'Deixa unha reseña na tenda';

  @override
  String get rateAppUnavailable =>
      'A valoración non está dispoñible neste dispositivo agora mesmo.';

  @override
  String get sendFeedback => 'Enviar feedback';

  @override
  String get adminControlPanel => 'Panel de control';

  @override
  String get adminFeedbackTitle => 'Feedback';

  @override
  String get feedbackWhatAbout => 'Que queres contarnos?';

  @override
  String get feedbackCategoryIssue => 'Problema ou erro';

  @override
  String get feedbackCategoryFeature => 'Suxestión de función';

  @override
  String get feedbackCategoryOther => 'Outro';

  @override
  String get feedbackTypeLabel => 'Tipo';

  @override
  String get feedbackYourMessage => 'A túa mensaxe';

  @override
  String get feedbackMessageHint =>
      'Describe o problema ou a túa idea co maior detalle posible…';

  @override
  String get feedbackMinCharsHint => 'Mínimo 10 caracteres';

  @override
  String get feedbackMessageTooShort =>
      'A mensaxe debe ter polo menos 10 caracteres.';

  @override
  String get feedbackSentSuccess =>
      'Grazas pola túa mensaxe. Revisarémola para mellorar a app.';

  @override
  String get feedbackSendError =>
      'Non se puido enviar o feedback. Téntao de novo.';

  @override
  String get feedbackCategoryFilter => 'Categoría';

  @override
  String get feedbackStatusFilter => 'Estado';

  @override
  String get feedbackFilterAll => 'Todos';

  @override
  String get feedbackStatusPending => 'Pendente';

  @override
  String get feedbackStatusResolved => 'Resolto';

  @override
  String get feedbackStatusIgnored => 'Ignorado';

  @override
  String get feedbackMarkResolved => 'Marcar como resolto';

  @override
  String get feedbackMarkIgnored => 'Marcar como ignorado';

  @override
  String get feedbackMarkedResolved => 'Feedback marcado como resolto.';

  @override
  String get feedbackMarkedIgnored => 'Feedback marcado como ignorado.';

  @override
  String get feedbackStatusUpdateError =>
      'Non se puido actualizar o estado do feedback.';

  @override
  String get adminFeedbackEmpty => 'Non hai feedback con estes filtros.';

  @override
  String get adminFeedbackLoadError => 'Non se puido cargar o feedback.';

  @override
  String get back => 'Atrás';

  @override
  String get send => 'Enviar';

  @override
  String get signOut => 'Pechar sesión';

  @override
  String get deleteAccount => 'Eliminar conta';

  @override
  String get deleteAccountConfirmTitle => 'Eliminar conta?';

  @override
  String get deleteAccountConfirmMessage =>
      'Esta acción é permanente. Borraranse o teu perfil, receitas, planificador persoal e listas asociadas.';

  @override
  String get deletePermanently => 'Eliminar definitivamente';

  @override
  String get gdprRightToErasure => 'Dereito de supresión (RXPD)';

  @override
  String get deleteAccountBulletsIntro =>
      'Ao eliminar a túa conta borraranse permanentemente:';

  @override
  String get deleteBulletProfile => 'O teu perfil e avatar';

  @override
  String get deleteBulletRecipes => 'Todas as túas receitas e imaxes asociadas';

  @override
  String get deleteBulletPlans =>
      'Os teus plans e listas da compra en modo individual';

  @override
  String get deleteBulletMembership => 'A túa pertenza a fogares compartidos';

  @override
  String get soleAdminWarning =>
      'Se es o único administrador dun fogar con outros membros, debes transferir o rol de administrador ou pedir aos membros que abandonen o fogar antes de eliminar a conta.';

  @override
  String get deleteAcknowledgement =>
      'Entendo que esta acción é irreversible e desexo eliminar a miña conta.';

  @override
  String get typeDeleteToConfirm => 'Escribe ELIMINAR para confirmar';

  @override
  String accountEmail(String email) {
    return 'Conta: $email';
  }

  @override
  String get deleteMyAccount => 'Eliminar a miña conta';

  @override
  String get gallery => 'Galería';

  @override
  String get camera => 'Cámara';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get removeProfilePhoto => 'Eliminar foto';

  @override
  String get couldNotOpenDocument => 'Non se puido abrir o documento';

  @override
  String get openInBrowser => 'Abrir no navegador';

  @override
  String get noConnection => 'Sen conexión';

  @override
  String get offlineModeTitle => 'Modo sen conexión';

  @override
  String get offlineHouseholdMessage =>
      'Estás sen conexión. Podes consultar a última versión gardada do teu receitar, planificador e lista da compra, pero a edición non está dispoñible en modo fogar sen conexión. Explorar tampouco está dispoñible.';

  @override
  String get offlineIndividualMessage =>
      'Estás sen conexión. Podes consultar e editar o teu receitar, planificador e lista da compra; os cambios sincronizaranse ao recuperar a conexión. A foto de receitas e a lapela Explorar non están dispoñibles sen conexión.';

  @override
  String get imageNotAllowedTitle => 'Imaxe non permitida';

  @override
  String get imageNotAllowedMessage =>
      'A imaxe seleccionada contén contido adulto ou explícito que non está permitido. Elixe outra imaxe.';

  @override
  String get imageCheckFailedTitle => 'Non se puido comprobar a imaxe';

  @override
  String get imageCheckFailedRetry =>
      'Non se puido comprobar a imaxe. Téntao de novo.';

  @override
  String get mealBreakfast => 'Almorzo';

  @override
  String get mealLunch => 'Comida';

  @override
  String get mealDinner => 'Ceá';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mér';

  @override
  String get dayThu => 'Xov';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get categoryMeatFish => 'Carnes e peixes';

  @override
  String get categoryVegetables => 'Verduras';

  @override
  String get categoryFruits => 'Froitas';

  @override
  String get categoryDairy => 'Lácteos';

  @override
  String get categoryGrains => 'Cereais';

  @override
  String get categoryLegumes => 'Legumes';

  @override
  String get categorySpices => 'Especias';

  @override
  String get categoryOilsVinegars => 'Aceites e vinagres';

  @override
  String get categoryCanned => 'Conservas';

  @override
  String get categoryNuts => 'Froitos secos';

  @override
  String get categoryBeverages => 'Bebidas';

  @override
  String get categoryBaking => 'Repostería';

  @override
  String get categoryFrozen => 'Conxelados';

  @override
  String get categorySauces => 'Salsas e condimentos';

  @override
  String get categoryOther => 'Outros';

  @override
  String get unitCustomOption => 'Outra';

  @override
  String get unitCount => 'unidade';

  @override
  String get unitPinch => 'pitada';

  @override
  String get unitTeaspoon => 'culleradiña';

  @override
  String get unitTablespoon => 'cullerada';

  @override
  String get unitGlass => 'vaso';

  @override
  String get unitCup => 'cunca';

  @override
  String get unitHandful => 'puñado';

  @override
  String get unitLeaf => 'folla';

  @override
  String get unitClove => 'dente';

  @override
  String get unitSplash => 'chorro';

  @override
  String get unitSlice => 'rebanda';

  @override
  String get unitSprig => 'rama';

  @override
  String get unitPiece => 'anaco';

  @override
  String get unitFillet => 'filete';

  @override
  String get unitRound => 'rolda';

  @override
  String get unitCan => 'lata';

  @override
  String get unitJar => 'bote';

  @override
  String get unitPackage => 'paquete';

  @override
  String get unitSachet => 'sobre';

  @override
  String get tagStarter => 'entrante';

  @override
  String get tagMainCourse => 'prato principal';

  @override
  String get tagDessert => 'sobremesa';

  @override
  String get tagVegetarian => 'vegetariana';

  @override
  String get tagVegan => 'vegano';

  @override
  String get tagPescatarian => 'pescetariana';

  @override
  String get tagGlutenFree => 'sen glute';

  @override
  String get tagLactoseFree => 'sen lactosa';

  @override
  String get tagEggFree => 'sen ovo';

  @override
  String get tagNutFree => 'sen froitos secos';

  @override
  String get tagSoyFree => 'sen soia';

  @override
  String get tagShellfishFree => 'sen marisco';

  @override
  String get tagSugarFree => 'sen azúcar';

  @override
  String get tagHighProtein => 'alto en proteínas';

  @override
  String get tagLowCalorie => 'baixa en calorías';

  @override
  String get tagLowCarb => 'baixa en hidratos';

  @override
  String get tagHighFiber => 'alta en fibra';

  @override
  String get tagMediterranean => 'mediterránea';

  @override
  String get tagQuick => 'rápida';

  @override
  String get tagBudget => 'económica';

  @override
  String get tagBatchCooking => 'batch cooking';

  @override
  String get tagFreezerFriendly => 'para conxelar';

  @override
  String get tagSpicy => 'picante';

  @override
  String get tagKidFriendly => 'para nenos';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Seguinte';

  @override
  String get onboardingPrevious => 'Anterior';

  @override
  String get onboardingFinish => 'Finalizar';

  @override
  String get onboardingStep0Title => 'Benvido/a a Böl!';

  @override
  String get onboardingStep0Body =>
      'Amosámosche como funciona a app nun minuto. Podes omitir este tutorial cando queiras.';

  @override
  String get onboardingStep1Title => 'Planificador semanal';

  @override
  String get onboardingStep1Body =>
      'Ves todos os días coas súas comidas. As frechas ‹ › cambian de semana. O día de hoxe aparece resaltado en verde.';

  @override
  String get onboardingStep2Title => 'Engade comidas ao plan';

  @override
  String get onboardingStep2Body =>
      'Toca un espazo baleiro para asignar unha receita. Tamén podes premer a icona de libro para abrir o receitar lateral e arrastrar receitas directamente ao día.';

  @override
  String get onboardingStep3Title => 'O teu receitar';

  @override
  String get onboardingStep3Body =>
      'Todas as túas receitas dunha ollada. A lupa busca por nome e a icona de libro abre o glosario culinario.';

  @override
  String get onboardingStep4Title => 'Crea unha receita';

  @override
  String get onboardingStep4Body =>
      'O botón + abre o formulario: foto, ingredientes con cantidades, pasos de elaboración, nutrición e etiquetas. Podes publicala para que outros a descubran.';

  @override
  String get onboardingStep5Title => 'Lista da compra';

  @override
  String get onboardingStep5Body =>
      'Cando planificas comidas, os ingredientes aparecen aquí automaticamente agrupados por categoría. Marca os ítems ao compralos.';

  @override
  String get onboardingStep6Title => 'Engade ingredientes';

  @override
  String get onboardingStep6Body =>
      'Preme o botón + para engadir ingredientes manualmente á túa lista da compra.';

  @override
  String get onboardingStep7Title => 'Comparte a túa lista';

  @override
  String get onboardingStep7Body =>
      'A icona de compartir xera un texto listo para enviar por WhatsApp ou outras apps.';

  @override
  String get onboardingStep8Title => 'Descobre a comunidade';

  @override
  String get onboardingStep8Body =>
      'Busca receitas doutros usuarios por nome ou etiquetas. Valóraas e gárdalas no teu receitar.';

  @override
  String get onboardingStep9Title => 'O teu feed de cociñeiros';

  @override
  String get onboardingStep9Body =>
      'Segue aos teus cociñeiros favoritos desde o seu perfil e consulta as súas últimas receitas premendo o botón do feed.';

  @override
  String get onboardingStep10Title => 'O teu perfil e fogar';

  @override
  String get onboardingStep10Body =>
      'Edita o teu nome e foto. Na sección O meu fogar podes planificar coa túa familia en tempo real. Desde aquí tamén cambias o idioma e o modo escuro.';

  @override
  String get createRecipeOptionsTitle => 'Crear receita';

  @override
  String get createRecipeManual => 'Crear manualmente';

  @override
  String get createRecipeManualSubtitle =>
      'Enche ti mesmo todos os campos da receita';

  @override
  String get createRecipeWithAssistant => 'Crear co asistente de IA';

  @override
  String get createRecipeWithAssistantSubtitle =>
      'Describe o prato e a IA elaborará a ficha';

  @override
  String get recipeAssistantTitle => 'Asistente de receitas';

  @override
  String get recipeAssistantDescription =>
      'Dime o que che apetece, o que tes na neveira, pega unha receita, anexa unha foto ou dicta co micrófono.';

  @override
  String get recipeAssistantPromptHint =>
      'Ex.: tortilla de patacas para 4 persoas con cebola...';

  @override
  String get recipeAssistantImagePromptHint =>
      'Indica ao asistente que facer coa foto (ex.: recrear este prato, extraer a receita...)';

  @override
  String get recipeAssistantSameRecipePhotosHint =>
      'Se anexas varias fotos, que sexan da mesma receita.';

  @override
  String get recipeAssistantListening => 'Escoitando…';

  @override
  String get recipeAssistantDictate => 'Ditar';

  @override
  String get recipeAssistantStopDictation => 'Parar o ditado';

  @override
  String get recipeAssistantSpeechUnavailable =>
      'O recoñecemento de voz non está dispoñible. Actívao en Axustes ou escribe a túa petición.';

  @override
  String get recipeAssistantSpeechFailed =>
      'Non se puido recoñecer a voz. Téntao de novo ou escribe a túa petición.';

  @override
  String get recipeAssistantGenerate => 'Xerar receita';

  @override
  String get recipeAssistantGenerating => 'Xerando...';

  @override
  String get recipeAssistantBlockingRecipe =>
      'O asistente está elaborando a túa receita…';

  @override
  String get recipeAssistantBlockingNutrition =>
      'Calculando a información nutricional…';

  @override
  String get recipeAssistantNotRecipeRequest =>
      'Só podo axudarte a elaborar receitas. Describe un prato ou unha receita.';

  @override
  String get recipeAssistantRateLimited =>
      'Límite de uso acadado. Téntao de novo máis tarde.';

  @override
  String get recipeAssistantFailed =>
      'Non se puido xerar a resposta. Téntao de novo.';

  @override
  String get recipeAssistantOffline =>
      'Requírese conexión a internet para usar o asistente.';

  @override
  String get recipeAssistantNotConfigured =>
      'O asistente de IA aínda non está configurado.';

  @override
  String get recipeAssistantTimeout =>
      'A solicitude tardou demasiado. Téntao de novo.';

  @override
  String get recipeAssistantPromptTooLong =>
      'A descrición da receita non pode superar os 3.000 caracteres.';

  @override
  String get recipeAssistantMissingInput =>
      'Escribe unha descrición ou anexa unha foto da receita.';

  @override
  String get recipeAssistantImageTooLarge =>
      'A imaxe é demasiado grande. Proba con outra foto ou fai unha nova.';

  @override
  String get recipeAssistantInvalidImage =>
      'Non se puido usar esa imaxe. Proba con outra foto.';

  @override
  String get recipeAssistantDailyLimitReached =>
      'Acadaches o límite diario do asistente. Volve mañá.';

  @override
  String get recipeAssistantTooFast =>
      'Agarda un momento antes de volver a usar o asistente.';

  @override
  String get recipeAssistantServiceAtCapacity =>
      'O asistente está saturado neste momento. Téntao máis tarde.';

  @override
  String get completeNutritionWithAssistant => 'Completar con IA';

  @override
  String get recipeAssistantNutritionSaved => 'Ficha nutricional completada';

  @override
  String get cookRecipeButton => 'Cociñar receita';

  @override
  String get continueCookingButton => 'Continuar cociñando';

  @override
  String get checkIngredientsStep => 'Comprobar ingredientes';

  @override
  String stepXofY(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get completeStepButton => 'Completar paso';

  @override
  String get finishCookingButton => 'Rematar';

  @override
  String get cookingPausedLabel => 'Pausada';

  @override
  String get cookingPauseTooltip => 'Pausar';

  @override
  String get cookingResumeTooltip => 'Continuar';

  @override
  String get finishCookingTitle => 'Rematar a receita?';

  @override
  String finishCookingConfirm(String title) {
    return 'Queres deixar de cociñar \"$title\"?';
  }

  @override
  String get cookingFinishedTitle => 'Receita rematada!';

  @override
  String get cookingFinishedMessage => 'Que che aproveite!';

  @override
  String get cookingInProgressTitle => 'Receita en curso';

  @override
  String cookingInProgressMessage(String title) {
    return 'Xa estás a cociñar \"$title\". Comezar unha receita nova?';
  }

  @override
  String get cookingReplaceButton => 'Nova receita';

  @override
  String get previousStep => 'Paso anterior';

  @override
  String get nextStep => 'Paso seguinte';

  @override
  String get minimize => 'Minimizar';

  @override
  String get expandCookingSession => 'Expandir';

  @override
  String get cookingNotificationChannelName => 'Sesión de cociña';

  @override
  String get cookingNotificationChannelDescription =>
      'Sesión de cociña en curso';
}
