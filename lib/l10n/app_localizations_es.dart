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
  String get settingsHealthConnect => 'Health Connect';

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
  String get guestUser => 'Invitado';

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
  String get authSubtitle => 'Sincroniza tu progreso y alcanza tus metas.';

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
  String get bmiNormal => 'Normal';

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
  String get achFirstFastDesc => 'Completa tu primer ayuno.';

  @override
  String get achStreak3Title => 'Buen comienzo';

  @override
  String get achStreak3Desc => 'Mantén una racha de 3 días.';

  @override
  String get achStreak7Title => 'Constante';

  @override
  String get achStreak7Desc => 'Mantén una racha de 7 días.';

  @override
  String get achTotal10Title => 'Novato';

  @override
  String get achTotal10Desc => 'Completa 10 ayunos.';

  @override
  String get achTotalHours100Title => 'Club de 100 horas';

  @override
  String get achTotalHours100Desc => 'Ayuna un total de 100 horas.';

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
}
