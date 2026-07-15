// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'MealPlanner';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageBasque => 'Euskera';

  @override
  String get languageCatalan => 'Catalán';

  @override
  String get languageGalician => 'Gallego';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageSystemDefault => 'Idioma del sistema';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get add => 'Añadir';

  @override
  String get edit => 'Editar';

  @override
  String get remove => 'Quitar';

  @override
  String get clear => 'Limpiar';

  @override
  String get retry => 'Reintentar';

  @override
  String get understood => 'Entendido';

  @override
  String get optional => 'Opcional';

  @override
  String get requiredField => 'Obligatorio';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get navExplore => 'Explorar';

  @override
  String get navRecipeBook => 'Recetario';

  @override
  String get navPlanner => 'Planificador';

  @override
  String get navShopping => 'Compra';

  @override
  String get navProfile => 'Perfil';

  @override
  String get exploreUnavailableOffline =>
      'Explorar no está disponible sin conexión';

  @override
  String get loginTagline => 'Planifica tus comidas semanales';

  @override
  String get sessionExpiredMessage =>
      'Tu sesión ha caducado. Inicia sesión de nuevo.';

  @override
  String get supabaseNotConfigured =>
      'Supabase no configurado. Copia dart_defines.example.json a dart_defines.json y añade SUPABASE_URL / SUPABASE_ANON_KEY.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get enterEmail => 'Introduce tu email';

  @override
  String get enterPassword => 'Introduce tu contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get forgotPasswordLink => '¿Olvidaste tu contraseña?';

  @override
  String get noAccountRegister => '¿No tienes cuenta? Regístrate';

  @override
  String get createAccountTitle => 'Crear cuenta';

  @override
  String registerInApp(String appName) {
    return 'Regístrate en $appName';
  }

  @override
  String get usernameLabel => 'Nombre de usuario';

  @override
  String get enterUsername => 'Introduce tu nombre de usuario';

  @override
  String get minTwoCharacters => 'Mínimo 2 caracteres';

  @override
  String get invalidEmail => 'Email no válido';

  @override
  String get enterPasswordRegister => 'Introduce una contraseña';

  @override
  String get minSixCharacters => 'Mínimo 6 caracteres';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get confirmYourPassword => 'Confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get mustAcceptTerms =>
      'Debes aceptar los Términos y la Política de Privacidad';

  @override
  String get acceptTermsPrefix => 'Acepto los';

  @override
  String get termsLink => 'Términos';

  @override
  String get andThe => 'y la';

  @override
  String get privacyPolicyLink => 'Política de Privacidad';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get checkYourEmail => 'Revisa tu email';

  @override
  String confirmationEmailSent(String email) {
    return 'Hemos enviado un enlace de confirmación a $email. Confirma tu cuenta antes de iniciar sesión.';
  }

  @override
  String get goToSignIn => 'Ir al inicio de sesión';

  @override
  String get recoverPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordInstructions =>
      'Introduce tu email y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get backToSignIn => 'Volver al inicio de sesión';

  @override
  String get emailSent => 'Email enviado';

  @override
  String resetEmailSentIfExists(String email) {
    return 'Si existe una cuenta con $email, recibirás un enlace para restablecer tu contraseña.';
  }

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get recipeBookTitle => 'Recetario';

  @override
  String get cookingGlossaryTooltip => 'Glosario culinario';

  @override
  String get newRecipeTooltip => 'Nueva receta';

  @override
  String get searchByName => 'Buscar por nombre';

  @override
  String get noRecipesFoundForSearch =>
      'No se ha encontrado ninguna receta relacionada con la búsqueda. Créala tú mismo.';

  @override
  String get noRecipesYet => 'No hay recetas todavía';

  @override
  String get createFirstRecipe => 'Crear primera receta';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count raciones',
      one: '1 ración',
    );
    return '$_temp0';
  }

  @override
  String get deleteRecipeTitle => 'Eliminar receta';

  @override
  String deleteRecipeConfirm(String title) {
    return '¿Seguro que quieres eliminar \"$title\"?';
  }

  @override
  String get publishRecipeTitle => 'Publicar receta';

  @override
  String publishRecipeMessage(String appName) {
    return 'Esta receta será visible para todos los usuarios de $appName. Podrás despublicarla en cualquier momento.';
  }

  @override
  String get makeRecipePrivateTitle => 'Hacer receta privada';

  @override
  String get makeRecipePrivateMessageDetail =>
      'La receta dejará de ser visible en Explorar. Las valoraciones existentes se conservan.';

  @override
  String get makeRecipePrivateMessageForm =>
      'La receta dejará de ser visible en Explorar.';

  @override
  String get publish => 'Publicar';

  @override
  String get makePrivate => 'Hacer privada';

  @override
  String visibilityChangeError(String error) {
    return 'Error al cambiar visibilidad: $error';
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
  String get forkedRecipeTitle => 'Receta guardada de otro usuario';

  @override
  String get forkedRecipeCannotPublish =>
      'Las recetas forkeadas no se pueden publicar en Explorar.';

  @override
  String get publicRecipeSwitch => 'Receta pública';

  @override
  String get visibleInExplore => 'Visible en Explorar para todos los usuarios';

  @override
  String get onlyInRecipeBook => 'Solo visible en tu recetario';

  @override
  String get ingredientsSection => 'Ingredientes';

  @override
  String get noIngredients => 'Sin ingredientes';

  @override
  String get preparationSection => 'Elaboración';

  @override
  String get noSteps => 'Sin pasos';

  @override
  String get tipsSection => 'Consejos';

  @override
  String get nutritionPerServing => 'Nutrición (por ración)';

  @override
  String get calories => 'Calorías';

  @override
  String get protein => 'Proteínas';

  @override
  String get carbohydrates => 'Carbohidratos';

  @override
  String get fat => 'Grasas';

  @override
  String get fiber => 'Fibra';

  @override
  String nutritionChip(String label, String value) {
    return '$label: $value';
  }

  @override
  String get newRecipeTitle => 'Nueva receta';

  @override
  String get editRecipeTitle => 'Editar receta';

  @override
  String get photoRequiresConnection =>
      'Necesitas conexión para añadir o cambiar la foto de la receta';

  @override
  String get householdEditRequiresConnection =>
      'Sin conexión: la edición en modo hogar requiere conexión';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get servingsLabel => 'Raciones';

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
  String get tipsLabel => 'Consejos';

  @override
  String get tipsHint => 'Trucos, variaciones o notas útiles';

  @override
  String get visibleInExploreShort =>
      'Visible para todos los usuarios en Explorar';

  @override
  String get addIngredient => 'Añadir ingrediente';

  @override
  String get addStep => 'Añadir paso';

  @override
  String stepLabel(int number) {
    return 'Paso $number';
  }

  @override
  String get optionalStepPrefix => 'Opcional:';

  @override
  String get checkingImage => 'Comprobando imagen...';

  @override
  String get choosePhoto => 'Elegir foto';

  @override
  String get caloriesKcal => 'Calorías (kcal)';

  @override
  String get proteinG => 'Proteínas (g)';

  @override
  String get carbohydratesG => 'Carbohidratos (g)';

  @override
  String get fatG => 'Grasas (g)';

  @override
  String get fiberG => 'Fibra (g)';

  @override
  String get householdLoadError =>
      'No se pudo cargar tu hogar. Inténtalo de nuevo.';

  @override
  String get ingredientLabel => 'Ingrediente';

  @override
  String get removeIngredientTooltip => 'Eliminar ingrediente';

  @override
  String get quantityLabel => 'Cantidad';

  @override
  String get enterValidNumber => 'Introduce un número válido';

  @override
  String get unitLabel => 'Unidad';

  @override
  String get customUnitLabel => 'Unidad personalizada';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get toTaste => 'Al gusto';

  @override
  String get toTasteShoppingHint =>
      'No se añade a la lista de la compra (p. ej. sal, pimienta)';

  @override
  String get optionalIngredientHint =>
      'Puedes incluirlo o excluirlo en la ficha de la receta';

  @override
  String get clearTags => 'Limpiar';

  @override
  String get cookingGlossaryTitle => 'Glosario culinario';

  @override
  String get addTermTooltip => 'Añadir término';

  @override
  String get newGlossaryEntry => 'Nueva entrada';

  @override
  String get termLabel => 'Término';

  @override
  String get enterTerm => 'Introduce un término';

  @override
  String get definitionLabel => 'Definición';

  @override
  String get enterDefinition => 'Introduce una definición';

  @override
  String get duplicateGlossaryTerm => 'Ese término ya existe en el glosario';

  @override
  String get searchTermOrDefinition => 'Buscar término o definición';

  @override
  String get noGlossaryEntries => 'No hay entradas en el glosario';

  @override
  String get noGlossaryTermsFound => 'No se encontraron términos';

  @override
  String get deleteEntryTooltip => 'Eliminar entrada';

  @override
  String get deleteGlossaryEntryTitle => 'Eliminar entrada';

  @override
  String deleteGlossaryEntryConfirm(String term) {
    return '¿Quieres eliminar \"$term\" del glosario?';
  }

  @override
  String get autoTranslatedBadge => 'Traducido automáticamente';

  @override
  String get viewOriginal => 'Ver original';

  @override
  String get viewTranslation => 'Ver traducción';

  @override
  String get translatingRecipe => 'Traduciendo receta...';

  @override
  String get translationFailed => 'No se pudo traducir esta receta';

  @override
  String get plannerTitle => 'Planificador';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get today => 'Hoy';

  @override
  String get showRecipeBookTooltip => 'Mostrar recetario';

  @override
  String get removeMealTitle => 'Quitar comida';

  @override
  String removeMealConfirm(String title) {
    return '¿Quitar \"$title\" del planificador?';
  }

  @override
  String get dropHere => 'Soltar aquí';

  @override
  String get dragOrTap => 'Arrastra o pulsa';

  @override
  String get servingsTitle => 'Raciones';

  @override
  String get servingsCountLabel => 'Número de raciones';

  @override
  String get addTextTitle => 'Añadir texto';

  @override
  String get mealNameLabel => 'Nombre (ej. Pedido a domicilio)';

  @override
  String get enterMealName => 'Escribe un nombre para la comida';

  @override
  String get fewerServingsTooltip => 'Menos raciones';

  @override
  String get moreServingsTooltip => 'Más raciones';

  @override
  String get leftovers => 'Son sobras';

  @override
  String get leftoversShoppingHint =>
      'No se añadirán ingredientes a la lista de la compra';

  @override
  String get recipeBookPanel => 'Recetario';

  @override
  String get closeTooltip => 'Cerrar';

  @override
  String get searchHint => 'Buscar...';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get noRecipesCreateInBook =>
      'No tienes recetas. Créalas en el recetario.';

  @override
  String get chooseRecipe => 'Elegir receta';

  @override
  String get searchRecipeHint => 'Buscar receta...';

  @override
  String get addFreeText => 'Añadir texto libre';

  @override
  String get noRecipeExample => 'Sin receta (ej. pedido, fuera, etc.)';

  @override
  String get clearListTitle => 'Limpiar lista';

  @override
  String get clearListConfirm =>
      '¿Eliminar todos los ítems de la lista de la compra?';

  @override
  String get shoppingListTitle => 'Lista de la compra';

  @override
  String get shareListTooltip => 'Compartir lista';

  @override
  String get clearListTooltip => 'Limpiar lista';

  @override
  String shoppingListLoadError(String error) {
    return 'No se pudo cargar la lista: $error';
  }

  @override
  String get shoppingListEmpty => 'Tu lista está vacía';

  @override
  String get shoppingListEmptyHint =>
      'Añade recetas al planificador o ítems manualmente con el botón +.';

  @override
  String get addItemTooltip => 'Añadir ítem';

  @override
  String get deleteItemTitle => 'Eliminar ítem';

  @override
  String deleteItemConfirm(String name) {
    return '¿Eliminar «$name» de la lista?';
  }

  @override
  String get editItem => 'Editar ítem';

  @override
  String get addItem => 'Añadir ítem';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get othersCategory => 'Otros';

  @override
  String get feedTitle => 'Feed';

  @override
  String get mostRecent => 'Más reciente';

  @override
  String sortedBy(String label) {
    return 'Ordenado por: $label';
  }

  @override
  String get noRecipesWithTags => 'Sin recetas con estas etiquetas';

  @override
  String get feedEmpty => 'Tu feed está vacío';

  @override
  String get tryOtherTags => 'Prueba con otras etiquetas o quita el filtro.';

  @override
  String get followUsersHint =>
      'Sigue a otros usuarios desde sus perfiles para ver sus recetas públicas aquí.';

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get feedTooltip => 'Feed';

  @override
  String get searchPublicRecipes => 'Buscar recetas públicas';

  @override
  String get recent => 'Recientes';

  @override
  String get topRated => 'Mejor valoradas';

  @override
  String get noPublicRecipesYet => 'No hay recetas públicas todavía';

  @override
  String get publishToExploreHint =>
      'Publica una receta desde tu recetario para que otros la descubran.';

  @override
  String get publicProfileTitle => 'Perfil público';

  @override
  String publicRecipesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recetas públicas',
      one: '1 receta pública',
    );
    return '$_temp0';
  }

  @override
  String get unfollow => 'Dejar de seguir';

  @override
  String get follow => 'Seguir';

  @override
  String get noPublicRecipes => 'Sin recetas públicas';

  @override
  String get recipeSavedToBook => 'Receta guardada en tu recetario';

  @override
  String get saveToMyRecipeBookTooltip => 'Guardar en mi recetario';

  @override
  String get recipeCreatedBy => 'Receta creada por';

  @override
  String get you => 'ti';

  @override
  String get yourRating => 'Tu valoración';

  @override
  String get optionalIngredientSuffix => '(opcional)';

  @override
  String get saveToMyRecipeBook => 'Guardar en mi recetario';

  @override
  String get optionalIngredientsTitle => 'Ingredientes opcionales';

  @override
  String get optionalIngredientsMessage =>
      'Esta receta contiene ingredientes opcionales. Añádelos o elimínalos en tu receta.';

  @override
  String get editRecipe => 'Editar receta';

  @override
  String get inviteCodeCopied => 'Código copiado al portapapeles';

  @override
  String get regenerateCodeTitle => 'Regenerar código';

  @override
  String get regenerateCodeMessage =>
      'El código anterior dejará de funcionar. ¿Quieres generar uno nuevo?';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get codeRegenerated => 'Código regenerado';

  @override
  String get kickMemberTitle => 'Expulsar miembro';

  @override
  String kickMemberConfirm(String username) {
    return '¿Expulsar a $username del hogar?';
  }

  @override
  String get kick => 'Expulsar';

  @override
  String get leaveHouseholdTitle => 'Abandonar hogar';

  @override
  String get leaveHouseholdMessage =>
      'Perderás acceso al planificador y lista compartidos. ¿Continuar?';

  @override
  String get leave => 'Abandonar';

  @override
  String get myHouseholdTitle => 'Mi hogar';

  @override
  String get inviteCode => 'Código de invitación';

  @override
  String get copyTooltip => 'Copiar';

  @override
  String get members => 'Miembros';

  @override
  String get leaveHousehold => 'Abandonar hogar';

  @override
  String get noSharedHousehold => 'Sin hogar compartido';

  @override
  String get individualModeDescription =>
      'En modo individual usas tu propio planificador y lista de la compra. Crea un hogar o únete con un código para compartirlos con otros.';

  @override
  String get createHousehold => 'Crear hogar';

  @override
  String get joinWithCode => 'Unirse con código';

  @override
  String currentUserSuffix(String username) {
    return '$username (tú)';
  }

  @override
  String get admin => 'Administrador';

  @override
  String get member => 'Miembro';

  @override
  String get joinHouseholdTitle => 'Unirse a un hogar';

  @override
  String get joinCodeInstructions =>
      'Introduce el código de 6 caracteres que te ha compartido un miembro del hogar.';

  @override
  String get invalidInviteCode => 'Código de invitación no válido';

  @override
  String get alreadyMember => 'Ya perteneces a este hogar';

  @override
  String get codeMustBeSixChars => 'El código debe tener 6 caracteres';

  @override
  String get join => 'Unirse';

  @override
  String get createHouseholdDescription =>
      'Dale un nombre a tu hogar compartido. Podrás invitar a otros miembros con un código.';

  @override
  String get householdNameLabel => 'Nombre del hogar';

  @override
  String get enterName => 'Introduce un nombre';

  @override
  String get signOutTitle => 'Cerrar sesión';

  @override
  String get signOutConfirm => '¿Seguro que quieres cerrar sesión?';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get defaultUsername => 'Usuario';

  @override
  String get individualModeNoHousehold => 'Modo individual (sin hogar)';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get myHousehold => 'Mi hogar';

  @override
  String get createOrJoinHousehold => 'Crear o unirse a un hogar';

  @override
  String get termsAndConditions => 'Términos y Condiciones';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirmTitle => '¿Eliminar cuenta?';

  @override
  String get deleteAccountConfirmMessage =>
      'Esta acción es permanente. Se borrarán tu perfil, recetas, planificador personal y listas asociadas.';

  @override
  String get deletePermanently => 'Eliminar definitivamente';

  @override
  String get gdprRightToErasure => 'Derecho de supresión (RGPD)';

  @override
  String get deleteAccountBulletsIntro =>
      'Al eliminar tu cuenta se borrarán de forma permanente:';

  @override
  String get deleteBulletProfile => 'Tu perfil y avatar';

  @override
  String get deleteBulletRecipes => 'Todas tus recetas e imágenes asociadas';

  @override
  String get deleteBulletPlans =>
      'Tus planes y listas de la compra en modo individual';

  @override
  String get deleteBulletMembership => 'Tu membresía en hogares compartidos';

  @override
  String get soleAdminWarning =>
      'Si eres el único administrador de un hogar con otros miembros, debes transferir el rol de administrador o pedir a los miembros que abandonen el hogar antes de eliminar la cuenta.';

  @override
  String get deleteAcknowledgement =>
      'Entiendo que esta acción es irreversible y deseo eliminar mi cuenta.';

  @override
  String get typeDeleteToConfirm => 'Escribe ELIMINAR para confirmar';

  @override
  String accountEmail(String email) {
    return 'Cuenta: $email';
  }

  @override
  String get deleteMyAccount => 'Eliminar mi cuenta';

  @override
  String get gallery => 'Galería';

  @override
  String get camera => 'Cámara';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get couldNotOpenDocument => 'No se pudo abrir el documento';

  @override
  String get openInBrowser => 'Abrir en el navegador';

  @override
  String get noConnection => 'Sin conexión';

  @override
  String get offlineModeTitle => 'Modo sin conexión';

  @override
  String get offlineHouseholdMessage =>
      'Estás sin conexión. Puedes consultar la última versión guardada de tu recetario, planificador y lista de la compra, pero la edición no está disponible en modo hogar sin conexión (para evitar conflictos con otros miembros). Explorar tampoco está disponible.';

  @override
  String get offlineIndividualMessage =>
      'Estás sin conexión. Puedes consultar y editar tu recetario, planificador y lista de la compra; los cambios se sincronizarán al recuperar la conexión. La foto de recetas y la pestaña Explorar no están disponibles sin conexión.';

  @override
  String get imageNotAllowedTitle => 'Imagen no permitida';

  @override
  String get imageNotAllowedMessage =>
      'La imagen seleccionada contiene contenido adulto o explícito que no está permitido. Por favor, elige otra imagen.';

  @override
  String get imageCheckFailedTitle => 'No se pudo comprobar la imagen';

  @override
  String get imageCheckFailedRetry =>
      'No se pudo comprobar la imagen. Inténtalo de nuevo.';

  @override
  String get mealBreakfast => 'Desayuno';

  @override
  String get mealLunch => 'Comida';

  @override
  String get mealDinner => 'Cena';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mié';

  @override
  String get dayThu => 'Jue';

  @override
  String get dayFri => 'Vie';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get categoryMeatFish => 'Carnes y pescados';

  @override
  String get categoryVegetables => 'Verduras';

  @override
  String get categoryFruits => 'Frutas';

  @override
  String get categoryDairy => 'Lácteos';

  @override
  String get categoryGrains => 'Cereales';

  @override
  String get categoryLegumes => 'Legumbres';

  @override
  String get categorySpices => 'Especias';

  @override
  String get categoryOilsVinegars => 'Aceites y vinagres';

  @override
  String get categoryCanned => 'Conservas';

  @override
  String get categoryNuts => 'Frutos secos';

  @override
  String get categoryBeverages => 'Bebidas';

  @override
  String get categoryBaking => 'Repostería';

  @override
  String get categoryFrozen => 'Congelados';

  @override
  String get categorySauces => 'Salsas y condimentos';

  @override
  String get categoryOther => 'Otros';

  @override
  String get unitCustomOption => 'Otra';

  @override
  String get unitCount => 'unidad';

  @override
  String get unitPinch => 'pizca';

  @override
  String get unitTeaspoon => 'cucharadita';

  @override
  String get unitTablespoon => 'cucharada';

  @override
  String get unitGlass => 'vaso';

  @override
  String get unitCup => 'taza';

  @override
  String get unitHandful => 'puñado';

  @override
  String get unitLeaf => 'hoja';

  @override
  String get unitClove => 'diente';

  @override
  String get unitSplash => 'chorrito';

  @override
  String get unitSlice => 'rebanada';

  @override
  String get unitSprig => 'rama';

  @override
  String get unitPiece => 'trozo';

  @override
  String get unitFillet => 'filete';

  @override
  String get unitRound => 'rodaja';

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
  String get tagMainCourse => 'plato principal';

  @override
  String get tagDessert => 'postre';

  @override
  String get tagVegetarian => 'vegetariana';

  @override
  String get tagVegan => 'vegano';

  @override
  String get tagPescatarian => 'pescetariana';

  @override
  String get tagGlutenFree => 'sin gluten';

  @override
  String get tagLactoseFree => 'sin lactosa';

  @override
  String get tagEggFree => 'sin huevo';

  @override
  String get tagNutFree => 'sin frutos secos';

  @override
  String get tagSoyFree => 'sin soja';

  @override
  String get tagShellfishFree => 'sin marisco';

  @override
  String get tagSugarFree => 'sin azúcar';

  @override
  String get tagHighProtein => 'alto en proteínas';

  @override
  String get tagLowCalorie => 'baja en calorías';

  @override
  String get tagLowCarb => 'baja en carbohidratos';

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
  String get tagFreezerFriendly => 'para congelar';

  @override
  String get tagSpicy => 'picante';

  @override
  String get tagKidFriendly => 'para niños';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingPrevious => 'Anterior';

  @override
  String get onboardingFinish => 'Finalizar';

  @override
  String get onboardingStep0Title => '¡Bienvenido/a a Recetea!';

  @override
  String get onboardingStep0Body =>
      'Te mostramos cómo funciona la app en un minuto. Puedes omitir este tutorial cuando quieras.';

  @override
  String get onboardingStep1Title => 'Planificador semanal';

  @override
  String get onboardingStep1Body =>
      'Ves todos los días con sus comidas. Las flechas ‹ › cambian de semana. El día de hoy aparece resaltado en verde.';

  @override
  String get onboardingStep2Title => 'Añade comidas al plan';

  @override
  String get onboardingStep2Body =>
      'Toca un slot vacío para asignar una receta. También puedes pulsar el icono de libro para abrir el recetario lateral y arrastrar recetas directamente al día.';

  @override
  String get onboardingStep3Title => 'Tu recetario';

  @override
  String get onboardingStep3Body =>
      'Todas tus recetas en un vistazo. La lupa busca por nombre y el icono de libro abre el glosario culinario.';

  @override
  String get onboardingStep4Title => 'Crea una receta';

  @override
  String get onboardingStep4Body =>
      'El botón + abre el formulario: foto, ingredientes con cantidades, pasos de elaboración, nutrición y etiquetas. Puedes publicarla para que otros la descubran.';

  @override
  String get onboardingStep5Title => 'Lista de la compra';

  @override
  String get onboardingStep5Body =>
      'Cuando planificas comidas, los ingredientes aparecen aquí automáticamente agrupados por categoría. Marca los ítems al comprarlos.';

  @override
  String get onboardingStep6Title => 'Añade ingredientes';

  @override
  String get onboardingStep6Body =>
      'Pulsa el botón + para añadir ingredientes manualmente a tu lista de la compra.';

  @override
  String get onboardingStep7Title => 'Comparte tu lista';

  @override
  String get onboardingStep7Body =>
      'El icono de compartir genera un texto listo para enviar por WhatsApp u otras apps.';

  @override
  String get onboardingStep8Title => 'Descubre la comunidad';

  @override
  String get onboardingStep8Body =>
      'Busca recetas de otros usuarios por nombre o etiquetas. Valóralas y guárdalas en tu recetario.';

  @override
  String get onboardingStep9Title => 'Tu feed de cocineros';

  @override
  String get onboardingStep9Body =>
      'Sigue a tus cocineros favoritos desde su perfil y consulta sus últimas recetas pulsando el botón del feed.';

  @override
  String get onboardingStep10Title => 'Tu perfil y hogar';

  @override
  String get onboardingStep10Body =>
      'Edita tu nombre y foto. En la sección Mi hogar puedes planificar con tu familia en tiempo real. Desde aquí también cambias el idioma y el modo oscuro.';

  @override
  String get createRecipeOptionsTitle => 'Crear receta';

  @override
  String get createRecipeManual => 'Crear manualmente';

  @override
  String get createRecipeManualSubtitle =>
      'Rellena tú mismo todos los campos de la receta';

  @override
  String get createRecipeWithAssistant => 'Crear con asistente de IA';

  @override
  String get createRecipeWithAssistantSubtitle =>
      'Describe el plato y la IA elaborará la ficha';

  @override
  String get recipeAssistantTitle => 'Asistente de recetas';

  @override
  String get recipeAssistantDescription =>
      'Describe el plato que quieres crear: solo el nombre o una receta detallada con ingredientes y pasos.';

  @override
  String get recipeAssistantPromptHint =>
      'Ej.: tortilla de patatas para 4 personas con cebolla...';

  @override
  String get recipeAssistantGenerate => 'Generar receta';

  @override
  String get recipeAssistantGenerating => 'Generando...';

  @override
  String get recipeAssistantBlockingRecipe =>
      'El asistente está elaborando tu receta…';

  @override
  String get recipeAssistantBlockingNutrition =>
      'Calculando información nutricional…';

  @override
  String get recipeAssistantNotRecipeRequest =>
      'Solo puedo ayudarte a elaborar recetas. Describe un plato o una receta.';

  @override
  String get recipeAssistantRateLimited =>
      'Límite de uso alcanzado. Inténtalo de nuevo más tarde.';

  @override
  String get recipeAssistantFailed =>
      'No se pudo generar la respuesta. Inténtalo de nuevo.';

  @override
  String get recipeAssistantOffline =>
      'Se requiere conexión a internet para usar el asistente.';

  @override
  String get recipeAssistantNotConfigured =>
      'El asistente de IA no está configurado todavía.';

  @override
  String get completeNutritionWithAssistant => 'Completar con IA';

  @override
  String get recipeAssistantNutritionSaved => 'Ficha nutricional completada';
}
