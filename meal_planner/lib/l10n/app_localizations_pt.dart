// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Böl';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageBasque => 'Basco';

  @override
  String get languageCatalan => 'Catalão';

  @override
  String get languageGalician => 'Galego';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSystemDefault => 'Idioma do sistema';

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
  String get add => 'Adicionar';

  @override
  String get edit => 'Editar';

  @override
  String get remove => 'Remover';

  @override
  String get clear => 'Limpar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get understood => 'Entendido';

  @override
  String get optional => 'Opcional';

  @override
  String get requiredField => 'Obrigatório';

  @override
  String errorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get navExplore => 'Explorar';

  @override
  String get navRecipeBook => 'Receitas';

  @override
  String get navPlanner => 'Plano';

  @override
  String get navShopping => 'Compras';

  @override
  String get navProfile => 'Perfil';

  @override
  String get exploreUnavailableOffline =>
      'Explorar não está disponível offline';

  @override
  String get loginTagline => 'Planeie as suas refeições semanais';

  @override
  String get sessionExpiredMessage =>
      'A sua sessão expirou. Inicie sessão novamente.';

  @override
  String get supabaseNotConfigured =>
      'Supabase não configurado. Copie dart_defines.example.json para dart_defines.json e adicione SUPABASE_URL / SUPABASE_ANON_KEY.';

  @override
  String get captchaRequired => 'Conclua a verificação';

  @override
  String get captchaFailed => 'A verificação falhou. Tente novamente.';

  @override
  String get turnstileNotConfigured =>
      'A verificação não está disponível de momento. Tente novamente mais tarde.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Palavra-passe';

  @override
  String get enterEmail => 'Introduza o seu email';

  @override
  String get enterPassword => 'Introduza a sua palavra-passe';

  @override
  String get signIn => 'Iniciar sessão';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get googleSignInFailed =>
      'Não foi possível iniciar sessão com o Google. Tente novamente.';

  @override
  String get continueWithApple => 'Continuar com Apple';

  @override
  String get forgotPasswordLink => 'Esqueceu-se da palavra-passe?';

  @override
  String get noAccountRegister => 'Não tem conta? Registe-se';

  @override
  String get createAccountTitle => 'Criar conta';

  @override
  String registerInApp(String appName) {
    return 'Registe-se em $appName';
  }

  @override
  String get usernameLabel => 'Nome de utilizador';

  @override
  String get enterUsername => 'Introduza o seu nome de utilizador';

  @override
  String get minTwoCharacters => 'Mínimo 2 caracteres';

  @override
  String get invalidEmail => 'Email inválido';

  @override
  String get enterPasswordRegister => 'Introduza uma palavra-passe';

  @override
  String get minSixCharacters => 'Mínimo 6 caracteres';

  @override
  String get passwordTooShort =>
      'A palavra-passe deve ter pelo menos 8 caracteres';

  @override
  String get passwordTooWeak =>
      'A palavra-passe deve incluir uma minúscula, uma maiúscula, um número e um símbolo';

  @override
  String get confirmPasswordLabel => 'Confirmar palavra-passe';

  @override
  String get confirmYourPassword => 'Confirme a sua palavra-passe';

  @override
  String get passwordsDoNotMatch => 'As palavras-passe não coincidem';

  @override
  String get changePasswordTitle => 'Alterar palavra-passe';

  @override
  String get currentPasswordLabel => 'Palavra-passe atual';

  @override
  String get newPasswordLabel => 'Nova palavra-passe';

  @override
  String get enterCurrentPassword => 'Introduza a palavra-passe atual';

  @override
  String get passwordChanged => 'Palavra-passe atualizada';

  @override
  String get currentPasswordIncorrect => 'A palavra-passe atual está incorreta';

  @override
  String get passwordSameAsCurrent =>
      'A nova palavra-passe deve ser diferente da atual';

  @override
  String get mustAcceptTerms =>
      'Deve aceitar os Termos e a Política de Privacidade';

  @override
  String get acceptTermsPrefix => 'Aceito os';

  @override
  String get termsLink => 'Termos';

  @override
  String get andThe => 'e a';

  @override
  String get privacyPolicyLink => 'Política de Privacidade';

  @override
  String get alreadyHaveAccount => 'Já tem conta? Inicie sessão';

  @override
  String get checkYourEmail => 'Verifique o seu email';

  @override
  String confirmationEmailSent(String email) {
    return 'Enviámos uma ligação de confirmação para $email. Confirme a sua conta antes de iniciar sessão.';
  }

  @override
  String get goToSignIn => 'Ir para início de sessão';

  @override
  String get recoverPasswordTitle => 'Recuperar palavra-passe';

  @override
  String get forgotPasswordInstructions =>
      'Introduza o seu email e enviaremos uma ligação para repor a palavra-passe.';

  @override
  String get sendResetLink => 'Enviar ligação';

  @override
  String get backToSignIn => 'Voltar ao início de sessão';

  @override
  String get emailSent => 'Email enviado';

  @override
  String resetEmailSentIfExists(String email) {
    return 'Se existir uma conta com $email, receberá uma ligação para repor a palavra-passe.';
  }

  @override
  String get showPassword => 'Mostrar palavra-passe';

  @override
  String get hidePassword => 'Ocultar palavra-passe';

  @override
  String get recipeBookTitle => 'Livro de receitas';

  @override
  String get cookingGlossaryTooltip => 'Glossário culinário';

  @override
  String get newRecipeTooltip => 'Nova receita';

  @override
  String get searchByName => 'Pesquisar por nome';

  @override
  String get noRecipesFoundForSearch =>
      'Nenhuma receita corresponde à pesquisa. Crie-a você mesmo.';

  @override
  String get noRecipesYet => 'Ainda não há receitas';

  @override
  String get sortAlphabetical => 'Alfabético';

  @override
  String get alphabeticalOrder => 'Ordem alfabética';

  @override
  String get favoritesFilter => 'Favoritos';

  @override
  String get favoriteRecipeTooltip => 'Adicionar aos favoritos';

  @override
  String get unfavoriteRecipeTooltip => 'Remover dos favoritos';

  @override
  String get noFavoriteRecipes =>
      'Ainda não há receitas favoritas. Marque-as com a estrela para as encontrar aqui.';

  @override
  String get createFirstRecipe => 'Criar primeira receita';

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses',
      one: '1 dose',
    );
    return '$_temp0';
  }

  @override
  String servingsCountShort(int count) {
    return '$count d.';
  }

  @override
  String get deleteRecipeTitle => 'Eliminar receita';

  @override
  String deleteRecipeConfirm(String title) {
    return 'Tem a certeza de que quer eliminar \"$title\"?';
  }

  @override
  String get publishRecipeTitle => 'Publicar receita';

  @override
  String publishRecipeMessage(String appName) {
    return 'Esta receita ficará visível para todos os utilizadores de $appName. Pode despublicá-la a qualquer momento.';
  }

  @override
  String get makeRecipePrivateTitle => 'Tornar receita privada';

  @override
  String get makeRecipePrivateMessageDetail =>
      'A receita deixará de ser visível em Explorar. As avaliações existentes serão mantidas.';

  @override
  String get makeRecipePrivateMessageForm =>
      'A receita deixará de ser visível em Explorar.';

  @override
  String get publish => 'Publicar';

  @override
  String get makePrivate => 'Tornar privada';

  @override
  String visibilityChangeError(String error) {
    return 'Erro ao alterar visibilidade: $error';
  }

  @override
  String get publicBadge => 'Pública';

  @override
  String get privateBadge => 'Privada';

  @override
  String prepTimeMin(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String cookTimeMin(int minutes) {
    return 'Cozedura: $minutes min';
  }

  @override
  String get forkedRecipeTitle => 'Receita guardada de outro utilizador';

  @override
  String get forkedRecipeCannotPublish =>
      'Receitas forkeadas não podem ser publicadas em Explorar.';

  @override
  String get publicRecipeSwitch => 'Receita pública';

  @override
  String get visibleInExplore =>
      'Visível em Explorar para todos os utilizadores';

  @override
  String get onlyInRecipeBook => 'Visível apenas no seu livro de receitas';

  @override
  String get ingredientsSection => 'Ingredientes';

  @override
  String get noIngredients => 'Sem ingredientes';

  @override
  String get preparationSection => 'Preparação';

  @override
  String get noSteps => 'Sem passos';

  @override
  String get tipsSection => 'Dicas';

  @override
  String get nutritionPerServing => 'Nutrição (por dose)';

  @override
  String get calories => 'Calorias';

  @override
  String get protein => 'Proteínas';

  @override
  String get carbohydrates => 'Hidratos de carbono';

  @override
  String get fat => 'Gorduras';

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
      'Precisa de ligação para adicionar ou alterar a foto da receita';

  @override
  String get householdEditRequiresConnection =>
      'Offline: a edição em modo casa requer ligação';

  @override
  String get nameLabel => 'Nome';

  @override
  String get servingsLabel => 'Doses';

  @override
  String get minOneServing => 'Mínimo 1';

  @override
  String get prepMinLabel => 'Prep (min)';

  @override
  String get cookMinLabel => 'Cozedura (min)';

  @override
  String get tagsSection => 'Etiquetas';

  @override
  String get customTagLabel => 'Etiqueta personalizada';

  @override
  String get clearAllTags => 'Remover todas';

  @override
  String get stepsSection => 'Passos';

  @override
  String get tipsLabel => 'Dicas';

  @override
  String get tipsHint => 'Truques, variações ou notas úteis';

  @override
  String get visibleInExploreShort =>
      'Visível para todos os utilizadores em Explorar';

  @override
  String get addIngredient => 'Adicionar ingrediente';

  @override
  String get addStep => 'Adicionar passo';

  @override
  String stepLabel(int number) {
    return 'Passo $number';
  }

  @override
  String get optionalStepPrefix => 'Opcional:';

  @override
  String get checkingImage => 'A verificar imagem...';

  @override
  String get choosePhoto => 'Escolher foto';

  @override
  String get caloriesKcal => 'Calorias (kcal)';

  @override
  String get proteinG => 'Proteínas (g)';

  @override
  String get carbohydratesG => 'Hidratos de carbono (g)';

  @override
  String get fatG => 'Gorduras (g)';

  @override
  String get fiberG => 'Fibra (g)';

  @override
  String get householdLoadError =>
      'Não foi possível carregar a sua casa. Tente novamente.';

  @override
  String get ingredientLabel => 'Ingrediente';

  @override
  String get removeIngredientTooltip => 'Remover ingrediente';

  @override
  String get quantityLabel => 'Quantidade';

  @override
  String get enterValidNumber => 'Introduza um número válido';

  @override
  String get unitLabel => 'Unidade';

  @override
  String get customUnitLabel => 'Unidade personalizada';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get toTaste => 'A gosto';

  @override
  String get toTasteShoppingHint =>
      'Não é adicionado à lista de compras (p. ex. sal, pimenta)';

  @override
  String get optionalIngredientHint =>
      'Pode incluí-lo ou excluí-lo na ficha da receita';

  @override
  String get clearTags => 'Limpar';

  @override
  String get cookingGlossaryTitle => 'Glossário culinário';

  @override
  String get addTermTooltip => 'Adicionar termo';

  @override
  String get newGlossaryEntry => 'Nova entrada';

  @override
  String get termLabel => 'Termo';

  @override
  String get enterTerm => 'Introduza um termo';

  @override
  String get definitionLabel => 'Definição';

  @override
  String get enterDefinition => 'Introduza uma definição';

  @override
  String get duplicateGlossaryTerm => 'Esse termo já existe no glossário';

  @override
  String get searchTermOrDefinition => 'Pesquisar termo ou definição';

  @override
  String get noGlossaryEntries => 'Não há entradas no glossário';

  @override
  String get noGlossaryTermsFound => 'Nenhum termo encontrado';

  @override
  String get deleteEntryTooltip => 'Eliminar entrada';

  @override
  String get deleteGlossaryEntryTitle => 'Eliminar entrada';

  @override
  String deleteGlossaryEntryConfirm(String term) {
    return 'Quer remover \"$term\" do glossário?';
  }

  @override
  String get autoTranslatedBadge => 'Traduzido automaticamente';

  @override
  String get viewOriginal => 'Ver original';

  @override
  String get viewTranslation => 'Ver tradução';

  @override
  String get translatingRecipe => 'A traduzir receita...';

  @override
  String get translationFailed => 'Não foi possível traduzir esta receita';

  @override
  String get plannerTitle => 'Planificador';

  @override
  String get sharePlannerTooltip => 'Partilhar planificador';

  @override
  String get copyPlannerTooltip => 'Copiar planificador';

  @override
  String get plannerCopied =>
      'Planificador copiado para a área de transferência';

  @override
  String get plannerShareLeftoverLabel => 'sobras';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get today => 'Hoje';

  @override
  String get showRecipeBookTooltip => 'Mostrar livro de receitas';

  @override
  String get removeMealTitle => 'Remover refeição';

  @override
  String removeMealConfirm(String title) {
    return 'Remover \"$title\" do planificador?';
  }

  @override
  String get dropHere => 'Largar aqui';

  @override
  String get dragOrTap => 'Arraste ou toque';

  @override
  String get servingsTitle => 'Doses';

  @override
  String get servingsCountLabel => 'Número de doses';

  @override
  String get addTextTitle => 'Adicionar texto';

  @override
  String get mealNameLabel => 'Nome (p. ex. Entrega ao domicílio)';

  @override
  String get enterMealName => 'Escreva um nome para a refeição';

  @override
  String get fewerServingsTooltip => 'Menos doses';

  @override
  String get moreServingsTooltip => 'Mais doses';

  @override
  String get leftovers => 'São sobras';

  @override
  String get leftoversShoppingHint =>
      'Os ingredientes não serão adicionados à lista de compras';

  @override
  String get pastMealPlanTitle => 'Refeição passada';

  @override
  String get pastMealPlanMessage =>
      'Está a planear uma refeição para um dia já passado. Os ingredientes não serão adicionados à lista de compras.';

  @override
  String get recipeBookPanel => 'Livro de receitas';

  @override
  String get closeTooltip => 'Fechar';

  @override
  String get searchHint => 'Pesquisar...';

  @override
  String get noResults => 'Sem resultados';

  @override
  String get noRecipesCreateInBook =>
      'Não tem receitas. Crie-as no livro de receitas.';

  @override
  String get chooseRecipe => 'Escolher receita';

  @override
  String get searchRecipeHint => 'Pesquisar receita...';

  @override
  String get addFreeText => 'Adicionar texto livre';

  @override
  String get noRecipeExample => 'Sem receita (p. ex. entrega, fora, etc.)';

  @override
  String get clearListTitle => 'Limpar lista';

  @override
  String get clearListConfirm => 'Eliminar todos os itens da lista de compras?';

  @override
  String get shoppingListTitle => 'Lista de compras';

  @override
  String get shareListTooltip => 'Partilhar lista';

  @override
  String get shareRecipeTooltip => 'Partilhar receita';

  @override
  String shareRecipeMessage(String title, String url) {
    return '$url\n\nVê esta receita no Böl: $title';
  }

  @override
  String get shareLinkExpired => 'Esta hiperligação expirou';

  @override
  String get shareLinkInvalid => 'Esta hiperligação não é válida';

  @override
  String get revokeShareLink => 'Revogar link de partilha';

  @override
  String get revokeShareLinkConfirm =>
      'Isto invalidará o link privado atual. Quem tiver o link deixará de poder abrir esta receita.';

  @override
  String get revoke => 'Revogar';

  @override
  String get shareLinkRevoked => 'Link revogado';

  @override
  String get noActiveShareLink => 'Não há nenhum link ativo para revogar';

  @override
  String get clearListTooltip => 'Limpar lista';

  @override
  String shoppingListLoadError(String error) {
    return 'Não foi possível carregar a lista: $error';
  }

  @override
  String get shoppingListEmpty => 'A sua lista está vazia';

  @override
  String get shoppingListEmptyHint =>
      'Adicione receitas ao planificador ou itens manualmente com o botão +.';

  @override
  String get addItemTooltip => 'Adicionar item';

  @override
  String get deleteItemTitle => 'Eliminar item';

  @override
  String deleteItemConfirm(String name) {
    return 'Remover «$name» da lista?';
  }

  @override
  String get editItem => 'Editar item';

  @override
  String get addItem => 'Adicionar item';

  @override
  String get nameRequired => 'O nome é obrigatório';

  @override
  String get othersCategory => 'Outros';

  @override
  String get feedTitle => 'Seguidos';

  @override
  String get mostRecent => 'Mais recentes';

  @override
  String sortedBy(String label) {
    return 'Ordenado por: $label';
  }

  @override
  String get noRecipesWithTags => 'Sem receitas com estas etiquetas';

  @override
  String get feedEmpty => 'Não há receitas de utilizadores que segue';

  @override
  String get tryOtherTags => 'Experimente outras etiquetas ou remova o filtro.';

  @override
  String get followUsersHint =>
      'Siga outros utilizadores a partir dos seus perfis para ver as receitas públicas aqui.';

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get feedTooltip => 'Seguidos';

  @override
  String get searchPublicRecipes => 'Pesquisar receitas públicas';

  @override
  String get recent => 'Recentes';

  @override
  String get topRated => 'Melhor avaliadas';

  @override
  String get noPublicRecipesYet => 'Ainda não há receitas públicas';

  @override
  String get publishToExploreHint =>
      'Publique uma receita a partir do seu livro de receitas para que outros a descubram.';

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
  String get noPublicRecipes => 'Sem receitas públicas';

  @override
  String get recipeSavedToBook => 'Receita guardada no seu livro de receitas';

  @override
  String get saveToMyRecipeBookTooltip => 'Guardar no meu livro de receitas';

  @override
  String get recipeCreatedBy => 'Receita criada por';

  @override
  String get recipeCreatedByName => 'Criada por';

  @override
  String get you => 'você';

  @override
  String get yourRating => 'A sua avaliação';

  @override
  String get optionalIngredientSuffix => '(opcional)';

  @override
  String get saveToMyRecipeBook => 'Guardar no meu livro de receitas';

  @override
  String get optionalIngredientsTitle => 'Ingredientes opcionais';

  @override
  String get optionalIngredientsMessage =>
      'Esta receita contém ingredientes opcionais. Adicione-os ou remova-os na sua receita.';

  @override
  String get editRecipe => 'Editar receita';

  @override
  String get inviteCodeCopied => 'Código copiado para a área de transferência';

  @override
  String get regenerateCodeTitle => 'Regenerar código';

  @override
  String get regenerateCodeMessage =>
      'O código anterior deixará de funcionar. Quer gerar um novo?';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get codeRegenerated => 'Código regenerado';

  @override
  String get kickMemberTitle => 'Expulsar membro';

  @override
  String kickMemberConfirm(String username) {
    return 'Expulsar $username da casa?';
  }

  @override
  String get kick => 'Expulsar';

  @override
  String get leaveHouseholdTitle => 'Abandonar casa';

  @override
  String get leaveHouseholdMessage =>
      'O planificador e a lista da casa serão copiados para o seu modo individual (semana atual e futuras). Continuar?';

  @override
  String get leave => 'Abandonar';

  @override
  String get myHouseholdTitle => 'A minha casa';

  @override
  String get inviteCode => 'Código de convite';

  @override
  String get inviteViaWhatsApp => 'Convidar via WhatsApp';

  @override
  String inviteWhatsAppHouseholdMessage(String appName, String url) {
    return 'Olá! Junta-te à minha casa no $appName:\n$url';
  }

  @override
  String get copyTooltip => 'Copiar';

  @override
  String get members => 'Membros';

  @override
  String get leaveHousehold => 'Abandonar casa';

  @override
  String get noSharedHousehold => 'Sem casa partilhada';

  @override
  String get individualModeDescription =>
      'Em modo individual usa o seu próprio planificador e lista de compras. Crie uma casa ou junte-se com um código para partilhar com outros.';

  @override
  String get createHousehold => 'Criar casa';

  @override
  String get joinWithCode => 'Juntar-se com código';

  @override
  String currentUserSuffix(String username) {
    return '$username (você)';
  }

  @override
  String get admin => 'Administrador';

  @override
  String get member => 'Membro';

  @override
  String get joinHouseholdTitle => 'Juntar-se a uma casa';

  @override
  String get joinCodeInstructions =>
      'Introduza o código de 6 ou 8 caracteres partilhado por um membro da casa.';

  @override
  String get invalidInviteCode => 'Código de convite inválido';

  @override
  String get alreadyMember => 'Já pertence a esta casa';

  @override
  String get tooManyAttempts =>
      'Muitas tentativas. Tente novamente em alguns minutos.';

  @override
  String get pleaseWaitMoment =>
      'Aguarde um momento antes de tentar novamente.';

  @override
  String get genericErrorMessage => 'Algo correu mal. Tente novamente.';

  @override
  String get codeMustBeSixOrEightChars => 'O código deve ter 6 ou 8 caracteres';

  @override
  String get join => 'Juntar-se';

  @override
  String get createHouseholdDescription =>
      'Dê um nome à sua casa partilhada. Poderá convidar outros membros com um código.';

  @override
  String get householdNameLabel => 'Nome da casa';

  @override
  String get enterName => 'Introduza um nome';

  @override
  String get signOutTitle => 'Terminar sessão';

  @override
  String get signOutConfirm => 'Tem a certeza de que quer terminar sessão?';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get defaultUsername => 'Utilizador';

  @override
  String get individualModeNoHousehold => 'Modo individual (sem casa)';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get myHousehold => 'A minha casa';

  @override
  String get createOrJoinHousehold => 'Criar ou juntar-se a uma casa';

  @override
  String get termsAndConditions => 'Termos e Condições';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get rateYourApp => 'Avaliar a app';

  @override
  String get rateYourAppSubtitle => 'Deixe uma avaliação na loja';

  @override
  String get rateAppUnavailable =>
      'A avaliação não está disponível neste dispositivo neste momento.';

  @override
  String get sendFeedback => 'Enviar feedback';

  @override
  String get adminControlPanel => 'Painel de controlo';

  @override
  String get adminFeedbackTitle => 'Feedback';

  @override
  String get feedbackWhatAbout => 'O que nos quer contar?';

  @override
  String get feedbackCategoryIssue => 'Problema ou erro';

  @override
  String get feedbackCategoryFeature => 'Sugestão de funcionalidade';

  @override
  String get feedbackCategoryOther => 'Outro';

  @override
  String get feedbackTypeLabel => 'Tipo';

  @override
  String get feedbackYourMessage => 'A sua mensagem';

  @override
  String get feedbackMessageHint =>
      'Descreva o problema ou a ideia com o maior detalhe possível…';

  @override
  String get feedbackMinCharsHint => 'Mínimo 10 caracteres';

  @override
  String get feedbackMessageTooShort =>
      'A mensagem deve ter pelo menos 10 caracteres.';

  @override
  String get feedbackSentSuccess =>
      'Obrigado pela mensagem. Vamos analisá-la para melhorar a app.';

  @override
  String get feedbackSendError =>
      'Não foi possível enviar o feedback. Tente novamente.';

  @override
  String get feedbackCategoryFilter => 'Categoria';

  @override
  String get feedbackStatusFilter => 'Estado';

  @override
  String get feedbackFilterAll => 'Todos';

  @override
  String get feedbackStatusPending => 'Pendente';

  @override
  String get feedbackStatusResolved => 'Resolvido';

  @override
  String get feedbackStatusIgnored => 'Ignorado';

  @override
  String get feedbackMarkResolved => 'Marcar como resolvido';

  @override
  String get feedbackMarkIgnored => 'Marcar como ignorado';

  @override
  String get feedbackMarkedResolved => 'Feedback marcado como resolvido.';

  @override
  String get feedbackMarkedIgnored => 'Feedback marcado como ignorado.';

  @override
  String get feedbackStatusUpdateError =>
      'Não foi possível atualizar o estado do feedback.';

  @override
  String get adminFeedbackEmpty => 'Não há feedback com estes filtros.';

  @override
  String get adminFeedbackLoadError => 'Não foi possível carregar o feedback.';

  @override
  String get back => 'Voltar';

  @override
  String get send => 'Enviar';

  @override
  String get signOut => 'Terminar sessão';

  @override
  String get deleteAccount => 'Eliminar conta';

  @override
  String get deleteAccountConfirmTitle => 'Eliminar conta?';

  @override
  String get deleteAccountConfirmMessage =>
      'Esta ação é permanente. Serão eliminados o seu perfil, receitas, planificador pessoal e listas associadas.';

  @override
  String get deletePermanently => 'Eliminar definitivamente';

  @override
  String get gdprRightToErasure => 'Direito ao apagamento (RGPD)';

  @override
  String get deleteAccountBulletsIntro =>
      'Ao eliminar a sua conta serão apagados permanentemente:';

  @override
  String get deleteBulletProfile => 'O seu perfil e avatar';

  @override
  String get deleteBulletRecipes =>
      'Todas as suas receitas e imagens associadas';

  @override
  String get deleteBulletPlans =>
      'Os seus planos e listas de compras em modo individual';

  @override
  String get deleteBulletMembership =>
      'A sua participação em casas partilhadas';

  @override
  String get soleAdminWarning =>
      'Se for o único administrador de uma casa com outros membros, transfira o papel de administrador ou peça aos membros que abandonem a casa antes de eliminar a conta.';

  @override
  String get deleteAcknowledgement =>
      'Compreendo que esta ação é irreversível e desejo eliminar a minha conta.';

  @override
  String get typeDeleteToConfirm => 'Escreva ELIMINAR para confirmar';

  @override
  String accountEmail(String email) {
    return 'Conta: $email';
  }

  @override
  String get deleteMyAccount => 'Eliminar a minha conta';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Câmara';

  @override
  String get changePhoto => 'Alterar foto';

  @override
  String get removeProfilePhoto => 'Remover foto';

  @override
  String get couldNotOpenDocument => 'Não foi possível abrir o documento';

  @override
  String get openInBrowser => 'Abrir no navegador';

  @override
  String get noConnection => 'Sem ligação';

  @override
  String get offlineModeTitle => 'Modo offline';

  @override
  String get offlineHouseholdMessage =>
      'Está offline. Pode consultar a última versão guardada do seu livro de receitas, planificador e lista de compras, mas a edição não está disponível em modo casa offline. Explorar também não está disponível.';

  @override
  String get offlineIndividualMessage =>
      'Está offline. Pode consultar e editar o seu livro de receitas, planificador e lista de compras; as alterações serão sincronizadas ao recuperar a ligação. A foto de receitas e o separador Explorar não estão disponíveis offline.';

  @override
  String get imageNotAllowedTitle => 'Imagem não permitida';

  @override
  String get imageNotAllowedMessage =>
      'A imagem selecionada contém conteúdo adulto ou explícito que não é permitido. Escolha outra imagem.';

  @override
  String get imageCheckFailedTitle => 'Não foi possível verificar a imagem';

  @override
  String get imageCheckFailedRetry =>
      'Não foi possível verificar a imagem. Tente novamente.';

  @override
  String get mealBreakfast => 'Peq. almoço';

  @override
  String get mealLunch => 'Almoço';

  @override
  String get mealDinner => 'Jantar';

  @override
  String get dayMon => 'Seg';

  @override
  String get dayTue => 'Ter';

  @override
  String get dayWed => 'Qua';

  @override
  String get dayThu => 'Qui';

  @override
  String get dayFri => 'Sex';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get categoryMeatFish => 'Carnes e peixes';

  @override
  String get categoryVegetables => 'Legumes';

  @override
  String get categoryFruits => 'Frutas';

  @override
  String get categoryDairy => 'Laticínios';

  @override
  String get categoryGrains => 'Cereais';

  @override
  String get categoryLegumes => 'Leguminosas';

  @override
  String get categorySpices => 'Especiarias';

  @override
  String get categoryOilsVinegars => 'Óleos e vinagres';

  @override
  String get categoryCanned => 'Conservas';

  @override
  String get categoryNuts => 'Frutos secos';

  @override
  String get categoryBeverages => 'Bebidas';

  @override
  String get categoryBaking => 'Pastelaria';

  @override
  String get categoryFrozen => 'Congelados';

  @override
  String get categorySauces => 'Molhos e condimentos';

  @override
  String get categoryOther => 'Outros';

  @override
  String get unitCustomOption => 'Outra';

  @override
  String get unitCount => 'unidade';

  @override
  String get unitPinch => 'pitada';

  @override
  String get unitTeaspoon => 'colher de chá';

  @override
  String get unitTablespoon => 'colher de sopa';

  @override
  String get unitGlass => 'copo';

  @override
  String get unitCup => 'chávena';

  @override
  String get unitHandful => 'punhado';

  @override
  String get unitLeaf => 'folha';

  @override
  String get unitClove => 'dente';

  @override
  String get unitSplash => 'fio';

  @override
  String get unitSlice => 'fatia';

  @override
  String get unitSprig => 'ramo';

  @override
  String get unitPiece => 'pedaço';

  @override
  String get unitFillet => 'filete';

  @override
  String get unitRound => 'rodela';

  @override
  String get unitCan => 'lata';

  @override
  String get unitJar => 'frasco';

  @override
  String get unitPackage => 'pacote';

  @override
  String get unitSachet => 'saqueta';

  @override
  String get tagStarter => 'entrada';

  @override
  String get tagMainCourse => 'prato principal';

  @override
  String get tagDessert => 'sobremesa';

  @override
  String get tagBreakfast => 'pequeno-almoço';

  @override
  String get tagAppetizer => 'aperitivo';

  @override
  String get tagSoup => 'sopa';

  @override
  String get tagSalad => 'salada';

  @override
  String get tagSideDish => 'acompanhamento';

  @override
  String get tagVegetarian => 'vegetariana';

  @override
  String get tagVegan => 'vegana';

  @override
  String get tagPescatarian => 'pescetariana';

  @override
  String get tagGlutenFree => 'sem glúten';

  @override
  String get tagLactoseFree => 'sem lactose';

  @override
  String get tagDairyFree => 'sem laticínios';

  @override
  String get tagEggFree => 'sem ovo';

  @override
  String get tagNutFree => 'sem frutos secos';

  @override
  String get tagPeanutFree => 'sem amendoim';

  @override
  String get tagSoyFree => 'sem soja';

  @override
  String get tagFishFree => 'sem peixe';

  @override
  String get tagShellfishFree => 'sem marisco';

  @override
  String get tagSugarFree => 'sem açúcar';

  @override
  String get tagHighProtein => 'alto teor proteico';

  @override
  String get tagLowCalorie => 'baixa caloria';

  @override
  String get tagLowCarb => 'baixo hidrato';

  @override
  String get tagHighFiber => 'alta fibra';

  @override
  String get tagHealthy => 'saudável';

  @override
  String get tagSpanish => 'espanhola';

  @override
  String get tagItalian => 'italiana';

  @override
  String get tagAsian => 'asiática';

  @override
  String get tagMexican => 'mexicana';

  @override
  String get tagIndian => 'indiana';

  @override
  String get tagQuick => 'rápida';

  @override
  String get tagBudget => 'económica';

  @override
  String get tagBatchCooking => 'batch cooking';

  @override
  String get tagFreezerFriendly => 'para congelar';

  @override
  String get tagNoOven => 'sem forno';

  @override
  String get tagSpicy => 'picante';

  @override
  String get tagKidFriendly => 'para crianças';

  @override
  String get onboardingSkip => 'Ignorar';

  @override
  String get onboardingNext => 'Seguinte';

  @override
  String get onboardingPrevious => 'Anterior';

  @override
  String get onboardingFinish => 'Concluir';

  @override
  String get onboardingStep0Title => 'Bem-vindo/a ao Böl!';

  @override
  String get onboardingStep0Body =>
      'Mostramos como a app funciona em cerca de um minuto. Pode ignorar este tutorial quando quiser.';

  @override
  String get onboardingStep1Title => 'Planificador semanal';

  @override
  String get onboardingStep1Body =>
      'Vê todos os dias com as suas refeições. As setas ‹ › mudam a semana. O dia de hoje aparece destacado a verde.';

  @override
  String get onboardingStep2Title => 'Adicione refeições ao plano';

  @override
  String get onboardingStep2Body =>
      'Toque num espaço vazio para atribuir uma receita. Também pode premir o ícone de livro para abrir o painel lateral de receitas e arrastar receitas diretamente para o dia.';

  @override
  String get onboardingStep3Title => 'O seu livro de receitas';

  @override
  String get onboardingStep3Body =>
      'Todas as suas receitas num relance. A lupa pesquisa por nome e o ícone de livro abre o glossário culinário.';

  @override
  String get onboardingStep4Title => 'Crie uma receita';

  @override
  String get onboardingStep4Body =>
      'O botão + abre o formulário: foto, ingredientes com quantidades, passos, nutrição e etiquetas. Pode publicá-la para que outros a descubram.';

  @override
  String get onboardingStep5Title => 'Lista de compras';

  @override
  String get onboardingStep5Body =>
      'Quando planifica refeições, os ingredientes aparecem aqui automaticamente agrupados por categoria. Marque os itens ao comprar.';

  @override
  String get onboardingStep6Title => 'Adicione ingredientes';

  @override
  String get onboardingStep6Body =>
      'Toque no botão + para adicionar ingredientes manualmente à sua lista de compras.';

  @override
  String get onboardingStep7Title => 'Partilhe a sua lista';

  @override
  String get onboardingStep7Body =>
      'O ícone de partilhar gera texto pronto para enviar por WhatsApp ou outras apps.';

  @override
  String get onboardingStep8Title => 'Descubra a comunidade';

  @override
  String get onboardingStep8Body =>
      'Pesquise receitas de outros utilizadores por nome ou etiquetas. Avalie-as e guarde-as no seu livro.';

  @override
  String get onboardingStep9Title => 'Os seus cozinheiros seguidos';

  @override
  String get onboardingStep9Body =>
      'Siga os seus cozinheiros favoritos a partir do perfil e consulte as suas últimas receitas premindo o botão de Seguidos.';

  @override
  String get onboardingStep10Title => 'O seu perfil, alergias e casa';

  @override
  String get onboardingStep10Body =>
      'Edite o seu nome e foto, e configure as suas alergias e intolerâncias para que o assistente de receitas as respeite. Na secção A minha casa pode planear com a família em tempo real. A partir daqui também muda o idioma e o modo escuro.';

  @override
  String get createRecipeOptionsTitle => 'Criar receita';

  @override
  String get createRecipeManual => 'Criar manualmente';

  @override
  String get createRecipeManualSubtitle =>
      'Preencha todos os campos da receita';

  @override
  String get createRecipeWithAssistant => 'Criar com assistente de IA';

  @override
  String get createRecipeWithAssistantSubtitle =>
      'Descreva o prato e a IA elaborará a ficha';

  @override
  String get recipeAssistantTitle => 'Assistente de receitas';

  @override
  String get recipeAssistantDescription =>
      'Diga-me o que lhe apetece, o que tem no frigorífico, cole uma receita, anexe uma foto ou dite com o microfone.';

  @override
  String get recipeAssistantPromptHint =>
      'Ex.: omelete de batata para 4 pessoas com cebola...';

  @override
  String get recipeAssistantImagePromptHint =>
      'Indique ao assistente o que fazer com a foto (ex.: recriar este prato, extrair a receita...)';

  @override
  String get recipeAssistantSameRecipePhotosHint =>
      'Se anexar várias fotos, devem ser da mesma receita.';

  @override
  String get recipeAssistantListening => 'A ouvir…';

  @override
  String get recipeAssistantDictate => 'Ditar';

  @override
  String get recipeAssistantStopDictation => 'Parar ditado';

  @override
  String get recipeAssistantSpeechUnavailable =>
      'O reconhecimento de voz não está disponível. Ative-o nas Definições ou escreva o seu pedido.';

  @override
  String get recipeAssistantSpeechFailed =>
      'Não foi possível reconhecer a voz. Tente novamente ou escreva o seu pedido.';

  @override
  String get recipeAssistantGenerate => 'Gerar receita';

  @override
  String get recipeAssistantGenerating => 'A gerar...';

  @override
  String get recipeAssistantBlockingRecipe =>
      'O assistente está a elaborar a sua receita…';

  @override
  String get recipeAssistantBlockingNutrition =>
      'A calcular a informação nutricional…';

  @override
  String get recipeAssistantBlockingTags => 'A escolher etiquetas…';

  @override
  String get recipeAssistantNotRecipeRequest =>
      'Só posso ajudar a elaborar receitas. Descreva um prato ou uma receita.';

  @override
  String get recipeAssistantRateLimited =>
      'Limite de uso atingido. Tente novamente mais tarde.';

  @override
  String get recipeAssistantFailed =>
      'Não foi possível gerar a resposta. Tente novamente.';

  @override
  String get recipeAssistantOffline =>
      'É necessária ligação à internet para usar o assistente.';

  @override
  String get recipeAssistantNotConfigured =>
      'O assistente de IA ainda não está configurado.';

  @override
  String get recipeAssistantTimeout =>
      'O pedido demorou demasiado. Tente novamente.';

  @override
  String get recipeAssistantPromptTooLong =>
      'A descrição da receita não pode exceder 3.000 caracteres.';

  @override
  String get recipeAssistantMissingInput =>
      'Escreva uma descrição ou anexe uma foto da receita.';

  @override
  String get recipeAssistantImageTooLarge =>
      'A imagem é demasiado grande. Experimente outra foto ou tire uma nova.';

  @override
  String get recipeAssistantInvalidImage =>
      'Não foi possível usar essa imagem. Experimente outra foto.';

  @override
  String get recipeAssistantDailyLimitReached =>
      'Atingiu o limite diário do assistente. Volte amanhã.';

  @override
  String get recipeAssistantTooFast =>
      'Aguarde um momento antes de usar o assistente novamente.';

  @override
  String get recipeAssistantServiceAtCapacity =>
      'O assistente está sobrecarregado neste momento. Tente mais tarde.';

  @override
  String get recipeAssistantAllergenConflict =>
      'A receita não pode ser adaptada para evitar uma das suas substâncias restritas.';

  @override
  String get allergenConflictTitle => 'Não é possível criar a receita';

  @override
  String allergenConflictBody(String allergen) {
    return 'Não é possível adaptar a receita para evitar: $allergen.';
  }

  @override
  String get allergenAdjustmentsTitle =>
      'Ingredientes ajustados às suas restrições';

  @override
  String get allergenAdjustmentsIntro =>
      'O assistente adaptou a receita para evitar o alergénio ou a intolerância indicados:';

  @override
  String allergenAdjustmentNote(String allergen) {
    return 'A receita foi adaptada para evitar o alergénio ou a intolerância: $allergen.';
  }

  @override
  String get allergenConfigureInProfileHint =>
      'Pode configurar as suas alergias e intolerâncias no perfil.';

  @override
  String get allergenSubstanceGluten => 'glúten';

  @override
  String get allergenSubstanceLactose => 'lactose';

  @override
  String get allergenSubstanceDairy => 'laticínios';

  @override
  String get allergenSubstanceEgg => 'ovo';

  @override
  String get allergenSubstanceNuts => 'frutos secos';

  @override
  String get allergenSubstancePeanuts => 'amendoins';

  @override
  String get allergenSubstanceSoy => 'soja';

  @override
  String get allergenSubstanceFish => 'peixe';

  @override
  String get allergenSubstanceShellfish => 'marisco';

  @override
  String get allergenSubstanceSugar => 'açúcar';

  @override
  String get allergiesSection => 'Alergias e intolerâncias';

  @override
  String get allergiesHint =>
      'O assistente de receitas evitará estes ingredientes ao criar receitas, e preferirá substitutos seguros de supermercado quando o prato puder ser adaptado.';

  @override
  String get editAllergies => 'Editar alergias e intolerâncias';

  @override
  String get allergiesNoneConfigured => 'Nenhuma configurada';

  @override
  String get addCustomAllergy => 'Adicionar alergia/intolerância personalizada';

  @override
  String get customAllergyDialogTitle =>
      'Alergia ou intolerância personalizada';

  @override
  String get customAllergyHint => 'Ex.: aipo, mostarda, sésamo…';

  @override
  String get customAllergyAdd => 'Adicionar';

  @override
  String get customAllergyInvalid =>
      'Introduza um nome válido (letras, números, espaços).';

  @override
  String get customAllergyDuplicate => 'Essa alergia já está na lista.';

  @override
  String get customAllergyLimitReached =>
      'Pode adicionar até 10 alergias personalizadas.';

  @override
  String customAllergenFreeLabel(String name) {
    return 'sem $name';
  }

  @override
  String get completeNutritionWithAssistant => 'Completar com IA';

  @override
  String get completeTagsWithAssistant => 'Completar com IA';

  @override
  String get recipeAssistantNutritionSaved => 'Ficha nutricional completada';

  @override
  String get cookRecipeButton => 'Cozinhar receita';

  @override
  String get continueCookingButton => 'Continuar a cozinhar';

  @override
  String get checkIngredientsStep => 'Verificar ingredientes';

  @override
  String stepXofY(int current, int total) {
    return 'Passo $current de $total';
  }

  @override
  String get completeStepButton => 'Completar passo';

  @override
  String get finishCookingButton => 'Terminar';

  @override
  String get cookingPausedLabel => 'Pausada';

  @override
  String get cookingPauseTooltip => 'Pausar';

  @override
  String get cookingResumeTooltip => 'Continuar';

  @override
  String get finishCookingTitle => 'Terminar a receita?';

  @override
  String finishCookingConfirm(String title) {
    return 'Quer parar de cozinhar \"$title\"?';
  }

  @override
  String get cookingFinishedTitle => 'Receita terminada!';

  @override
  String get cookingFinishedMessage => 'Bom apetite!';

  @override
  String get cookingInProgressTitle => 'Receita em curso';

  @override
  String cookingInProgressMessage(String title) {
    return 'Já está a cozinhar \"$title\". Iniciar uma nova receita?';
  }

  @override
  String get cookingReplaceButton => 'Nova receita';

  @override
  String get previousStep => 'Passo anterior';

  @override
  String get nextStep => 'Próximo passo';

  @override
  String get minimize => 'Minimizar';

  @override
  String get expandCookingSession => 'Expandir';

  @override
  String get cookingNotificationChannelName => 'Sessão de cozinha';

  @override
  String get cookingNotificationChannelDescription =>
      'Sessão de cozinha em andamento';
}
