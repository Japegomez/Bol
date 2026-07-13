// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'MealPlanner';

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
  String get navRecipeBook => 'Livro de receitas';

  @override
  String get navPlanner => 'Planificador';

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
  String get confirmPasswordLabel => 'Confirmar palavra-passe';

  @override
  String get confirmYourPassword => 'Confirme a sua palavra-passe';

  @override
  String get passwordsDoNotMatch => 'As palavras-passe não coincidem';

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
  String get feedTitle => 'Feed';

  @override
  String get mostRecent => 'Mais recente';

  @override
  String sortedBy(String label) {
    return 'Ordenado por: $label';
  }

  @override
  String get noRecipesWithTags => 'Sem receitas com estas etiquetas';

  @override
  String get feedEmpty => 'O seu feed está vazio';

  @override
  String get tryOtherTags => 'Experimente outras etiquetas ou remova o filtro.';

  @override
  String get followUsersHint =>
      'Siga outros utilizadores a partir dos seus perfis para ver as receitas públicas aqui.';

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get feedTooltip => 'Feed';

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
      'Perderá acesso ao planificador e lista partilhados. Continuar?';

  @override
  String get leave => 'Abandonar';

  @override
  String get myHouseholdTitle => 'A minha casa';

  @override
  String get inviteCode => 'Código de convite';

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
      'Introduza o código de 6 caracteres partilhado por um membro da casa.';

  @override
  String get invalidInviteCode => 'Código de convite inválido';

  @override
  String get alreadyMember => 'Já pertence a esta casa';

  @override
  String get codeMustBeSixChars => 'O código deve ter 6 caracteres';

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
  String get mealBreakfast => 'Pequeno-almoço';

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
  String get tagVegetarian => 'vegetariana';

  @override
  String get tagVegan => 'vegano';

  @override
  String get tagPescatarian => 'pescetariana';

  @override
  String get tagGlutenFree => 'sem glúten';

  @override
  String get tagLactoseFree => 'sem lactose';

  @override
  String get tagEggFree => 'sem ovo';

  @override
  String get tagNutFree => 'sem frutos secos';

  @override
  String get tagSoyFree => 'sem soja';

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
  String get tagMediterranean => 'mediterrânica';

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
  String get onboardingStep0Title => 'Bem-vindo/a ao Recetea!';

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
  String get onboardingStep9Title => 'O seu feed de cozinheiros';

  @override
  String get onboardingStep9Body =>
      'Siga os seus cozinheiros favoritos a partir do perfil e consulte as suas últimas receitas premindo o botão do feed.';

  @override
  String get onboardingStep10Title => 'O seu perfil e casa';

  @override
  String get onboardingStep10Body =>
      'Edite o seu nome e foto. Na secção A minha casa pode planear com a família em tempo real. A partir daqui também muda o idioma e o modo escuro.';
}
