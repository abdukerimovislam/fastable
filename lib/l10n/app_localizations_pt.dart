// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Fastable';

  @override
  String get dashboardToday => 'Hoje';

  @override
  String get dashboardOverview => 'Visão geral';

  @override
  String get navTimer => 'Temporizador';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navStats => 'Estatísticas';

  @override
  String get navLearn => 'Aprender';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navAchievements => 'Conquistas';

  @override
  String get navPro => 'Fastable PRO';

  @override
  String get fastingPhase => 'Fase de jejum';

  @override
  String get eatingWindow => 'Janela alimentar';

  @override
  String get readyToFast => 'Pronto para jejuar';

  @override
  String get autophagyZone => 'Zona de autofagia';

  @override
  String get startFast => 'Iniciar jejum';

  @override
  String get endFast => 'Encerrar jejum';

  @override
  String get endCycle => 'Encerrar ciclo';

  @override
  String get remaining => 'Restante';

  @override
  String get targetGoal => 'Meta';

  @override
  String get waterTracker => 'Controle de água';

  @override
  String get waterCups => 'copos';

  @override
  String get addWater => 'Adicionar água';

  @override
  String get waterToday => 'Água de hoje';

  @override
  String get waterIntake => 'Ingestão de água';

  @override
  String get cups => 'copos';

  @override
  String get cupsUnit => 'copos';

  @override
  String get weightTracker => 'Controle de peso';

  @override
  String get logWeight => 'Registrar peso';

  @override
  String get saveWeight => 'Salvar peso';

  @override
  String get weightJourney => 'Evolução do peso';

  @override
  String get last7Days => 'Últimos 7 dias';

  @override
  String get fastingHours => 'Horas de jejum';

  @override
  String get currentWeight => 'Atual';

  @override
  String get goalWeight => 'Meta';

  @override
  String get startWeight => 'Inicial';

  @override
  String get addWeight => 'Adicionar peso';

  @override
  String get enterWeight => 'Digite o peso';

  @override
  String get unitKg => 'kg';

  @override
  String get unitCm => 'cm';

  @override
  String get weightProgress => 'Progresso do peso';

  @override
  String get chartEmpty => 'Adicione pelo menos dois registros para ver o gráfico.';

  @override
  String get proBannerTitle => 'Fastable PRO';

  @override
  String get proBannerDesc => 'Desbloquear análises';

  @override
  String get premiumContentTitle => 'Conteúdo premium';

  @override
  String get premiumContentDesc => 'Desbloqueie acesso total a todos os recursos.';

  @override
  String get getPro => 'Obter acesso PRO';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get proTitle => 'Obter acesso PRO';

  @override
  String get proMonthly => 'Assinatura mensal';

  @override
  String get proAnnual => 'Assinatura anual (40% OFF)';

  @override
  String get unlockAll => 'Desbloquear PRO';

  @override
  String get accessStatus => 'Acesso atual';

  @override
  String statusActive(Object date) {
    return 'Ativo até $date';
  }

  @override
  String get statusFree => 'Grátis';

  @override
  String get proRequired => 'É necessária uma assinatura PRO para ver este conteúdo';

  @override
  String get proComingSoon => 'Versão PRO em breve! Fique ligado.';

  @override
  String get year => 'ano';

  @override
  String get month => 'mês';

  @override
  String get discount => 'Desconto';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historyCalendar => 'Calendário';

  @override
  String get historyLog => 'Registro';

  @override
  String get historyEmpty => 'Nenhum jejum concluído ainda. Eles aparecerão aqui!';

  @override
  String get fastComplete => 'Jejum concluído! 🎉';

  @override
  String fastCompleteDesc(String time) {
    return 'Você jejuou por $time. Deseja salvar este registro?';
  }

  @override
  String get noFastsOnDay => 'Nenhum jejum concluído neste dia.';

  @override
  String get detailsFor => 'Detalhes de';

  @override
  String get endCyclePrompt => 'Encerrar janela de alimentação?';

  @override
  String get endCyclePromptDesc => 'Isso irá parar o temporizador de alimentação e reiniciar o ciclo.';

  @override
  String get endFastPrompt => 'Finalize o ciclo atual para alterar o plano.';

  @override
  String get discard => 'Descartar';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get next => 'Próximo';

  @override
  String get finish => 'Concluir';

  @override
  String get attention => 'Atenção';

  @override
  String get continueAction => 'Continuar';

  @override
  String get settingLanguage => 'Idioma';

  @override
  String get settingWaterGoal => 'Meta diária de água';

  @override
  String get settingHeight => 'Altura';

  @override
  String get settingGoalWeight => 'Peso meta';

  @override
  String get settingTheme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get settingsHealthConnect => 'Health Connect';

  @override
  String get settingsSyncWeight => 'Sincronizar peso e passos';

  @override
  String get healthConnectSyncTitle => 'Sincronizar com Health Connect';

  @override
  String get healthConnectDisclosureIntro => 'Fastable solicita acesso de LEITURA e ESCRITA ao PESO via Health Connect.';

  @override
  String get healthConnectDisclosureRead => 'Usamos LEITURA para exibir gráficos e estatísticas com base no histórico.';

  @override
  String get healthConnectDisclosureWrite => 'Usamos ESCRITA para que você possa salvar dados de peso do Fastable no telefone.';

  @override
  String get healthConnectDisclosureSecure => 'Os dados são armazenados localmente e usados apenas para rastreamento. Você pode revogar permissões a qualquer momento.';

  @override
  String get healthConnectConnected => 'Health Connect conectado!';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get notifyWater => 'Lembretes de água';

  @override
  String get notifyWaterDesc => 'Receba lembretes para beber água';

  @override
  String get notifyWeight => 'Lembrete de peso';

  @override
  String get notifyWeightDesc => 'Lembrete diário para se pesar';

  @override
  String get notifyFastingStart => 'Início do jejum';

  @override
  String get notifyFastingStartDesc => 'Notificar quando a janela de jejum começar';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get termsOfService => 'Termos de uso';

  @override
  String get errorOpenLink => 'Não foi possível abrir o link';

  @override
  String get errorLoading => 'Erro ao carregar dados';

  @override
  String get noArticlesFound => 'Nenhum artigo encontrado';

  @override
  String get tabFasting => 'Jejum';

  @override
  String get tabKeto => 'Keto';

  @override
  String get tabPartner => 'Parceiro';

  @override
  String get guestUser => 'Convidado';

  @override
  String get defaultUser => 'Usuário';

  @override
  String get anonymousLogin => 'Login anônimo';

  @override
  String get dataOnDevice => 'Dados salvos no dispositivo';

  @override
  String get connectGoogle => 'Conectar conta Google';

  @override
  String get saveProgressCloud => 'Salvar progresso na nuvem';

  @override
  String get accountLinked => 'Conta vinculada com sucesso!';

  @override
  String get linkError => 'Erro ao vincular conta';

  @override
  String get resetAndExit => 'Redefinir dados e sair';

  @override
  String get deleteAndExit => 'Excluir e sair';

  @override
  String get signOut => 'Sair';

  @override
  String get confirmLogout => 'Tem certeza que deseja sair?';

  @override
  String get guestLogoutWarning => 'Você está usando uma conta de convidado. Se sair, todos os dados locais serão excluídos permanentemente.';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get deleteAccountWarning => 'Tem certeza? Isso apagará todos os seus dados permanentemente.';

  @override
  String get authWelcome => 'Bem-vindo ao Fastable';

  @override
  String get authSubtitle => 'Sincronize seu progresso e alcance seus objetivos.';

  @override
  String get signInGoogle => 'Entrar com Google';

  @override
  String get continueGuest => 'Continuar como convidado';

  @override
  String get signInFailed => 'Falha no login. Tente novamente.';

  @override
  String get welcomeMessage => 'Bem-vindo ao seu app de jejum!';

  @override
  String get choosePlan => 'Escolher plano';

  @override
  String get fastingPlan16_8 => 'Jejum Intermitente 16:8';

  @override
  String get fastingPlan18_6 => 'Jejum Intermitente 18:6';

  @override
  String get fastingPlan20_4 => 'A Dieta do Guerreiro 20:4';

  @override
  String get fastingPlanEatStopEat => 'Eat-Stop-Eat (24h)';

  @override
  String get bmiCalculator => 'Calculadora de IMC';

  @override
  String get bmiCategory => 'Categoria';

  @override
  String get bmiUnderweight => 'Abaixo do peso';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Sobrepeso';

  @override
  String get bmiObese => 'Obesidade';

  @override
  String get enterHeightCm => 'Digite a altura (cm)';

  @override
  String get enterGoalWeightKg => 'Digite o peso meta (kg)';

  @override
  String get fastingStats => 'Estatísticas de jejum';

  @override
  String get fastingStatsCurrentStreak => 'Sequência atual';

  @override
  String get fastingStatsDay => 'Dia';

  @override
  String get fastingStatsDays => 'Dias';

  @override
  String get fastingStatsTotalFasts => 'Total de jejuns';

  @override
  String get fastingStatsTotalHours => 'Total de horas';

  @override
  String get fastingStatsAvgFast => 'Jejum médio';

  @override
  String get fastingStatsHours => 'Horas';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo!';

  @override
  String get onboardingWelcomeDesc => 'Comece sua jornada para a saúde. Vamos configurar seu perfil.';

  @override
  String get onboardingGoalTitle => 'Quais são seus objetivos?';

  @override
  String get onboardingGoalDesc => 'Defina sua altura e peso meta para calcularmos seu IMC.';

  @override
  String get onboardingPlanTitle => 'Escolha seu plano';

  @override
  String get onboardingPlanDesc => 'Com qual plano de jejum você gostaria de começar? Você pode alterá-lo depois.';

  @override
  String get onboardingCurrentWeight => 'Seu peso atual';

  @override
  String get getStarted => 'Começar';

  @override
  String get currentStage => 'Estágio atual';

  @override
  String get nextStage => 'Próximo';

  @override
  String get stageAnabolicTitle => 'Anabólico (Alimentado)';

  @override
  String get stageAnabolicDesc => 'Seu corpo está digerindo e usando glicose. Crescimento celular ativo.';

  @override
  String get stageCatabolicTitle => 'Catabólico';

  @override
  String get stageCatabolicDesc => 'O nível de açúcar cai. O corpo começa a usar glicogênio armazenado.';

  @override
  String get stageKetosisTitle => 'Cetose';

  @override
  String get stageKetosisDesc => 'Estoques de glicogênio esgotados. O corpo queima gordura como combustível principal.';

  @override
  String get stageAutophagyTitle => 'Autofagia';

  @override
  String get stageAutophagyDesc => 'Começa a limpeza celular. O corpo recicla componentes celulares velhos.';

  @override
  String get stagePeakAutophagyTitle => 'Pico de autofagia';

  @override
  String get stagePeakAutophagyDesc => 'O processo de renovação celular atinge o máximo.';

  @override
  String get achievementsTitle => 'Conquistas';

  @override
  String get achievementsUnlocked => 'Desbloqueadas';

  @override
  String get achievementsLocked => 'Bloqueadas';

  @override
  String achEarnedOn(Object date) {
    return 'Obtido em $date';
  }

  @override
  String get achFirstFastTitle => 'Primeiro Jejum!';

  @override
  String get achFirstFastDesc => 'Complete seu primeiro jejum.';

  @override
  String get achStreak3Title => 'Bom Começo';

  @override
  String get achStreak3Desc => 'Mantenha uma sequência de 3 dias.';

  @override
  String get achStreak7Title => 'Consistente';

  @override
  String get achStreak7Desc => 'Mantenha uma sequência de 7 dias.';

  @override
  String get achTotal10Title => 'Novato';

  @override
  String get achTotal10Desc => 'Complete 10 jejuns.';

  @override
  String get achTotalHours100Title => 'Clube das 100 Horas';

  @override
  String get achTotalHours100Desc => 'Jejue por um total de 100 horas.';

  @override
  String get journalTitle => 'Nota do diário';

  @override
  String get journalHint => 'Como você se sentiu durante este jejum?';

  @override
  String get addNote => 'Adicionar nota';

  @override
  String get editNote => 'Editar nota';

  @override
  String get noteSaved => 'Nota salva';

  @override
  String get syncHealthTitle => 'Sincronizar saúde';

  @override
  String get syncHealthDesc => 'Gravar jejuns e ler peso automaticamente.';

  @override
  String get shareProgress => 'Compartilhar progresso';

  @override
  String get metricPhase => 'Fase';

  @override
  String get metricStreak => 'Sequência';

  @override
  String get metricStatus => 'Status';

  @override
  String get statusDigesting => 'Digestão';

  @override
  String get statusStable => 'Estável';

  @override
  String get statusFatBurn => 'Queima de gordura';

  @override
  String get statusKetosis => 'Cetose';

  @override
  String get statusNormal => 'Normal';

  @override
  String get titleCurrentPhase => 'Fase atual';

  @override
  String get valFastingZone => 'Zona de jejum';

  @override
  String get valEatingWindow => 'Janela de alimentação';

  @override
  String get descFastingZone => 'Você está atualmente na janela de jejum. Nenhuma caloria deve ser consumida.';

  @override
  String get descEatingWindow => 'Você está na sua janela de alimentação. Foque em alimentos nutritivos.';

  @override
  String get titleConsistencyStreak => 'Sequência de consistência';

  @override
  String valStreakDays(int days) {
    return '$days dias 🔥';
  }

  @override
  String descStreak(int days) {
    return 'Você atingiu sua meta de jejum por $days dias consecutivos. Continue assim para criar o hábito!';
  }

  @override
  String get titleBodyStatus => 'Estado do corpo';

  @override
  String get descDigesting => 'Seu corpo está digerindo alimentos e repondo as reservas de glicogênio. Os níveis de insulina estão aumentando.';

  @override
  String get descStable => 'Os níveis de açúcar no sangue estão se normalizando. O corpo está se preparando para mudar da glicose para a gordura como fonte de energia.';

  @override
  String get descFatBurn => 'Ótimo trabalho! Seu corpo está começando a queimar gordura armazenada para obter energia. Os níveis do hormônio do crescimento podem aumentar.';

  @override
  String get descKetosis => 'Cetose profunda! Seu corpo está queimando gordura de forma eficiente. A autofagia pode começar em breve.';

  @override
  String get btnGotIt => 'Entendi!';

  @override
  String get stage0_4 => 'Blood Sugar Rise';

  @override
  String get stage0_4_desc => 'Your body is digesting your last meal. Blood sugar and insulin levels go up.';

  @override
  String get stage4_8 => 'Blood Sugar Drop';

  @override
  String get stage4_8_desc => 'Insulin levels start to drop. Your body begins to use up stored glucose.';

  @override
  String get stage8_12 => 'Normalization';

  @override
  String get stage8_12_desc => 'Digestive system rests. Your body starts healing and cleaning itself.';

  @override
  String get stage12_16 => 'Fat Burning';

  @override
  String get stage12_16_desc => 'Insulin is low. Your body starts burning stored fat for energy.';

  @override
  String get stage16_18 => 'Ketosis';

  @override
  String get stage16_18_desc => 'Fat burning accelerates. You are in full fat-burning mode.';

  @override
  String get stage18_24 => 'Autophagy';

  @override
  String get stage18_24_desc => 'Cellular cleanup begins. Your body recycles old and damaged cells.';

  @override
  String get stage24_plus => 'Deep Repair';

  @override
  String get stage24_plus_desc => 'Growth hormone levels increase. Significant cellular regeneration occurs.';

  @override
  String get viewTimeline => 'View Body Timeline';

  @override
  String get navFood => 'Alimentação';

  @override
  String get circadianEnabled => 'Circadian mode enabled';

  @override
  String get circadianDisabled => 'Circadian mode disabled';

  @override
  String get tabRecipes => 'Receitas';

  @override
  String get tabKnowledge => 'Conhecimento';

  @override
  String get categoryAll => 'Todos';

  @override
  String get categoryKeto => 'Keto';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryVegan => 'Vegano';

  @override
  String recipeTime(int minutes) {
    return '$minutes min';
  }
}
