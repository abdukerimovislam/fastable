// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fastable';

  @override
  String get dashboardToday => 'Hoy';

  @override
  String get dashboardOverview => 'Resumen';

  @override
  String get navTimer => 'Temporizador';

  @override
  String get navHistory => 'Historial';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get navLearn => 'Aprender';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSettings => 'Configuración';

  @override
  String get navAchievements => 'Logros';

  @override
  String get navPro => 'Fastable PRO';

  @override
  String get fastingPhase => 'Fase de ayuno';

  @override
  String get eatingWindow => 'Ventana de comida';

  @override
  String get readyToFast => 'Listo para ayunar';

  @override
  String get autophagyZone => 'Zona de autofagia';

  @override
  String get startFast => 'Iniciar ayuno';

  @override
  String get endFast => 'Finalizar ayuno';

  @override
  String get endCycle => 'Finalizar ciclo';

  @override
  String get remaining => 'Restante';

  @override
  String get targetGoal => 'Objetivo';

  @override
  String get waterTracker => 'Seguimiento de agua';

  @override
  String get waterCups => 'vasos';

  @override
  String get addWater => 'Agregar agua';

  @override
  String get waterToday => 'Agua de hoy';

  @override
  String get waterIntake => 'Consumo de agua';

  @override
  String get cups => 'vasos';

  @override
  String get cupsUnit => 'vasos';

  @override
  String get weightTracker => 'Seguimiento de peso';

  @override
  String get logWeight => 'Registrar peso';

  @override
  String get saveWeight => 'Guardar peso';

  @override
  String get weightJourney => 'Evolución del peso';

  @override
  String get last7Days => 'Últimos 7 días';

  @override
  String get fastingHours => 'Horas de ayuno';

  @override
  String get currentWeight => 'Actual';

  @override
  String get goalWeight => 'Objetivo';

  @override
  String get startWeight => 'Inicial';

  @override
  String get addWeight => 'Agregar peso';

  @override
  String get enterWeight => 'Introducir peso';

  @override
  String get unitKg => 'kg';

  @override
  String get unitCm => 'cm';

  @override
  String get weightProgress => 'Progreso de peso';

  @override
  String get chartEmpty => 'Agrega al menos dos registros de peso para ver el gráfico.';

  @override
  String get proBannerTitle => 'Fastable PRO';

  @override
  String get proBannerDesc => 'Desbloquear análisis';

  @override
  String get premiumContentTitle => 'Contenido premium';

  @override
  String get premiumContentDesc => 'Desbloquea acceso completo a todos los artículos y funciones.';

  @override
  String get getPro => 'Obtener acceso PRO';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get proTitle => 'Obtener acceso PRO';

  @override
  String get proMonthly => 'Suscripción mensual';

  @override
  String get proAnnual => 'Suscripción anual (40% de descuento)';

  @override
  String get unlockAll => 'Desbloquear PRO';

  @override
  String get accessStatus => 'Acceso actual';

  @override
  String statusActive(Object date) {
    return 'Activo hasta $date';
  }

  @override
  String get statusFree => 'Gratis';

  @override
  String get proRequired => 'Se requiere una suscripción PRO para ver este contenido';

  @override
  String get proComingSoon => '¡La versión PRO llegará pronto! Mantente al tanto.';

  @override
  String get year => 'año';

  @override
  String get month => 'mes';

  @override
  String get discount => 'Descuento';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyCalendar => 'Calendario';

  @override
  String get historyLog => 'Registro';

  @override
  String get historyEmpty => 'Aún no hay ayunos completados. ¡Aparecerán aquí!';

  @override
  String get fastComplete => '¡Ayuno completado! 🎉';

  @override
  String fastCompleteDesc(String time) {
    return 'Has ayunado durante $time. ¿Guardar este registro?';
  }

  @override
  String get noFastsOnDay => 'No se completaron ayunos este día.';

  @override
  String get detailsFor => 'Detalles para';

  @override
  String get endCyclePrompt => '¿Finalizar la ventana de alimentación?';

  @override
  String get endCyclePromptDesc => 'Esto detendrá el temporizador de comida y reiniciará el ciclo.';

  @override
  String get endFastPrompt => 'Finaliza el ciclo actual para cambiar el plan.';

  @override
  String get discard => 'Descartar';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Finalizar';

  @override
  String get attention => 'Atención';

  @override
  String get continueAction => 'Continuar';

  @override
  String get settingLanguage => 'Idioma';

  @override
  String get settingWaterGoal => 'Objetivo diario de agua';

  @override
  String get settingHeight => 'Altura';

  @override
  String get settingGoalWeight => 'Peso objetivo';

  @override
  String get settingTheme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get settingsHealthConnect => 'Conexión de salud';

  @override
  String get settingsSyncWeight => 'Sincronizar peso y pasos';

  @override
  String get healthConnectSyncTitle => 'Sincronizar con Health Connect';

  @override
  String get healthConnectDisclosureIntro => 'Fastable solicita acceso de LECTURA y ESCRITURA a datos de PESO a través de Health Connect.';

  @override
  String get healthConnectDisclosureRead => 'Usamos el acceso de LECTURA para mostrar tu gráfico de progreso de peso basado en datos históricos.';

  @override
  String get healthConnectDisclosureWrite => 'Usamos el acceso de ESCRITURA para que puedas guardar registros de peso de Fastable en la base de datos de tu teléfono.';

  @override
  String get healthConnectDisclosureSecure => 'Los datos se almacenan localmente y se usan solo para seguimiento. Puedes revocar los permisos en cualquier momento.';

  @override
  String get healthConnectConnected => '¡Health Connect conectado!';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get notifyWater => 'Recordatorios de agua';

  @override
  String get notifyWaterDesc => 'Recibe recordatorios para beber agua';

  @override
  String get notifyWeight => 'Recordatorio de peso';

  @override
  String get notifyWeightDesc => 'Recordatorio diario para pesarte';

  @override
  String get notifyFastingStart => 'Inicio de ayuno';

  @override
  String get notifyFastingStartDesc => 'Notificar cuando comience la ventana de ayuno';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfService => 'Términos del servicio';

  @override
  String get errorOpenLink => 'No se pudo abrir el enlace';

  @override
  String get errorLoading => 'Error al cargar datos';

  @override
  String get noArticlesFound => 'No se encontraron artículos';

  @override
  String get tabFasting => 'Ayuno';

  @override
  String get tabKeto => 'Keto';

  @override
  String get tabPartner => 'Socio';

  @override
  String get guestUser => 'Usuario invitado';

  @override
  String get defaultUser => 'Usuario';

  @override
  String get anonymousLogin => 'Inicio de sesión anónimo';

  @override
  String get dataOnDevice => 'Datos guardados en el dispositivo';

  @override
  String get connectGoogle => 'Conectar cuenta de Google';

  @override
  String get saveProgressCloud => 'Guardar progreso en la nube';

  @override
  String get accountLinked => '¡Cuenta vinculada con éxito!';

  @override
  String get linkError => 'Error al vincular la cuenta';

  @override
  String get resetAndExit => 'Restablecer datos y salir';

  @override
  String get deleteAndExit => 'Eliminar y salir';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get confirmLogout => '¿Seguro que deseas cerrar sesión?';

  @override
  String get guestLogoutWarning => 'Estás usando una cuenta de invitado. Si cierras sesión, todos los datos locales se eliminarán permanentemente.';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountWarning => '¿Estás seguro? Esto eliminará todos tus datos permanentemente.';

  @override
  String get authWelcome => 'Bienvenido a Fastable';

  @override
  String get authSubtitle => 'Inicia sesión para sincronizar datos';

  @override
  String get signInGoogle => 'Iniciar sesión con Google';

  @override
  String get continueGuest => 'Continuar como invitado';

  @override
  String get signInFailed => 'Error al iniciar sesión. Inténtalo de nuevo.';

  @override
  String get welcomeMessage => '¡Bienvenido a tu app de ayuno!';

  @override
  String get choosePlan => 'Elegir plan';

  @override
  String get fastingPlan16_8 => 'Ayuno intermitente 16:8';

  @override
  String get fastingPlan18_6 => 'Ayuno intermitente 18:6';

  @override
  String get fastingPlan20_4 => 'La dieta del guerrero 20:4';

  @override
  String get fastingPlanEatStopEat => 'Eat-Stop-Eat (24h)';

  @override
  String get bmiCalculator => 'Calculadora IMC';

  @override
  String get bmiCategory => 'Categoría';

  @override
  String get bmiUnderweight => 'Bajo peso';

  @override
  String get bmiNormal => 'Peso normal';

  @override
  String get bmiOverweight => 'Sobrepeso';

  @override
  String get bmiObese => 'Obesidad';

  @override
  String get enterHeightCm => 'Introducir altura (cm)';

  @override
  String get enterGoalWeightKg => 'Introducir peso objetivo (kg)';

  @override
  String get fastingStats => 'Estadísticas de ayuno';

  @override
  String get fastingStatsCurrentStreak => 'Racha actual';

  @override
  String get fastingStatsDay => 'Día';

  @override
  String get fastingStatsDays => 'Días';

  @override
  String get fastingStatsTotalFasts => 'Ayunos totales';

  @override
  String get fastingStatsTotalHours => 'Horas totales';

  @override
  String get fastingStatsAvgFast => 'Promedio de ayuno';

  @override
  String get fastingStatsHours => 'Horas';

  @override
  String get onboardingWelcomeTitle => '¡Bienvenido!';

  @override
  String get onboardingWelcomeDesc => 'Comienza tu camino hacia la salud. Configuremos tu perfil.';

  @override
  String get onboardingGoalTitle => '¿Cuáles son tus objetivos?';

  @override
  String get onboardingGoalDesc => 'Indica tu altura y peso objetivo para que podamos calcular tu IMC.';

  @override
  String get onboardingPlanTitle => 'Elige tu plan';

  @override
  String get onboardingPlanDesc => '¿Con qué plan de ayuno te gustaría empezar? Siempre puedes cambiarlo más tarde.';

  @override
  String get onboardingCurrentWeight => 'Tu peso actual';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get currentStage => 'Etapa actual';

  @override
  String get nextStage => 'Siguiente';

  @override
  String get stageAnabolicTitle => 'Anabólica (Alimentación)';

  @override
  String get stageAnabolicDesc => 'Tu cuerpo digiere y usa glucosa para obtener energía. Crecimiento celular activo.';

  @override
  String get stageCatabolicTitle => 'Catabólica';

  @override
  String get stageCatabolicDesc => 'El nivel de azúcar cae. El cuerpo empieza a usar glucógeno almacenado.';

  @override
  String get stageKetosisTitle => 'Cetosis';

  @override
  String get stageKetosisDesc => 'Reservas de glucógeno agotadas. El cuerpo quema grasa como combustible principal.';

  @override
  String get stageAutophagyTitle => 'Autofagia';

  @override
  String get stageAutophagyDesc => 'Comienza la limpieza celular. El cuerpo recicla componentes celulares viejos.';

  @override
  String get stagePeakAutophagyTitle => 'Pico de autofagia';

  @override
  String get stagePeakAutophagyDesc => 'El proceso de renovación celular alcanza su máximo.';

  @override
  String get achievementsTitle => 'Logros';

  @override
  String get achievementsUnlocked => 'Desbloqueados';

  @override
  String get achievementsLocked => 'Bloqueados';

  @override
  String achEarnedOn(Object date) {
    return 'Obtenido el $date';
  }

  @override
  String get achFirstFastTitle => '¡Primer ayuno!';

  @override
  String get achFirstFastDesc => 'Completa tu primera sesión de ayuno.';

  @override
  String get achStreak3Title => 'Buen comienzo';

  @override
  String get achStreak3Desc => 'Mantén una racha de ayuno de 3 días.';

  @override
  String get achStreak7Title => 'Constante';

  @override
  String get achStreak7Desc => 'Alcanza una racha de 7 días.';

  @override
  String get achTotal10Title => 'Novato';

  @override
  String get achTotal10Desc => 'Completa 10 ayunos en total.';

  @override
  String get achTotalHours100Title => 'Club de 100 horas';

  @override
  String get achTotalHours100Desc => 'Acumula 100 horas de ayuno.';

  @override
  String get journalTitle => 'Nota del diario';

  @override
  String get journalHint => '¿Cómo te sentiste durante este ayuno?';

  @override
  String get addNote => 'Agregar nota';

  @override
  String get editNote => 'Editar nota';

  @override
  String get noteSaved => 'Nota guardada';

  @override
  String get syncHealthTitle => 'Sincronizar salud';

  @override
  String get syncHealthDesc => 'Registrar ayunos y leer peso automáticamente.';

  @override
  String get shareProgress => 'Compartir progreso';

  @override
  String get metricPhase => 'Fase';

  @override
  String get metricStreak => 'Racha';

  @override
  String get metricStatus => 'Estado';

  @override
  String get statusDigesting => 'Digestión';

  @override
  String get statusStable => 'Estable';

  @override
  String get statusFatBurn => 'Quema de grasa';

  @override
  String get statusKetosis => 'Cetosis';

  @override
  String get statusNormal => 'Normal';

  @override
  String get titleCurrentPhase => 'Fase actual';

  @override
  String get valFastingZone => 'Zona de ayuno';

  @override
  String get valEatingWindow => 'Ventana de alimentación';

  @override
  String get descFastingZone => 'Actualmente estás en la ventana de ayuno. No se deben consumir calorías.';

  @override
  String get descEatingWindow => 'Estás en tu ventana de alimentación. Prioriza alimentos nutritivos.';

  @override
  String get titleConsistencyStreak => 'Racha de constancia';

  @override
  String valStreakDays(int days) {
    return '$days días 🔥';
  }

  @override
  String descStreak(int days) {
    return 'Has cumplido tu objetivo de ayuno durante $days días consecutivos. ¡Sigue así para crear el hábito!';
  }

  @override
  String get titleBodyStatus => 'Estado del cuerpo';

  @override
  String get descDigesting => 'Tu cuerpo está digiriendo alimentos y reponiendo las reservas de glucógeno. Los niveles de insulina están aumentando.';

  @override
  String get descStable => 'Los niveles de azúcar en sangre se están normalizando. El cuerpo se prepara para cambiar de glucosa a grasa como fuente de energía.';

  @override
  String get descFatBurn => '¡Buen trabajo! Tu cuerpo comienza a quemar grasa almacenada para obtener energía. Los niveles de la hormona del crecimiento pueden aumentar.';

  @override
  String get descKetosis => '¡Cetosis profunda! Tu cuerpo quema grasa de forma eficiente. La autofagia puede comenzar pronto.';

  @override
  String get btnGotIt => '¡Entendido!';

  @override
  String get stage0_4 => 'Aumento do açúcar no sangue';

  @override
  String get stage0_4_desc => 'Seu corpo está digerindo a última refeição. Os níveis de glicose e insulina aumentam.';

  @override
  String get stage4_8 => 'Queda do açúcar no sangue';

  @override
  String get stage4_8_desc => 'Os níveis de insulina começam a cair. O corpo passa a usar a glicose armazenada.';

  @override
  String get stage8_12 => 'Normalização';

  @override
  String get stage8_12_desc => 'O sistema digestivo descansa. O corpo inicia processos de reparação e limpeza.';

  @override
  String get stage12_16 => 'Queima de gordura';

  @override
  String get stage12_16_desc => 'A insulina está baixa. O corpo começa a usar a gordura armazenada como energia.';

  @override
  String get stage16_18 => 'Cetose';

  @override
  String get stage16_18_desc => 'A queima de gordura se intensifica. Você entra em modo total de queima de gordura.';

  @override
  String get stage18_24 => 'Autofagia';

  @override
  String get stage18_24_desc => 'A limpeza celular começa. O corpo recicla células antigas e danificadas.';

  @override
  String get stage24_plus => 'Reparação profunda';

  @override
  String get stage24_plus_desc => 'Os níveis do hormônio do crescimento aumentam. Ocorre uma regeneração celular significativa.';

  @override
  String get viewTimeline => 'Ver linha do tempo do corpo';

  @override
  String get navFood => 'Comida';

  @override
  String get circadianEnabled => 'Circadian mode enabled';

  @override
  String get circadianDisabled => 'Circadian mode disabled';

  @override
  String get tabRecipes => 'Recetas';

  @override
  String get tabKnowledge => 'Conocimiento';

  @override
  String get categoryAll => 'Todo';

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
  String get waterSettings => 'Configuración de agua';

  @override
  String get removeCup => 'Quitar vaso (-1)';

  @override
  String get dailyGoal => 'Objetivo diario';

  @override
  String get bmiScore => 'IMC';

  @override
  String bmiDescription(int height, String weight) {
    return 'Basado en tu altura ($height cm) y peso ($weight kg).';
  }

  @override
  String get onboardingTitle => 'Personaliza tu plan';

  @override
  String get onboardingHeightTitle => '¿Cuál es tu altura?';

  @override
  String get onboardingHeightDesc => 'La necesitamos para calibrar el visualizador corporal y calcular tus métricas de salud con precisión.';

  @override
  String get onboardingWeightTitle => '¿Cuál es tu peso?';

  @override
  String get onboardingWeightDesc => 'Esto nos ayuda a seguir tu progreso y ajustar tu plan de ayuno dinámicamente.';

  @override
  String get btnNext => 'Siguiente';

  @override
  String get btnFinish => 'Comenzar';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get statsSuccessRate => 'Tasa de éxito';

  @override
  String statsSuccessDesc(int success, int total) {
    return '$success de $total ayunos fueron de 16 h o más';
  }

  @override
  String get statsTotalFasts => 'Ayunos totales';

  @override
  String get statsTotalHours => 'Horas totales';

  @override
  String get statsAverage => 'Promedio';

  @override
  String get statsLongest => 'Más largo';

  @override
  String get circadianTitle => 'Ritmo circadiano';

  @override
  String get circadianIntroTitle => 'Come con el sol ☀️';

  @override
  String get circadianIntroDesc => 'Tu metabolismo está conectado con el sol.\n\n• Amanecer: el mejor momento para despertar e hidratarte.\n• Día: metabolismo alto. Ideal para comer.\n• Atardecer: el metabolismo se ralentiza. Es mejor dejar de comer.\n• Noche: modo de reparación profunda. Ayunar se vuelve más fácil.\n\nEste modo ajusta automáticamente tus objetivos de ayuno según las horas de amanecer y atardecer de tu ubicación.';

  @override
  String get circadianBtnEnable => 'Activar modo circadiano';

  @override
  String get circadianBtnDisable => 'Desactivar';

  @override
  String get circadianTargetSunrise => 'Hasta el amanecer';

  @override
  String get circadianTargetSunset => 'Hasta el atardecer';

  @override
  String get circadianPhaseDay => 'Día (Comer)';

  @override
  String get circadianPhaseNight => 'Noche (Ayuno)';

  @override
  String get circadianWarnDayTitle => 'Es de día ☀️';

  @override
  String get circadianWarnDayDesc => '¡El sol ya está arriba! Tu cuerpo está listo para comer. Idealmente, espera hasta el atardecer para comenzar el ayuno.';

  @override
  String get circadianWarnBtnStart => 'Empezar de todos modos';

  @override
  String get circadianWarnBtnWait => 'Esperar al atardecer';

  @override
  String get circadianBonusTime => 'Tiempo extra 🔥';

  @override
  String get circadianSyncing => 'Sincronizando con el sol...';

  @override
  String get circadianError => 'No se pudo obtener la ubicación. Usando temporizador estándar.';

  @override
  String get circadianManaged => 'Controlado por el sol';

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
  String get permTitle => 'Activar permisos';

  @override
  String get permDesc => 'Para ofrecerte la mejor experiencia, Fastable necesita acceso a las notificaciones y a los datos de salud.';

  @override
  String get permNotifTitle => 'Notificaciones';

  @override
  String get permNotifDesc => 'Mantente al día con recordatorios de ayuno.';

  @override
  String get permHealthTitle => 'Apple Health';

  @override
  String get permHealthDesc => 'Sincroniza datos de peso y agua.';

  @override
  String get permAllow => 'Permitir';

  @override
  String get permContinue => 'Continuar';

  @override
  String get achFirstFast => 'Primer paso';

  @override
  String get achStreak3 => 'Constancia';

  @override
  String get achStreak7 => 'Imparable';

  @override
  String get achTotal10 => 'Compromiso';

  @override
  String get achTotalHours100 => 'Centurión';

  @override
  String get onboardingDesc => 'Calculemos tu tasa metabólica.';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnStart => 'Comenzar el viaje';

  @override
  String get selectGender => 'Género';

  @override
  String get selectAge => 'Edad';

  @override
  String get selectWeight => 'Peso';

  @override
  String get selectHeight => 'Altura';

  @override
  String get selectActivity => 'Nivel de actividad';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Femenino';

  @override
  String get activitySedentary => 'Sedentario';

  @override
  String get activityModerate => 'Moderado';

  @override
  String get activityActive => 'Muy activo';

  @override
  String get contactSupport => 'Contactar soporte';

  @override
  String get metabolicProfile => 'Perfil metabólico';

  @override
  String ageYears(int age) {
    return '$age años';
  }

  @override
  String get metricBmrTitle => 'BMR';

  @override
  String get metricBmrSubtitle => 'Basal';

  @override
  String get metricBmrDesc => 'Tasa metabólica basal. Calorías quemadas en reposo absoluto.';

  @override
  String get metricTdeeTitle => 'TDEE';

  @override
  String get metricTdeeSubtitle => 'Mantenimiento';

  @override
  String get metricTdeeDesc => 'Gasto energético diario total. Calorías necesarias para mantener el peso actual.';

  @override
  String get dialogStartTitle => '¿Cuándo comenzaste?';

  @override
  String get btnStartFasting => 'Iniciar ayuno';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get stage2Title => 'El azúcar en sangre está bajando 📉';

  @override
  String get stage2Body => 'Tu cuerpo se está calmando. Si sientes hambre, bebe un poco de agua. 💧';

  @override
  String get stage4Title => 'La insulina está bajando ⬇️';

  @override
  String get stage4Body => '¡Genial! Tu cuerpo deja de almacenar grasa y empieza a prepararse para quemarla.';

  @override
  String get stage8Title => 'Limpieza iniciada ✨';

  @override
  String get stage8Body => '8 horas cumplidas. Tu estómago está descansando. ¡Lo estás haciendo muy bien por tu salud!';

  @override
  String get stage11Title => 'Modo quema de grasa 🔥';

  @override
  String get stage11Body => '¡Empieza lo bueno! Tu cuerpo cambia a reservas internas.';

  @override
  String get stage12Title => 'Cetosis activada 🚀';

  @override
  String get stage12Body => 'Las células grasas se convierten en energía. Tu mente está más clara.';

  @override
  String get stage14Title => 'Cetosis profunda 🔥';

  @override
  String get stage14Body => '¡Estás en la zona de quema de grasa! La limpieza avanza más rápido.';

  @override
  String get stage16Title => 'Autofagia (reparación celular) 🧬';

  @override
  String get stage16Body => 'Tus células se están renovando. El cuerpo entra en modo reparación.';

  @override
  String get stage18Title => 'Pico de hormona de crecimiento 📈';

  @override
  String get stage18Body => 'La hormona de crecimiento ayuda a quemar grasa y mantener músculo. ¡Te estás fortaleciendo!';

  @override
  String get stage24Title => '¡24 horas! 🏆';

  @override
  String get stage24Body => '¡Increíble! Un día completo logrado. La limpieza profunda está en marcha.';

  @override
  String get notifyHalfwayTitle => '¡Mitad del camino! ⛰️';

  @override
  String get notifyHalfwayBody => 'La parte más difícil ya pasó. Tu cuerpo te lo agradece.';

  @override
  String get notify1hTitle => '¡Último tramo! 🏁';

  @override
  String get notify1hBody => 'Solo queda 1 hora. ¡Lo estás haciendo increíble!';

  @override
  String get notifyGoalTitle => '¡Objetivo alcanzado! 🎉';

  @override
  String get notifyGoalBody => '¡Felicidades! Rompe el ayuno con suavidad.';

  @override
  String get notifyEatCloseTitle => 'La ventana de comida se cierra 🛑';

  @override
  String get notifyEatCloseBody => 'Es hora de comenzar tu próximo ayuno. ¡Revisa la app!';

  @override
  String get notifyEat30mTitle => 'Quedan 30 minutos 🥗';

  @override
  String get notifyEat30mBody => 'No olvides beber agua o hacer una última comida ligera.';

  @override
  String get learnTitle => 'Aprender y comer';

  @override
  String get tabArticles => 'Artículos';

  @override
  String get catBasics => 'Conceptos básicos';

  @override
  String get catNutrition => 'Nutrición';

  @override
  String get catHealth => 'Salud';

  @override
  String get catKeto => 'Keto';

  @override
  String get headerLatestArticles => 'Últimos artículos';

  @override
  String get headerHealthyChoices => 'Opciones saludables';

  @override
  String get statusNoArticles => 'No se encontraron artículos.';

  @override
  String get msgComingSoon => 'Próximamente...';

  @override
  String get learnBannerTitle => 'Desbloquea más de 500 recetas';

  @override
  String get learnBannerSubtitle => 'Acceso completo con PRO';

  @override
  String get labelPremium => 'PREMIUM';

  @override
  String get bannerRecipeTitle => 'Recetas saludables';

  @override
  String get bannerRecipeSubtitle => 'Keto, bajas en carbohidratos y más';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitMin => 'min';

  @override
  String get lblAchievements => 'Logros';

  @override
  String get lblPersonalData => 'Datos personales';

  @override
  String get lblSettings => 'Configuración';

  @override
  String get lblAbout => 'Acerca de';

  @override
  String get lblHeight => 'Altura';

  @override
  String get lblWeight => 'Peso';

  @override
  String get lblAge => 'Edad';

  @override
  String get lblGender => 'Género';

  @override
  String get lblActivity => 'Nivel de actividad';

  @override
  String get lblLanguage => 'Idioma';

  @override
  String get msgHealthSyncEnabled => '¡Sincronización de salud activada!';

  @override
  String get msgHealthSyncFailed => 'Permiso denegado';

  @override
  String get aiGreeting => '¡Hola! Soy Fasty 🥑. ¿Cómo puedo ayudarte a alcanzar tus objetivos hoy?';

  @override
  String get aiConnectionError => '¡Ups! Se perdió la conexión. Revisa tu internet o inténtalo más tarde. 🥑';

  @override
  String get aiSystemError => 'El servicio de IA no está configurado correctamente (falta la clave API).';

  @override
  String get aiCoachTitle => 'Entrenador de ayuno con IA';

  @override
  String get aiCoachDesc => 'Obtén respuestas instantáneas sobre keto, ayuno intermitente y hábitos saludables de nuestro asistente inteligente con IA.';

  @override
  String get aiChatHint => 'Pregunta sobre keto o ayuno...';

  @override
  String get btnUnlockPro => 'Desbloquear con PRO';

  @override
  String get aiInsightFallback => '¡La constancia es la clave! Bebe agua y sigue en movimiento. 💧';

  @override
  String get aiErrorConnection => 'Problema de conexión. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get aiInsightTitle => 'INSIGHT DIARIO';

  @override
  String get aiInsightTeaser => 'Según tus últimos 7 días de ayuno, hemos detectado un patrón importante que afecta a tu progreso...';

  @override
  String get tapToUnlock => 'Toca para desbloquear';

  @override
  String get notifyAiInsightTitle => '¡Tu insight diario de IA está listo! 🥑';

  @override
  String get notifyAiInsightBody => 'Descubre lo que Fasty ha analizado para ti hoy. Toca para desbloquear.';

  @override
  String get notifyWeightTitle => 'Registra tu peso ⚖️';

  @override
  String get notifyWeightBody => '¡La constancia es la clave! Registra tu peso hoy.';

  @override
  String get aiInsightNotEnoughData => '¡Sigue registrando! Necesitamos al menos 3 ayunos para analizar tus patrones únicos. 📊';

  @override
  String msgLoginFailed(Object error) {
    return 'Error de inicio de sesión: $error';
  }

  @override
  String msgAppleLoginFailed(Object error) {
    return 'Error al iniciar sesión con Apple: $error';
  }

  @override
  String get msgSyncCompleted => '¡Sincronización completada!';

  @override
  String get msgErrorRelogin => 'Error: por favor, vuelve a iniciar sesión e inténtalo de nuevo.';

  @override
  String get signInApple => 'Iniciar sesión con Apple';

  @override
  String get lblDangerZone => 'ZONA DE PELIGRO';

  @override
  String get btnDeleteAccount => 'Eliminar cuenta';

  @override
  String get dialogDeleteAccountTitle => '¿Eliminar cuenta?';

  @override
  String get dialogDeleteAccountContent => 'Esta acción es permanente. Todo tu historial de peso, registros de ayuno y logros se eliminarán de la nube.';

  @override
  String get btnDelete => 'ELIMINAR';

  @override
  String get dialogSyncConflictTitle => 'Conflicto de sincronización';

  @override
  String get dialogSyncConflictContent => 'Esta cuenta ya tiene datos en la nube.\n\n¿Qué deseas hacer con tus datos actuales de invitado?';

  @override
  String get btnUseCloud => 'Usar la nube\n(descartar invitado)';

  @override
  String get btnMergeData => 'Combinar datos';

  @override
  String lblVersion(Object version) {
    return 'Versión $version';
  }

  @override
  String get lblCurrentWeight => 'Peso actual';

  @override
  String get lblBasalBmr => 'Basal (BMR)';

  @override
  String get lblActiveTdee => 'Activo (TDEE)';

  @override
  String get lblTotalHours => 'Horas totales';

  @override
  String get unitHoursShort => 'h';

  @override
  String get lblConsistency => 'Constancia';

  @override
  String get lblLast7Days => 'Últimos 7 días';

  @override
  String get lblFasts => 'Ayunos';

  @override
  String get lblHours => 'Horas';

  @override
  String get lblDayStreak => 'Días seguidos';

  @override
  String get msgStartJourney => 'Comienza tu camino hoy';

  @override
  String get lblToday => 'Hoy';

  @override
  String get lblYesterday => 'Ayer';

  @override
  String get lblFastingTypeCircadian => 'Circadiano';

  @override
  String get lblFastingTypeWarrior => 'Guerrero';

  @override
  String get lblFastingTypeOmad => 'OMAD';

  @override
  String lblHistoryFor(Object date) {
    return 'Historial del $date';
  }

  @override
  String get lblNoRecordsForDay => 'No hay registros para este día';

  @override
  String get lblCustomPlan => 'Plan personalizado';

  @override
  String get lblAdjustDuration => 'Ajustar duración';

  @override
  String get lblFasting => 'Ayuno';

  @override
  String get lblEating => 'Comida';

  @override
  String get lblSlideToAdjust => 'Desliza para ajustar las horas';

  @override
  String get btnStartCustomPlan => 'Iniciar plan personalizado';

  @override
  String get btnUnlockFeature => 'Desbloquear plan personalizado';

  @override
  String get proFeatureTitle => 'Función PRO';

  @override
  String get proFeatureDesc => 'Los horarios de ayuno personalizados están disponibles para usuarios PRO.';
}
