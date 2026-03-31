// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Fastable';

  @override
  String get dashboardToday => 'Сегодня';

  @override
  String get dashboardOverview => 'Обзор';

  @override
  String get navTimer => 'Таймер';

  @override
  String get navHistory => 'История';

  @override
  String get navStats => 'Статистика';

  @override
  String get navLearn => 'Обучение';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navAchievements => 'Достижения';

  @override
  String get navPro => 'Fastable PRO';

  @override
  String get fastingPhase => 'Фаза голодания';

  @override
  String get eatingWindow => 'Окно питания';

  @override
  String get readyToFast => 'Готов к голоданию';

  @override
  String get autophagyZone => 'Зона аутофагии';

  @override
  String get startFast => 'Начать голодание';

  @override
  String get endFast => 'Завершить голодание';

  @override
  String get endCycle => 'Завершить цикл';

  @override
  String get remaining => 'Осталось';

  @override
  String get targetGoal => 'Цель';

  @override
  String get waterTracker => 'Трекер воды';

  @override
  String get waterCups => 'стаканов';

  @override
  String get addWater => 'Добавить воду';

  @override
  String get waterToday => 'Вода за сегодня';

  @override
  String get waterIntake => 'Потребление воды';

  @override
  String get cups => 'стаканов';

  @override
  String get cupsUnit => 'стаканов';

  @override
  String get weightTracker => 'Трекер веса';

  @override
  String get logWeight => 'Записать вес';

  @override
  String get saveWeight => 'Сохранить вес';

  @override
  String get weightJourney => 'История веса';

  @override
  String get last7Days => 'Последние 7 дней';

  @override
  String get fastingHours => 'Часы голодания';

  @override
  String get currentWeight => 'Текущий';

  @override
  String get goalWeight => 'Цель';

  @override
  String get startWeight => 'Начальный';

  @override
  String get addWeight => 'Добавить вес';

  @override
  String get enterWeight => 'Введите вес';

  @override
  String get unitKg => 'кг';

  @override
  String get unitCm => 'см';

  @override
  String get weightProgress => 'Прогресс веса';

  @override
  String get chartEmpty => 'Добавьте хотя бы две записи веса, чтобы увидеть график.';

  @override
  String get proBannerTitle => 'Fastable PRO';

  @override
  String get proBannerDesc => 'Разблокировать аналитику';

  @override
  String get premiumContentTitle => 'Премиум контент';

  @override
  String get premiumContentDesc => 'Получите полный доступ ко всем статьям и функциям.';

  @override
  String get getPro => 'Получить доступ к PRO';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get proTitle => 'Получить доступ к PRO';

  @override
  String get proMonthly => 'Ежемесячная подписка';

  @override
  String get proAnnual => 'Годовая подписка (Скидка 40%)';

  @override
  String get unlockAll => 'Разблокировать PRO';

  @override
  String get accessStatus => 'Текущий доступ';

  @override
  String statusActive(Object date) {
    return 'Активен до $date';
  }

  @override
  String get statusFree => 'Бесплатный';

  @override
  String get proRequired => 'Для просмотра этого контента требуется подписка PRO';

  @override
  String get proComingSoon => 'PRO версия скоро появится! Следите за обновлениями.';

  @override
  String get year => 'год';

  @override
  String get month => 'мес.';

  @override
  String get discount => 'Скидка';

  @override
  String get historyTitle => 'История';

  @override
  String get historyCalendar => 'Календарь';

  @override
  String get historyLog => 'Журнал';

  @override
  String get historyEmpty => 'Пока нет завершенных голоданий. Ваша история появится здесь!';

  @override
  String get fastComplete => 'Голодание завершено!';

  @override
  String fastCompleteDesc(String time) {
    return 'Вы успешно голодали в течение $time. Сохранить эту запись?';
  }

  @override
  String get noFastsOnDay => 'В этот день нет завершенных голоданий.';

  @override
  String get detailsFor => 'Подробности за';

  @override
  String get endCyclePrompt => 'Завершить окно питания?';

  @override
  String get endCyclePromptDesc => 'Это завершит ваш текущий цикл и сбросит таймер.';

  @override
  String get endFastPrompt => 'Завершите текущий цикл, чтобы изменить план.';

  @override
  String get discard => 'Сбросить';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get next => 'Далее';

  @override
  String get finish => 'Завершить';

  @override
  String get attention => 'Внимание';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get settingLanguage => 'Язык';

  @override
  String get settingWaterGoal => 'Ежедневная норма воды';

  @override
  String get settingHeight => 'Рост';

  @override
  String get settingGoalWeight => 'Целевой вес';

  @override
  String get settingTheme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get themeSystem => 'Системная';

  @override
  String get settingsHealthConnect => 'Health Connect';

  @override
  String get settingsSyncWeight => 'Синхронизация веса и шагов';

  @override
  String get healthConnectSyncTitle => 'Синхронизация с Health Connect';

  @override
  String get healthConnectDisclosureIntro => 'Fastable запрашивает доступ на ЧТЕНИЕ и ЗАПИСЬ данных о ВЕСЕ через Health Connect.';

  @override
  String get healthConnectDisclosureRead => 'Мы используем доступ на ЧТЕНИЕ для отображения графика прогресса веса и статистики на основе исторических данных.';

  @override
  String get healthConnectDisclosureWrite => 'Мы используем доступ на ЗАПИСЬ, чтобы вы могли сохранять записи веса из Fastable в центральную базу данных вашего телефона.';

  @override
  String get healthConnectDisclosureSecure => 'Данные хранятся локально и используются только для отслеживания веса. Вы можете отозвать разрешения в любое время.';

  @override
  String get healthConnectConnected => 'Health Connect подключен!';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get notifyWater => 'Напоминания о воде';

  @override
  String get notifyWaterDesc => 'Получать напоминания попить воду';

  @override
  String get notifyWeight => 'Напоминание о весе';

  @override
  String get notifyWeightDesc => 'Ежедневное напоминание о взвешивании';

  @override
  String get notifyFastingStart => 'Начало голодания';

  @override
  String get notifyFastingStartDesc => 'Уведомлять о начале окна голодания';

  @override
  String get simplifiedAnimation => 'Упрощенная анимация';

  @override
  String get simplifiedAnimationDesc => 'Уменьшает размытие и эффекты для экономии заряда батареи и повышения производительности';

  @override
  String get settingPerformance => 'Производительность';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get errorOpenLink => 'Не удалось открыть ссылку';

  @override
  String get errorLoading => 'Ошибка загрузки данных';

  @override
  String get noArticlesFound => 'Статьи не найдены';

  @override
  String get tabFasting => 'Голодание';

  @override
  String get tabKeto => 'Кето';

  @override
  String get tabPartner => 'Партнер';

  @override
  String get guestUser => 'Гость';

  @override
  String get defaultUser => 'Пользователь';

  @override
  String get anonymousLogin => 'Анонимный вход';

  @override
  String get dataOnDevice => 'Данные сохранены на устройстве';

  @override
  String get connectGoogle => 'Подключить Google Аккаунт';

  @override
  String get saveProgressCloud => 'Сохранить прогресс в облаке';

  @override
  String get accountLinked => 'Аккаунт успешно привязан!';

  @override
  String get linkError => 'Ошибка привязки аккаунта';

  @override
  String get resetAndExit => 'Сбросить данные и выйти';

  @override
  String get deleteAndExit => 'Удалить и выйти';

  @override
  String get signOut => 'Выйти';

  @override
  String get confirmLogout => 'Вы уверены, что хотите выйти?';

  @override
  String get guestLogoutWarning => 'Вы используете гостевой аккаунт. Если вы выйдете, все локальные данные будут безвозвратно удалены.';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountWarning => 'Вы уверены? Это безвозвратно удалит все ваши данные.';

  @override
  String get authWelcome => 'Добро пожаловать в современное голодание';

  @override
  String get authSubtitle => 'Синхронизируйте свой прогресс и достигайте целей.';

  @override
  String get signInGoogle => 'Войти через Google';

  @override
  String get continueGuest => 'Продолжить как гость';

  @override
  String get signInFailed => 'Ошибка входа. Пожалуйста, попробуйте еще раз.';

  @override
  String get welcomeMessage => 'Добро пожаловать в ваше приложение для голодания!';

  @override
  String get choosePlan => 'Выберите план';

  @override
  String get fastingPlan16_8 => '16:8 Интервальное голодание';

  @override
  String get fastingPlan18_6 => '18:6 Интервальное голодание';

  @override
  String get fastingPlan20_4 => '20:4 Диета Воина';

  @override
  String get fastingPlanEatStopEat => 'Ешь-Стой-Ешь (24ч)';

  @override
  String get bmiCalculator => 'Калькулятор ИМТ';

  @override
  String get bmiCategory => 'Категория';

  @override
  String get bmiUnderweight => 'Недостаточный вес';

  @override
  String get bmiNormal => 'Норма';

  @override
  String get bmiOverweight => 'Избыточный вес';

  @override
  String get bmiObese => 'Ожирение';

  @override
  String get enterHeightCm => 'Введите рост (см)';

  @override
  String get enterGoalWeightKg => 'Введите целевой вес (кг)';

  @override
  String get fastingStats => 'Статистика голодания';

  @override
  String get fastingStatsCurrentStreak => 'Текущая серия';

  @override
  String get fastingStatsDay => 'День';

  @override
  String get fastingStatsDays => 'Дней';

  @override
  String get fastingStatsTotalFasts => 'Всего голоданий';

  @override
  String get fastingStatsTotalHours => 'Всего часов';

  @override
  String get fastingStatsAvgFast => 'Среднее голодание';

  @override
  String get fastingStatsHours => 'Часов';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать!';

  @override
  String get onboardingWelcomeDesc => 'Начните свой путь к здоровью. Давайте настроим ваш профиль.';

  @override
  String get onboardingGoalTitle => 'Каковы ваши цели?';

  @override
  String get onboardingGoalDesc => 'Укажите свой рост и целевой вес, чтобы мы могли рассчитать ваш ИМТ.';

  @override
  String get onboardingPlanTitle => 'Выберите ваш план';

  @override
  String get onboardingPlanDesc => 'С какого плана голодания вы хотели бы начать? Вы всегда сможете изменить его позже.';

  @override
  String get onboardingCurrentWeight => 'Ваш текущий вес';

  @override
  String get getStarted => 'Начать';

  @override
  String get currentStage => 'Текущая стадия';

  @override
  String get nextStage => 'Далее';

  @override
  String get stageAnabolicTitle => 'Анаболическая (Сытость)';

  @override
  String get stageAnabolicDesc => 'Ваше тело переваривает пищу и использует глюкозу для энергии. Активен рост клеток.';

  @override
  String get stageCatabolicTitle => 'Катаболическая';

  @override
  String get stageCatabolicDesc => 'Уровень сахара в крови падает. Ваше тело начинает использовать накопленный гликоген из печени.';

  @override
  String get stageKetosisTitle => 'Кетоз';

  @override
  String get stageKetosisDesc => 'Запасы гликогена истощены. Ваше тело переключается на сжигание жира как основного топлива.';

  @override
  String get stageAutophagyTitle => 'Аутофагия';

  @override
  String get stageAutophagyDesc => 'Начинается процесс клеточной очистки. Ваше тело перерабатывает старые и поврежденные компоненты клеток.';

  @override
  String get stagePeakAutophagyTitle => 'Пик аутофагии';

  @override
  String get stagePeakAutophagyDesc => 'Процесс аутофагии достигает своего пика, максимизируя клеточное обновление.';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String get achievementsUnlocked => 'Разблокировано';

  @override
  String get achievementsLocked => 'Заблокировано';

  @override
  String achEarnedOn(Object date) {
    return 'Получено $date';
  }

  @override
  String get achFirstFastTitle => 'Первое голодание!';

  @override
  String get achFirstFastDesc => 'Завершите свое первое голодание.';

  @override
  String get achStreak3Title => 'Хорошее начало';

  @override
  String get achStreak3Desc => 'Поддерживайте серию из 3 дней.';

  @override
  String get achStreak7Title => 'Стабильность';

  @override
  String get achStreak7Desc => 'Поддерживайте серию из 7 дней.';

  @override
  String get achTotal10Title => 'Новичок';

  @override
  String get achTotal10Desc => 'Завершите 10 голоданий.';

  @override
  String get achTotalHours100Title => 'Клуб 100 часов';

  @override
  String get achTotalHours100Desc => 'Голодайте в общей сложности 100 часов.';

  @override
  String get journalTitle => 'Заметка в журнале';

  @override
  String get journalHint => 'Как вы себя чувствовали во время этого голодания?';

  @override
  String get addNote => 'Добавить заметку';

  @override
  String get editNote => 'Изменить заметку';

  @override
  String get noteSaved => 'Заметка сохранена';

  @override
  String get syncHealthTitle => 'Синхронизация с Health / Здоровье';

  @override
  String get syncHealthDesc => 'Автоматически записывать данные о голодании и читать вес.';

  @override
  String get shareProgress => 'Поделиться прогрессом';

  @override
  String get metricPhase => 'Фаза';

  @override
  String get metricStreak => 'Серия';

  @override
  String get metricStatus => 'Статус';

  @override
  String get statusDigesting => 'Пищеварение';

  @override
  String get statusStable => 'Стабильность';

  @override
  String get statusFatBurn => 'Сжигание жира';

  @override
  String get statusKetosis => 'Кетоз';

  @override
  String get statusNormal => 'Норма';

  @override
  String get titleCurrentPhase => 'Текущая фаза';

  @override
  String get valFastingZone => 'Зона голодания';

  @override
  String get valEatingWindow => 'Окно питания';

  @override
  String get descFastingZone => 'Сейчас вы находитесь в окне голодания. Не следует потреблять калории.';

  @override
  String get descEatingWindow => 'Вы находитесь в окне питания. Сосредоточьтесь на продуктах, богатых питательными веществами.';

  @override
  String get titleConsistencyStreak => 'Серия стабильности';

  @override
  String valStreakDays(int days) {
    return '$days Дней 🔥';
  }

  @override
  String descStreak(int days) {
    return 'Вы достигаете своей цели по голоданию уже $days дней подряд. Продолжайте в том же духе, чтобы выработать привычку!';
  }

  @override
  String get titleBodyStatus => 'Статус тела';

  @override
  String get descDigesting => 'В настоящее время ваше тело переваривает пищу и пополняет запасы гликогена. Уровень инсулина повышается.';

  @override
  String get descStable => 'Уровень сахара в вашей крови нормализуется. Организм готовится переключиться с глюкозы на жир в качестве топлива.';

  @override
  String get descFatBurn => 'Отличная работа! Ваше тело начинает сжигать накопленный жир для получения энергии. Уровень гормона роста может начать расти.';

  @override
  String get descKetosis => 'Глубокий кетоз! Ваше тело эффективно сжигает жир. Аутофагия (очистка клеток) может начаться в ближайшее время.';

  @override
  String get btnGotIt => 'Понятно!';

  @override
  String get stage0_4 => 'Сахар в крови растет';

  @override
  String get stage0_4_desc => 'Ваше тело переваривает последний прием пищи. Уровень сахара в крови и инсулина повышается.';

  @override
  String get stage4_8 => 'Сахар в крови падает';

  @override
  String get stage4_8_desc => 'Уровень инсулина начинает падать. Ваше тело начинает использовать накопленную глюкозу.';

  @override
  String get stage8_12 => 'Нормализация';

  @override
  String get stage8_12_desc => 'Пищеварительная система отдыхает. Ваше тело начинает лечить и очищать себя.';

  @override
  String get stage12_16 => 'Сжигание жира';

  @override
  String get stage12_16_desc => 'Инсулин низкий. Ваше тело начинает сжигать накопленный жир для получения энергии.';

  @override
  String get stage16_18 => 'Кетоз';

  @override
  String get stage16_18_desc => 'Сжигание жира ускоряется. Вы находитесь в режиме полного сжигания жира.';

  @override
  String get stage18_24 => 'Аутофагия';

  @override
  String get stage18_24_desc => 'Начинается клеточная очистка. Ваше тело перерабатывает старые и поврежденные клетки.';

  @override
  String get stage24_plus => 'Глубокое восстановление';

  @override
  String get stage24_plus_desc => 'Уровень гормона роста повышается. Происходит значительная клеточная регенерация.';

  @override
  String get viewTimeline => 'График процессов в теле';

  @override
  String get navFood => 'Питание';

  @override
  String get circadianEnabled => 'Циркадный режим включен';

  @override
  String get circadianDisabled => 'Циркадный режим выключен';

  @override
  String get tabRecipes => 'Рецепты';

  @override
  String get tabKnowledge => 'Знания';

  @override
  String get categoryAll => 'Все';

  @override
  String get categoryKeto => 'Кето';

  @override
  String get categoryFitness => 'Фитнес';

  @override
  String get categoryVegan => 'Веган';

  @override
  String recipeTime(int minutes) {
    return '$minutes мин';
  }

  @override
  String get waterSettings => 'Настройки воды';

  @override
  String get removeCup => 'Удалить стакан (-1)';

  @override
  String get dailyGoal => 'Ежедневная цель';

  @override
  String get bmiScore => 'Значение ИМТ';

  @override
  String bmiDescription(int height, String weight) {
    return 'На основе вашего роста ($height см) и веса ($weight кг).';
  }

  @override
  String get onboardingTitle => 'Персонализируйте свой план';

  @override
  String get onboardingHeightTitle => 'Какой у вас рост?';

  @override
  String get onboardingHeightDesc => 'Нам это нужно, чтобы откалибровать визуализатор тела и точно рассчитать ваши показатели здоровья.';

  @override
  String get onboardingWeightTitle => 'Какой у вас вес?';

  @override
  String get onboardingWeightDesc => 'Это поможет нам отслеживать ваш прогресс и динамически корректировать план голодания.';

  @override
  String get btnNext => 'Далее';

  @override
  String get btnFinish => 'Начать путешествие';

  @override
  String get cm => 'см';

  @override
  String get kg => 'кг';

  @override
  String get statsSuccessRate => 'Успешность';

  @override
  String statsSuccessDesc(int success, int total) {
    return '$success из $total голоданий были 16ч+';
  }

  @override
  String get statsTotalFasts => 'Всего голоданий';

  @override
  String get statsTotalHours => 'Всего часов';

  @override
  String get statsAverage => 'В среднем';

  @override
  String get statsLongest => 'Самое долгое';

  @override
  String get circadianTitle => 'Циркадный ритм';

  @override
  String get circadianIntroTitle => 'Питайтесь вместе с Солнцем ☀️';

  @override
  String get circadianIntroDesc => 'Ваш метаболизм связан с солнцем.\n\n• Рассвет: Лучшее время для пробуждения и питья.\n• День: Высокий метаболизм. Идеально для еды.\n• Закат: Метаболизм замедляется. Перестаньте есть.\n• Ночь: Режим глубокого восстановления. Голодание дается легко.\n\nЭтот режим автоматически настраивает ваши цели по голоданию на время восхода и заката солнца в вашем регионе.';

  @override
  String get circadianBtnEnable => 'Включить циркадный режим';

  @override
  String get circadianBtnDisable => 'Отключить';

  @override
  String get circadianTargetSunrise => 'До рассвета';

  @override
  String get circadianTargetSunset => 'До заката';

  @override
  String get circadianPhaseDay => 'Дневное время (Еда)';

  @override
  String get circadianPhaseNight => 'Ночное время (Голод)';

  @override
  String get circadianWarnDayTitle => 'Сейчас день ☀️';

  @override
  String get circadianWarnDayDesc => 'Солнце взошло! Ваше тело готово к еде. В идеале подождите до заката, чтобы начать голодать.';

  @override
  String get circadianWarnBtnStart => 'Все равно начать';

  @override
  String get circadianWarnBtnWait => 'Подождать заката';

  @override
  String get circadianBonusTime => 'Бонусное время 🔥';

  @override
  String get circadianSyncing => 'Синхронизация с солнцем...';

  @override
  String get circadianError => 'Не удалось получить местоположение. Используется стандартный таймер.';

  @override
  String get circadianManaged => 'Солнечное управление';

  @override
  String get notifBio4hTitle => 'Сахар в крови стабилизирован 🩸';

  @override
  String get notifBio4hBody => 'Уровень инсулина падает. Ложные приступы голода могут исчезнуть.';

  @override
  String get notifBio8hTitle => 'Желудок пуст ✅';

  @override
  String get notifBio8hBody => 'Пищеварение завершено. Ваше тело переходит в режим восстановления.';

  @override
  String get notifBio12hTitle => 'Входим в Кетоз 🔥';

  @override
  String get notifBio12hBody => 'Ваше тело начало сжигать накопленный жир для получения энергии!';

  @override
  String get notifBio16hTitle => 'Пик сжигания жира ⚡️';

  @override
  String get notifBio16hBody => 'Метаболизм ускорен. Вы в зоне интенсивного сжигания.';

  @override
  String get notifBio18hTitle => 'Аутофагия запущена ♻️';

  @override
  String get notifBio18hBody => 'Клеточная очистка активна. Тело перерабатывает старые клетки.';

  @override
  String get notifBio24hTitle => 'Скачок Гормона Роста 🛡';

  @override
  String get notifBio24hBody => 'Уровень гормона роста повысился, чтобы защитить ваши мышцы.';

  @override
  String get notifProg50Title => 'Половина пути пройдена! 🚀';

  @override
  String get notifProg50Body => 'Вы прошли 50% своей цели. Продолжайте в том же духе!';

  @override
  String get notifProg1hTitle => 'Остался 1 час ⏳';

  @override
  String get notifProg1hBody => 'Почти готово! Вы можете начать готовить еду.';

  @override
  String get notifProgFinishTitle => 'Цель достигнута! 🏆';

  @override
  String get notifProgFinishBody => 'Вы сделали это! Не забудьте остановить таймер.';

  @override
  String get notifWaterTitle => 'Попейте воды 💧';

  @override
  String get notifWaterBody => 'Гидратация ускоряет ваш метаболизм и уменьшает голод.';

  @override
  String get notifWeightTitle => 'Утреннее взвешивание ⚖️';

  @override
  String get notifWeightBody => 'Утро - лучшее время для отслеживания веса.';

  @override
  String get permTitle => 'Включите разрешения';

  @override
  String get permDesc => 'Чтобы предоставить вам лучший опыт, Fastable нужен доступ к уведомлениям и данным о здоровье.';

  @override
  String get permNotifTitle => 'Уведомления';

  @override
  String get permNotifDesc => 'Оставайтесь на пути с оповещениями о голодании.';

  @override
  String get permHealthTitle => 'Apple Health';

  @override
  String get permHealthDesc => 'Синхронизация данных о весе и воде.';

  @override
  String get permAllow => 'Разрешить';

  @override
  String get permContinue => 'Продолжить';

  @override
  String get achFirstFast => 'Первый шаг';

  @override
  String get achStreak3 => 'Стабильность';

  @override
  String get achStreak7 => 'Неудержимый';

  @override
  String get achTotal10 => 'Dedicated';

  @override
  String get achTotalHours100 => 'Centurion';

  @override
  String get onboardingDesc => 'Давайте рассчитаем ваш уровень метаболизма.';

  @override
  String get btnContinue => 'Продолжить';

  @override
  String get btnStart => 'Start Journey';

  @override
  String get selectGender => 'Пол';

  @override
  String get selectAge => 'Возраст';

  @override
  String get selectWeight => 'Вес';

  @override
  String get selectHeight => 'Рост';

  @override
  String get selectActivity => 'Уровень активности';

  @override
  String get genderMale => 'Мужской';

  @override
  String get genderFemale => 'Женский';

  @override
  String get activitySedentary => 'Малоподвижный';

  @override
  String get activityModerate => 'Умеренный';

  @override
  String get activityActive => 'Очень активный';

  @override
  String get contactSupport => 'Связаться с поддержкой';

  @override
  String get metabolicProfile => 'Метаболический профиль';

  @override
  String ageYears(int age) {
    return '$age лет';
  }

  @override
  String get metricBmrTitle => 'BMR';

  @override
  String get metricBmrSubtitle => 'Базовый';

  @override
  String get metricBmrDesc => 'Базовый уровень метаболизма. Калории, сжигаемые в состоянии полного покоя.';

  @override
  String get metricTdeeTitle => 'TDEE';

  @override
  String get metricTdeeSubtitle => 'Поддержание';

  @override
  String get metricTdeeDesc => 'Общий ежедневный расход энергии. Калории, необходимые для поддержания текущего веса.';

  @override
  String get dialogStartTitle => 'Когда началось ваше голодание?';

  @override
  String get btnStartFasting => 'Начать голодание';

  @override
  String get btnCancel => 'Отмена';

  @override
  String get stage2Title => 'Уровень сахара падает 📉';

  @override
  String get stage2Body => 'Ваше тело успокаивается. Если вы чувствуете голод, выпейте воды. 💧';

  @override
  String get stage4Title => 'Уровень инсулина падает ⬇️';

  @override
  String get stage4Body => 'Отлично! Ваше тело перестает накапливать жир и начинает готовиться к его сжиганию.';

  @override
  String get stage8Title => 'Началась очистка ✨';

  @override
  String get stage8Body => 'Прошло 8 часов. Ваш желудок отдыхает. Вы делаете большое дело для своего здоровья!';

  @override
  String get stage11Title => 'Режим сжигания жира 🔥';

  @override
  String get stage11Body => 'Начинается самое интересное! Ваше тело переключается на внутренние резервы.';

  @override
  String get stage12Title => 'Кетоз активирован 🚀';

  @override
  String get stage12Body => 'Жировые клетки превращаются в энергию. Ваш разум теперь яснее.';

  @override
  String get stage14Title => 'Глубокий кетоз 🔥';

  @override
  String get stage14Body => 'Вы находитесь в зоне сжигания жира! Детоксикация теперь идет быстро.';

  @override
  String get stage16Title => 'Аутофагия (Ремонт клеток) 🧬';

  @override
  String get stage16Body => 'Ваши клетки обновляются. Это источник молодости!';

  @override
  String get stage18Title => 'Пик гормона роста 📈';

  @override
  String get stage18Body => 'Гормон роста помогает мышцам и сжигает жир. Вы становитесь сильнее!';

  @override
  String get stage24Title => '24 часа! 🏆';

  @override
  String get stage24Body => 'Невероятно! Полный день завершен. Глубокая очистка в самом разгаре.';

  @override
  String get notifyHalfwayTitle => 'Половина пути! ⛰️';

  @override
  String get notifyHalfwayBody => 'Самая трудная часть позади. Ваше тело благодарит вас.';

  @override
  String get notify1hTitle => 'Home Stretch! 🏁';

  @override
  String get notify1hBody => 'Only 1 hour left. You are doing amazing!';

  @override
  String get notifyGoalTitle => 'Goal Reached! 🎉';

  @override
  String get notifyGoalBody => 'Congratulations! Break your fast gently.';

  @override
  String get notifyEatCloseTitle => 'Окно питания закрывается 🛑';

  @override
  String get notifyEatCloseBody => 'Время начать следующее голодание. Проверьте приложение!';

  @override
  String get notifyEat30mTitle => 'Осталось 30 минут 🥗';

  @override
  String get notifyEat30mBody => 'Не забудьте попить воды или съесть последний перекус.';

  @override
  String get learnTitle => 'Обучение и питание';

  @override
  String get tabArticles => 'Статьи';

  @override
  String get catBasics => 'Основы';

  @override
  String get catNutrition => 'Питание';

  @override
  String get catHealth => 'Здоровье';

  @override
  String get catKeto => 'Кето';

  @override
  String get headerLatestArticles => 'Последние статьи';

  @override
  String get headerHealthyChoices => 'Здоровый выбор';

  @override
  String get statusNoArticles => 'Статьи не найдены';

  @override
  String get msgComingSoon => 'Эта функция скоро появится!';

  @override
  String get learnBannerTitle => 'Откройте 500+ рецептов';

  @override
  String get learnBannerSubtitle => 'Получите полный доступ с PRO';

  @override
  String get labelPremium => 'ПРЕМИУМ';

  @override
  String get bannerRecipeTitle => 'Здоровые рецепты';

  @override
  String get bannerRecipeSubtitle => 'Keto, Low-Carb & More';

  @override
  String get unitKcal => 'ккал';

  @override
  String get unitMin => 'мин';

  @override
  String get lblAchievements => 'Достижения';

  @override
  String get lblPersonalData => 'Личные данные';

  @override
  String get lblSettings => 'Настройки';

  @override
  String get lblAbout => 'О приложении';

  @override
  String get lblHeight => 'Рост';

  @override
  String get lblWeight => 'Вес';

  @override
  String get lblAge => 'Возраст';

  @override
  String get lblGender => 'Пол';

  @override
  String get lblActivity => 'Уровень активности';

  @override
  String get lblLanguage => 'Язык';

  @override
  String get msgHealthSyncEnabled => 'Синхронизация со Здоровьем включена!';

  @override
  String get msgHealthSyncFailed => 'В доступе отказано';

  @override
  String get aiGreeting => 'Привет! Я Fasty 🥑. Как я могу помочь вам достичь ваших целей сегодня?';

  @override
  String get aiConnectionError => 'Упс! Соединение прервано. Пожалуйста, проверьте интернет или повторите попытку позже. 🥑';

  @override
  String get aiSystemError => 'Служба ИИ не настроена (отсутствует API ключ).';

  @override
  String get aiCoachTitle => 'AI Тренер по Голоданию';

  @override
  String get aiCoachDesc => 'Получайте мгновенные ответы о кето, интервальном голодании и здоровых привычках от нашего умного ИИ-ассистента.';

  @override
  String get aiChatHint => 'Спросите о кето или голодании...';

  @override
  String get btnUnlockPro => 'Разблокировать с PRO';

  @override
  String get aiInsightFallback => 'Постоянство - это ключ! Пейте воду и продолжайте двигаться. 💧';

  @override
  String get aiErrorConnection => 'Проблема с соединением. Пожалуйста, попробуйте позже.';

  @override
  String get aiInsightTitle => 'ЕЖЕДНЕВНЫЙ ИНСАЙТ';

  @override
  String get aiInsightTeaser => 'На основе ваших последних 7 дней голодания мы обнаружили важную закономерность, влияющую на ваш прогресс...';

  @override
  String get tapToUnlock => 'Нажмите, чтобы разблокировать';

  @override
  String get notifyAiInsightTitle => 'Ваш ежедневный ИИ инсайт готов! 🥑';

  @override
  String get notifyAiInsightBody => 'Узнайте, что Fasty проанализировал для вас сегодня. Нажмите, чтобы разблокировать.';

  @override
  String get notifyWeightTitle => 'Track your weight ⚖️';

  @override
  String get notifyWeightBody => 'Consistency is key! Log your weight today.';

  @override
  String get aiInsightNotEnoughData => 'Продолжайте отслеживать! Нам нужно хотя бы 3 голодания, чтобы проанализировать ваши уникальные шаблоны. 📊';

  @override
  String msgLoginFailed(Object error) {
    return 'Ошибка входа: $error';
  }

  @override
  String msgAppleLoginFailed(Object error) {
    return 'Ошибка входа через Apple: $error';
  }

  @override
  String get msgSyncCompleted => 'Синхронизация завершена!';

  @override
  String get msgErrorRelogin => 'Ошибка: Пожалуйста, войдите снова и повторите попытку.';

  @override
  String get signInApple => 'Войти через Apple';

  @override
  String get lblDangerZone => 'ОПАСНАЯ ЗОНА';

  @override
  String get btnDeleteAccount => 'Удалить аккаунт';

  @override
  String get dialogDeleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get dialogDeleteAccountContent => 'Это действие необратимо. Вся ваша история веса, записи о голоданиях и достижения будут удалены из облака.';

  @override
  String get btnDelete => 'УДАЛИТЬ';

  @override
  String get dialogSyncConflictTitle => 'Конфликт синхронизации';

  @override
  String get dialogSyncConflictContent => 'В этом аккаунте уже есть данные в облаке.\n\nЧто бы вы хотели сделать с текущими гостевыми данными?';

  @override
  String get btnUseCloud => 'Использовать облако\n(Удалить гостевые)';

  @override
  String get btnMergeData => 'Объединить данные';

  @override
  String lblVersion(Object version) {
    return 'Версия $version';
  }

  @override
  String get lblCurrentWeight => 'Текущий вес';

  @override
  String get lblBasalBmr => 'Базовый (BMR)';

  @override
  String get lblActiveTdee => 'Активный (TDEE)';

  @override
  String get lblTotalHours => 'Всего часов';

  @override
  String get unitHoursShort => 'ч';

  @override
  String get lblConsistency => 'Стабильность';

  @override
  String get lblLast7Days => 'Последние 7 дней';

  @override
  String get lblFasts => 'Голодания';

  @override
  String get lblHours => 'Часы';

  @override
  String get lblDayStreak => 'Серия дней';

  @override
  String get msgStartJourney => 'Начните ваше путешествие сегодня';

  @override
  String get lblToday => 'Сегодня';

  @override
  String get lblYesterday => 'Вчера';

  @override
  String get confirmTime => 'Подтвердить время';

  @override
  String get lblFastingTypeCircadian => 'Циркадное';

  @override
  String get lblFastingTypeWarrior => 'Воин';

  @override
  String get lblFastingTypeOmad => 'OMAD';

  @override
  String lblHistoryFor(Object date) {
    return 'История за $date';
  }

  @override
  String get lblNoRecordsForDay => 'Нет записей за этот день';

  @override
  String get lblCustomPlan => 'Свой план';

  @override
  String get lblAdjustDuration => 'Настроить длительность';

  @override
  String get lblFasting => 'Голодание';

  @override
  String get lblEating => 'Питание';

  @override
  String get lblSlideToAdjust => 'Проведите, чтобы настроить часы';

  @override
  String get btnStartCustomPlan => 'Начать свой план';

  @override
  String get btnUnlockFeature => 'Разблокировать свой план';

  @override
  String get proFeatureTitle => 'Функция Pro';

  @override
  String get proFeatureDesc => 'Пользовательские расписания голодания доступны для пользователей Pro.';

  @override
  String get setFastingGoal => 'Установить цель голодания';

  @override
  String get fastingSaved => 'Голодание сохранено! 🏆';

  @override
  String get whenStopEating => 'Когда вы закончили есть?';

  @override
  String get editTime => 'Изменить время';

  @override
  String get customPlan => 'Custom';

  @override
  String get tapToEdit => 'Нажмите, чтобы задать цель';

  @override
  String get timeLeft => 'ОСТАЛОСЬ';

  @override
  String get maxBenefits => 'Достигнут максимум пользы';

  @override
  String get appNameUpper => 'FASTABLE';

  @override
  String get splashSlogan => 'Раскройте потенциал вашего тела';

  @override
  String get weightSaved => 'Вес сохранен';

  @override
  String get proSubtitle => 'Раскройте свой полный потенциал';

  @override
  String get featureCoach => 'Личный ИИ Тренер';

  @override
  String get featureCoachDesc => 'Задавайте вопросы, получайте советы 24/7';

  @override
  String get featureRecipes => 'Здоровые рецепты';

  @override
  String get featureRecipesDesc => 'Кето, низкоуглеводные и др.';

  @override
  String get featureNoAds => 'Без рекламы, только фокус';

  @override
  String get featureNoAdsDesc => 'Опыт без отвлекающих факторов';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get loadingOffers => 'Загрузка предложений...';

  @override
  String get welcomePro => 'Добро пожаловать в Pro! 🌟';

  @override
  String get errorPro => 'Purchase failed. Please try again.';

  @override
  String get confirmDeleteMsg => 'This action cannot be undone. All your data will be lost.';

  @override
  String get statusLocked => 'Заблокировано';

  @override
  String get sectionLegal => 'Правовая информация и поддержка';

  @override
  String get btnOverwriteLocal => 'Перезаписать локальные';

  @override
  String get msgDeleteError => 'Ошибка удаления аккаунта';

  @override
  String get msgDeleteReauthCancelled => 'Удаление аккаунта отменено.';

  @override
  String get msgDeleteReauthFailed => 'Мы не смогли подтвердить вашу личность. Пожалуйста, попробуйте еще раз.';

  @override
  String get msgDeleteReauthUnavailable => 'Пожалуйста, войдите снова с помощью исходного провайдера, прежде чем удалять этот аккаунт.';

  @override
  String get stepLanguage => 'Выберите язык';

  @override
  String get stepBodyMetrics => 'Параметры тела';

  @override
  String get stepBodyMetricsDesc => 'Помогите нам рассчитать ваш ИМТ и цели';

  @override
  String get activityHint => 'Используется для расчета ваших ежедневных затрат энергии.';

  @override
  String get activitySedentaryDesc => 'Офисная работа, мало упражнений';

  @override
  String get activityModerateDesc => 'Активная работа или тренировки 3-4 раза';

  @override
  String get activityActiveDesc => 'Физическая работа или ежедневные тренировки';

  @override
  String get stepGoal => 'Выберите вашу цель';

  @override
  String get recommendationMsg => 'Мы рекомендуем вам план 16-8.';

  @override
  String get planBeginner => 'Новичок';

  @override
  String get planPopular => 'Популярный (16:8)';

  @override
  String get planAdvanced => 'Продвинутый (18:6)';

  @override
  String get planExpert => 'Эксперт (OMAD)';

  @override
  String get labelRecommended => 'РЕКОМЕНДУЕТСЯ';

  @override
  String get permHealthConnect => 'Health Connect';

  @override
  String get permHealthConnectDesc => 'Синхронизация веса и шагов с Google Fit';

  @override
  String get planMonthly => 'Ежемесячно';

  @override
  String get planAnnual => 'Ежегодно';

  @override
  String get planLifetime => 'Навсегда';

  @override
  String savePercent(String percent) {
    return 'СКИДКА $percent%';
  }

  @override
  String get medicalDisclaimerTitle => 'Медицинский отказ от ответственности';

  @override
  String get medicalDisclaimerHeading => 'Медицинский отказ от ответственности';

  @override
  String get medicalDisclaimerBody => 'Fastable разработан, чтобы помочь вам отслеживать интервальное голодание и предоставлять AI-коучинг на основе общих знаний. Это НЕ медицинское устройство. Предоставленная информация предназначена только для образовательных целей и не должна заменять профессиональную медицинскую консультацию.\n\nПожалуйста, проконсультируйтесь с врачом перед началом любого режима голодания, особенно если вы беременны, кормите грудью, страдаете диабетом или имеете какие-либо другие медицинские противопоказания.';

  @override
  String get scientificSourcesHeading => 'Научные источники и цитаты';

  @override
  String get sourceJohnsHopkins => 'Медицина Джонса Хопкинса';

  @override
  String get sourceJohnsHopkinsDesc => 'Интервальное голодание: что это такое и как оно работает?';

  @override
  String get sourceMayoClinic => 'Клиника Майо';

  @override
  String get sourceMayoClinicDesc => 'Диета голодания: Может ли это улучшить здоровье моего сердца?';

  @override
  String get sourceHarvard => 'Гарвардская медицинская школа';

  @override
  String get sourceHarvardDesc => 'Интервальное голодание: Удивительное обновление';

  @override
  String get legalAgreementPrefix => 'Продолжая, вы соглашаетесь со стандартными ';

  @override
  String get legalTermsOfUse => 'Условиями использования (EULA)';

  @override
  String get legalAgreementAnd => ' Apple и нашей ';

  @override
  String get legalPrivacyPolicy => 'Политикой конфиденциальности';

  @override
  String get comingSoonTitle => 'Скоро!';

  @override
  String get comingSoonDesc => 'Мы усердно работаем над созданием потрясающего контента для вас. Оставайтесь с нами!';

  @override
  String get statusNoRecipes => 'Рецепты не найдены';

  @override
  String get aboutAndLegal => 'О приложении и правовая информация';

  @override
  String get settingsMedicalDisclaimer => 'Медицинский отказ от ответственности и источники';

  @override
  String get settingsTermsOfUse => 'Условия использования (EULA)';

  @override
  String get deleteAccountAndData => 'Удалить аккаунт и данные';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountContent => 'Это действие необратимо. Вся ваша история голоданий и локальные данные будут удалены навсегда.';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get planExtended => 'Расширенный';

  @override
  String get zoneSugarRises => 'Уровень сахара растет';

  @override
  String get zoneSugarRisesDesc => 'Ваше тело перерабатывает последний прием пищи и накапливает энергию.';

  @override
  String get zoneSugarDrops => 'Уровень сахара падает';

  @override
  String get zoneSugarDropsDesc => 'Пищеварение заканчивается. Уровень сахара в крови возвращается к норме.';

  @override
  String get zoneFatBurning => 'Сжигание жира';

  @override
  String get zoneFatBurningDesc => 'Ваше тело начинает сжигать накопленный жир для получения энергии.';

  @override
  String get zoneKetosis => 'Кетоз';

  @override
  String get zoneKetosisDesc => 'Сжигание жира ускоряется. Ясность ума повышается.';

  @override
  String get zoneAutophagy => 'Аутофагия';

  @override
  String get zoneAutophagyDesc => 'Начинается восстановление и переработка клеток. Антивозрастной эффект.';

  @override
  String get zoneGrowthHormone => 'Гормон роста';

  @override
  String get zoneGrowthHormoneDesc => 'Пик сжигания жира, восстановление тканей и сохранение мышц.';

  @override
  String continueForPrice(String price) {
    return 'Продолжить за $price';
  }

  @override
  String get offersUnavailable => 'Предложения временно недоступны';

  @override
  String get billedMonthly => 'Оплата ежемесячно';

  @override
  String get billedAnnually => 'Оплата ежегодно';

  @override
  String get oneTimePurchase => 'Единоразовая покупка';

  @override
  String get goalPriorityTitle => 'Что важнее всего прямо сейчас?';

  @override
  String get goalPriorityDesc => 'Мы используем это, чтобы сбалансировать скорость, восстановление и долгосрочную стабильность.';

  @override
  String get goalFatLossTitle => 'Быстрее сбросить жир';

  @override
  String get goalFatLossDesc => 'Отдайте предпочтение более сильным окнам голодания, если ваш профиль может с ними справиться.';

  @override
  String get goalHealthTitle => 'Улучшить здоровье и энергию';

  @override
  String get goalHealthDesc => 'Стремитесь к сбалансированному плану, который поддерживает концентрацию, энергию и соблюдение режима.';

  @override
  String get goalHabitTitle => 'Выработать устойчивую привычку';

  @override
  String get goalHabitDesc => 'Начните с простого, чтобы режим действительно закрепился.';

  @override
  String get routineTitle => 'Расскажите нам о вашем распорядке';

  @override
  String get routineDesc => 'Сон и опыт голодания меняют то, насколько агрессивным должен быть ваш начальный план.';

  @override
  String get fastingExperienceTitle => 'Опыт голодания';

  @override
  String get experienceBeginnerTitle => 'Новичок';

  @override
  String get experienceBeginnerDesc => 'Я новичок в голодании или обычно рано сдаюсь.';

  @override
  String get experienceIntermediateTitle => 'Некоторый опыт';

  @override
  String get experienceIntermediateDesc => 'Я могу выдержать 14-16 часов голодания без особых проблем.';

  @override
  String get experienceAdvancedTitle => 'Продвинутый';

  @override
  String get experienceAdvancedDesc => 'Я проводил более длительные голодания и хочу более сильный протокол.';

  @override
  String get sleepPatternTitle => 'График сна';

  @override
  String get sleepRegularTitle => 'Регулярный сон';

  @override
  String get sleepRegularDesc => 'Мое время сна и пробуждения в основном стабильно.';

  @override
  String get sleepLateTitle => 'Поздние ночи';

  @override
  String get sleepLateDesc => 'Я часто ложусь поздно или сбиваю режим на выходных.';

  @override
  String get sleepIrregularTitle => 'Нерегулярный или сменный график';

  @override
  String get sleepIrregularDesc => 'Мой сон сильно меняется или я работаю по сменам.';

  @override
  String get smartPlanDashboardTitle => 'Ваша текущая стратегия';

  @override
  String get smartPlanProfileTitle => 'Ваша начальная стратегия';

  @override
  String get smartPlanCurrentPlanLabel => 'Текущий план';

  @override
  String get smartPlanRecommendedPlanLabel => 'Умная рекомендация';

  @override
  String get smartPlanSignalsLabel => 'Сигналы';

  @override
  String get smartPlanTitle => 'Умная рекомендация';

  @override
  String smartPlanBestMatch(String plan) {
    return 'Лучший стартовый план: $plan';
  }

  @override
  String get smartPlanHint => 'Вы сможете изменить это позже в настройках.';

  @override
  String get smartPlanWhyRecovery => 'Более мягкое окно лучше подходит для восстановления, стабильности и адаптации.';

  @override
  String get smartPlanWhyActive => 'Ваш уровень активности способствует плану, который защищает энергию и качество тренировок.';

  @override
  String get smartPlanWhyBeginner => 'Ваша цель и опыт предлагают начать с плана, который вы сможете стабильно повторять.';

  @override
  String get smartPlanWhyBalanced => 'Это дает вам более сильные преимущества голодания, не становясь слишком агрессивным.';

  @override
  String get smartPlanWhyAggressive => 'Ваш текущий профиль может справиться с более жестким окном, если вы хотите более быстрого прогресса.';

  @override
  String get smartPlanWhySleep => 'Ваш график сна способствует более стабильному плану, который добавляет меньше стресса в ваш распорядок.';

  @override
  String get smartPlanWhySustainable => 'Устойчивое начало обычно приводит к лучшему соблюдению режима в первые недели.';

  @override
  String smartPlanAlternativeEasier(String plan) {
    return '$plan — это более мягкий вариант, если вам нужна более легкая адаптация.';
  }

  @override
  String smartPlanAlternativeStronger(String plan) {
    return '$plan — это более сильный вариант, если вы хотите более амбициозного сокращения.';
  }

  @override
  String smartPlanCoachGreeting(String plan, String goal, String experience, String sleep) {
    return 'Я Fasty 🥑. Сейчас вы на плане $plan и сфокусированы на $goal. С вашим опытом ($experience) и графиком сна ($sleep), я помогу вам оставаться последовательными.';
  }

  @override
  String get smartPlanUseRecommendation => 'Использовать умную рекомендацию';

  @override
  String get labelAlternative => 'АЛЬТЕРНАТИВА';

  @override
  String perMonthEquivalent(String price, String period) {
    return '~$price/$period';
  }

  @override
  String get circadianProExclusive => 'ЭКСКЛЮЗИВНО PRO';

  @override
  String get circadianStartFast => 'Начать циркадное голодание';

  @override
  String get sunriseLabel => 'Рассвет';

  @override
  String get sunsetLabel => 'Закат';

  @override
  String get lastMeal => 'Последний прием';

  @override
  String get circadianTotalWindow => 'Общее окно';

  @override
  String get hoursLabel => 'часов';

  @override
  String get basedOnLocalCoordinates => 'На основе ваших местных координат';

  @override
  String get locationRequiredTitle => 'Требуется местоположение';

  @override
  String get locationRequiredDesc => 'Нам нужно ваше местоположение, чтобы рассчитать точное время заката в вашем городе.';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get circadianStarted => 'Циркадное голодание началось! 🌅';

  @override
  String get planCircadianTitle => 'Циркадное голодание';

  @override
  String get planCircadianSubtitle => 'В гармонии с солнцем';

  @override
  String get planCustomSubtitle => 'Свой график';

  @override
  String get planPresets => 'Шаблоны';

  @override
  String durationHoursShort(int hours) {
    return '$hoursч';
  }

  @override
  String durationHoursMinutesShort(int hours, int minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String get endFastCongrats => 'Вы сделали это! 🎉';

  @override
  String endFastTotalTime(String time) {
    return 'Общее время голодания: $time';
  }

  @override
  String get endFastHowFeel => 'Как вы себя чувствуете?';

  @override
  String get endFastSaveEat => 'Сохранить и поесть';

  @override
  String get endFastKeepFasting => 'Отмена, продолжать голодать';

  @override
  String get proAccessLabel => 'ДОСТУП PRO';

  @override
  String get timerEndTitle => 'Когда вы закончили голодание?';

  @override
  String get timerCannotStartFuture => 'Вы не можете начать голодание в будущем.';

  @override
  String get timerCannotEndFuture => 'Вы не можете завершить голодание в будущем.';

  @override
  String get timerEndBeforeStart => 'Время окончания не может быть раньше времени начала.';

  @override
  String get timerGoalReachedExtra => '🔥 Цель достигнута (+ сверх нормы)';

  @override
  String get timerWindowExtended => 'Окно расширено';

  @override
  String get timerRemainingInWindow => 'Осталось в окне';

  @override
  String get timerUnknownPlan => 'Неизвестный план';

  @override
  String get timerLogMoodSymptoms => 'Настроение и симптомы';

  @override
  String get timerBreakAlreadyActive => 'Вы уже на перерыве. Приятного отдыха! ☕';

  @override
  String get timerRestDayStarted => 'Окно питания закрыто. Приятного дня отдыха! 🏖️';

  @override
  String get timerTakeBreak => 'Сделать перерыв';

  @override
  String get timerLogStartEarlier => 'Записать начало раньше';

  @override
  String get timerLogEndEarlier => 'Записать конец раньше';

  @override
  String get timerLogFastStartEarlier => 'Записать начало голодания раньше';

  @override
  String get bodyMeasureChest => 'Грудь';

  @override
  String get bodyMeasureWaist => 'Талия';

  @override
  String get bodyMeasureHips => 'Бедра';

  @override
  String get bodyMeasureChestTitle => 'Обхват груди (см)';

  @override
  String get bodyMeasureWaistTitle => 'Обхват талии (см)';

  @override
  String get bodyMeasureHipsTitle => 'Обхват бедер (см)';

  @override
  String get bodyMeasureAdd => 'Добавить';

  @override
  String get drinkWater => 'Вода';

  @override
  String get drinkBlackCoffee => 'Черный кофе';

  @override
  String get drinkLatteSweetCoffee => 'Латте / Сладкий кофе';

  @override
  String get drinkGreenBlackTea => 'Зеленый / Черный чай';

  @override
  String get drinkDietSoda => 'Диетическая газировка';

  @override
  String get drinkSweetSoda => 'Сладкая газировка';

  @override
  String get drinkJuice => 'Сок';

  @override
  String get drinkAlcohol => 'Алкоголь';

  @override
  String waterDrinkContainsCalories(String drink) {
    return '$drink содержит калории!';
  }

  @override
  String get waterBreakFastWarning => 'Этот напиток прервет ваше голодание и автоматически начнет окно питания. Вы уверены?';

  @override
  String get waterConfirmDrinkBreakFast => 'Да, я выпил';

  @override
  String get waterDrinkPrompt => 'Что вы выпили?';

  @override
  String waterFastStoppedByDrink(String drink) {
    return 'Таймер голодания остановлен, потому что вы выпили $drink.';
  }

  @override
  String get waterUndoLastDrink => 'Отменить последний напиток';

  @override
  String get unitMl => 'мл';

  @override
  String get healthBadgeSync => 'Синхр.';

  @override
  String get healthNoData => 'Нет данных';

  @override
  String get healthSleepLabel => 'Сон';

  @override
  String get healthCyclePhaseLabel => 'Фаза цикла';

  @override
  String get cyclePhaseMenstruation => 'Менструация';

  @override
  String get cyclePhaseFollicular => 'Фолликулярная';

  @override
  String get cyclePhaseOvulation => 'Овуляция';

  @override
  String get cyclePhaseLuteal => 'Лютеиновая';

  @override
  String get learnQuickBites => 'Короткие факты';

  @override
  String get storyFasting101 => 'Основы голодания';

  @override
  String get storyAutophagy => 'Аутофагия';

  @override
  String get storyKetoDiet => 'Кето диета';

  @override
  String get storyHydration => 'Гидратация';

  @override
  String get storySleep => 'Сон';

  @override
  String storyOpening(String title) {
    return 'Открываем: $title...';
  }

  @override
  String recipeSelected(String title) {
    return 'Выбрано: $title';
  }

  @override
  String get aiUpdatingConfig => 'ИИ обновляет конфигурацию. Проверьте интернет и перезапустите приложение.';

  @override
  String get aiSessionExpired => 'Сессия с коучем истекла. Переоткройте чат для продолжения.';

  @override
  String get aiEmptyResponse => 'Я все еще думаю. Пожалуйста, попробуйте еще раз.';

  @override
  String get authGoogleFailed => 'Ошибка входа через Google. Попробуйте еще раз.';

  @override
  String get authAppleUnavailable => 'Вход через Apple доступен только на iOS.';

  @override
  String get authAppleFailed => 'Ошибка входа через Apple. Попробуйте еще раз.';

  @override
  String get journalSymptomsTitle => 'Симптомы и состояние';

  @override
  String get journalSymptomsPrefix => 'Симптомы';

  @override
  String get journalUpdated => 'Журнал обновлен! 📝';

  @override
  String get symptomEnergy => 'Энергия';

  @override
  String get symptomFocus => 'Фокус';

  @override
  String get symptomHungry => 'Голод';

  @override
  String get symptomFatigue => 'Усталость';

  @override
  String get symptomHeadache => 'Головная боль';

  @override
  String get symptomThirsty => 'Жажда';

  @override
  String get moodTerrible => 'Ужасно';

  @override
  String get moodBad => 'Плохо';

  @override
  String get moodOkay => 'Нормально';

  @override
  String get moodGood => 'Хорошо';

  @override
  String get moodGreat => 'Отлично';

  @override
  String get disclaimerCheckboxPrefix => 'Я согласен с ';

  @override
  String get disclaimerCheckboxLink => 'Медицинским отказом от ответственности и Политикой конфиденциальности';

  @override
  String get pdfReportTitle => 'Медицинский отчет';

  @override
  String get pdfReportSubtitle => 'Сводка по интервальному голоданию';

  @override
  String get pdfReportGenerating => 'Генерация отчета...';

  @override
  String get pdfReportGenerate => 'Создать PDF-отчет';

  @override
  String get pdfReportShare => 'Поделиться';

  @override
  String get pdfReportPreview => 'Предпросмотр';

  @override
  String get pdfReportPeriod => 'Период отчета';

  @override
  String get pdfReportPeriod7 => 'Последние 7 дней';

  @override
  String get pdfReportPeriod30 => 'Последние 30 дней';

  @override
  String get pdfReportPeriodAll => 'За все время';

  @override
  String get pdfReportProOnly => 'PDF-отчеты доступны только в PRO';

  @override
  String get pdfReportProDesc => 'Перейдите на PRO, чтобы создавать и делиться персонализированными отчетами.';

  @override
  String get pdfReportSectionProfile => 'Личный профиль';

  @override
  String get pdfReportSectionStats => 'Статистика';

  @override
  String get pdfReportSectionHistory => 'История голоданий';

  @override
  String get pdfReportSectionDisclaimer => 'Медицинский отказ';

  @override
  String get pdfReportLabelAge => 'Возраст';

  @override
  String get pdfReportLabelGender => 'Пол';

  @override
  String get pdfReportLabelWeight => 'Вес';

  @override
  String get pdfReportLabelHeight => 'Рост';

  @override
  String get pdfReportLabelBmi => 'ИМТ';

  @override
  String get pdfReportLabelTotalFasts => 'Всего голоданий';

  @override
  String get pdfReportLabelTotalHours => 'Всего часов';

  @override
  String get pdfReportLabelAvgDuration => 'Средняя длительность';

  @override
  String get pdfReportLabelLongest => 'Самое долгое';

  @override
  String get pdfReportLabelStreak => 'Лучшая серия';

  @override
  String get pdfReportLabelDate => 'Дата';

  @override
  String get pdfReportLabelDuration => 'Длительность';

  @override
  String get pdfReportLabelCompleted => 'Завершено';

  @override
  String get pdfReportDisclaimerText => 'Этот отчет сгенерирован Fastable и предназначен только для личного отслеживания. Он не является медицинским советом. Пожалуйста, проконсультируйтесь с врачом перед принятием любых решений о здоровье.';

  @override
  String get pdfReportGeneratedBy => 'Сгенерировано Fastable';

  @override
  String get pdfReportGenderMale => 'Мужской';

  @override
  String get pdfReportGenderFemale => 'Женский';

  @override
  String get pdfReportNoData => 'Нет записей о голодании за выбранный период.';

  @override
  String pdfReportHours(int hours, int minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String get bodyMetricsTitle => 'Параметры тела';

  @override
  String get bodyMetricsHint => 'Нажмите на карточки для обновления';

  @override
  String get bodyMetricsAdd => 'Добавить';

  @override
  String get bodyMetricsTapToSet => 'Нажмите, чтобы задать';

  @override
  String get nextStageUpper => 'СЛЕДУЮЩАЯ СТАДИЯ';

  @override
  String get maxBenefitsReached => 'Достигнут максимум преимуществ!';

  @override
  String get holdToComplete => 'УДЕРЖИВАЙТЕ ДЛЯ ЗАВЕРШЕНИЯ';

  @override
  String get heroActiveSession => 'АКТИВНАЯ СЕССИЯ';

  @override
  String get heroEatingWindow => 'ОКНО ПИТАНИЯ';

  @override
  String get heroNextFast => 'СЛЕДУЮЩЕЕ ГОЛОДАНИЕ';

  @override
  String get insightsAndTrends => 'ИНСАЙТЫ И ТРЕНДЫ';

  @override
  String get bmiLabel => 'ИМТ';

  @override
  String get liveTrackerChannelName => 'Таймер голодания';

  @override
  String get liveTrackerChannelDesc => 'Текущий таймер голодания';

  @override
  String get liveTrackerSubtextFasting => '🔥 Стадия Fastable';

  @override
  String get liveTrackerSubtextEating => '🍽 Окно Fastable';

  @override
  String get liveTrackerActionEndFast => '🏁 ЗАВЕРШИТЬ ГОЛОДАНИЕ';

  @override
  String get liveTrackerActionStopWindow => '🛑 ОСТАНОВИТЬ ОКНО';

  @override
  String liveTrackerGoal(String time) {
    return 'Цель: $time';
  }

  @override
  String liveTrackerWindowEnds(String time) {
    return 'Окно заканчивается: $time';
  }

  @override
  String get liveTrackerTimeRemaining => 'Осталось времени: ';

  @override
  String get elapsed => 'Прошло';

  @override
  String get status => 'Статус';

  @override
  String get complete => 'Завершено';

  @override
  String get fastingStages => 'Стадии голодания';

  @override
  String get statusNow => 'Сейчас';

  @override
  String get statusNext => 'Далее';

  @override
  String get statusDone => 'Готово';

  @override
  String get chartFastingVsWeight => 'Голодание и Вес';

  @override
  String get chartTrackMetabolic => 'Отслеживайте корреляцию метаболизма со временем.';

  @override
  String get chart1W => '1Н';

  @override
  String get chart1M => '1М';

  @override
  String get chart3M => '3М';

  @override
  String get chartSmartInsight => 'Умный инсайт';

  @override
  String chartGoal(String value) {
    return 'Цель: $value';
  }

  @override
  String get chartHours => 'Часы';

  @override
  String get chartWeight => 'Вес';

  @override
  String get chartLegendFasting => 'Часы голодания';

  @override
  String get chartLegendWeight => 'Тренд веса';

  @override
  String get chartInsight1W => 'Ваши окна стабильны на этой неделе! Поддержание 16+ часов коррелирует с более быстрым сжиганием жира.';

  @override
  String get chartInsight1M => 'За последний месяц мы заметили стабильное снижение вашего веса, когда вы завершаете голодание после 18:00.';

  @override
  String get chartInsight3M => 'Долгосрочные данные показывают невероятный прогресс! Ваш организм отлично адаптируется к метаболическому переключению.';

  @override
  String get statsUnlockChartTitle => 'Pro Аналитика';

  @override
  String get statsUnlockChartDesc => 'Посмотрите короткую видеорекламу, чтобы разблокировать график метаболической корреляции для этой сессии.';

  @override
  String get statsBtnWatchAd => 'Смотреть рекламу';

  @override
  String get adNotReady => 'Реклама еще не готова. Пожалуйста, попробуйте еще раз через несколько секунд.';
}
