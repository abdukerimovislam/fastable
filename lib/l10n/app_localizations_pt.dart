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
  String get dashboardOverview => 'Visão Geral';

  @override
  String get navTimer => 'Timer';

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
  String get fastingPhase => 'Fase de Jejum';

  @override
  String get eatingWindow => 'Janela de Alimentação';

  @override
  String get readyToFast => 'Pronto para Jejuar';

  @override
  String get autophagyZone => 'Zona de Autofagia';

  @override
  String get startFast => 'Iniciar Jejum';

  @override
  String get endFast => 'Encerrar Jejum';

  @override
  String get endCycle => 'Encerrar Ciclo';

  @override
  String get remaining => 'Restante';

  @override
  String get targetGoal => 'Meta Alvo';

  @override
  String get waterTracker => 'Rastreador de Água';

  @override
  String get waterCups => 'copos';

  @override
  String get addWater => 'Adicionar Água';

  @override
  String get waterToday => 'Água de Hoje';

  @override
  String get waterIntake => 'Consumo de Água';

  @override
  String get cups => 'copos';

  @override
  String get cupsUnit => 'copos';

  @override
  String get weightTracker => 'Rastreador de Peso';

  @override
  String get logWeight => 'Registrar Peso';

  @override
  String get saveWeight => 'Salvar Peso';

  @override
  String get weightJourney => 'Jornada de Peso';

  @override
  String get last7Days => 'Últimos 7 Dias';

  @override
  String get fastingHours => 'Horas de Jejum';

  @override
  String get currentWeight => 'Atual';

  @override
  String get goalWeight => 'Meta';

  @override
  String get startWeight => 'Inicial';

  @override
  String get addWeight => 'Adicionar Peso';

  @override
  String get enterWeight => 'Inserir peso';

  @override
  String get unitKg => 'kg';

  @override
  String get unitCm => 'cm';

  @override
  String get weightProgress => 'Progresso de Peso';

  @override
  String get chartEmpty => 'Add at least two weight entries to see a graph.';

  @override
  String get proBannerTitle => 'Fastable PRO';

  @override
  String get proBannerDesc => 'Desbloquear análises';

  @override
  String get premiumContentTitle => 'Conteúdo Premium';

  @override
  String get premiumContentDesc => 'Desbloqueie acesso total a todos os artigos e recursos.';

  @override
  String get getPro => 'Obter Acesso PRO';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String get proTitle => 'Desbloquear Fastable Pro';

  @override
  String get proMonthly => 'Assinatura Mensal';

  @override
  String get proAnnual => 'Annual Subscription (40% Off)';

  @override
  String get unlockAll => 'Desbloquear Tudo';

  @override
  String get accessStatus => 'Acesso Atual';

  @override
  String statusActive(Object date) {
    return 'Ativo até $date';
  }

  @override
  String get statusFree => 'Grátis';

  @override
  String get proRequired => 'Uma assinatura PRO é necessária para ver este conteúdo';

  @override
  String get proComingSoon => 'A versão PRO chegará em breve! Fique ligado.';

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
  String get historyEmpty => 'Nenhum jejum concluído ainda. Seu histórico aparecerá aqui!';

  @override
  String get fastComplete => 'Jejum Concluído! 🎉';

  @override
  String fastCompleteDesc(String time) {
    return 'Você jejuou por $time. Salvar este registro?';
  }

  @override
  String get noFastsOnDay => 'Nenhum jejum concluído neste dia.';

  @override
  String get detailsFor => 'Detalhes de';

  @override
  String get endCyclePrompt => 'Encerrar Janela de Alimentação?';

  @override
  String get endCyclePromptDesc => 'Isso encerrará sua janela de alimentação e redefinirá o ciclo.';

  @override
  String get endFastPrompt => 'Encerre seu ciclo atual para mudar o plano.';

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
  String get settingWaterGoal => 'Meta Diária de Água';

  @override
  String get settingHeight => 'Altura';

  @override
  String get settingGoalWeight => 'Peso Meta';

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
  String get healthConnectDisclosureIntro => 'Fastable solicita acesso de LEITURA e GRAVAÇÃO a dados de PESO via Health Connect.';

  @override
  String get healthConnectDisclosureRead => 'Usamos acesso de LEITURA para exibir seu gráfico de progresso de peso e estatísticas.';

  @override
  String get healthConnectDisclosureWrite => 'Usamos acesso de GRAVAÇÃO para que você possa salvar entradas de peso do Fastable.';

  @override
  String get healthConnectDisclosureSecure => 'Os dados são armazenados localmente. Você pode revogar as permissões a qualquer momento.';

  @override
  String get healthConnectConnected => 'Health Connect conectado!';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get notifyWater => 'Lembretes de Água';

  @override
  String get notifyWaterDesc => 'Receba lembretes para beber água';

  @override
  String get notifyWeight => 'Lembrete de Peso';

  @override
  String get notifyWeightDesc => 'Lembrete diário para se pesar';

  @override
  String get notifyFastingStart => 'Início do Jejum';

  @override
  String get notifyFastingStartDesc => 'Notificar quando a janela de jejum começar';

  @override
  String get simplifiedAnimation => 'Animações Simplificadas';

  @override
  String get simplifiedAnimationDesc => 'Reduz o desfoque e efeitos para melhorar a bateria.';

  @override
  String get settingPerformance => 'Desempenho';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get termsOfService => 'Termos de Uso';

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
  String get guestUser => 'Usuário Convidado';

  @override
  String get defaultUser => 'Usuário';

  @override
  String get anonymousLogin => 'Login Anônimo';

  @override
  String get dataOnDevice => 'Dados salvos no dispositivo';

  @override
  String get connectGoogle => 'Conectar Conta do Google';

  @override
  String get saveProgressCloud => 'Salvar progresso na nuvem';

  @override
  String get accountLinked => 'Conta vinculada com sucesso!';

  @override
  String get linkError => 'Erro ao vincular conta';

  @override
  String get resetAndExit => 'Redefinir Dados e Sair';

  @override
  String get deleteAndExit => 'Excluir e Sair';

  @override
  String get signOut => 'Sair';

  @override
  String get confirmLogout => 'Tem certeza de que deseja sair?';

  @override
  String get guestLogoutWarning => 'Você está usando uma conta de Convidado. Se você sair, todos os dados locais serão excluídos permanentemente.';

  @override
  String get deleteAccount => 'Excluir Conta';

  @override
  String get deleteAccountWarning => 'Tem certeza? Isso excluirá permanentemente todos os seus dados.';

  @override
  String get authWelcome => 'Bem-vindo ao Jejum Moderno';

  @override
  String get authSubtitle => 'Faça login para sincronizar dados';

  @override
  String get signInGoogle => 'Fazer login com o Google';

  @override
  String get continueGuest => 'Continuar como Convidado';

  @override
  String get signInFailed => 'O login falhou. Por favor, tente novamente.';

  @override
  String get welcomeMessage => 'Bem-vindo ao seu aplicativo de jejum!';

  @override
  String get choosePlan => 'Escolha o Plano';

  @override
  String get fastingPlan16_8 => '16:8 Jejum Intermitente';

  @override
  String get fastingPlan18_6 => '18:6 Jejum Intermitente';

  @override
  String get fastingPlan20_4 => '20:4 A Dieta do Guerreiro';

  @override
  String get fastingPlanEatStopEat => 'Coma-Pare-Coma (24h)';

  @override
  String get bmiCalculator => 'Calculadora de IMC';

  @override
  String get bmiCategory => 'Categoria';

  @override
  String get bmiUnderweight => 'Abaixo do peso';

  @override
  String get bmiNormal => 'Peso Normal';

  @override
  String get bmiOverweight => 'Sobrepeso';

  @override
  String get bmiObese => 'Obesidade';

  @override
  String get enterHeightCm => 'Insira a altura (cm)';

  @override
  String get enterGoalWeightKg => 'Insira o peso meta (kg)';

  @override
  String get fastingStats => 'Estatísticas de Jejum';

  @override
  String get fastingStatsCurrentStreak => 'Sequência Atual';

  @override
  String get fastingStatsDay => 'Dia';

  @override
  String get fastingStatsDays => 'Dias';

  @override
  String get fastingStatsTotalFasts => 'Total de Jejuns';

  @override
  String get fastingStatsTotalHours => 'Horas Totais';

  @override
  String get fastingStatsAvgFast => 'Média de Jejum';

  @override
  String get fastingStatsHours => 'Horas';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo!';

  @override
  String get onboardingWelcomeDesc => 'Inicie sua jornada rumo à saúde. Vamos configurar seu perfil.';

  @override
  String get onboardingGoalTitle => 'Quais são seus objetivos?';

  @override
  String get onboardingGoalDesc => 'Defina sua altura e peso ideal para que possamos calcular seu IMC.';

  @override
  String get onboardingPlanTitle => 'Escolha seu plano';

  @override
  String get onboardingPlanDesc => 'Com qual plano de jejum você gostaria de começar? Você pode alterá-lo depois.';

  @override
  String get onboardingCurrentWeight => 'Seu peso atual';

  @override
  String get getStarted => 'Começar';

  @override
  String get currentStage => 'Estágio Atual';

  @override
  String get nextStage => 'Próximo';

  @override
  String get stageAnabolicTitle => 'Anabólico (Alimentado)';

  @override
  String get stageAnabolicDesc => 'Seu corpo está digerindo e usando glicose como energia.';

  @override
  String get stageCatabolicTitle => 'Catabólico';

  @override
  String get stageCatabolicDesc => 'Os níveis de açúcar no sangue caem. O corpo começa a usar glicogênio.';

  @override
  String get stageKetosisTitle => 'Cetose';

  @override
  String get stageKetosisDesc => 'As reservas de glicogênio estão esgotadas. O corpo muda para queimar gordura.';

  @override
  String get stageAutophagyTitle => 'Autofagia';

  @override
  String get stageAutophagyDesc => 'Começa o processo de limpeza celular. Seu corpo recicla células velhas.';

  @override
  String get stagePeakAutophagyTitle => 'Pico de Autofagia';

  @override
  String get stagePeakAutophagyDesc => 'O processo de autofagia atinge seu pico, maximizando a renovação celular.';

  @override
  String get achievementsTitle => 'Conquistas';

  @override
  String get achievementsUnlocked => 'Desbloqueado';

  @override
  String get achievementsLocked => 'Bloqueado';

  @override
  String achEarnedOn(Object date) {
    return 'Ganho em $date';
  }

  @override
  String get achFirstFastTitle => 'Primeiro Jejum!';

  @override
  String get achFirstFastDesc => 'Conclua sua primeira sessão de jejum.';

  @override
  String get achStreak3Title => 'Começando';

  @override
  String get achStreak3Desc => 'Mantenha uma sequência de 3 dias de jejum.';

  @override
  String get achStreak7Title => 'Consistente';

  @override
  String get achStreak7Desc => 'Alcance uma sequência de 7 dias. Você está incrível!';

  @override
  String get achTotal10Title => 'Novato';

  @override
  String get achTotal10Desc => 'Conclua 10 jejuns no total.';

  @override
  String get achTotalHours100Title => 'Clube das 100 Horas';

  @override
  String get achTotalHours100Desc => 'Acumule 100 horas de jejum.';

  @override
  String get journalTitle => 'Nota de Diário';

  @override
  String get journalHint => 'Como você se sentiu durante este jejum?';

  @override
  String get addNote => 'Adicionar Nota';

  @override
  String get editNote => 'Editar Nota';

  @override
  String get noteSaved => 'Nota salva';

  @override
  String get syncHealthTitle => 'Sincronizar com Apple Health';

  @override
  String get syncHealthDesc => 'Grava automaticamente dados de jejum e lê peso.';

  @override
  String get shareProgress => 'Compartilhar Progresso';

  @override
  String get metricPhase => 'Fase';

  @override
  String get metricStreak => 'Sequência';

  @override
  String get metricStatus => 'Status';

  @override
  String get statusDigesting => 'Digerindo';

  @override
  String get statusStable => 'Estável';

  @override
  String get statusFatBurn => 'Queima de Gordura';

  @override
  String get statusKetosis => 'Cetose';

  @override
  String get statusNormal => 'Normal';

  @override
  String get titleCurrentPhase => 'Fase Atual';

  @override
  String get valFastingZone => 'Zona de Jejum';

  @override
  String get valEatingWindow => 'Janela de Alimentação';

  @override
  String get descFastingZone => 'Você está atualmente na janela de jejum. Nenhuma caloria deve ser consumida.';

  @override
  String get descEatingWindow => 'Você está na sua janela de alimentação. Concentre-se em alimentos ricos em nutrientes.';

  @override
  String get titleConsistencyStreak => 'Sequência de Consistência';

  @override
  String valStreakDays(int days) {
    return '$days Dias 🔥';
  }

  @override
  String descStreak(int days) {
    return 'Você atingiu sua meta de jejum por $days dias consecutivos. Continue assim para construir um hábito!';
  }

  @override
  String get titleBodyStatus => 'Status do Corpo';

  @override
  String get descDigesting => 'Seu corpo está digerindo alimentos e repondo as reservas de glicogênio. Os níveis de insulina estão subindo.';

  @override
  String get descStable => 'Seus níveis de açúcar no sangue estão se normalizando. O corpo se prepara para mudar de glicose para gordura como combustível.';

  @override
  String get descFatBurn => 'Bom trabalho! Seu corpo está começando a queimar gordura armazenada para obter energia. Os níveis de hormônio de crescimento podem começar a aumentar.';

  @override
  String get descKetosis => 'Cetose Profunda! Seu corpo está queimando gordura eficientemente. A autofagia (limpeza celular) pode começar em breve.';

  @override
  String get btnGotIt => 'Entendi!';

  @override
  String get stage0_4 => 'Açúcar no sangue sobe';

  @override
  String get stage0_4_desc => 'Seu corpo está digerindo sua última refeição. Açúcar e insulina sobem.';

  @override
  String get stage4_8 => 'Queda de Açúcar no Sangue';

  @override
  String get stage4_8_desc => 'A insulina começa a cair. Seu corpo usa a glicose armazenada.';

  @override
  String get stage8_12 => 'Normalização';

  @override
  String get stage8_12_desc => 'O sistema digestivo descansa. Seu corpo começa a curar a si mesmo.';

  @override
  String get stage12_16 => 'Queima de Gordura';

  @override
  String get stage12_16_desc => 'A insulina está baixa. Seu corpo começa a queimar gordura armazenada.';

  @override
  String get stage16_18 => 'Cetose';

  @override
  String get stage16_18_desc => 'A queima de gordura acelera. Você está no modo de queima total.';

  @override
  String get stage18_24 => 'Autofagia';

  @override
  String get stage18_24_desc => 'A limpeza celular começa. Seu corpo recicla células velhas.';

  @override
  String get stage24_plus => 'Reparo Profundo';

  @override
  String get stage24_plus_desc => 'Os níveis de hormônio do crescimento aumentam. Ocorre regeneração celular.';

  @override
  String get viewTimeline => 'Ver Linha do Tempo do Corpo';

  @override
  String get navFood => 'Comida';

  @override
  String get circadianEnabled => 'Modo circadiano ativado';

  @override
  String get circadianDisabled => 'Modo circadiano desativado';

  @override
  String get tabRecipes => 'Receitas';

  @override
  String get tabKnowledge => 'Conhecimento';

  @override
  String get categoryAll => 'Tudo';

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
  String get waterSettings => 'Configurações de Água';

  @override
  String get removeCup => 'Remover Copo (-1)';

  @override
  String get dailyGoal => 'Meta Diária';

  @override
  String get bmiScore => 'Pontuação IMC';

  @override
  String bmiDescription(int height, String weight) {
    return 'Baseado na sua altura ($height cm) e peso ($weight kg).';
  }

  @override
  String get onboardingTitle => 'Vamos personalizar\nsua jornada';

  @override
  String get onboardingHeightTitle => 'Qual é a sua altura?';

  @override
  String get onboardingHeightDesc => 'Precisamos disso para calibrar o Visualizador Corporal e calcular com precisão.';

  @override
  String get onboardingWeightTitle => 'Qual é o seu peso?';

  @override
  String get onboardingWeightDesc => 'Isso nos ajuda a acompanhar seu progresso e ajustar seu plano.';

  @override
  String get btnNext => 'Próximo';

  @override
  String get btnFinish => 'Começar Jornada';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get statsSuccessRate => 'Taxa de Sucesso';

  @override
  String statsSuccessDesc(int success, int total) {
    return '$success de $total jejuns foram de 16h+';
  }

  @override
  String get statsTotalFasts => 'Total de Jejuns';

  @override
  String get statsTotalHours => 'Total de Horas';

  @override
  String get statsAverage => 'Média';

  @override
  String get statsLongest => 'Mais Longo';

  @override
  String get circadianTitle => 'Ritmo Circadiano';

  @override
  String get circadianIntroTitle => 'Coma com o Sol ☀️';

  @override
  String get circadianIntroDesc => 'Seu metabolismo está ligado ao sol.\n\n• Nascer do sol: Melhor hora para acordar e se hidratar.\n• Dia: Metabolismo alto. Ideal para comer.\n• Pôr do sol: O metabolismo desacelera. Pare de comer.\n• Noite: Modo de reparação profunda. O jejum é fácil.\n\nEste modo ajusta automaticamente suas metas de jejum aos horários do nascer e pôr do sol em sua localização.';

  @override
  String get circadianBtnEnable => 'Ativar Modo Circadiano';

  @override
  String get circadianBtnDisable => 'Desativar';

  @override
  String get circadianTargetSunrise => 'Até o Nascer do Sol';

  @override
  String get circadianTargetSunset => 'Até o Pôr do Sol';

  @override
  String get circadianPhaseDay => 'Dia (Comer)';

  @override
  String get circadianPhaseNight => 'Noite (Ajuar)';

  @override
  String get circadianWarnDayTitle => 'É de Dia ☀️';

  @override
  String get circadianWarnDayDesc => 'O sol já nasceu! Seu corpo está pronto para a comida. Idealmente, espere até o pôr do sol para começar a jejuar.';

  @override
  String get circadianWarnBtnStart => 'Começar Mesmo Assim';

  @override
  String get circadianWarnBtnWait => 'Esperar pelo Pôr do Sol';

  @override
  String get circadianBonusTime => 'Tempo Bônus 🔥';

  @override
  String get circadianSyncing => 'Sincronizando com o Sol...';

  @override
  String get circadianError => 'Não foi possível obter a localização. Usando temporizador padrão.';

  @override
  String get circadianManaged => 'Controlado pelo Sol';

  @override
  String get notifBio4hTitle => 'Açúcar no Sangue Estabilizado 🩸';

  @override
  String get notifBio4hBody => 'Seus níveis de insulina estão caindo. Falsas pontadas de fome podem desaparecer.';

  @override
  String get notifBio8hTitle => 'O Estômago está Vazio ✅';

  @override
  String get notifBio8hBody => 'A digestão está completa. Seu corpo está mudando para o modo de reparação.';

  @override
  String get notifBio12hTitle => 'Entrando em Cetose 🔥';

  @override
  String get notifBio12hBody => 'Seu corpo começou a queimar gordura armazenada para obter energia!';

  @override
  String get notifBio16hTitle => 'Pico de Queima de Gordura ⚡️';

  @override
  String get notifBio16hBody => 'O metabolismo está acelerado. Você está na zona de queima intensa.';

  @override
  String get notifBio18hTitle => 'Autofagia Iniciada ♻️';

  @override
  String get notifBio18hBody => 'Limpeza celular ativa. Seu corpo está reciclando células velhas.';

  @override
  String get notifBio24hTitle => 'Pico de HGH 🛡';

  @override
  String get notifBio24hBody => 'Os níveis de hormônio do crescimento aumentaram para proteger seus músculos.';

  @override
  String get notifProg50Title => 'Na Metade do Caminho! 🚀';

  @override
  String get notifProg50Body => 'Você passou de 50% do seu objetivo. Continue assim!';

  @override
  String get notifProg1hTitle => 'Falta 1 Hora ⏳';

  @override
  String get notifProg1hBody => 'Quase lá! Você pode começar a preparar sua refeição.';

  @override
  String get notifProgFinishTitle => 'Objetivo Alcançado! 🏆';

  @override
  String get notifProgFinishBody => 'Você conseguiu! Não se esqueça de parar o temporizador.';

  @override
  String get notifWaterTitle => 'Beba Água 💧';

  @override
  String get notifWaterBody => 'A hidratação aumenta seu metabolismo e reduz a fome.';

  @override
  String get notifWeightTitle => 'Pesagem Matinal ⚖️';

  @override
  String get notifWeightBody => 'A manhã é a melhor hora para acompanhar seu peso.';

  @override
  String get permTitle => 'Ativar Permissões';

  @override
  String get permDesc => 'Para lhe dar a melhor experiência, Fastable precisa de acesso a notificações e dados de saúde.';

  @override
  String get permNotifTitle => 'Notificações';

  @override
  String get permNotifDesc => 'Mantenha-se no caminho com alertas de jejum.';

  @override
  String get permHealthTitle => 'Apple Health';

  @override
  String get permHealthDesc => 'Sincronize dados de peso e água.';

  @override
  String get permAllow => 'Permitir';

  @override
  String get permContinue => 'Continuar';

  @override
  String get achFirstFast => 'Primeiro Passo';

  @override
  String get achStreak3 => 'Consistência';

  @override
  String get achStreak7 => 'Imparável';

  @override
  String get achTotal10 => 'Dedicado';

  @override
  String get achTotalHours100 => 'Centurião';

  @override
  String get onboardingDesc => 'Vamos calcular sua taxa metabólica.';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnStart => 'Começar Jornada';

  @override
  String get selectGender => 'Gênero';

  @override
  String get selectAge => 'Idade';

  @override
  String get selectWeight => 'Peso';

  @override
  String get selectHeight => 'Altura';

  @override
  String get selectActivity => 'Nível de Atividade';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activityModerate => 'Moderate';

  @override
  String get activityActive => 'Very Active';

  @override
  String get contactSupport => 'Contatar Suporte';

  @override
  String get metabolicProfile => 'Perfil Metabólico';

  @override
  String ageYears(int age) {
    return '$age anos';
  }

  @override
  String get metricBmrTitle => 'TMB';

  @override
  String get metricBmrSubtitle => 'Basal';

  @override
  String get metricBmrDesc => 'Taxa Metabólica Basal. Calorias queimadas em repouso completo.';

  @override
  String get metricTdeeTitle => 'GEDT';

  @override
  String get metricTdeeSubtitle => 'Manutenção';

  @override
  String get metricTdeeDesc => 'Gasto Energético Diário Total. Calorias necessárias para manter o peso atual.';

  @override
  String get dialogStartTitle => 'Quando começou o seu jejum?';

  @override
  String get btnStartFasting => 'Iniciar Jejum';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get stage2Title => 'Açúcar no sangue caindo 📉';

  @override
  String get stage2Body => 'Seu corpo está se acalmando. Se sentir fome, beba água. 💧';

  @override
  String get stage4Title => 'A insulina está caindo ⬇️';

  @override
  String get stage4Body => 'Ótimo! Seu corpo para de armazenar gordura e se prepara para queimá-la.';

  @override
  String get stage8Title => 'A limpeza começou ✨';

  @override
  String get stage8Body => '8 horas. Seu estômago está descansando. Você está indo muito bem!';

  @override
  String get stage11Title => 'Modo de Queima de Gordura 🔥';

  @override
  String get stage11Body => 'A parte divertida começa! Seu corpo muda para as reservas internas.';

  @override
  String get stage12Title => 'Cetose Ativada 🚀';

  @override
  String get stage12Body => 'As células de gordura viram energia. Sua mente fica mais clara.';

  @override
  String get stage14Title => 'Cetose Profunda 🔥';

  @override
  String get stage14Body => 'Você está na zona de queima de gordura! A desintoxicação é rápida.';

  @override
  String get stage16Title => 'Autofagia (Reparação Celular) 🧬';

  @override
  String get stage16Body => 'Suas células estão se renovando. Esta é a fonte da juventude!';

  @override
  String get stage18Title => 'Pico do Hormônio do Crescimento 📈';

  @override
  String get stage18Body => 'O hormônio do crescimento ajuda os músculos. Você está mais forte!';

  @override
  String get stage24Title => '24 Horas! 🏆';

  @override
  String get stage24Body => 'Incrível! Dia completo. A limpeza profunda está a todo vapor.';

  @override
  String get notifyHalfwayTitle => 'Na metade do caminho! ⛰️';

  @override
  String get notifyHalfwayBody => 'A parte mais difícil já passou. Seu corpo agradece.';

  @override
  String get notify1hTitle => 'Reta Final! 🏁';

  @override
  String get notify1hBody => 'Falta apenas 1 hora. Você está indo incrivelmente bem!';

  @override
  String get notifyGoalTitle => 'Objetivo Alcançado! 🎉';

  @override
  String get notifyGoalBody => 'Parabéns! Quebre seu jejum com cuidado.';

  @override
  String get notifyEatCloseTitle => 'A janela de alimentação está fechando 🛑';

  @override
  String get notifyEatCloseBody => 'Hora de começar seu próximo jejum. Verifique o aplicativo!';

  @override
  String get notifyEat30mTitle => '30 minutos restantes 🥗';

  @override
  String get notifyEat30mBody => 'Não se esqueça de beber água ou comer um último lanche.';

  @override
  String get learnTitle => 'Aprender e Comer';

  @override
  String get tabArticles => 'Artigos';

  @override
  String get catBasics => 'Básicos';

  @override
  String get catNutrition => 'Nutrição';

  @override
  String get catHealth => 'Saúde';

  @override
  String get catKeto => 'Keto';

  @override
  String get headerLatestArticles => 'Artigos Mais Recentes';

  @override
  String get headerHealthyChoices => 'Escolhas Saudáveis';

  @override
  String get statusNoArticles => 'Nenhum artigo encontrado';

  @override
  String get msgComingSoon => 'Este recurso estará disponível em breve!';

  @override
  String get learnBannerTitle => 'Desbloqueie mais de 500 Receitas';

  @override
  String get learnBannerSubtitle => 'Obtenha acesso completo com PRO';

  @override
  String get labelPremium => 'PREMIUM';

  @override
  String get bannerRecipeTitle => 'Receitas Saudáveis';

  @override
  String get bannerRecipeSubtitle => 'Keto, Low-Carb e Mais';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitMin => 'min';

  @override
  String get lblAchievements => 'Conquistas';

  @override
  String get lblPersonalData => 'Dados Pessoais';

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
  String get lblActivity => 'Nível de Atividade';

  @override
  String get lblLanguage => 'Idioma';

  @override
  String get msgHealthSyncEnabled => 'Sincronização de Saúde Ativada!';

  @override
  String get msgHealthSyncFailed => 'Permissão negada';

  @override
  String get aiGreeting => 'Olá! Eu sou Fasty 🥑. Como posso te ajudar a atingir seus objetivos hoje?';

  @override
  String get aiConnectionError => 'Ops! Perdi a conexão. Verifique sua internet ou tente novamente mais tarde. 🥑';

  @override
  String get aiSystemError => 'O serviço de IA não está configurado corretamente (Falta a chave API).';

  @override
  String get aiCoachTitle => 'Coach de Jejum com IA';

  @override
  String get aiCoachDesc => 'Obtenha respostas instantâneas sobre Keto, Jejum Intermitente e hábitos saudáveis do nosso assistente inteligente de IA.';

  @override
  String get aiChatHint => 'Pergunte sobre keto ou jejum...';

  @override
  String get btnUnlockPro => 'Desbloquear com PRO';

  @override
  String get aiInsightFallback => 'Consistência é a chave! Beba água e continue se movendo. 💧';

  @override
  String get aiErrorConnection => 'Problema de conexão. Por favor, tente novamente mais tarde.';

  @override
  String get aiInsightTitle => 'INSIGHT DIÁRIO';

  @override
  String get aiInsightTeaser => 'Com base nos seus últimos 7 dias de jejum, encontramos um padrão significativo que afeta seu progresso...';

  @override
  String get tapToUnlock => 'Toque para Desbloquear';

  @override
  String get notifyAiInsightTitle => 'Seu Insight Diário de IA está Pronto! 🥑';

  @override
  String get notifyAiInsightBody => 'Veja o que o Fasty analisou para você hoje. Toque para desbloquear.';

  @override
  String get notifyWeightTitle => 'Registre seu peso ⚖️';

  @override
  String get notifyWeightBody => 'Consistência é a chave! Registre seu peso hoje.';

  @override
  String get aiInsightNotEnoughData => 'Continue registrando! Precisamos de pelo menos 3 jejuns para analisar seus padrões únicos. 📊';

  @override
  String msgLoginFailed(Object error) {
    return 'Falha no login: $error';
  }

  @override
  String msgAppleLoginFailed(Object error) {
    return 'O login com a Apple falhou: $error';
  }

  @override
  String get msgSyncCompleted => 'Sincronização concluída';

  @override
  String get msgErrorRelogin => 'Erro: Por favor, faça o login novamente e tente de novo.';

  @override
  String get signInApple => 'Fazer login com a Apple';

  @override
  String get lblDangerZone => 'ZONA DE PERIGO';

  @override
  String get btnDeleteAccount => 'Excluir Conta';

  @override
  String get dialogDeleteAccountTitle => 'Excluir Conta?';

  @override
  String get dialogDeleteAccountContent => 'Esta ação é permanente. Todo o seu histórico de peso, registros de jejum e conquistas serão excluídos da nuvem.';

  @override
  String get btnDelete => 'EXCLUIR';

  @override
  String get dialogSyncConflictTitle => 'Conflito de Sincronização';

  @override
  String get dialogSyncConflictContent => 'Dados encontrados na nuvem. Mesclar com dados locais ou substituir?';

  @override
  String get btnUseCloud => 'Usar Nuvem\n(Descartar Convidado)';

  @override
  String get btnMergeData => 'Mesclar Dados';

  @override
  String lblVersion(Object version) {
    return 'Versão $version';
  }

  @override
  String get lblCurrentWeight => 'Peso Atual';

  @override
  String get lblBasalBmr => 'Basal (TMB)';

  @override
  String get lblActiveTdee => 'Ativo (GEDT)';

  @override
  String get lblTotalHours => 'Horas Totais';

  @override
  String get unitHoursShort => 'h';

  @override
  String get lblConsistency => 'Consistência';

  @override
  String get lblLast7Days => 'Últimos 7 Dias';

  @override
  String get lblFasts => 'Jejuns';

  @override
  String get lblHours => 'Horas';

  @override
  String get lblDayStreak => 'Sequência de Dias';

  @override
  String get msgStartJourney => 'Comece sua jornada hoje';

  @override
  String get lblToday => 'Hoje';

  @override
  String get lblYesterday => 'Ontem';

  @override
  String get confirmTime => 'Confirmar Horário';

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
  String get lblNoRecordsForDay => 'Sem registros para este dia';

  @override
  String get lblCustomPlan => 'Plano Personalizado';

  @override
  String get lblAdjustDuration => 'Ajustar Duração';

  @override
  String get lblFasting => 'Jejum';

  @override
  String get lblEating => 'Alimentação';

  @override
  String get lblSlideToAdjust => 'Deslize para ajustar as horas';

  @override
  String get btnStartCustomPlan => 'Iniciar Plano Personalizado';

  @override
  String get btnUnlockFeature => 'Desbloquear Plano Personalizado';

  @override
  String get proFeatureTitle => 'Recurso Pro';

  @override
  String get proFeatureDesc => 'Horários de jejum personalizados estão disponíveis para usuários Pro.';

  @override
  String get setFastingGoal => 'Definir Meta de Jejum';

  @override
  String get fastingSaved => 'Jejum salvo! 🏆';

  @override
  String get whenStopEating => 'Quando você parou de comer?';

  @override
  String get editTime => 'Editar Tempo';

  @override
  String get customPlan => 'Personalizado';

  @override
  String get tapToEdit => 'Toque para ajustar a meta';

  @override
  String get timeLeft => 'RESTANTE';

  @override
  String get maxBenefits => 'Benefícios Máximos Alcançados';

  @override
  String get appNameUpper => 'FASTABLE';

  @override
  String get splashSlogan => 'Desbloqueie o potencial do seu corpo';

  @override
  String get weightSaved => 'Peso salvo';

  @override
  String get proSubtitle => 'Libere todo o seu potencial';

  @override
  String get featureCoach => 'Coach Fasty com IA';

  @override
  String get featureCoachDesc => 'Conselhos personalizados e motivação 24/7';

  @override
  String get featureRecipes => 'Receitas Saudáveis';

  @override
  String get featureRecipesDesc => 'Refeições amigáveis para Keto, Low-Carb e Jejum';

  @override
  String get featureNoAds => 'Experiência Sem Anúncios';

  @override
  String get featureNoAdsDesc => 'Concentre-se em seus objetivos sem distrações';

  @override
  String get bestValue => 'MELHOR VALOR';

  @override
  String get loadingOffers => 'Carregando ofertas...';

  @override
  String get welcomePro => 'Bem-vindo ao Pro! 🚀';

  @override
  String get errorPro => 'A compra falhou. Por favor, tente novamente.';

  @override
  String get confirmDeleteMsg => 'Esta ação não pode ser desfeita. Todos os seus dados serão perdidos.';

  @override
  String get statusLocked => 'Bloqueado';

  @override
  String get sectionLegal => 'Legal e Suporte';

  @override
  String get btnOverwriteLocal => 'Substituir Local';

  @override
  String get msgDeleteError => 'Erro ao excluir conta';

  @override
  String get msgDeleteReauthCancelled => 'Exclusão de conta cancelada.';

  @override
  String get msgDeleteReauthFailed => 'Não conseguimos confirmar sua identidade. Por favor, tente novamente.';

  @override
  String get msgDeleteReauthUnavailable => 'Por favor, faça login novamente com o provedor original antes de excluir esta conta.';

  @override
  String get stepLanguage => 'Selecionar Idioma';

  @override
  String get stepBodyMetrics => 'Métricas Corporais';

  @override
  String get stepBodyMetricsDesc => 'Ajude-nos a calcular seu IMC e metas';

  @override
  String get activityHint => 'Usado para calcular seu gasto diário de energia.';

  @override
  String get activitySedentaryDesc => 'Trabalho de escritório, pouco exercício';

  @override
  String get activityModerateDesc => 'Trabalho ativo ou exercício 3-4x na semana';

  @override
  String get activityActiveDesc => 'Trabalho físico ou treino diário';

  @override
  String get stepGoal => 'Escolha seu Objetivo';

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
  String get permHealthConnectDesc => 'Sincroniza peso e passos com Google Fit';

  @override
  String get planMonthly => 'Mensal';

  @override
  String get planAnnual => 'Anual';

  @override
  String get planLifetime => 'Vitalício';

  @override
  String savePercent(String percent) {
    return 'ECONOMIZE $percent%';
  }

  @override
  String get medicalDisclaimerTitle => 'Aviso Médico e Fontes';

  @override
  String get medicalDisclaimerHeading => 'Aviso Médico';

  @override
  String get medicalDisclaimerBody => 'Fastable foi projetado para ajudar a monitorar seu jejum intermitente. NÃO é um dispositivo médico. As informações fornecidas são apenas para fins educacionais e não devem substituir conselhos médicos profissionais.\n\nConsulte um médico antes de iniciar qualquer regime de jejum, especialmente se estiver grávida, amamentando, for diabético ou tiver outras condições médicas.';

  @override
  String get scientificSourcesHeading => 'Fontes Científicas e Citações';

  @override
  String get sourceJohnsHopkins => 'Johns Hopkins Medicine';

  @override
  String get sourceJohnsHopkinsDesc => 'Jejum Intermitente: O que é e como funciona?';

  @override
  String get sourceMayoClinic => 'Mayo Clinic';

  @override
  String get sourceMayoClinicDesc => 'Dieta de jejum: Pode melhorar a saúde do meu coração?';

  @override
  String get sourceHarvard => 'Harvard Medical School';

  @override
  String get sourceHarvardDesc => 'Jejum intermitente: Atualização surpreendente';

  @override
  String get legalAgreementPrefix => 'Ao continuar, você concorda com os ';

  @override
  String get legalTermsOfUse => 'Termos de Uso (EULA)';

  @override
  String get legalAgreementAnd => ' e nossa ';

  @override
  String get legalPrivacyPolicy => 'Política de Privacidade';

  @override
  String get comingSoonTitle => 'Em breve!';

  @override
  String get comingSoonDesc => 'Estamos trabalhando duro para preparar conteúdo incrível para você. Fique ligado!';

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
  String get planExtended => 'Estendido';

  @override
  String get zoneSugarRises => 'Açúcar no Sangue Sobe';

  @override
  String get zoneSugarRisesDesc => 'Seu corpo está processando sua última refeição e armazenando energia.';

  @override
  String get zoneSugarDrops => 'Açúcar no Sangue Cai';

  @override
  String get zoneSugarDropsDesc => 'A digestão termina. Os níveis de açúcar no sangue voltam ao normal.';

  @override
  String get zoneFatBurning => 'Queima de Gordura';

  @override
  String get zoneFatBurningDesc => 'Seu corpo começa a queimar gordura armazenada para obter energia.';

  @override
  String get zoneKetosis => 'Cetose';

  @override
  String get zoneKetosisDesc => 'A queima de gordura acelera. A clareza mental aumenta.';

  @override
  String get zoneAutophagy => 'Autofagia';

  @override
  String get zoneAutophagyDesc => 'O reparo e a reciclagem celular começam. Efeitos antienvelhecimento.';

  @override
  String get zoneGrowthHormone => 'Hormônio do Crescimento';

  @override
  String get zoneGrowthHormoneDesc => 'Pico de queima de gordura, reparação de tecidos e preservação muscular.';

  @override
  String continueForPrice(String price) {
    return 'Continuar por $price';
  }

  @override
  String get offersUnavailable => 'As ofertas estão temporariamente indisponíveis';

  @override
  String get billedMonthly => 'Faturado mensalmente';

  @override
  String get billedAnnually => 'Faturado anualmente';

  @override
  String get oneTimePurchase => 'Compra única';

  @override
  String get goalPriorityTitle => 'O que é mais importante agora?';

  @override
  String get goalPriorityDesc => 'Usamos isso para equilibrar velocidade, recuperação e consistência a longo prazo.';

  @override
  String get goalFatLossTitle => 'Perder gordura mais rápido';

  @override
  String get goalFatLossDesc => 'Favorecer janelas de jejum mais fortes quando seu perfil puder lidar com elas.';

  @override
  String get goalHealthTitle => 'Melhorar a saúde e energia';

  @override
  String get goalHealthDesc => 'Busque um plano equilibrado que apoie o foco, a energia e a adesão.';

  @override
  String get goalHabitTitle => 'Construir um hábito sustentável';

  @override
  String get goalHabitDesc => 'Comece mais fácil para que a rotina realmente se fixe.';

  @override
  String get routineTitle => 'Conte-nos sobre sua rotina';

  @override
  String get routineDesc => 'O sono e a experiência com jejum mudam o quão agressivo seu plano inicial deve ser.';

  @override
  String get fastingExperienceTitle => 'Experiência de jejum';

  @override
  String get experienceBeginnerTitle => 'Iniciante';

  @override
  String get experienceBeginnerDesc => 'Sou novo no jejum ou geralmente paro cedo.';

  @override
  String get experienceIntermediateTitle => 'Alguma experiência';

  @override
  String get experienceIntermediateDesc => 'Consigo lidar com jejuns de 14-16 horas sem muito problema.';

  @override
  String get experienceAdvancedTitle => 'Avançado';

  @override
  String get experienceAdvancedDesc => 'Já fiz jejuns mais longos e quero um protocolo mais forte.';

  @override
  String get sleepPatternTitle => 'Horário de sono';

  @override
  String get sleepRegularTitle => 'Sono regular';

  @override
  String get sleepRegularDesc => 'Meu horário de dormir e acordar é majoritariamente consistente.';

  @override
  String get sleepLateTitle => 'Noites longas';

  @override
  String get sleepLateDesc => 'Frequentemente durmo tarde ou saio da rotina nos fins de semana.';

  @override
  String get sleepIrregularTitle => 'Irregular ou turnos';

  @override
  String get sleepIrregularDesc => 'Meu sono muda muito ou trabalho em turnos.';

  @override
  String get smartPlanDashboardTitle => 'Sua estratégia atual';

  @override
  String get smartPlanProfileTitle => 'Sua estratégia inicial';

  @override
  String get smartPlanCurrentPlanLabel => 'Plano atual';

  @override
  String get smartPlanRecommendedPlanLabel => 'Recomendação inteligente';

  @override
  String get smartPlanSignalsLabel => 'Sinais';

  @override
  String get smartPlanTitle => 'Recomendação inteligente';

  @override
  String smartPlanBestMatch(String plan) {
    return 'Melhor plano inicial: $plan';
  }

  @override
  String get smartPlanHint => 'Você pode mudar isso depois nas configurações.';

  @override
  String get smartPlanWhyRecovery => 'Uma janela mais suave é melhor para recuperação e consistência.';

  @override
  String get smartPlanWhyActive => 'Seu nível de atividade favorece um plano que protege energia e treinos.';

  @override
  String get smartPlanWhyBeginner => 'Seu objetivo e experiência sugerem começar com um plano repetível.';

  @override
  String get smartPlanWhyBalanced => 'Isso oferece fortes benefícios do jejum sem ser muito agressivo.';

  @override
  String get smartPlanWhyAggressive => 'Seu perfil atual pode lidar com uma janela mais restrita.';

  @override
  String get smartPlanWhySleep => 'Seu horário de sono favorece um plano que adiciona menos estresse.';

  @override
  String get smartPlanWhySustainable => 'Um início sustentável geralmente leva a uma melhor adesão.';

  @override
  String smartPlanAlternativeEasier(String plan) {
    return '$plan é uma opção mais suave se você deseja um ajuste mais fácil.';
  }

  @override
  String smartPlanAlternativeStronger(String plan) {
    return '$plan é uma opção mais forte se você deseja um corte mais ambicioso.';
  }

  @override
  String smartPlanCoachGreeting(String plan, String goal, String experience, String sleep) {
    return 'Eu sou Fasty 🥑. Você está no plano $plan focado em $goal. Com sua experiência $experience e sono $sleep, eu posso te ajudar.';
  }

  @override
  String get smartPlanUseRecommendation => 'Usar recomendação inteligente';

  @override
  String get labelAlternative => 'ALTERNATIVA';

  @override
  String perMonthEquivalent(String price, String period) {
    return '~$price/$period';
  }

  @override
  String get circadianProExclusive => 'EXCLUSIVO PRO';

  @override
  String get circadianStartFast => 'Iniciar Jejum Circadiano';

  @override
  String get sunriseLabel => 'Nascer do sol';

  @override
  String get sunsetLabel => 'Pôr do sol';

  @override
  String get lastMeal => 'Última Refeição';

  @override
  String get circadianTotalWindow => 'Janela Total de Jejum';

  @override
  String get hoursLabel => 'horas';

  @override
  String get basedOnLocalCoordinates => 'Baseado em suas coordenadas locais';

  @override
  String get locationRequiredTitle => 'Localização Necessária';

  @override
  String get locationRequiredDesc => 'Precisamos da sua localização para calcular a hora exata do pôr do sol em sua cidade.';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get circadianStarted => 'Jejum Circadiano Iniciado! 🌅';

  @override
  String get planCircadianTitle => 'Jejum Circadiano';

  @override
  String get planCircadianSubtitle => 'Alinhe o jejum com o sol';

  @override
  String get planCustomSubtitle => 'Defina sua própria janela';

  @override
  String get planPresets => 'Predefinições';

  @override
  String durationHoursShort(int hours) {
    return '${hours}h';
  }

  @override
  String durationHoursMinutesShort(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get endFastCongrats => 'Você conseguiu! 🎉';

  @override
  String endFastTotalTime(String time) {
    return 'Tempo total de jejum: $time';
  }

  @override
  String get endFastHowFeel => 'Como você se sente?';

  @override
  String get endFastSaveEat => 'Salvar e Comer';

  @override
  String get endFastKeepFasting => 'Cancelar, continuar jejuando';

  @override
  String get proAccessLabel => 'ACESSO PRO';

  @override
  String get timerEndTitle => 'Quando você quebrou seu jejum?';

  @override
  String get timerCannotStartFuture => 'Você não pode iniciar um jejum no futuro.';

  @override
  String get timerCannotEndFuture => 'Você não pode terminar um jejum no futuro.';

  @override
  String get timerEndBeforeStart => 'A hora de término não pode ser antes do início.';

  @override
  String get timerGoalReachedExtra => '🔥 Meta atingida (+ extra)';

  @override
  String get timerWindowExtended => 'Janela estendida';

  @override
  String get timerRemainingInWindow => 'Restante na janela';

  @override
  String get timerUnknownPlan => 'Plano Desconhecido';

  @override
  String get timerLogMoodSymptoms => 'Registrar humor e sintomas';

  @override
  String get timerBreakAlreadyActive => 'Você já está em uma pausa. Aproveite! ☕';

  @override
  String get timerRestDayStarted => 'Janela fechada. Aproveite seu dia de descanso! 🏖️';

  @override
  String get timerTakeBreak => 'Fazer uma pausa';

  @override
  String get timerLogStartEarlier => 'Registrar início antes';

  @override
  String get timerLogEndEarlier => 'Registrar término antes';

  @override
  String get timerLogFastStartEarlier => 'Registrar início do jejum antes';

  @override
  String get bodyMeasureChest => 'Peito';

  @override
  String get bodyMeasureWaist => 'Cintura';

  @override
  String get bodyMeasureHips => 'Quadris';

  @override
  String get bodyMeasureChestTitle => 'Tamanho do Peito (cm)';

  @override
  String get bodyMeasureWaistTitle => 'Tamanho da Cintura (cm)';

  @override
  String get bodyMeasureHipsTitle => 'Tamanho dos Quadris (cm)';

  @override
  String get bodyMeasureAdd => 'Adicionar';

  @override
  String get drinkWater => 'Água';

  @override
  String get drinkBlackCoffee => 'Café Preto';

  @override
  String get drinkLatteSweetCoffee => 'Latte / Café Doce';

  @override
  String get drinkGreenBlackTea => 'Chá Verde / Preto';

  @override
  String get drinkDietSoda => 'Refrigerante Diet';

  @override
  String get drinkSweetSoda => 'Refrigerante Doce';

  @override
  String get drinkJuice => 'Suco';

  @override
  String get drinkAlcohol => 'Álcool';

  @override
  String waterDrinkContainsCalories(String drink) {
    return '$drink contém calorias!';
  }

  @override
  String get waterBreakFastWarning => 'Beber isso quebrará seu jejum atual e iniciará sua janela de alimentação. Tem certeza?';

  @override
  String get waterConfirmDrinkBreakFast => 'Sim, eu bebi';

  @override
  String get waterDrinkPrompt => 'O que você bebeu?';

  @override
  String waterFastStoppedByDrink(String drink) {
    return 'O jejum parou porque você bebeu $drink.';
  }

  @override
  String get waterUndoLastDrink => 'Desfazer última bebida';

  @override
  String get unitMl => 'ml';

  @override
  String get healthBadgeSync => 'Sincronizar';

  @override
  String get healthNoData => 'Sem Dados';

  @override
  String get healthSleepLabel => 'Sono';

  @override
  String get healthCyclePhaseLabel => 'Fase do Ciclo';

  @override
  String get cyclePhaseMenstruation => 'Menstruação';

  @override
  String get cyclePhaseFollicular => 'Folicular';

  @override
  String get cyclePhaseOvulation => 'Ovulação';

  @override
  String get cyclePhaseLuteal => 'Lútea';

  @override
  String get learnQuickBites => 'Dicas Rápidas';

  @override
  String get storyFasting101 => 'Jejum 101';

  @override
  String get storyAutophagy => 'Autofagia';

  @override
  String get storyKetoDiet => 'Dieta Keto';

  @override
  String get storyHydration => 'Hidratação';

  @override
  String get storySleep => 'Sono';

  @override
  String storyOpening(String title) {
    return 'Abrindo história: $title...';
  }

  @override
  String recipeSelected(String title) {
    return 'Selecionado: $title';
  }

  @override
  String get aiUpdatingConfig => 'A IA está atualizando a configuração. Verifique sua internet e reinicie o aplicativo.';

  @override
  String get aiSessionExpired => 'A sessão com o coach expirou. Feche e reabra o chat para continuar.';

  @override
  String get aiEmptyResponse => 'Ainda estou pensando. Por favor, tente novamente.';

  @override
  String get authGoogleFailed => 'O login com o Google falhou. Por favor, tente novamente.';

  @override
  String get authAppleUnavailable => 'O login com a Apple está disponível apenas no iOS.';

  @override
  String get authAppleFailed => 'O login com a Apple falhou. Por favor, tente novamente.';

  @override
  String get journalSymptomsTitle => 'Sintomas e Estado';

  @override
  String get journalSymptomsPrefix => 'Sintomas';

  @override
  String get journalUpdated => 'Diário atualizado! 📝';

  @override
  String get symptomEnergy => 'Energy';

  @override
  String get symptomFocus => 'Focus';

  @override
  String get symptomHungry => 'Hungry';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomThirsty => 'Thirsty';

  @override
  String get moodTerrible => 'Terrível';

  @override
  String get moodBad => 'Mal';

  @override
  String get moodOkay => 'Normal';

  @override
  String get moodGood => 'Bem';

  @override
  String get moodGreat => 'Ótimo';

  @override
  String get disclaimerCheckboxPrefix => 'Eu concordo com o ';

  @override
  String get disclaimerCheckboxLink => 'Aviso Médico e Política de Privacidade';

  @override
  String get pdfReportTitle => 'Relatório Médico';

  @override
  String get pdfReportSubtitle => 'Resumo de Jejum Intermitente';

  @override
  String get pdfReportGenerating => 'Gerando seu relatório...';

  @override
  String get pdfReportGenerate => 'Gerar Relatório PDF';

  @override
  String get pdfReportShare => 'Compartilhar Relatório';

  @override
  String get pdfReportPreview => 'Visualizar';

  @override
  String get pdfReportPeriod => 'Período do Relatório';

  @override
  String get pdfReportPeriod7 => 'Últimos 7 dias';

  @override
  String get pdfReportPeriod30 => 'Últimos 30 dias';

  @override
  String get pdfReportPeriodAll => 'Todo o período';

  @override
  String get pdfReportProOnly => 'Relatórios PDF são um recurso PRO';

  @override
  String get pdfReportProDesc => 'Atualize para PRO para gerar e compartilhar seus relatórios personalizados.';

  @override
  String get pdfReportSectionProfile => 'Perfil Pessoal';

  @override
  String get pdfReportSectionStats => 'Estatísticas de Jejum';

  @override
  String get pdfReportSectionHistory => 'Histórico de Jejuns';

  @override
  String get pdfReportSectionDisclaimer => 'Aviso Médico';

  @override
  String get pdfReportLabelAge => 'Idade';

  @override
  String get pdfReportLabelGender => 'Gênero';

  @override
  String get pdfReportLabelWeight => 'Peso';

  @override
  String get pdfReportLabelHeight => 'Altura';

  @override
  String get pdfReportLabelBmi => 'IMC';

  @override
  String get pdfReportLabelTotalFasts => 'Total de Jejuns';

  @override
  String get pdfReportLabelTotalHours => 'Total de Horas';

  @override
  String get pdfReportLabelAvgDuration => 'Duração Média';

  @override
  String get pdfReportLabelLongest => 'Jejum Mais Longo';

  @override
  String get pdfReportLabelStreak => 'Melhor Sequência';

  @override
  String get pdfReportLabelDate => 'Data';

  @override
  String get pdfReportLabelDuration => 'Duração';

  @override
  String get pdfReportLabelCompleted => 'Concluído';

  @override
  String get pdfReportDisclaimerText => 'Este relatório é gerado pelo Fastable para fins de acompanhamento pessoal. Não constitui aconselhamento médico.';

  @override
  String get pdfReportGeneratedBy => 'Gerado pelo Fastable';

  @override
  String get pdfReportGenderMale => 'Homem';

  @override
  String get pdfReportGenderFemale => 'Mulher';

  @override
  String get pdfReportNoData => 'Nenhum registro encontrado no período.';

  @override
  String pdfReportHours(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get bodyMetricsTitle => 'Métricas Corporais';

  @override
  String get bodyMetricsHint => 'Toque nos cartões para atualizar';

  @override
  String get bodyMetricsAdd => 'Adicionar';

  @override
  String get bodyMetricsTapToSet => 'Toque para definir';

  @override
  String get nextStageUpper => 'PRÓXIMO ESTÁGIO';

  @override
  String get maxBenefitsReached => 'Benefícios Máximos Alcançados!';

  @override
  String get holdToComplete => 'SEGURE PARA CONCLUIR';

  @override
  String get heroActiveSession => 'SESSÃO ATIVA';

  @override
  String get heroEatingWindow => 'JANELA DE ALIMENTAÇÃO';

  @override
  String get heroNextFast => 'PRÓXIMO JEJUM';

  @override
  String get insightsAndTrends => 'INSIGHTS E TENDÊNCIAS';

  @override
  String get bmiLabel => 'IMC';

  @override
  String get liveTrackerChannelName => 'Temporizador de Jejum';

  @override
  String get liveTrackerChannelDesc => 'Temporizador de jejum em andamento';

  @override
  String get liveTrackerSubtextFasting => '🔥 Estágio Fastable';

  @override
  String get liveTrackerSubtextEating => '🍽 Janela Fastable';

  @override
  String get liveTrackerActionEndFast => '🏁 ENCERRAR JEJUM';

  @override
  String get liveTrackerActionStopWindow => '🛑 PARAR JANELA';

  @override
  String liveTrackerGoal(String time) {
    return 'Meta: $time';
  }

  @override
  String liveTrackerWindowEnds(String time) {
    return 'A janela termina: $time';
  }

  @override
  String get liveTrackerTimeRemaining => 'Tempo restante: ';

  @override
  String get elapsed => 'Decorrido';

  @override
  String get status => 'Status';

  @override
  String get complete => 'Concluído';

  @override
  String get fastingStages => 'Estágios do Jejum';

  @override
  String get statusNow => 'Agora';

  @override
  String get statusNext => 'Próximo';

  @override
  String get statusDone => 'Concluído';

  @override
  String get chartFastingVsWeight => 'Jejum vs Peso';

  @override
  String get chartTrackMetabolic => 'Acompanhe sua correlação metabólica ao longo do tempo.';

  @override
  String get chart1W => '1S';

  @override
  String get chart1M => '1M';

  @override
  String get chart3M => '3M';

  @override
  String get chartSmartInsight => 'Insight Inteligente';

  @override
  String chartGoal(String value) {
    return 'Meta: $value';
  }

  @override
  String get chartHours => 'Horas';

  @override
  String get chartWeight => 'Peso';

  @override
  String get chartLegendFasting => 'Horas de Jejum';

  @override
  String get chartLegendWeight => 'Tendência de Peso';

  @override
  String get chartInsight1W => 'Suas janelas de jejum estão consistentes esta semana! Manter uma média de mais de 16h se correlaciona com uma queima de gordura mais rápida.';

  @override
  String get chartInsight1M => 'No último mês, notamos uma queda constante no seu peso quando você termina o jejum após as 18:00.';

  @override
  String get chartInsight3M => 'Dados de longo prazo mostram um progresso incrível! Seu corpo está se adaptando perfeitamente à mudança metabólica.';

  @override
  String get statsUnlockChartTitle => 'Análise Pro';

  @override
  String get statsUnlockChartDesc => 'Assista a um pequeno anúncio em vídeo para desbloquear o gráfico de correlação.';

  @override
  String get statsBtnWatchAd => 'Ver Anúncio';

  @override
  String get adNotReady => 'O anúncio ainda não está pronto. Por favor, tente novamente em alguns segundos.';
}
