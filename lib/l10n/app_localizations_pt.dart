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
  String get proTitle => 'Desbloquear Fastable Pro';

  @override
  String get proMonthly => 'Assinatura mensal';

  @override
  String get proAnnual => 'Assinatura anual (40% OFF)';

  @override
  String get unlockAll => 'Desbloquear todas as funcionalidades';

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
  String get settingsHealthConnect => 'Conexão de saúde';

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
  String get guestUser => 'Usuário convidado';

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
  String get authSubtitle => 'Faça login para sincronizar os dados';

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
  String get bmiNormal => 'Peso normal';

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
  String get achFirstFastDesc => 'Complete sua primeira sessão de jejum.';

  @override
  String get achStreak3Title => 'Bom Começo';

  @override
  String get achStreak3Desc => 'Mantenha uma sequência de jejum por 3 dias.';

  @override
  String get achStreak7Title => 'Consistente';

  @override
  String get achStreak7Desc => 'Alcance uma sequência de 7 dias.';

  @override
  String get achTotal10Title => 'Novato';

  @override
  String get achTotal10Desc => 'Complete 10 jejuns no total.';

  @override
  String get achTotalHours100Title => 'Clube das 100 Horas';

  @override
  String get achTotalHours100Desc => 'Acumule 100 horas de jejum.';

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

  @override
  String get waterSettings => 'Configurações de água';

  @override
  String get removeCup => 'Remover copo (-1)';

  @override
  String get dailyGoal => 'Meta diária';

  @override
  String get bmiScore => 'IMC';

  @override
  String bmiDescription(int height, String weight) {
    return 'Com base na sua altura ($height cm) e peso ($weight kg).';
  }

  @override
  String get onboardingTitle => 'Personalize seu plano';

  @override
  String get onboardingHeightTitle => 'Qual é a sua altura?';

  @override
  String get onboardingHeightDesc => 'Precisamos disso para calibrar o visualizador corporal e calcular suas métricas de saúde com precisão.';

  @override
  String get onboardingWeightTitle => 'Qual é o seu peso?';

  @override
  String get onboardingWeightDesc => 'Isso nos ajuda a acompanhar seu progresso e ajustar seu plano de jejum dinamicamente.';

  @override
  String get btnNext => 'Próximo';

  @override
  String get btnFinish => 'Iniciar jornada';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get statsSuccessRate => 'Taxa de sucesso';

  @override
  String statsSuccessDesc(int success, int total) {
    return '$success de $total jejuns foram de 16 h ou mais';
  }

  @override
  String get statsTotalFasts => 'Total de jejuns';

  @override
  String get statsTotalHours => 'Total de horas';

  @override
  String get statsAverage => 'Média';

  @override
  String get statsLongest => 'Mais longo';

  @override
  String get circadianTitle => 'Ritmo circadiano';

  @override
  String get circadianIntroTitle => 'Coma com o sol ☀️';

  @override
  String get circadianIntroDesc => 'O seu metabolismo está ligado ao sol.\n\n• Nascer do sol: melhor momento para acordar e se hidratar.\n• Dia: metabolismo elevado. Ideal para se alimentar.\n• Pôr do sol: o metabolismo desacelera. É melhor parar de comer.\n• Noite: modo de recuperação profunda. O jejum acontece com mais facilidade.\n\nEste modo ajusta automaticamente suas metas de jejum de acordo com os horários de nascer e pôr do sol da sua localização.';

  @override
  String get circadianBtnEnable => 'Ativar modo circadiano';

  @override
  String get circadianBtnDisable => 'Desativar';

  @override
  String get circadianTargetSunrise => 'Até o nascer do sol';

  @override
  String get circadianTargetSunset => 'Até o pôr do sol';

  @override
  String get circadianPhaseDay => 'Dia (Comer)';

  @override
  String get circadianPhaseNight => 'Noite (Jejum)';

  @override
  String get circadianWarnDayTitle => 'É dia ☀️';

  @override
  String get circadianWarnDayDesc => 'O sol já nasceu! Seu corpo está pronto para se alimentar. Idealmente, espere até o pôr do sol para iniciar o jejum.';

  @override
  String get circadianWarnBtnStart => 'Começar mesmo assim';

  @override
  String get circadianWarnBtnWait => 'Esperar o pôr do sol';

  @override
  String get circadianBonusTime => 'Tempo bônus 🔥';

  @override
  String get circadianSyncing => 'Sincronizando com o sol...';

  @override
  String get circadianError => 'Não foi possível obter a localização. Usando temporizador padrão.';

  @override
  String get circadianManaged => 'Controlado pelo sol';

  @override
  String get notifBio4hTitle => 'Blood Sugar Stabilized 🩸';

  @override
  String get notifBio4hBody => 'Your insulin levels are dropping. False hunger pangs may disappear.';

  @override
  String get notifBio8hTitle => 'Stomach is Empty ✅';

  @override
  String get notifBio8hBody => 'Digestion is complete. Your body is shifting into repair mode.';

  @override
  String get notifBio12hTitle => 'Entering Ketosis 🔥';

  @override
  String get notifBio12hBody => 'Your body has started burning stored fat for energy!';

  @override
  String get notifBio16hTitle => 'Fat Burning Peak ⚡️';

  @override
  String get notifBio16hBody => 'Metabolism is accelerated. You are in the intense burning zone.';

  @override
  String get notifBio18hTitle => 'Autophagy Started ♻️';

  @override
  String get notifBio18hBody => 'Cellular cleaning active. Your body is recycling old cells.';

  @override
  String get notifBio24hTitle => 'HGH Spike 🛡';

  @override
  String get notifBio24hBody => 'Growth hormone levels are up to protect your muscles.';

  @override
  String get notifProg50Title => 'Halfway There! 🚀';

  @override
  String get notifProg50Body => 'You passed 50% of your goal. Keep going!';

  @override
  String get notifProg1hTitle => '1 Hour Left ⏳';

  @override
  String get notifProg1hBody => 'Almost done! You can start preparing your meal.';

  @override
  String get notifProgFinishTitle => 'Goal Reached! 🏆';

  @override
  String get notifProgFinishBody => 'You did it! Don\'t forget to stop the timer.';

  @override
  String get notifWaterTitle => 'Drink Water 💧';

  @override
  String get notifWaterBody => 'Hydration boosts your metabolism and reduces hunger.';

  @override
  String get notifWeightTitle => 'Morning Weigh-in ⚖️';

  @override
  String get notifWeightBody => 'Morning is the best time to track your weight.';

  @override
  String get permTitle => 'Ativar permissões';

  @override
  String get permDesc => 'Para oferecer a melhor experiência, o Fastable precisa de acesso às notificações e aos dados de saúde.';

  @override
  String get permNotifTitle => 'Notificações';

  @override
  String get permNotifDesc => 'Acompanhe seus alertas de jejum.';

  @override
  String get permHealthTitle => 'Apple Health';

  @override
  String get permHealthDesc => 'Sincronize dados de peso e consumo de água.';

  @override
  String get permAllow => 'Permitir';

  @override
  String get permContinue => 'Continuar';

  @override
  String get achFirstFast => 'Primeiro passo';

  @override
  String get achStreak3 => 'Consistência';

  @override
  String get achStreak7 => 'Imparável';

  @override
  String get achTotal10 => 'Dedicação';

  @override
  String get achTotalHours100 => 'Centurião';

  @override
  String get onboardingDesc => 'Vamos calcular sua taxa metabólica.';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnStart => 'Iniciar jornada';

  @override
  String get selectGender => 'Gênero';

  @override
  String get selectAge => 'Idade';

  @override
  String get selectWeight => 'Peso';

  @override
  String get selectHeight => 'Altura';

  @override
  String get selectActivity => 'Nível de atividade';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Feminino';

  @override
  String get activitySedentary => 'Sedentário';

  @override
  String get activityModerate => 'Moderado';

  @override
  String get activityActive => 'Muito ativo';

  @override
  String get contactSupport => 'Contato com suporte';

  @override
  String get metabolicProfile => 'Perfil metabólico';

  @override
  String ageYears(int age) {
    return '$age anos';
  }

  @override
  String get metricBmrTitle => 'BMR';

  @override
  String get metricBmrSubtitle => 'Basal';

  @override
  String get metricBmrDesc => 'Taxa metabólica basal. Calorias queimadas em repouso absoluto.';

  @override
  String get metricTdeeTitle => 'TDEE';

  @override
  String get metricTdeeSubtitle => 'Manutenção';

  @override
  String get metricTdeeDesc => 'Gasto energético diário total. Calorias necessárias para manter o peso atual.';

  @override
  String get dialogStartTitle => 'Quando você começou?';

  @override
  String get btnStartFasting => 'Iniciar jejum';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get stage2Title => 'O açúcar no sangue está caindo 📉';

  @override
  String get stage2Body => 'Seu corpo está se acalmando. Se sentir fome, beba um pouco de água. 💧';

  @override
  String get stage4Title => 'A insulina está diminuindo ⬇️';

  @override
  String get stage4Body => 'Ótimo! Seu corpo para de armazenar gordura e começa a se preparar para queimá-la.';

  @override
  String get stage8Title => 'Limpeza iniciada ✨';

  @override
  String get stage8Body => '8 horas completas. Seu estômago está descansando. Você está cuidando bem da sua saúde!';

  @override
  String get stage11Title => 'Modo queima de gordura 🔥';

  @override
  String get stage11Body => 'A parte divertida começa! Seu corpo muda para reservas internas.';

  @override
  String get stage12Title => 'Cetose ativada 🚀';

  @override
  String get stage12Body => 'As células de gordura viram energia. Sua mente fica mais clara.';

  @override
  String get stage14Title => 'Cetose profunda 🔥';

  @override
  String get stage14Body => 'Você está na zona de queima de gordura! A limpeza acontece mais rápido.';

  @override
  String get stage16Title => 'Autofagia (reparo celular) 🧬';

  @override
  String get stage16Body => 'Suas células estão se renovando. O corpo entra em modo de reparo.';

  @override
  String get stage18Title => 'Pico do hormônio do crescimento 📈';

  @override
  String get stage18Body => 'O hormônio do crescimento ajuda a queimar gordura e preservar músculos. Você está ficando mais forte!';

  @override
  String get stage24Title => '24 horas! 🏆';

  @override
  String get stage24Body => 'Incrível! Um dia completo concluído. A limpeza profunda está a todo vapor.';

  @override
  String get notifyHalfwayTitle => 'Metade do caminho! ⛰️';

  @override
  String get notifyHalfwayBody => 'A parte mais difícil já passou. Seu corpo agradece.';

  @override
  String get notify1hTitle => 'Reta final! 🏁';

  @override
  String get notify1hBody => 'Falta apenas 1 hora. Você está indo muito bem!';

  @override
  String get notifyGoalTitle => 'Objetivo alcançado! 🎉';

  @override
  String get notifyGoalBody => 'Parabéns! Quebre o jejum com cuidado.';

  @override
  String get notifyEatCloseTitle => 'Janela de alimentação encerrando 🛑';

  @override
  String get notifyEatCloseBody => 'Hora de iniciar o próximo jejum. Confira no app!';

  @override
  String get notifyEat30mTitle => 'Faltam 30 minutos 🥗';

  @override
  String get notifyEat30mBody => 'Não se esqueça de beber água ou fazer um último lanche leve.';

  @override
  String get learnTitle => 'Aprender e comer';

  @override
  String get tabArticles => 'Artigos';

  @override
  String get catBasics => 'Básico';

  @override
  String get catNutrition => 'Nutrição';

  @override
  String get catHealth => 'Saúde';

  @override
  String get catKeto => 'Keto';

  @override
  String get headerLatestArticles => 'Artigos mais recentes';

  @override
  String get headerHealthyChoices => 'Escolhas saudáveis';

  @override
  String get statusNoArticles => 'Nenhum artigo encontrado';

  @override
  String get msgComingSoon => 'Este recurso estará disponível em breve!';

  @override
  String get learnBannerTitle => 'Desbloqueie mais de 500 receitas';

  @override
  String get learnBannerSubtitle => 'Acesso completo com PRO';

  @override
  String get labelPremium => 'PREMIUM';

  @override
  String get bannerRecipeTitle => 'Receitas saudáveis';

  @override
  String get bannerRecipeSubtitle => 'Keto, baixo carboidrato e mais';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitMin => 'min';

  @override
  String get lblAchievements => 'Conquistas';

  @override
  String get lblPersonalData => 'Dados pessoais';

  @override
  String get lblSettings => 'Configurações';

  @override
  String get lblAbout => 'Sobre';

  @override
  String get lblHeight => 'Altura';

  @override
  String get lblWeight => 'Peso';

  @override
  String get lblAge => 'Idade';

  @override
  String get lblGender => 'Gênero';

  @override
  String get lblActivity => 'Nível de atividade';

  @override
  String get lblLanguage => 'Idioma';

  @override
  String get msgHealthSyncEnabled => 'Sincronização de saúde ativada!';

  @override
  String get msgHealthSyncFailed => 'Permissão negada';

  @override
  String get aiGreeting => 'Olá! Eu sou o Fasty 🥑. Como posso ajudar você a alcançar seus objetivos hoje?';

  @override
  String get aiConnectionError => 'Ops! A conexão foi perdida. Verifique sua internet ou tente novamente mais tarde. 🥑';

  @override
  String get aiSystemError => 'O serviço de IA não está configurado corretamente (chave de API ausente).';

  @override
  String get aiCoachTitle => 'Coach de jejum com IA';

  @override
  String get aiCoachDesc => 'Receba respostas instantâneas sobre keto, jejum intermitente e hábitos saudáveis com nosso assistente inteligente de IA.';

  @override
  String get aiChatHint => 'Pergunte sobre keto ou jejum...';

  @override
  String get btnUnlockPro => 'Desbloquear com PRO';

  @override
  String get aiInsightFallback => 'A consistência é a chave! Beba água e continue em movimento. 💧';

  @override
  String get aiErrorConnection => 'Problema de conexão. Tente novamente mais tarde.';

  @override
  String get aiInsightTitle => 'INSIGHT DIÁRIO';

  @override
  String get aiInsightTeaser => 'Com base nos seus últimos 7 dias de jejum, encontramos um padrão importante que afeta seu progresso...';

  @override
  String get tapToUnlock => 'Toque para desbloquear';

  @override
  String get notifyAiInsightTitle => 'Seu insight diário de IA está pronto! 🥑';

  @override
  String get notifyAiInsightBody => 'Veja o que o Fasty analisou para você hoje. Toque para desbloquear.';

  @override
  String get notifyWeightTitle => 'Acompanhe seu peso ⚖️';

  @override
  String get notifyWeightBody => 'A consistência é a chave! Registre seu peso hoje.';

  @override
  String get aiInsightNotEnoughData => 'Continue registrando! Precisamos de pelo menos 3 jejuns para analisar seus padrões únicos. 📊';

  @override
  String msgLoginFailed(Object error) {
    return 'Falha no login: $error';
  }

  @override
  String msgAppleLoginFailed(Object error) {
    return 'Falha no login com Apple: $error';
  }

  @override
  String get msgSyncCompleted => 'Sincronização concluída';

  @override
  String get msgErrorRelogin => 'Erro: faça login novamente e tente outra vez.';

  @override
  String get signInApple => 'Entrar com Apple';

  @override
  String get lblDangerZone => 'ZONA DE PERIGO';

  @override
  String get btnDeleteAccount => 'Excluir conta';

  @override
  String get dialogDeleteAccountTitle => 'Excluir conta?';

  @override
  String get dialogDeleteAccountContent => 'Esta ação é permanente. Todo o histórico de peso, registros de jejum e conquistas serão excluídos da nuvem.';

  @override
  String get btnDelete => 'EXCLUIR';

  @override
  String get dialogSyncConflictTitle => 'Conflito de sincronização';

  @override
  String get dialogSyncConflictContent => 'Dados na nuvem encontrados. Deseja mesclar com os dados locais ou sobrescrever?';

  @override
  String get btnUseCloud => 'Usar a nuvem\n(descartar convidado)';

  @override
  String get btnMergeData => 'Mesclar dados';

  @override
  String lblVersion(Object version) {
    return 'Versão $version';
  }

  @override
  String get lblCurrentWeight => 'Peso atual';

  @override
  String get lblBasalBmr => 'Basal (BMR)';

  @override
  String get lblActiveTdee => 'Ativo (TDEE)';

  @override
  String get lblTotalHours => 'Horas totais';

  @override
  String get unitHoursShort => 'h';

  @override
  String get lblConsistency => 'Consistência';

  @override
  String get lblLast7Days => 'Últimos 7 dias';

  @override
  String get lblFasts => 'Jejuns';

  @override
  String get lblHours => 'Horas';

  @override
  String get lblDayStreak => 'Dias seguidos';

  @override
  String get msgStartJourney => 'Comece sua jornada hoje';

  @override
  String get lblToday => 'Hoje';

  @override
  String get lblYesterday => 'Ontem';

  @override
  String get lblFastingTypeCircadian => 'Circadiano';

  @override
  String get lblFastingTypeWarrior => 'Guerreiro';

  @override
  String get lblFastingTypeOmad => 'OMAD';

  @override
  String lblHistoryFor(Object date) {
    return 'Histórico de $date';
  }

  @override
  String get lblNoRecordsForDay => 'Nenhum registro para este dia';

  @override
  String get lblCustomPlan => 'Plano personalizado';

  @override
  String get lblAdjustDuration => 'Ajustar duração';

  @override
  String get lblFasting => 'Jejum';

  @override
  String get lblEating => 'Alimentação';

  @override
  String get lblSlideToAdjust => 'Deslize para ajustar as horas';

  @override
  String get btnStartCustomPlan => 'Iniciar plano personalizado';

  @override
  String get btnUnlockFeature => 'Desbloquear plano personalizado';

  @override
  String get proFeatureTitle => 'Recurso PRO';

  @override
  String get proFeatureDesc => 'Agendamentos de jejum personalizados estão disponíveis para usuários PRO.';

  @override
  String get setFastingGoal => 'Definir meta de jejum';

  @override
  String get fastingSaved => 'Jejum salvo! 🏆';

  @override
  String get whenStopEating => 'Quando você parou de comer?';

  @override
  String get editTime => 'Editar horário';

  @override
  String get customPlan => 'Personalizado';

  @override
  String get tapToEdit => 'Toque para definir a meta';

  @override
  String get timeLeft => 'RESTAM';

  @override
  String get maxBenefits => 'Benefícios máximos alcançados';

  @override
  String get appNameUpper => 'FASTABLE';

  @override
  String get splashSlogan => 'Liberte o potencial do seu corpo';

  @override
  String get weightSaved => 'Peso salvo';

  @override
  String get proSubtitle => 'Acesso ilimitado ao AI Coach e às receitas';

  @override
  String get featureCoach => 'AI Coach Fasty';

  @override
  String get featureCoachDesc => 'Conselhos personalizados e motivação 24/7';

  @override
  String get featureRecipes => 'Receitas saudáveis';

  @override
  String get featureRecipesDesc => 'Refeições keto, com baixo teor de carboidratos e adequadas ao jejum';

  @override
  String get featureNoAds => 'Sem anúncios';

  @override
  String get featureNoAdsDesc => 'Foque nos seus objetivos sem distrações';

  @override
  String get bestValue => 'MELHOR OFERTA';

  @override
  String get loadingOffers => 'A carregar ofertas...';

  @override
  String get welcomePro => 'Bem-vindo ao Pro! 🚀';

  @override
  String get errorPro => 'A compra falhou. Por favor, tente novamente.';

  @override
  String get confirmDeleteMsg => 'Esta ação não pode ser desfeita. Todos os seus dados serão perdidos.';

  @override
  String get statusLocked => 'Bloqueado';

  @override
  String get sectionLegal => 'Legal e suporte';

  @override
  String get btnOverwriteLocal => 'Sobrescrever dados locais';

  @override
  String get msgDeleteError => 'Erro ao excluir a conta';

  @override
  String get stepLanguage => 'Selecionar idioma';

  @override
  String get stepBodyMetrics => 'Métricas corporais';

  @override
  String get stepBodyMetricsDesc => 'Ajude-nos a calcular seu IMC e objetivos';

  @override
  String get activityHint => 'Usado para calcular seu gasto energético.';

  @override
  String get activitySedentaryDesc => 'Trabalho de escritório, pouco exercício';

  @override
  String get activityModerateDesc => 'Trabalho ativo ou exercício 3-4x';

  @override
  String get activityActiveDesc => 'Trabalho físico ou treino diário';

  @override
  String get stepGoal => 'Escolha seu objetivo';

  @override
  String get recommendationMsg => 'Recomendamos o plano 16-8 para você.';

  @override
  String get planBeginner => 'Iniciante';

  @override
  String get planPopular => 'Popular (16:8)';

  @override
  String get planAdvanced => 'Avançado (18:6)';

  @override
  String get planExpert => 'Especialista (OMAD)';

  @override
  String get labelRecommended => 'RECOMENDADO';

  @override
  String get permHealthConnect => 'Health Connect';

  @override
  String get permHealthConnectDesc => 'Sincronize peso e passos com o Google Fit';

  @override
  String get planMonthly => 'Mensal';

  @override
  String get planAnnual => 'Anual';

  @override
  String get planLifetime => 'Vitalício';

  @override
  String savePercent(String percent) {
    return 'POUPE $percent%';
  }

  @override
  String get medicalDisclaimerTitle => 'Aviso Médico e Fontes';

  @override
  String get medicalDisclaimerHeading => 'Aviso Médico';

  @override
  String get medicalDisclaimerBody => 'O Fastable foi projetado para ajudar você a monitorar seu jejum intermitente e fornecer treinamento com IA com base em conhecimentos gerais. NÃO é um dispositivo médico. As informações fornecidas são apenas para fins educacionais e não devem substituir o aconselhamento médico profissional.\n\nPor favor, consulte um médico antes de iniciar qualquer regime de jejum, especialmente se estiver grávida, amamentando, tiver diabetes ou qualquer outra condição médica.';

  @override
  String get scientificSourcesHeading => 'Fontes Científicas e Citações';

  @override
  String get sourceJohnsHopkins => 'Medicina Johns Hopkins';

  @override
  String get sourceJohnsHopkinsDesc => 'Jejum Intermitente: O que é e como funciona?';

  @override
  String get sourceMayoClinic => 'Clínica Mayo';

  @override
  String get sourceMayoClinicDesc => 'Dieta de jejum: Pode melhorar a saúde do meu coração?';

  @override
  String get sourceHarvard => 'Escola de Medicina de Harvard';

  @override
  String get sourceHarvardDesc => 'Jejum intermitente: Atualização surpreendente';

  @override
  String get legalAgreementPrefix => 'Ao continuar, você concorda com os ';

  @override
  String get legalTermsOfUse => 'Termos de Uso (EULA)';

  @override
  String get legalAgreementAnd => ' padrão da Apple e nossa ';

  @override
  String get legalPrivacyPolicy => 'Política de Privacidade';

  @override
  String get comingSoonTitle => 'Em breve!';

  @override
  String get comingSoonDesc => 'Estamos trabalhando duro para preparar um conteúdo incrível para você. Fique ligado!';

  @override
  String get statusNoRecipes => 'Nenhuma receita encontrada';

  @override
  String get aboutAndLegal => 'Sobre e Legal';

  @override
  String get settingsMedicalDisclaimer => 'Aviso Médico e Fontes';

  @override
  String get settingsTermsOfUse => 'Termos de Uso (EULA)';

  @override
  String get deleteAccountAndData => 'Excluir Conta e Dados';

  @override
  String get deleteAccountTitle => 'Excluir Conta?';

  @override
  String get deleteAccountContent => 'Esta ação é irreversível. Todo o seu histórico de jejum e dados locais serão excluídos permanentemente.';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Excluir';

  @override
  String get planExtended => 'Prolongado';
}
