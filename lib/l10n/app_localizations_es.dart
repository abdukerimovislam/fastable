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
  String get fastingPhase => 'Fase de Ayuno';

  @override
  String get eatingWindow => 'Ventana de Alimentación';

  @override
  String get readyToFast => 'Listo para Ayunar';

  @override
  String get autophagyZone => 'Zona de Autofagia';

  @override
  String get startFast => 'Iniciar Ayuno';

  @override
  String get endFast => 'Terminar Ayuno';

  @override
  String get endCycle => 'Terminar Ciclo';

  @override
  String get remaining => 'Restante';

  @override
  String get targetGoal => 'Objetivo';

  @override
  String get waterTracker => 'Rastreador de Agua';

  @override
  String get waterCups => 'vasos';

  @override
  String get addWater => 'Añadir Agua';

  @override
  String get waterToday => 'Agua de Hoy';

  @override
  String get waterIntake => 'Consumo de Agua';

  @override
  String get cups => 'vasos';

  @override
  String get cupsUnit => 'vasos';

  @override
  String get weightTracker => 'Rastreador de Peso';

  @override
  String get logWeight => 'Registrar Peso';

  @override
  String get saveWeight => 'Guardar Peso';

  @override
  String get weightJourney => 'Viaje de Peso';

  @override
  String get last7Days => 'Últimos 7 Días';

  @override
  String get fastingHours => 'Horas de Ayuno';

  @override
  String get currentWeight => 'Actual';

  @override
  String get goalWeight => 'Objetivo';

  @override
  String get startWeight => 'Inicial';

  @override
  String get addWeight => 'Añadir Peso';

  @override
  String get enterWeight => 'Introduce peso';

  @override
  String get unitKg => 'kg';

  @override
  String get unitCm => 'cm';

  @override
  String get weightProgress => 'Progreso de Peso';

  @override
  String get chartEmpty => 'Add at least two weight entries to see a graph.';

  @override
  String get proBannerTitle => 'Fastable PRO';

  @override
  String get proBannerDesc => 'Desbloquear análisis';

  @override
  String get premiumContentTitle => 'Contenido Premium';

  @override
  String get premiumContentDesc => 'Desbloquea acceso completo a todos los artículos y funciones.';

  @override
  String get getPro => 'Obtener Acceso PRO';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String get proTitle => 'Desbloquea Fastable Pro';

  @override
  String get proMonthly => 'Suscripción Mensual';

  @override
  String get proAnnual => 'Annual Subscription (40% Off)';

  @override
  String get unlockAll => 'Desbloquear Todo';

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
  String get proComingSoon => '¡La versión PRO llegará pronto! Mantente atento.';

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
  String get historyEmpty => 'Aún no hay ayunos completados. ¡Tu historial aparecerá aquí!';

  @override
  String get fastComplete => '¡Ayuno Completado! 🎉';

  @override
  String fastCompleteDesc(String time) {
    return 'Has ayunado durante $time. ¿Guardar este registro?';
  }

  @override
  String get noFastsOnDay => 'No hay ayunos completados en este día.';

  @override
  String get detailsFor => 'Detalles para';

  @override
  String get endCyclePrompt => '¿Terminar Ventana de Alimentación?';

  @override
  String get endCyclePromptDesc => 'Esto terminará tu ventana de alimentación y reiniciará el ciclo.';

  @override
  String get endFastPrompt => 'Termina tu ciclo actual para cambiar el plan.';

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
  String get finish => 'Terminar';

  @override
  String get attention => 'Atención';

  @override
  String get continueAction => 'Continuar';

  @override
  String get settingLanguage => 'Idioma';

  @override
  String get settingWaterGoal => 'Objetivo Diario de Agua';

  @override
  String get settingHeight => 'Altura';

  @override
  String get settingGoalWeight => 'Peso Objetivo';

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
  String get healthConnectDisclosureIntro => 'Fastable solicita acceso de LECTURA y ESCRITURA a los datos de PESO a través de Health Connect.';

  @override
  String get healthConnectDisclosureRead => 'Usamos el acceso de LECTURA para mostrar tu gráfico de progreso de peso y estadísticas.';

  @override
  String get healthConnectDisclosureWrite => 'Usamos el acceso de ESCRITURA para que puedas guardar las entradas de peso de Fastable.';

  @override
  String get healthConnectDisclosureSecure => 'Los datos se almacenan localmente. Puedes revocar los permisos en cualquier momento.';

  @override
  String get healthConnectConnected => '¡Health Connect conectado!';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get notifyWater => 'Recordatorios de Agua';

  @override
  String get notifyWaterDesc => 'Recibe recordatorios para beber agua';

  @override
  String get notifyWeight => 'Recordatorio de Peso';

  @override
  String get notifyWeightDesc => 'Recordatorio diario para pesarse';

  @override
  String get notifyFastingStart => 'Inicio del Ayuno';

  @override
  String get notifyFastingStartDesc => 'Notificar cuando comience la ventana de ayuno';

  @override
  String get simplifiedAnimation => 'Animaciones Simplificadas';

  @override
  String get simplifiedAnimationDesc => 'Reduce el desenfoque y los efectos para mejorar la batería.';

  @override
  String get settingPerformance => 'Rendimiento';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Uso';

  @override
  String get errorOpenLink => 'No se pudo abrir el enlace';

  @override
  String get errorLoading => 'Error al cargar los datos';

  @override
  String get noArticlesFound => 'No se encontraron artículos';

  @override
  String get tabFasting => 'Ayuno';

  @override
  String get tabKeto => 'Keto';

  @override
  String get tabPartner => 'Compañero';

  @override
  String get guestUser => 'Usuario Invitado';

  @override
  String get defaultUser => 'Usuario';

  @override
  String get anonymousLogin => 'Inicio de sesión anónimo';

  @override
  String get dataOnDevice => 'Datos guardados en el dispositivo';

  @override
  String get connectGoogle => 'Conectar Cuenta de Google';

  @override
  String get saveProgressCloud => 'Guardar progreso en la nube';

  @override
  String get accountLinked => '¡Cuenta vinculada con éxito!';

  @override
  String get linkError => 'Error al vincular la cuenta';

  @override
  String get resetAndExit => 'Restablecer Datos y Salir';

  @override
  String get deleteAndExit => 'Eliminar y Salir';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get confirmLogout => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get guestLogoutWarning => 'Estás usando una cuenta de Invitado. Si cierras sesión, todos los datos locales se eliminarán permanentemente.';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountWarning => '¿Estás seguro? Esto eliminará permanentemente todos tus datos.';

  @override
  String get authWelcome => 'Bienvenido al Ayuno Moderno';

  @override
  String get authSubtitle => 'Inicia sesión para sincronizar datos';

  @override
  String get signInGoogle => 'Iniciar sesión con Google';

  @override
  String get continueGuest => 'Continuar como Invitado';

  @override
  String get signInFailed => 'El inicio de sesión falló. Por favor, inténtalo de nuevo.';

  @override
  String get welcomeMessage => '¡Bienvenido a tu aplicación de ayuno!';

  @override
  String get choosePlan => 'Elige un Plan';

  @override
  String get fastingPlan16_8 => '16:8 Ayuno Intermitente';

  @override
  String get fastingPlan18_6 => '18:6 Ayuno Intermitente';

  @override
  String get fastingPlan20_4 => '20:4 La Dieta del Guerrero';

  @override
  String get fastingPlanEatStopEat => 'Come-Para-Come (24h)';

  @override
  String get bmiCalculator => 'Calculadora de IMC';

  @override
  String get bmiCategory => 'Categoría';

  @override
  String get bmiUnderweight => 'Bajo peso';

  @override
  String get bmiNormal => 'Peso Normal';

  @override
  String get bmiOverweight => 'Sobrepeso';

  @override
  String get bmiObese => 'Obesidad';

  @override
  String get enterHeightCm => 'Introduce tu altura (cm)';

  @override
  String get enterGoalWeightKg => 'Introduce tu peso objetivo (kg)';

  @override
  String get fastingStats => 'Estadísticas de Ayuno';

  @override
  String get fastingStatsCurrentStreak => 'Racha Actual';

  @override
  String get fastingStatsDay => 'Día';

  @override
  String get fastingStatsDays => 'Días';

  @override
  String get fastingStatsTotalFasts => 'Total de Ayunos';

  @override
  String get fastingStatsTotalHours => 'Horas Totales';

  @override
  String get fastingStatsAvgFast => 'Ayuno Promedio';

  @override
  String get fastingStatsHours => 'Horas';

  @override
  String get onboardingWelcomeTitle => '¡Bienvenido!';

  @override
  String get onboardingWelcomeDesc => 'Inicia tu viaje hacia la salud. Configuremos tu perfil.';

  @override
  String get onboardingGoalTitle => '¿Cuáles son tus objetivos?';

  @override
  String get onboardingGoalDesc => 'Configura tu altura y peso objetivo para calcular tu IMC.';

  @override
  String get onboardingPlanTitle => 'Elige tu plan';

  @override
  String get onboardingPlanDesc => '¿Con qué plan te gustaría empezar? Puedes cambiarlo más tarde.';

  @override
  String get onboardingCurrentWeight => 'Tu peso actual';

  @override
  String get getStarted => 'Empezar';

  @override
  String get currentStage => 'Etapa Actual';

  @override
  String get nextStage => 'Siguiente';

  @override
  String get stageAnabolicTitle => 'Anabólico (Alimentado)';

  @override
  String get stageAnabolicDesc => 'Tu cuerpo está digiriendo y usando glucosa para obtener energía.';

  @override
  String get stageCatabolicTitle => 'Catabólico';

  @override
  String get stageCatabolicDesc => 'Los niveles de azúcar en sangre caen. Tu cuerpo empieza a usar glucógeno del hígado.';

  @override
  String get stageKetosisTitle => 'Cetosis';

  @override
  String get stageKetosisDesc => 'Las reservas de glucógeno se agotan. Tu cuerpo cambia a quemar grasa.';

  @override
  String get stageAutophagyTitle => 'Autofagia';

  @override
  String get stageAutophagyDesc => 'Comienza el proceso de limpieza celular. Tu cuerpo recicla células viejas.';

  @override
  String get stagePeakAutophagyTitle => 'Pico de Autofagia';

  @override
  String get stagePeakAutophagyDesc => 'El proceso de autofagia alcanza su pico, maximizando la renovación celular.';

  @override
  String get achievementsTitle => 'Logros';

  @override
  String get achievementsUnlocked => 'Desbloqueado';

  @override
  String get achievementsLocked => 'Bloqueado';

  @override
  String achEarnedOn(Object date) {
    return 'Obtenido el $date';
  }

  @override
  String get achFirstFastTitle => '¡Primer Ayuno!';

  @override
  String get achFirstFastDesc => 'Completa tu primera sesión de ayuno.';

  @override
  String get achStreak3Title => 'Empezando';

  @override
  String get achStreak3Desc => 'Mantén una racha de ayuno de 3 días.';

  @override
  String get achStreak7Title => 'Constante';

  @override
  String get achStreak7Desc => 'Alcanza una racha de 7 días. ¡Estás en racha!';

  @override
  String get achTotal10Title => 'Novato';

  @override
  String get achTotal10Desc => 'Completa 10 ayunos en total.';

  @override
  String get achTotalHours100Title => 'Club de 100 Horas';

  @override
  String get achTotalHours100Desc => 'Acumula 100 horas de ayuno.';

  @override
  String get journalTitle => 'Nota de Diario';

  @override
  String get journalHint => '¿Cómo te sentiste durante este ayuno?';

  @override
  String get addNote => 'Añadir Nota';

  @override
  String get editNote => 'Editar Nota';

  @override
  String get noteSaved => 'Nota guardada';

  @override
  String get syncHealthTitle => 'Sincronizar con Apple Health';

  @override
  String get syncHealthDesc => 'Escribe automáticamente datos de ayuno y lee peso.';

  @override
  String get shareProgress => 'Compartir Progreso';

  @override
  String get metricPhase => 'Fase';

  @override
  String get metricStreak => 'Racha';

  @override
  String get metricStatus => 'Estado';

  @override
  String get statusDigesting => 'Digiriendo';

  @override
  String get statusStable => 'Estable';

  @override
  String get statusFatBurn => 'Quema de Grasa';

  @override
  String get statusKetosis => 'Cetosis';

  @override
  String get statusNormal => 'Normal';

  @override
  String get titleCurrentPhase => 'Fase Actual';

  @override
  String get valFastingZone => 'Zona de Ayuno';

  @override
  String get valEatingWindow => 'Ventana de Alimentación';

  @override
  String get descFastingZone => 'Actualmente estás en la ventana de ayuno. No se deben consumir calorías.';

  @override
  String get descEatingWindow => 'Estás en tu ventana de alimentación. Céntrate en alimentos ricos en nutrientes.';

  @override
  String get titleConsistencyStreak => 'Racha de Constancia';

  @override
  String valStreakDays(int days) {
    return '$days Días 🔥';
  }

  @override
  String descStreak(int days) {
    return 'Has alcanzado tu objetivo de ayuno por $days días consecutivos. ¡Sigue así para crear un hábito!';
  }

  @override
  String get titleBodyStatus => 'Estado del Cuerpo';

  @override
  String get descDigesting => 'Tu cuerpo está digiriendo alimentos y reponiendo las reservas de glucógeno. Los niveles de insulina están subiendo.';

  @override
  String get descStable => 'Tus niveles de azúcar en sangre se están normalizando. El cuerpo se prepara para cambiar de glucosa a grasa como combustible.';

  @override
  String get descFatBurn => '¡Gran trabajo! Tu cuerpo está comenzando a quemar grasa almacenada para obtener energía. Los niveles de hormona de crecimiento pueden empezar a aumentar.';

  @override
  String get descKetosis => '¡Cetosis Profunda! Tu cuerpo está quemando grasa eficientemente. La autofagia (limpieza celular) puede comenzar pronto.';

  @override
  String get btnGotIt => '¡Entendido!';

  @override
  String get stage0_4 => 'El azúcar en sangre sube';

  @override
  String get stage0_4_desc => 'Tu cuerpo está digiriendo tu última comida. El azúcar y la insulina suben.';

  @override
  String get stage4_8 => 'Caída de Azúcar en Sangre';

  @override
  String get stage4_8_desc => 'La insulina empieza a bajar. Tu cuerpo usa la glucosa almacenada.';

  @override
  String get stage8_12 => 'Normalización';

  @override
  String get stage8_12_desc => 'El sistema digestivo descansa. Tu cuerpo empieza a curarse y limpiarse.';

  @override
  String get stage12_16 => 'Quema de Grasa';

  @override
  String get stage12_16_desc => 'La insulina está baja. Tu cuerpo empieza a quemar grasa almacenada.';

  @override
  String get stage16_18 => 'Cetosis';

  @override
  String get stage16_18_desc => 'La quema de grasa se acelera. Estás en modo de quema de grasa total.';

  @override
  String get stage18_24 => 'Autofagia';

  @override
  String get stage18_24_desc => 'Comienza la limpieza celular. Tu cuerpo recicla células viejas.';

  @override
  String get stage24_plus => 'Reparación Profunda';

  @override
  String get stage24_plus_desc => 'La hormona de crecimiento aumenta. Ocurre una regeneración celular significativa.';

  @override
  String get viewTimeline => 'Ver Línea de Tiempo del Cuerpo';

  @override
  String get navFood => 'Comida';

  @override
  String get circadianEnabled => 'Modo circadiano activado';

  @override
  String get circadianDisabled => 'Modo circadiano desactivado';

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
  String get waterSettings => 'Ajustes de Agua';

  @override
  String get removeCup => 'Quitar Vaso (-1)';

  @override
  String get dailyGoal => 'Objetivo Diario';

  @override
  String get bmiScore => 'Puntuación IMC';

  @override
  String bmiDescription(int height, String weight) {
    return 'Basado en tu altura ($height cm) y peso ($weight kg).';
  }

  @override
  String get onboardingTitle => 'Personaliza tu plan';

  @override
  String get onboardingHeightTitle => '¿Cuál es tu altura?';

  @override
  String get onboardingHeightDesc => 'Necesitamos esto para calibrar el Visualizador Corporal y calcular tus métricas.';

  @override
  String get onboardingWeightTitle => '¿Cuál es tu peso?';

  @override
  String get onboardingWeightDesc => 'Esto nos ayuda a rastrear tu progreso y ajustar tu plan.';

  @override
  String get btnNext => 'Siguiente';

  @override
  String get btnFinish => 'Comenzar Viaje';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get statsSuccessRate => 'Tasa de Éxito';

  @override
  String statsSuccessDesc(int success, int total) {
    return '$success de $total ayunos fueron de más de 16h';
  }

  @override
  String get statsTotalFasts => 'Total de Ayunos';

  @override
  String get statsTotalHours => 'Horas Totales';

  @override
  String get statsAverage => 'Promedio';

  @override
  String get statsLongest => 'Más Largo';

  @override
  String get circadianTitle => 'Ritmo Circadiano';

  @override
  String get circadianIntroTitle => 'Come con el Sol ☀️';

  @override
  String get circadianIntroDesc => 'Tu metabolismo está ligado al sol.\n\n• Amanecer: Mejor momento para despertar e hidratarse.\n• Día: Metabolismo alto. Ideal para comer.\n• Atardecer: El metabolismo se ralentiza. Deja de comer.\n• Noche: Modo de reparación profunda. El ayuno es fácil.\n\nEste modo ajusta automáticamente tus objetivos de ayuno a las horas de salida y puesta del sol en tu ubicación.';

  @override
  String get circadianBtnEnable => 'Activar Modo Circadiano';

  @override
  String get circadianBtnDisable => 'Desactivar';

  @override
  String get circadianTargetSunrise => 'Hasta el Amanecer';

  @override
  String get circadianTargetSunset => 'Hasta el Atardecer';

  @override
  String get circadianPhaseDay => 'Día (Comer)';

  @override
  String get circadianPhaseNight => 'Noche (Ayunar)';

  @override
  String get circadianWarnDayTitle => 'Es de Día ☀️';

  @override
  String get circadianWarnDayDesc => '¡El sol ya salió! Tu cuerpo está listo para comer. Lo ideal es esperar hasta el atardecer para comenzar a ayunar.';

  @override
  String get circadianWarnBtnStart => 'Comenzar de todos modos';

  @override
  String get circadianWarnBtnWait => 'Esperar al Atardecer';

  @override
  String get circadianBonusTime => 'Tiempo Extra 🔥';

  @override
  String get circadianSyncing => 'Sincronizando con el Sol...';

  @override
  String get circadianError => 'No se pudo obtener la ubicación. Usando el temporizador estándar.';

  @override
  String get circadianManaged => 'Controlado por el Sol';

  @override
  String get notifBio4hTitle => 'Azúcar en Sangre Estabilizada 🩸';

  @override
  String get notifBio4hBody => 'Tus niveles de insulina están bajando. Los falsos dolores de hambre pueden desaparecer.';

  @override
  String get notifBio8hTitle => 'El Estómago está Vacío ✅';

  @override
  String get notifBio8hBody => 'La digestión se ha completado. Tu cuerpo está cambiando al modo de reparación.';

  @override
  String get notifBio12hTitle => 'Entrando en Cetosis 🔥';

  @override
  String get notifBio12hBody => '¡Tu cuerpo ha comenzado a quemar grasa almacenada para obtener energía!';

  @override
  String get notifBio16hTitle => 'Pico de Quema de Grasa ⚡️';

  @override
  String get notifBio16hBody => 'El metabolismo se acelera. Estás en la zona de quema intensa.';

  @override
  String get notifBio18hTitle => 'Autofagia Iniciada ♻️';

  @override
  String get notifBio18hBody => 'Limpieza celular activa. Tu cuerpo está reciclando células viejas.';

  @override
  String get notifBio24hTitle => 'Pico de HGH 🛡';

  @override
  String get notifBio24hBody => 'Los niveles de hormona de crecimiento han subido para proteger tus músculos.';

  @override
  String get notifProg50Title => '¡A Mitad de Camino! 🚀';

  @override
  String get notifProg50Body => 'Has superado el 50% de tu objetivo. ¡Sigue así!';

  @override
  String get notifProg1hTitle => 'Queda 1 Hora ⏳';

  @override
  String get notifProg1hBody => '¡Casi listo! Puedes empezar a preparar tu comida.';

  @override
  String get notifProgFinishTitle => '¡Objetivo Alcanzado! 🏆';

  @override
  String get notifProgFinishBody => '¡Lo lograste! No olvides detener el temporizador.';

  @override
  String get notifWaterTitle => 'Bebe Agua 💧';

  @override
  String get notifWaterBody => 'La hidratación acelera tu metabolismo y reduce el hambre.';

  @override
  String get notifWeightTitle => 'Pesaje Matutino ⚖️';

  @override
  String get notifWeightBody => 'La mañana es el mejor momento para registrar tu peso.';

  @override
  String get permTitle => 'Activar Permisos';

  @override
  String get permDesc => 'Para darte la mejor experiencia, Fastable necesita acceso a notificaciones y datos de salud.';

  @override
  String get permNotifTitle => 'Notificaciones';

  @override
  String get permNotifDesc => 'Mantente en el camino con alertas de ayuno.';

  @override
  String get permHealthTitle => 'Apple Health';

  @override
  String get permHealthDesc => 'Sincroniza datos de peso y agua.';

  @override
  String get permAllow => 'Permitir';

  @override
  String get permContinue => 'Continuar';

  @override
  String get achFirstFast => 'Primer Paso';

  @override
  String get achStreak3 => 'Constancia';

  @override
  String get achStreak7 => 'Imparable';

  @override
  String get achTotal10 => 'Dedicado';

  @override
  String get achTotalHours100 => 'Centurión';

  @override
  String get onboardingDesc => 'Vamos a calcular tu tasa metabólica.';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnStart => 'Comenzar Viaje';

  @override
  String get selectGender => 'Género';

  @override
  String get selectAge => 'Edad';

  @override
  String get selectWeight => 'Peso';

  @override
  String get selectHeight => 'Altura';

  @override
  String get selectActivity => 'Nivel de Actividad';

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
  String get contactSupport => 'Contactar Soporte';

  @override
  String get metabolicProfile => 'Perfil Metabólico';

  @override
  String ageYears(int age) {
    return '$age años';
  }

  @override
  String get metricBmrTitle => 'TMB';

  @override
  String get metricBmrSubtitle => 'Basal';

  @override
  String get metricBmrDesc => 'Tasa Metabólica Basal. Calorías quemadas en reposo completo.';

  @override
  String get metricTdeeTitle => 'GEDT';

  @override
  String get metricTdeeSubtitle => 'Mantenimiento';

  @override
  String get metricTdeeDesc => 'Gasto Energético Diario Total. Calorías necesarias para mantener el peso actual.';

  @override
  String get dialogStartTitle => '¿Cuándo empezó tu ayuno?';

  @override
  String get btnStartFasting => 'Iniciar Ayuno';

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
  String get stage8Body => '8 horas. Tu estómago está descansando. ¡Lo estás haciendo muy bien!';

  @override
  String get stage11Title => 'Modo de Quema de Grasa 🔥';

  @override
  String get stage11Body => '¡Empieza la parte divertida! Tu cuerpo cambia a reservas internas.';

  @override
  String get stage12Title => 'Cetosis Activada 🚀';

  @override
  String get stage12Body => 'Las células grasas se convierten en energía. Tu mente está más clara.';

  @override
  String get stage14Title => 'Cetosis Profunda 🔥';

  @override
  String get stage14Body => '¡Estás en la zona de quema de grasa! La desintoxicación es rápida ahora.';

  @override
  String get stage16Title => 'Autofagia (Reparación Celular) 🧬';

  @override
  String get stage16Body => 'Tus células se están renovando. ¡Esta es la fuente de la juventud!';

  @override
  String get stage18Title => 'Pico de Hormona de Crecimiento 📈';

  @override
  String get stage18Body => 'La hormona de crecimiento ayuda a los músculos y quema grasa. ¡Te estás fortaleciendo!';

  @override
  String get stage24Title => '¡24 Horas! 🏆';

  @override
  String get stage24Body => '¡Increíble! Día completo. La limpieza profunda está en pleno efecto.';

  @override
  String get notifyHalfwayTitle => '¡A mitad de camino! ⛰️';

  @override
  String get notifyHalfwayBody => 'La parte más difícil ha pasado. Tu cuerpo te lo agradece.';

  @override
  String get notify1hTitle => '¡Recta Final! 🏁';

  @override
  String get notify1hBody => 'Solo queda 1 hora. ¡Lo estás haciendo increíble!';

  @override
  String get notifyGoalTitle => '¡Objetivo Alcanzado! 🎉';

  @override
  String get notifyGoalBody => '¡Felicidades! Rompe tu ayuno suavemente.';

  @override
  String get notifyEatCloseTitle => 'La ventana de alimentación se cierra 🛑';

  @override
  String get notifyEatCloseBody => 'Es hora de empezar tu próximo ayuno. ¡Revisa la aplicación!';

  @override
  String get notifyEat30mTitle => 'Quedan 30 minutos 🥗';

  @override
  String get notifyEat30mBody => 'No olvides beber agua o comer un último refrigerio.';

  @override
  String get learnTitle => 'Aprender y Comer';

  @override
  String get tabArticles => 'Artículos';

  @override
  String get catBasics => 'Básicos';

  @override
  String get catNutrition => 'Nutrición';

  @override
  String get catHealth => 'Salud';

  @override
  String get catKeto => 'Keto';

  @override
  String get headerLatestArticles => 'Últimos Artículos';

  @override
  String get headerHealthyChoices => 'Opciones Saludables';

  @override
  String get statusNoArticles => 'No se encontraron artículos';

  @override
  String get msgComingSoon => '¡Esta función estará disponible pronto!';

  @override
  String get learnBannerTitle => 'Desbloquea más de 500 Recetas';

  @override
  String get learnBannerSubtitle => 'Obtén acceso completo con PRO';

  @override
  String get labelPremium => 'PREMIUM';

  @override
  String get bannerRecipeTitle => 'Recetas Saludables';

  @override
  String get bannerRecipeSubtitle => 'Keto, Bajo en Carbohidratos y Más';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitMin => 'min';

  @override
  String get lblAchievements => 'Logros';

  @override
  String get lblPersonalData => 'Datos Personales';

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
  String get lblActivity => 'Nivel de Actividad';

  @override
  String get lblLanguage => 'Idioma';

  @override
  String get msgHealthSyncEnabled => '¡Sincronización de Salud Activada!';

  @override
  String get msgHealthSyncFailed => 'Permiso denegado';

  @override
  String get aiGreeting => '¡Hola! Soy Fasty 🥑. ¿Cómo puedo ayudarte a alcanzar tus objetivos hoy?';

  @override
  String get aiConnectionError => '¡Ups! Perdí la conexión. Por favor, comprueba tu internet o inténtalo más tarde. 🥑';

  @override
  String get aiSystemError => 'El servicio de IA no está configurado correctamente (Falta la clave API).';

  @override
  String get aiCoachTitle => 'Coach de Ayuno con IA';

  @override
  String get aiCoachDesc => 'Obtén respuestas instantáneas sobre Keto, Ayuno Intermitente y hábitos saludables de nuestro asistente inteligente de IA.';

  @override
  String get aiChatHint => 'Pregunta sobre keto o ayuno...';

  @override
  String get btnUnlockPro => 'Desbloquear con PRO';

  @override
  String get aiInsightFallback => '¡La constancia es la clave! Bebe agua y mantente en movimiento. 💧';

  @override
  String get aiErrorConnection => 'Problema de conexión. Por favor, inténtalo más tarde.';

  @override
  String get aiInsightTitle => 'INSIGHT DIARIO';

  @override
  String get aiInsightTeaser => 'Basado en tus últimos 7 días de ayuno, encontramos un patrón significativo que afecta tu progreso...';

  @override
  String get tapToUnlock => 'Tocar para Desbloquear';

  @override
  String get notifyAiInsightTitle => '¡Tu Insight Diario de IA está Listo! 🥑';

  @override
  String get notifyAiInsightBody => 'Mira lo que Fasty ha analizado para ti hoy. Toca para desbloquear.';

  @override
  String get notifyWeightTitle => 'Registra tu peso ⚖️';

  @override
  String get notifyWeightBody => '¡La consistencia es clave! Registra tu peso hoy.';

  @override
  String get aiInsightNotEnoughData => '¡Sigue registrando! Necesitamos al menos 3 ayunos para analizar tus patrones únicos. 📊';

  @override
  String msgLoginFailed(Object error) {
    return 'Error de inicio de sesión: $error';
  }

  @override
  String msgAppleLoginFailed(Object error) {
    return 'El inicio de sesión con Apple falló: $error';
  }

  @override
  String get msgSyncCompleted => 'Sincronización completada';

  @override
  String get msgErrorRelogin => 'Error: Por favor, vuelve a iniciar sesión e inténtalo de nuevo.';

  @override
  String get signInApple => 'Iniciar sesión con Apple';

  @override
  String get lblDangerZone => 'ZONA DE PELIGRO';

  @override
  String get btnDeleteAccount => 'Eliminar Cuenta';

  @override
  String get dialogDeleteAccountTitle => '¿Eliminar Cuenta?';

  @override
  String get dialogDeleteAccountContent => 'Esta acción es permanente. Todo tu historial de peso, registros de ayuno y logros se eliminarán de la nube.';

  @override
  String get btnDelete => 'ELIMINAR';

  @override
  String get dialogSyncConflictTitle => 'Conflicto de Sincronización';

  @override
  String get dialogSyncConflictContent => 'Se encontraron datos en la nube. ¿Combinar con datos locales o sobrescribir?';

  @override
  String get btnUseCloud => 'Usar la Nube\n(Descartar Invitado)';

  @override
  String get btnMergeData => 'Combinar Datos';

  @override
  String lblVersion(Object version) {
    return 'Versión $version';
  }

  @override
  String get lblCurrentWeight => 'Peso Actual';

  @override
  String get lblBasalBmr => 'Basal (TMB)';

  @override
  String get lblActiveTdee => 'Activo (GEDT)';

  @override
  String get lblTotalHours => 'Horas Totales';

  @override
  String get unitHoursShort => 'h';

  @override
  String get lblConsistency => 'Constancia';

  @override
  String get lblLast7Days => 'Últimos 7 Días';

  @override
  String get lblFasts => 'Ayunos';

  @override
  String get lblHours => 'Horas';

  @override
  String get lblDayStreak => 'Racha de Días';

  @override
  String get msgStartJourney => 'Comienza tu viaje hoy';

  @override
  String get lblToday => 'Hoy';

  @override
  String get lblYesterday => 'Ayer';

  @override
  String get confirmTime => 'Confirmar Tiempo';

  @override
  String get lblFastingTypeCircadian => 'Circadiano';

  @override
  String get lblFastingTypeWarrior => 'Guerrero';

  @override
  String get lblFastingTypeOmad => 'OMAD';

  @override
  String lblHistoryFor(Object date) {
    return 'Historial para $date';
  }

  @override
  String get lblNoRecordsForDay => 'No hay registros para este día';

  @override
  String get lblCustomPlan => 'Plan Personalizado';

  @override
  String get lblAdjustDuration => 'Ajustar Duración';

  @override
  String get lblFasting => 'Ayuno';

  @override
  String get lblEating => 'Alimentación';

  @override
  String get lblSlideToAdjust => 'Desliza para ajustar horas';

  @override
  String get btnStartCustomPlan => 'Iniciar Plan Personalizado';

  @override
  String get btnUnlockFeature => 'Desbloquear Plan Personalizado';

  @override
  String get proFeatureTitle => 'Función Pro';

  @override
  String get proFeatureDesc => 'Los horarios de ayuno personalizados están disponibles para usuarios Pro.';

  @override
  String get setFastingGoal => 'Establecer Objetivo de Ayuno';

  @override
  String get fastingSaved => '¡Ayuno guardado! 🏆';

  @override
  String get whenStopEating => '¿Cuándo dejaste de comer?';

  @override
  String get editTime => 'Editar Tiempo';

  @override
  String get customPlan => 'Personalizado';

  @override
  String get tapToEdit => 'Toca para ajustar el objetivo';

  @override
  String get timeLeft => 'RESTANTE';

  @override
  String get maxBenefits => 'Máximos Beneficios Alcanzados';

  @override
  String get appNameUpper => 'FASTABLE';

  @override
  String get splashSlogan => 'Libera el potencial de tu cuerpo';

  @override
  String get weightSaved => 'Peso guardado';

  @override
  String get proSubtitle => 'Libera todo tu potencial';

  @override
  String get featureCoach => 'Coach de IA Fasty';

  @override
  String get featureCoachDesc => 'Consejos personalizados y motivación 24/7';

  @override
  String get featureRecipes => 'Recetas Saludables';

  @override
  String get featureRecipesDesc => 'Comidas aptas para Keto, Bajas en Carbohidratos y Ayuno';

  @override
  String get featureNoAds => 'Experiencia Sin Anuncios';

  @override
  String get featureNoAdsDesc => 'Concéntrate en tus objetivos sin distracciones';

  @override
  String get bestValue => 'MEJOR VALOR';

  @override
  String get loadingOffers => 'Cargando ofertas...';

  @override
  String get welcomePro => '¡Bienvenido a Pro! 🚀';

  @override
  String get errorPro => 'La compra falló. Por favor, inténtalo de nuevo.';

  @override
  String get confirmDeleteMsg => 'Esta acción no se puede deshacer. Se perderán todos tus datos.';

  @override
  String get statusLocked => 'Bloqueado';

  @override
  String get sectionLegal => 'Legal y Soporte';

  @override
  String get btnOverwriteLocal => 'Sobrescribir Local';

  @override
  String get msgDeleteError => 'Error al eliminar la cuenta';

  @override
  String get msgDeleteReauthCancelled => 'Eliminación de cuenta cancelada.';

  @override
  String get msgDeleteReauthFailed => 'No pudimos confirmar tu identidad. Por favor, inténtalo de nuevo.';

  @override
  String get msgDeleteReauthUnavailable => 'Por favor, vuelve a iniciar sesión con el proveedor original antes de eliminar esta cuenta.';

  @override
  String get stepLanguage => 'Seleccionar Idioma';

  @override
  String get stepBodyMetrics => 'Métricas Corporales';

  @override
  String get stepBodyMetricsDesc => 'Ayúdanos a calcular tu IMC y objetivos';

  @override
  String get activityHint => 'Se utiliza para calcular tu gasto diario de energía.';

  @override
  String get activitySedentaryDesc => 'Trabajo de oficina, poco ejercicio';

  @override
  String get activityModerateDesc => 'Trabajo activo o ejercicio 3-4 veces por semana';

  @override
  String get activityActiveDesc => 'Trabajo físico o entrenamiento diario';

  @override
  String get stepGoal => 'Elige tu Objetivo';

  @override
  String get recommendationMsg => 'Te recomendamos el plan 16-8.';

  @override
  String get planBeginner => 'Principiante';

  @override
  String get planPopular => 'Popular (16:8)';

  @override
  String get planAdvanced => 'Avanzado (18:6)';

  @override
  String get planExpert => 'Experto (OMAD)';

  @override
  String get labelRecommended => 'RECOMENDADO';

  @override
  String get permHealthConnect => 'Health Connect';

  @override
  String get permHealthConnectDesc => 'Sincroniza peso y pasos con Google Fit';

  @override
  String get planMonthly => 'Mensual';

  @override
  String get planAnnual => 'Anual';

  @override
  String get planLifetime => 'De por vida';

  @override
  String savePercent(String percent) {
    return 'AHORRA $percent%';
  }

  @override
  String get medicalDisclaimerTitle => 'Aviso Médico y Fuentes';

  @override
  String get medicalDisclaimerHeading => 'Aviso Médico';

  @override
  String get medicalDisclaimerBody => 'Fastable está diseñado para ayudarte a rastrear tu ayuno intermitente. NO es un dispositivo médico. La información proporcionada es solo para fines educativos y no debe reemplazar el consejo médico profesional.\n\nPor favor, consulta a un médico antes de comenzar cualquier régimen de ayuno, especialmente si estás embarazada, amamantando, eres diabético o tienes cualquier otra condición médica.';

  @override
  String get scientificSourcesHeading => 'Fuentes Científicas y Citas';

  @override
  String get sourceJohnsHopkins => 'Johns Hopkins Medicine';

  @override
  String get sourceJohnsHopkinsDesc => 'Ayuno intermitente: ¿Qué es y cómo funciona?';

  @override
  String get sourceMayoClinic => 'Mayo Clinic';

  @override
  String get sourceMayoClinicDesc => 'Dieta de ayuno: ¿Puede mejorar la salud de mi corazón?';

  @override
  String get sourceHarvard => 'Harvard Medical School';

  @override
  String get sourceHarvardDesc => 'Ayuno intermitente: Actualización sorprendente';

  @override
  String get legalAgreementPrefix => 'Al continuar, aceptas los ';

  @override
  String get legalTermsOfUse => 'Términos de Uso (EULA)';

  @override
  String get legalAgreementAnd => ' y nuestra ';

  @override
  String get legalPrivacyPolicy => 'Política de Privacidad';

  @override
  String get comingSoonTitle => '¡Próximamente!';

  @override
  String get comingSoonDesc => 'Estamos trabajando duro para preparar contenido increíble para ti. ¡Mantente atento!';

  @override
  String get statusNoRecipes => 'No se encontraron recetas';

  @override
  String get aboutAndLegal => 'Acerca de y Legal';

  @override
  String get settingsMedicalDisclaimer => 'Aviso Médico y Fuentes';

  @override
  String get settingsTermsOfUse => 'Términos de Uso (EULA)';

  @override
  String get deleteAccountAndData => 'Eliminar Cuenta y Datos';

  @override
  String get deleteAccountTitle => '¿Eliminar Cuenta?';

  @override
  String get deleteAccountContent => 'Esta acción es irreversible. Todo tu historial de ayuno y datos locales se eliminarán permanentemente.';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get planExtended => 'Extendido';

  @override
  String get zoneSugarRises => 'El azúcar en sangre sube';

  @override
  String get zoneSugarRisesDesc => 'Tu cuerpo está procesando tu última comida y almacenando energía.';

  @override
  String get zoneSugarDrops => 'El azúcar en sangre cae';

  @override
  String get zoneSugarDropsDesc => 'Termina la digestión. Los niveles de azúcar en la sangre vuelven a la normalidad.';

  @override
  String get zoneFatBurning => 'Quema de Grasa';

  @override
  String get zoneFatBurningDesc => 'Tu cuerpo comienza a quemar grasa almacenada para obtener energía.';

  @override
  String get zoneKetosis => 'Cetosis';

  @override
  String get zoneKetosisDesc => 'La quema de grasa se acelera. Aumenta la claridad mental.';

  @override
  String get zoneAutophagy => 'Autofagia';

  @override
  String get zoneAutophagyDesc => 'Comienza la reparación y reciclaje celular. Efectos antienvejecimiento.';

  @override
  String get zoneGrowthHormone => 'Hormona de Crecimiento';

  @override
  String get zoneGrowthHormoneDesc => 'Pico de quema de grasa, reparación de tejidos y preservación muscular.';

  @override
  String continueForPrice(String price) {
    return 'Continuar por $price';
  }

  @override
  String get offersUnavailable => 'Las ofertas no están disponibles temporalmente';

  @override
  String get billedMonthly => 'Facturado mensualmente';

  @override
  String get billedAnnually => 'Facturado anualmente';

  @override
  String get oneTimePurchase => 'Compra única';

  @override
  String get goalPriorityTitle => '¿Qué es lo más importante ahora mismo?';

  @override
  String get goalPriorityDesc => 'Usamos esto para equilibrar la velocidad, la recuperación y la consistencia a largo plazo.';

  @override
  String get goalFatLossTitle => 'Perder grasa más rápido';

  @override
  String get goalFatLossDesc => 'Favorecer ventanas de ayuno más fuertes cuando tu perfil pueda manejarlas.';

  @override
  String get goalHealthTitle => 'Mejorar la salud y la energía';

  @override
  String get goalHealthDesc => 'Busca un plan equilibrado que apoye la concentración, la energía y la adherencia.';

  @override
  String get goalHabitTitle => 'Construir un hábito sostenible';

  @override
  String get goalHabitDesc => 'Empieza más fácil para que la rutina realmente se mantenga.';

  @override
  String get routineTitle => 'Cuéntanos sobre tu rutina';

  @override
  String get routineDesc => 'El sueño y la experiencia de ayuno cambian lo agresivo que debe ser tu plan inicial.';

  @override
  String get fastingExperienceTitle => 'Experiencia de ayuno';

  @override
  String get experienceBeginnerTitle => 'Principiante';

  @override
  String get experienceBeginnerDesc => 'Soy nuevo en el ayuno o normalmente me detengo temprano.';

  @override
  String get experienceIntermediateTitle => 'Algo de experiencia';

  @override
  String get experienceIntermediateDesc => 'Puedo manejar ayunos de 14-16 horas sin mucho problema.';

  @override
  String get experienceAdvancedTitle => 'Avanzado';

  @override
  String get experienceAdvancedDesc => 'He hecho ayunos más largos y quiero un protocolo más fuerte.';

  @override
  String get sleepPatternTitle => 'Horario de sueño';

  @override
  String get sleepRegularTitle => 'Sueño regular';

  @override
  String get sleepRegularDesc => 'Mi hora de acostarme y despertarme son mayormente consistentes.';

  @override
  String get sleepLateTitle => 'Noches trasnochadoras';

  @override
  String get sleepLateDesc => 'A menudo me acuesto tarde o me desvío los fines de semana.';

  @override
  String get sleepIrregularTitle => 'Irregular o turnos';

  @override
  String get sleepIrregularDesc => 'Mi sueño cambia mucho o trabajo en turnos rotativos.';

  @override
  String get smartPlanDashboardTitle => 'Tu estrategia actual';

  @override
  String get smartPlanProfileTitle => 'Tu estrategia de inicio';

  @override
  String get smartPlanCurrentPlanLabel => 'Plan actual';

  @override
  String get smartPlanRecommendedPlanLabel => 'Recomendación inteligente';

  @override
  String get smartPlanSignalsLabel => 'Señales';

  @override
  String get smartPlanTitle => 'Recomendación inteligente';

  @override
  String smartPlanBestMatch(String plan) {
    return 'Mejor plan inicial: $plan';
  }

  @override
  String get smartPlanHint => 'Puedes cambiar esto más tarde en la configuración.';

  @override
  String get smartPlanWhyRecovery => 'Una ventana más suave es mejor para la recuperación y la consistencia.';

  @override
  String get smartPlanWhyActive => 'Tu nivel de actividad favorece un plan que protege la energía y el entrenamiento.';

  @override
  String get smartPlanWhyBeginner => 'Tu objetivo y experiencia sugieren comenzar con un plan que puedas repetir.';

  @override
  String get smartPlanWhyBalanced => 'Esto te da mayores beneficios del ayuno sin volverse demasiado agresivo.';

  @override
  String get smartPlanWhyAggressive => 'Tu perfil actual puede manejar una ventana más ajustada si quieres un progreso rápido.';

  @override
  String get smartPlanWhySleep => 'Tu horario de sueño favorece un plan constante que añade menos estrés.';

  @override
  String get smartPlanWhySustainable => 'Un comienzo sostenible generalmente conduce a una mejor adherencia.';

  @override
  String smartPlanAlternativeEasier(String plan) {
    return '$plan es una opción más suave si deseas un ajuste más fácil.';
  }

  @override
  String smartPlanAlternativeStronger(String plan) {
    return '$plan es una opción más fuerte si deseas un corte más ambicioso.';
  }

  @override
  String smartPlanCoachGreeting(String plan, String goal, String experience, String sleep) {
    return 'Soy Fasty 🥑. Actualmente estás en $plan y concentrado en $goal. Con tu experiencia $experience y patrón de sueño $sleep, puedo ayudarte a ser constante.';
  }

  @override
  String get smartPlanUseRecommendation => 'Usar recomendación inteligente';

  @override
  String get labelAlternative => 'ALTERNATIVA';

  @override
  String perMonthEquivalent(String price, String period) {
    return '~$price/$period';
  }

  @override
  String get circadianProExclusive => 'EXCLUSIVO PRO';

  @override
  String get circadianStartFast => 'Iniciar Ayuno Circadiano';

  @override
  String get sunriseLabel => 'Amanecer';

  @override
  String get sunsetLabel => 'Atardecer';

  @override
  String get lastMeal => 'Última Comida';

  @override
  String get circadianTotalWindow => 'Ventana Total de Ayuno';

  @override
  String get hoursLabel => 'horas';

  @override
  String get basedOnLocalCoordinates => 'Basado en tus coordenadas locales';

  @override
  String get locationRequiredTitle => 'Ubicación Requerida';

  @override
  String get locationRequiredDesc => 'Necesitamos tu ubicación para calcular la hora exacta del atardecer en tu ciudad.';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get circadianStarted => '¡Ayuno Circadiano Iniciado! 🌅';

  @override
  String get planCircadianTitle => 'Ayuno Circadiano';

  @override
  String get planCircadianSubtitle => 'Alinea el ayuno con el sol';

  @override
  String get planCustomSubtitle => 'Configura tu propia ventana';

  @override
  String get planPresets => 'Ajustes';

  @override
  String durationHoursShort(int hours) {
    return '${hours}h';
  }

  @override
  String durationHoursMinutesShort(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get endFastCongrats => '¡Lo lograste! 🎉';

  @override
  String endFastTotalTime(String time) {
    return 'Tiempo total de ayuno: $time';
  }

  @override
  String get endFastHowFeel => '¿Cómo te sientes?';

  @override
  String get endFastSaveEat => 'Guardar y Comer';

  @override
  String get endFastKeepFasting => 'Cancelar, seguir ayunando';

  @override
  String get proAccessLabel => 'ACCESO PRO';

  @override
  String get timerEndTitle => '¿Cuándo rompiste tu ayuno?';

  @override
  String get timerCannotStartFuture => 'No puedes empezar un ayuno en el futuro.';

  @override
  String get timerCannotEndFuture => 'No puedes terminar un ayuno en el futuro.';

  @override
  String get timerEndBeforeStart => 'La hora de fin no puede ser anterior a la de inicio.';

  @override
  String get timerGoalReachedExtra => '🔥 Objetivo alcanzado (+ extra)';

  @override
  String get timerWindowExtended => 'Ventana extendida';

  @override
  String get timerRemainingInWindow => 'Restante en ventana';

  @override
  String get timerUnknownPlan => 'Plan Desconocido';

  @override
  String get timerLogMoodSymptoms => 'Registrar estado de ánimo';

  @override
  String get timerBreakAlreadyActive => 'Ya estás en un descanso. ¡Disfruta! ☕';

  @override
  String get timerRestDayStarted => 'Ventana cerrada. ¡Disfruta tu día de descanso! 🏖️';

  @override
  String get timerTakeBreak => 'Tomar un descanso';

  @override
  String get timerLogStartEarlier => 'Registrar inicio antes';

  @override
  String get timerLogEndEarlier => 'Registrar fin antes';

  @override
  String get timerLogFastStartEarlier => 'Registrar inicio antes';

  @override
  String get bodyMeasureChest => 'Pecho';

  @override
  String get bodyMeasureWaist => 'Cintura';

  @override
  String get bodyMeasureHips => 'Caderas';

  @override
  String get bodyMeasureChestTitle => 'Tamaño del Pecho (cm)';

  @override
  String get bodyMeasureWaistTitle => 'Tamaño de Cintura (cm)';

  @override
  String get bodyMeasureHipsTitle => 'Tamaño de Caderas (cm)';

  @override
  String get bodyMeasureAdd => 'Añadir';

  @override
  String get drinkWater => 'Agua';

  @override
  String get drinkBlackCoffee => 'Café Solo';

  @override
  String get drinkLatteSweetCoffee => 'Latte / Café Dulce';

  @override
  String get drinkGreenBlackTea => 'Té Verde / Negro';

  @override
  String get drinkDietSoda => 'Refresco Light';

  @override
  String get drinkSweetSoda => 'Refresco Dulce';

  @override
  String get drinkJuice => 'Zumo';

  @override
  String get drinkAlcohol => 'Alcohol';

  @override
  String waterDrinkContainsCalories(String drink) {
    return '¡$drink contiene calorías!';
  }

  @override
  String get waterBreakFastWarning => 'Beber esto romperá tu ayuno actual y comenzará tu ventana de alimentación. ¿Estás seguro?';

  @override
  String get waterConfirmDrinkBreakFast => 'Sí, lo bebí';

  @override
  String get waterDrinkPrompt => '¿Qué bebiste?';

  @override
  String waterFastStoppedByDrink(String drink) {
    return 'Temporizador de ayuno detenido porque bebiste $drink.';
  }

  @override
  String get waterUndoLastDrink => 'Deshacer última bebida';

  @override
  String get unitMl => 'ml';

  @override
  String get healthBadgeSync => 'Sincronizar';

  @override
  String get healthNoData => 'Sin Datos';

  @override
  String get healthSleepLabel => 'Sueño';

  @override
  String get healthCyclePhaseLabel => 'Fase del Ciclo';

  @override
  String get cyclePhaseMenstruation => 'Menstruación';

  @override
  String get cyclePhaseFollicular => 'Folicular';

  @override
  String get cyclePhaseOvulation => 'Ovulación';

  @override
  String get cyclePhaseLuteal => 'Lútea';

  @override
  String get learnQuickBites => 'Consejos Rápidos';

  @override
  String get storyFasting101 => 'Ayuno 101';

  @override
  String get storyAutophagy => 'Autofagia';

  @override
  String get storyKetoDiet => 'Dieta Keto';

  @override
  String get storyHydration => 'Hidratación';

  @override
  String get storySleep => 'Sueño';

  @override
  String storyOpening(String title) {
    return 'Abriendo historia: $title...';
  }

  @override
  String recipeSelected(String title) {
    return 'Seleccionado: $title';
  }

  @override
  String get aiUpdatingConfig => 'La IA está actualizando la configuración. Por favor, comprueba tu internet y reinicia la aplicación.';

  @override
  String get aiSessionExpired => 'La sesión con el coach ha expirado. Cierra y vuelve a abrir el chat para continuar.';

  @override
  String get aiEmptyResponse => 'Todavía estoy pensando. Por favor, inténtalo de nuevo.';

  @override
  String get authGoogleFailed => 'El inicio de sesión con Google falló. Por favor, inténtalo de nuevo.';

  @override
  String get authAppleUnavailable => 'El inicio de sesión con Apple solo está disponible en iOS.';

  @override
  String get authAppleFailed => 'El inicio de sesión con Apple falló. Por favor, inténtalo de nuevo.';

  @override
  String get journalSymptomsTitle => 'Síntomas y Estado';

  @override
  String get journalSymptomsPrefix => 'Síntomas';

  @override
  String get journalUpdated => '¡Diario actualizado! 📝';

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
  String get moodTerrible => 'Terrible';

  @override
  String get moodBad => 'Mal';

  @override
  String get moodOkay => 'Regular';

  @override
  String get moodGood => 'Bien';

  @override
  String get moodGreat => 'Genial';

  @override
  String get disclaimerCheckboxPrefix => 'Acepto el ';

  @override
  String get disclaimerCheckboxLink => 'Aviso Médico y Política de Privacidad';

  @override
  String get pdfReportTitle => 'Informe Médico';

  @override
  String get pdfReportSubtitle => 'Resumen de Ayuno Intermitente';

  @override
  String get pdfReportGenerating => 'Generando tu informe...';

  @override
  String get pdfReportGenerate => 'Generar Informe PDF';

  @override
  String get pdfReportShare => 'Compartir Informe';

  @override
  String get pdfReportPreview => 'Vista Previa';

  @override
  String get pdfReportPeriod => 'Período del Informe';

  @override
  String get pdfReportPeriod7 => 'Últimos 7 días';

  @override
  String get pdfReportPeriod30 => 'Últimos 30 días';

  @override
  String get pdfReportPeriodAll => 'Todo el tiempo';

  @override
  String get pdfReportProOnly => 'Los Informes PDF son una función PRO';

  @override
  String get pdfReportProDesc => 'Actualiza a PRO para generar y compartir tus informes personalizados.';

  @override
  String get pdfReportSectionProfile => 'Perfil Personal';

  @override
  String get pdfReportSectionStats => 'Estadísticas de Ayuno';

  @override
  String get pdfReportSectionHistory => 'Historial de Ayunos';

  @override
  String get pdfReportSectionDisclaimer => 'Aviso Médico';

  @override
  String get pdfReportLabelAge => 'Edad';

  @override
  String get pdfReportLabelGender => 'Género';

  @override
  String get pdfReportLabelWeight => 'Peso';

  @override
  String get pdfReportLabelHeight => 'Altura';

  @override
  String get pdfReportLabelBmi => 'IMC';

  @override
  String get pdfReportLabelTotalFasts => 'Ayunos Totales';

  @override
  String get pdfReportLabelTotalHours => 'Horas Totales';

  @override
  String get pdfReportLabelAvgDuration => 'Duración Promedio';

  @override
  String get pdfReportLabelLongest => 'Ayuno Más Largo';

  @override
  String get pdfReportLabelStreak => 'Mejor Racha';

  @override
  String get pdfReportLabelDate => 'Fecha';

  @override
  String get pdfReportLabelDuration => 'Duración';

  @override
  String get pdfReportLabelCompleted => 'Completado';

  @override
  String get pdfReportDisclaimerText => 'Este informe es generado por Fastable solo para fines de seguimiento personal. No constituye consejo médico.';

  @override
  String get pdfReportGeneratedBy => 'Generado por Fastable';

  @override
  String get pdfReportGenderMale => 'Hombre';

  @override
  String get pdfReportGenderFemale => 'Mujer';

  @override
  String get pdfReportNoData => 'No se encontraron registros en el período.';

  @override
  String pdfReportHours(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get bodyMetricsTitle => 'Métricas Corporales';

  @override
  String get bodyMetricsHint => 'Toca las tarjetas para actualizar';

  @override
  String get bodyMetricsAdd => 'Añadir';

  @override
  String get bodyMetricsTapToSet => 'Toca para ajustar';

  @override
  String get nextStageUpper => 'SIGUIENTE ETAPA';

  @override
  String get maxBenefitsReached => '¡Máximos Beneficios Alcanzados!';

  @override
  String get holdToComplete => 'MANTÉN PARA COMPLETAR';

  @override
  String get heroActiveSession => 'SESIÓN ACTIVA';

  @override
  String get heroEatingWindow => 'VENTANA DE ALIMENTACIÓN';

  @override
  String get heroNextFast => 'PRÓXIMO AYUNO';

  @override
  String get insightsAndTrends => 'ANÁLISIS Y TENDENCIAS';

  @override
  String get bmiLabel => 'IMC';

  @override
  String get liveTrackerChannelName => 'Temporizador de Ayuno';

  @override
  String get liveTrackerChannelDesc => 'Temporizador de ayuno en curso';

  @override
  String get liveTrackerSubtextFasting => '🔥 Etapa Fastable';

  @override
  String get liveTrackerSubtextEating => '🍽 Ventana Fastable';

  @override
  String get liveTrackerActionEndFast => '🏁 TERMINAR AYUNO';

  @override
  String get liveTrackerActionStopWindow => '🛑 DETENER VENTANA';

  @override
  String liveTrackerGoal(String time) {
    return 'Objetivo: $time';
  }

  @override
  String liveTrackerWindowEnds(String time) {
    return 'La ventana termina: $time';
  }

  @override
  String get liveTrackerTimeRemaining => 'Tiempo restante: ';

  @override
  String get elapsed => 'Transcurrido';

  @override
  String get status => 'Estado';

  @override
  String get complete => 'Completado';

  @override
  String get fastingStages => 'Etapas de Ayuno';

  @override
  String get statusNow => 'Ahora';

  @override
  String get statusNext => 'Siguiente';

  @override
  String get statusDone => 'Hecho';

  @override
  String get chartFastingVsWeight => 'Ayuno vs Peso';

  @override
  String get chartTrackMetabolic => 'Sigue tu correlación metabólica a lo largo del tiempo.';

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
    return 'Objetivo: $value';
  }

  @override
  String get chartHours => 'Horas';

  @override
  String get chartWeight => 'Peso';

  @override
  String get chartLegendFasting => 'Horas de Ayuno';

  @override
  String get chartLegendWeight => 'Tendencia de Peso';

  @override
  String get chartInsight1W => '¡Tus ventanas de ayuno son consistentes esta semana! Mantener un promedio de más de 16h se correlaciona con una quema de grasa más rápida.';

  @override
  String get chartInsight1M => 'Durante el último mes, notamos una caída constante en tu peso cuando completas ayunos después de las 18:00.';

  @override
  String get chartInsight3M => '¡Los datos a largo plazo muestran un progreso increíble! Tu cuerpo se está adaptando perfectamente al cambio metabólico.';

  @override
  String get statsUnlockChartTitle => 'Analítica Pro';

  @override
  String get statsUnlockChartDesc => 'Mira un anuncio en video corto para desbloquear tu gráfico de correlación.';

  @override
  String get statsBtnWatchAd => 'Ver Anuncio';

  @override
  String get adNotReady => 'El anuncio aún no está listo. Por favor, inténtalo de nuevo en unos segundos.';
}
