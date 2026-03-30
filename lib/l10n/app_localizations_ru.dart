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
  String get endFast => 'Закончить';

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
  String get waterToday => 'Вода сегодня';

  @override
  String get waterIntake => 'Потребление воды';

  @override
  String get cups => 'стак.';

  @override
  String get cupsUnit => 'ст.';

  @override
  String get weightTracker => 'Трекер веса';

  @override
  String get logWeight => 'Записать вес';

  @override
  String get saveWeight => 'Сохранить вес';

  @override
  String get weightJourney => 'Динамика веса';

  @override
  String get last7Days => 'За 7 дней';

  @override
  String get fastingHours => 'Часов голодания';

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
  String get chartEmpty => 'Добавьте хотя бы две записи веса для графика.';

  @override
  String get proBannerTitle => 'Fastable PRO';

  @override
  String get proBannerDesc => 'Открыть аналитику';

  @override
  String get premiumContentTitle => 'Премиум контент';

  @override
  String get premiumContentDesc => 'Получите полный доступ ко всем статьям и функциям.';

  @override
  String get getPro => 'Купить PRO';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get proTitle => 'Открыть Fastable Pro';

  @override
  String get proMonthly => 'Подписка на месяц';

  @override
  String get proAnnual => 'Подписка на год (Скидка 40%)';

  @override
  String get unlockAll => 'Открыть все функции';

  @override
  String get accessStatus => 'Текущий доступ';

  @override
  String statusActive(Object date) {
    return 'Активен до $date';
  }

  @override
  String get statusFree => 'Бесплатный';

  @override
  String get proRequired => 'Для просмотра требуется подписка PRO';

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
  String get historyEmpty => 'Пока нет завершенных голоданий. Они появятся здесь!';

  @override
  String get fastComplete => 'Пост завершён! 🎉';

  @override
  String fastCompleteDesc(String time) {
    return 'Вы соблюдали пост в течение $time. Сохранить запись?';
  }

  @override
  String get noFastsOnDay => 'В этот день голоданий не было.';

  @override
  String get detailsFor => 'Детали за';

  @override
  String get endCyclePrompt => 'Завершить окно питания?';

  @override
  String get endCyclePromptDesc => 'Это остановит таймер питания и сбросит цикл.';

  @override
  String get endFastPrompt => 'Завершите текущий цикл, чтобы изменить план.';

  @override
  String get discard => 'Отменить';

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
  String get finish => 'Готово';

  @override
  String get attention => 'Внимание';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get settingLanguage => 'Язык';

  @override
  String get settingWaterGoal => 'Цель воды (в день)';

  @override
  String get settingHeight => 'Рост';

  @override
  String get settingGoalWeight => 'Желаемый вес';

  @override
  String get settingTheme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Системная';

  @override
  String get settingsHealthConnect => 'Подключение к здоровью';

  @override
  String get settingsSyncWeight => 'Синхронизация веса и шагов';

  @override
  String get healthConnectSyncTitle => 'Синхронизация с Health Connect';

  @override
  String get healthConnectDisclosureIntro => 'Fastable запрашивает доступ к ЧТЕНИЮ и ЗАПИСИ данных о ВЕСЕ через Health Connect.';

  @override
  String get healthConnectDisclosureRead => 'Мы используем ЧТЕНИЕ для отображения графика прогресса веса на основе исторических данных.';

  @override
  String get healthConnectDisclosureWrite => 'Мы используем ЗАПИСЬ, чтобы вы могли сохранять вес из Fastable в общее хранилище телефона.';

  @override
  String get healthConnectDisclosureSecure => 'Данные хранятся локально и используются только для трекинга. Вы можете отозвать доступ в любой момент.';

  @override
  String get healthConnectConnected => 'Health Connect подключен!';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get notifyWater => 'Напоминания о воде';

  @override
  String get notifyWaterDesc => 'Напоминать пить воду';

  @override
  String get notifyWeight => 'Напоминание о весе';

  @override
  String get notifyWeightDesc => 'Ежедневное напоминание взвеситься';

  @override
  String get notifyFastingStart => 'Начало голодания';

  @override
  String get notifyFastingStartDesc => 'Уведомлять о начале окна голодания';

  @override
  String get simplifiedAnimation => 'Упрощенная анимация';

  @override
  String get simplifiedAnimationDesc => 'Снижает размытие и эффекты для экономии батареи и производительности';

  @override
  String get settingPerformance => 'Производительность';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get errorOpenLink => 'Не удалось открыть ссылку';

  @override
  String get errorLoading => 'Ошибка загрузки';

  @override
  String get noArticlesFound => 'Статьи не найдены';

  @override
  String get tabFasting => 'Голодание';

  @override
  String get tabKeto => 'Кето';

  @override
  String get tabPartner => 'Партнеры';

  @override
  String get guestUser => 'Гость';

  @override
  String get defaultUser => 'Пользователь';

  @override
  String get anonymousLogin => 'Анонимный вход';

  @override
  String get dataOnDevice => 'Данные хранятся на устройстве';

  @override
  String get connectGoogle => 'Подключить Google аккаунт';

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
  String get guestLogoutWarning => 'Вы используете гостевой аккаунт. При выходе все локальные данные будут безвозвратно удалены.';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountWarning => 'Вы уверены? Это действие навсегда удалит все ваши данные.';

  @override
  String get authWelcome => 'Добро пожаловать в Fastable';

  @override
  String get authSubtitle => 'Войдите, чтобы синхронизировать данные';

  @override
  String get signInGoogle => 'Войти через Google';

  @override
  String get continueGuest => 'Продолжить как Гость';

  @override
  String get signInFailed => 'Вход не выполнен. Попробуйте снова.';

  @override
  String get welcomeMessage => 'Добро пожаловать в приложение!';

  @override
  String get choosePlan => 'Выберите план';

  @override
  String get fastingPlan16_8 => '16:8 Интервальное голодание';

  @override
  String get fastingPlan18_6 => '18:6 Продвинутый';

  @override
  String get fastingPlan20_4 => '20:4 Диета воина';

  @override
  String get fastingPlanEatStopEat => '24ч Ешь-Стоп-Ешь';

  @override
  String get bmiCalculator => 'Калькулятор ИМТ';

  @override
  String get bmiCategory => 'Категория';

  @override
  String get bmiUnderweight => 'Дефицит веса';

  @override
  String get bmiNormal => 'Норма';

  @override
  String get bmiOverweight => 'Лишний вес';

  @override
  String get bmiObese => 'Ожирение';

  @override
  String get enterHeightCm => 'Введите рост (см)';

  @override
  String get enterGoalWeightKg => 'Введите желаемый вес (кг)';

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
  String get fastingStatsAvgFast => 'Среднее время';

  @override
  String get fastingStatsHours => 'Часов';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать!';

  @override
  String get onboardingWelcomeDesc => 'Начните путь к здоровью. Давайте настроим ваш профиль.';

  @override
  String get onboardingGoalTitle => 'Каковы ваши цели?';

  @override
  String get onboardingGoalDesc => 'Укажите рост и желаемый вес для расчета ИМТ.';

  @override
  String get onboardingPlanTitle => 'Выберите план';

  @override
  String get onboardingPlanDesc => 'С какого плана голодания вы хотите начать? Его можно изменить позже.';

  @override
  String get onboardingCurrentWeight => 'Ваш текущий вес';

  @override
  String get getStarted => 'Начать';

  @override
  String get currentStage => 'Текущая стадия';

  @override
  String get nextStage => 'Далее';

  @override
  String get stageAnabolicTitle => 'Анаболическая (Питание)';

  @override
  String get stageAnabolicDesc => 'Организм переваривает пищу и использует глюкозу. Активный рост клеток.';

  @override
  String get stageCatabolicTitle => 'Катаболическая';

  @override
  String get stageCatabolicDesc => 'Уровень сахара падает. Тело начинает использовать запасенный гликоген.';

  @override
  String get stageKetosisTitle => 'Кетоз';

  @override
  String get stageKetosisDesc => 'Запасы гликогена истощены. Организм сжигает жир как основное топливо.';

  @override
  String get stageAutophagyTitle => 'Аутофагия';

  @override
  String get stageAutophagyDesc => 'Клеточное очищение. Организм перерабатывает старые компоненты клеток.';

  @override
  String get stagePeakAutophagyTitle => 'Пик аутофагии';

  @override
  String get stagePeakAutophagyDesc => 'Процесс очищения и обновления клеток достигает максимума.';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String get achievementsUnlocked => 'Получено';

  @override
  String get achievementsLocked => 'Закрыто';

  @override
  String achEarnedOn(Object date) {
    return 'Получено $date';
  }

  @override
  String get achFirstFastTitle => 'Первый шаг!';

  @override
  String get achFirstFastDesc => 'Завершите своё первое голодание.';

  @override
  String get achStreak3Title => 'Хорошее начало';

  @override
  String get achStreak3Desc => 'Поддерживайте серию из 3 дней голодания.';

  @override
  String get achStreak7Title => 'Стабильность';

  @override
  String get achStreak7Desc => 'Достигните серии из 7 дней.';

  @override
  String get achTotal10Title => 'Новичок';

  @override
  String get achTotal10Desc => 'Завершите 10 голоданий.';

  @override
  String get achTotalHours100Title => 'Клуб 100 часов';

  @override
  String get achTotalHours100Desc => 'Накопите 100 часов голодания.';

  @override
  String get journalTitle => 'Заметка в журнал';

  @override
  String get journalHint => 'Как вы себя чувствовали во время голодания?';

  @override
  String get addNote => 'Добавить заметку';

  @override
  String get editNote => 'Изменить заметку';

  @override
  String get noteSaved => 'Заметка сохранена';

  @override
  String get syncHealthTitle => 'Синхронизация здоровья';

  @override
  String get syncHealthDesc => 'Автоматически записывать голодание и читать вес.';

  @override
  String get shareProgress => 'Поделиться';

  @override
  String get metricPhase => 'Фаза';

  @override
  String get metricStreak => 'Серия';

  @override
  String get metricStatus => 'Статус';

  @override
  String get statusDigesting => 'Пищеварение';

  @override
  String get statusStable => 'Стабильно';

  @override
  String get statusFatBurn => 'Сжигание жира';

  @override
  String get statusKetosis => 'Кетоз';

  @override
  String get statusNormal => 'Норма';

  @override
  String get titleCurrentPhase => 'Текущая фаза';

  @override
  String get valFastingZone => 'Зона поста';

  @override
  String get valEatingWindow => 'Окно питания';

  @override
  String get descFastingZone => 'Сейчас вы находитесь в периоде поста. Калории потреблять не рекомендуется.';

  @override
  String get descEatingWindow => 'Сейчас ваше окно питания. Сосредоточьтесь на питательных продуктах.';

  @override
  String get titleConsistencyStreak => 'Серия регулярности';

  @override
  String valStreakDays(int days) {
    return '$days дней 🔥';
  }

  @override
  String descStreak(int days) {
    return 'Вы достигали цели поста $days дней подряд. Продолжайте, чтобы закрепить привычку!';
  }

  @override
  String get titleBodyStatus => 'Состояние организма';

  @override
  String get descDigesting => 'Ваш организм переваривает пищу и восполняет запасы гликогена. Уровень инсулина повышается.';

  @override
  String get descStable => 'Уровень сахара в крови нормализуется. Организм готовится перейти от глюкозы к жиру как источнику энергии.';

  @override
  String get descFatBurn => 'Отличная работа! Организм начинает использовать жировые запасы для энергии. Уровень гормона роста может повышаться.';

  @override
  String get descKetosis => 'Глубокий кетоз! Организм эффективно сжигает жир. Процессы аутофагии могут скоро начаться.';

  @override
  String get btnGotIt => 'Понятно!';

  @override
  String get stage0_4 => 'Рост сахара';

  @override
  String get stage0_4_desc => 'Тело переваривает еду. Уровень сахара и инсулина растет.';

  @override
  String get stage4_8 => 'Падение сахара';

  @override
  String get stage4_8_desc => 'Инсулин падает. Организм начинает использовать запасы глюкозы.';

  @override
  String get stage8_12 => 'Нормализация';

  @override
  String get stage8_12_desc => 'Пищеварение отдыхает. Тело начинает процессы очищения.';

  @override
  String get stage12_16 => 'Сжигание жира';

  @override
  String get stage12_16_desc => 'Инсулин низкий. Организм переключается на сжигание жира.';

  @override
  String get stage16_18 => 'Кетоз';

  @override
  String get stage16_18_desc => 'Сжигание жира ускоряется. Вы в режиме активного похудения.';

  @override
  String get stage18_24 => 'Аутофагия';

  @override
  String get stage18_24_desc => 'Клеточное очищение. Организм перерабатывает старые клетки.';

  @override
  String get stage24_plus => 'Глубокое восстановление';

  @override
  String get stage24_plus_desc => 'Растет гормон роста. Идет мощная регенерация клеток.';

  @override
  String get viewTimeline => 'График тела';

  @override
  String get navFood => 'Еда';

  @override
  String get circadianEnabled => 'Циркадный режим включен';

  @override
  String get circadianDisabled => 'Циркадный режим отключен';

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
  String get removeCup => 'Убрать стакан (-1)';

  @override
  String get dailyGoal => 'Дневная цель';

  @override
  String get bmiScore => 'ИМТ';

  @override
  String bmiDescription(int height, String weight) {
    return 'На основе роста ($height см) и веса ($weight кг).';
  }

  @override
  String get onboardingTitle => 'Настройте свой план';

  @override
  String get onboardingHeightTitle => 'Ваш рост';

  @override
  String get onboardingHeightDesc => 'Это нужно для работы Визуализатора Тела и точного расчета индексов здоровья.';

  @override
  String get onboardingWeightTitle => 'Ваш вес';

  @override
  String get onboardingWeightDesc => 'Поможет отслеживать прогресс и адаптировать план голодания под вас.';

  @override
  String get btnNext => 'Далее';

  @override
  String get btnFinish => 'Начать путь';

  @override
  String get cm => 'см';

  @override
  String get kg => 'кг';

  @override
  String get statsSuccessRate => 'Успешность';

  @override
  String statsSuccessDesc(int success, int total) {
    return '$success из $total голоданий длились 16 ч и более';
  }

  @override
  String get statsTotalFasts => 'Всего голоданий';

  @override
  String get statsTotalHours => 'Всего часов';

  @override
  String get statsAverage => 'Среднее';

  @override
  String get statsLongest => 'Максимум';

  @override
  String get circadianTitle => 'Циркадный ритм';

  @override
  String get circadianIntroTitle => 'Питание по Солнцу ☀️';

  @override
  String get circadianIntroDesc => 'Ваш метаболизм зависит от солнца.\n\n• Восход: Пробуждение. Лучше время для воды.\n• День: Пик метаболизма. Идеально для еды.\n• Закат: Организм готовится ко сну. Стоп еда.\n• Ночь: Время восстановления. Естественный голод.\n\nЭтот режим автоматически подстраивает цели голодания под восход и закат в вашей локации.';

  @override
  String get circadianBtnEnable => 'Включить режим';

  @override
  String get circadianBtnDisable => 'Отключить';

  @override
  String get circadianTargetSunrise => 'До восхода';

  @override
  String get circadianTargetSunset => 'До заката';

  @override
  String get circadianPhaseDay => 'День (Можно есть)';

  @override
  String get circadianPhaseNight => 'Ночь (Голодание)';

  @override
  String get circadianWarnDayTitle => 'Сейчас день ☀️';

  @override
  String get circadianWarnDayDesc => 'Солнце высоко! Организм ждет пищу. Лучше всего начать голодание после заката.';

  @override
  String get circadianWarnBtnStart => 'Всё равно начать';

  @override
  String get circadianWarnBtnWait => 'Ждать заката';

  @override
  String get circadianBonusTime => 'Сверх нормы 🔥';

  @override
  String get circadianSyncing => 'Синхронизация с солнцем...';

  @override
  String get circadianError => 'Нет геопозиции. Включен обычный таймер.';

  @override
  String get circadianManaged => 'По Солнцу';

  @override
  String get notifBio4hTitle => 'Сахар в норме 🩸';

  @override
  String get notifBio4hBody => 'Инсулин падает. Ложный голод должен скоро пройти.';

  @override
  String get notifBio8hTitle => 'Желудок пуст ✅';

  @override
  String get notifBio8hBody => 'Пищеварение завершено. Тело переходит в режим отдыха.';

  @override
  String get notifBio12hTitle => 'Вход в Кетоз 🔥';

  @override
  String get notifBio12hBody => 'Организм начал сжигать жировые запасы для энергии!';

  @override
  String get notifBio16hTitle => 'Пик жиросжигания ⚡️';

  @override
  String get notifBio16hBody => 'Метаболизм ускорен. Вы в зоне максимальной эффективности.';

  @override
  String get notifBio18hTitle => 'Старт Аутофагии ♻️';

  @override
  String get notifBio18hBody => 'Клеточное очищение. Организм перерабатывает старые клетки.';

  @override
  String get notifBio24hTitle => 'Рост иммунитета 🛡';

  @override
  String get notifBio24hBody => 'Гормон роста повышен для защиты мышц и обновления тканей.';

  @override
  String get notifProg50Title => 'Половина пути! 🚀';

  @override
  String get notifProg50Body => 'Вы прошли 50% цели. Так держать!';

  @override
  String get notifProg1hTitle => 'Остался 1 час ⏳';

  @override
  String get notifProg1hBody => 'Почти всё! Можно начинать готовить еду.';

  @override
  String get notifProgFinishTitle => 'Цель достигнута! 🏆';

  @override
  String get notifProgFinishBody => 'Вы справились! Не забудьте остановить таймер.';

  @override
  String get notifWaterTitle => 'Время воды 💧';

  @override
  String get notifWaterBody => 'Вода ускоряет метаболизм и притупляет чувство голода.';

  @override
  String get notifWeightTitle => 'Утреннее взвешивание ⚖️';

  @override
  String get notifWeightBody => 'Утро — лучшее время, чтобы зафиксировать прогресс.';

  @override
  String get permTitle => 'Разрешения';

  @override
  String get permDesc => 'Чтобы обеспечить лучший опыт, Fastable требуется доступ к уведомлениям и данным здоровья.';

  @override
  String get permNotifTitle => 'Уведомления';

  @override
  String get permNotifDesc => 'Помогают не сбиваться с графика голодания.';

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
  String get achStreak3 => 'Постоянство';

  @override
  String get achStreak7 => 'Неостановимый';

  @override
  String get achTotal10 => 'Преданность';

  @override
  String get achTotalHours100 => 'Центурион';

  @override
  String get onboardingDesc => 'Давайте рассчитаем ваш метаболизм.';

  @override
  String get btnContinue => 'Продолжить';

  @override
  String get btnStart => 'Начать путь';

  @override
  String get selectGender => 'Пол';

  @override
  String get selectAge => 'Возраст';

  @override
  String get selectWeight => 'Вес';

  @override
  String get selectHeight => 'Рост';

  @override
  String get selectActivity => 'Активность';

  @override
  String get genderMale => 'Мужской';

  @override
  String get genderFemale => 'Женский';

  @override
  String get activitySedentary => 'Низкая';

  @override
  String get activityModerate => 'Умеренная';

  @override
  String get activityActive => 'Высокая';

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
  String get metricBmrDesc => 'Базальный метаболизм. Калории, сжигаемые в состоянии полного покоя.';

  @override
  String get metricTdeeTitle => 'TDEE';

  @override
  String get metricTdeeSubtitle => 'Поддержание';

  @override
  String get metricTdeeDesc => 'Суточные энергозатраты. Калории, необходимые для поддержания текущего веса.';

  @override
  String get dialogStartTitle => 'Когда вы начали?';

  @override
  String get btnStartFasting => 'Начать голодание';

  @override
  String get btnCancel => 'Отмена';

  @override
  String get stage2Title => 'Уровень сахара снижается 📉';

  @override
  String get stage2Body => 'Организм начинает успокаиваться. Если чувствуете голод — выпейте воды. 💧';

  @override
  String get stage4Title => 'Инсулин снижается ⬇️';

  @override
  String get stage4Body => 'Отлично! Организм перестаёт запасать жир и готовится его сжигать.';

  @override
  String get stage8Title => 'Запуск очищения ✨';

  @override
  String get stage8Body => '8 часов прошло. Желудок отдыхает. Вы делаете большое дело для здоровья!';

  @override
  String get stage11Title => 'Режим сжигания жира 🔥';

  @override
  String get stage11Body => 'Самое интересное начинается! Организм переходит на внутренние резервы.';

  @override
  String get stage12Title => 'Кетоз активирован 🚀';

  @override
  String get stage12Body => 'Жировые клетки превращаются в энергию. Сознание становится яснее.';

  @override
  String get stage14Title => 'Глубокий кетоз 🔥';

  @override
  String get stage14Body => 'Вы в зоне сжигания жира! Процессы очищения идут быстрее.';

  @override
  String get stage16Title => 'Аутофагия (обновление клеток) 🧬';

  @override
  String get stage16Body => 'Клетки обновляются. Организм работает над восстановлением.';

  @override
  String get stage18Title => 'Пик гормона роста 📈';

  @override
  String get stage18Body => 'Гормон роста помогает сжигать жир и поддерживать мышцы. Вы становитесь сильнее!';

  @override
  String get stage24Title => '24 часа! 🏆';

  @override
  String get stage24Body => 'Невероятно! Полные сутки завершены. Глубокое очищение в самом разгаре.';

  @override
  String get notifyHalfwayTitle => 'Половина пути! ⛰️';

  @override
  String get notifyHalfwayBody => 'Самое сложное позади. Ваш организм благодарен вам.';

  @override
  String get notify1hTitle => 'Финишная прямая! 🏁';

  @override
  String get notify1hBody => 'Остался всего 1 час. Вы справляетесь отлично!';

  @override
  String get notifyGoalTitle => 'Цель достигнута! 🎉';

  @override
  String get notifyGoalBody => 'Поздравляем! Завершайте голодание мягко.';

  @override
  String get notifyEatCloseTitle => 'Окно питания закрывается 🛑';

  @override
  String get notifyEatCloseBody => 'Пора начинать следующее голодание. Загляните в приложение!';

  @override
  String get notifyEat30mTitle => 'Осталось 30 минут 🥗';

  @override
  String get notifyEat30mBody => 'Не забудьте выпить воды или сделать лёгкий приём пищи.';

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
  String get headerHealthyChoices => 'Полезный выбор';

  @override
  String get statusNoArticles => 'Статьи не найдены';

  @override
  String get msgComingSoon => 'Эта функция скоро появится!';

  @override
  String get learnBannerTitle => 'Откройте 500+ рецептов';

  @override
  String get learnBannerSubtitle => 'Полный доступ с PRO';

  @override
  String get labelPremium => 'ПРЕМИУМ';

  @override
  String get bannerRecipeTitle => 'Полезные рецепты';

  @override
  String get bannerRecipeSubtitle => 'Кето, низкоуглеводные и другие';

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
  String get msgHealthSyncEnabled => 'Синхронизация здоровья включена!';

  @override
  String get msgHealthSyncFailed => 'Доступ запрещён';

  @override
  String get aiGreeting => 'Привет! Я Fasty 🥑. Чем могу помочь вам достичь ваших целей сегодня?';

  @override
  String get aiConnectionError => 'Упс! Соединение потеряно. Проверьте интернет или попробуйте позже. 🥑';

  @override
  String get aiSystemError => 'Сервис ИИ настроен некорректно (отсутствует API-ключ).';

  @override
  String get aiCoachTitle => 'ИИ-коуч по голоданию';

  @override
  String get aiCoachDesc => 'Получайте мгновенные ответы о кето, интервальном голодании и здоровых привычках от нашего умного ИИ-ассистента.';

  @override
  String get aiChatHint => 'Спросите про кето или голодание...';

  @override
  String get btnUnlockPro => 'Открыть с PRO';

  @override
  String get aiInsightFallback => 'Постоянство — ключ к успеху! Пейте воду и оставайтесь в движении. 💧';

  @override
  String get aiErrorConnection => 'Проблема с соединением. Пожалуйста, попробуйте позже.';

  @override
  String get aiInsightTitle => 'ИНСАЙТ ДНЯ';

  @override
  String get aiInsightTeaser => 'На основе ваших последних 7 дней голодания мы обнаружили важную закономерность, влияющую на ваш прогресс...';

  @override
  String get tapToUnlock => 'Нажмите, чтобы открыть';

  @override
  String get notifyAiInsightTitle => 'Ваш ежедневный ИИ-инсайт готов! 🥑';

  @override
  String get notifyAiInsightBody => 'Посмотрите, что Fasty проанализировал для вас сегодня. Нажмите, чтобы открыть.';

  @override
  String get notifyWeightTitle => 'Отслеживайте вес ⚖️';

  @override
  String get notifyWeightBody => 'Постоянство — ключ к успеху! Запишите свой вес сегодня.';

  @override
  String get aiInsightNotEnoughData => 'Продолжайте трекинг! Нам нужно хотя бы 3 записи, чтобы найти ваши скрытые паттерны. 📊';

  @override
  String msgLoginFailed(Object error) {
    return 'Ошибка входа: $error';
  }

  @override
  String msgAppleLoginFailed(Object error) {
    return 'Ошибка входа Apple: $error';
  }

  @override
  String get msgSyncCompleted => 'Синхронизация завершена';

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
  String get dialogDeleteAccountContent => 'Это действие необратимо. Вся история веса, голоданий и достижения будут удалены из облака.';

  @override
  String get btnDelete => 'УДАЛИТЬ';

  @override
  String get dialogSyncConflictTitle => 'Конфликт синхронизации';

  @override
  String get dialogSyncConflictContent => 'Найдены данные в облаке. Объединить с локальными или перезаписать?';

  @override
  String get btnUseCloud => 'Взять из облака\n(Удалить текущие)';

  @override
  String get btnMergeData => 'Объединить';

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
  String get lblLast7Days => 'За 7 дней';

  @override
  String get lblFasts => 'Голоданий';

  @override
  String get lblHours => 'Часов';

  @override
  String get lblDayStreak => 'Дней подряд';

  @override
  String get msgStartJourney => 'Начните свой путь сегодня';

  @override
  String get lblToday => 'Сегодня';

  @override
  String get lblYesterday => 'Вчера';

  @override
  String get confirmTime => 'Подтвердить время';

  @override
  String get lblFastingTypeCircadian => 'Циркадный';

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
  String get lblAdjustDuration => 'Настройка длительности';

  @override
  String get lblFasting => 'Голод';

  @override
  String get lblEating => 'Еда';

  @override
  String get lblSlideToAdjust => 'Сдвиньте для настройки';

  @override
  String get btnStartCustomPlan => 'Запустить план';

  @override
  String get btnUnlockFeature => 'Разблокировать';

  @override
  String get proFeatureTitle => 'Pro Функция';

  @override
  String get proFeatureDesc => 'Кастомные планы доступны только Pro пользователям.';

  @override
  String get setFastingGoal => 'Цель голодания';

  @override
  String get fastingSaved => 'Голодание сохранено! 🏆';

  @override
  String get whenStopEating => 'Когда вы закончили есть?';

  @override
  String get editTime => 'Изменить время';

  @override
  String get customPlan => 'Свой план';

  @override
  String get tapToEdit => 'Нажми для настройки';

  @override
  String get timeLeft => 'ОСТАЛОСЬ';

  @override
  String get maxBenefits => 'Максимум пользы достигнут';

  @override
  String get appNameUpper => 'FASTABLE';

  @override
  String get splashSlogan => 'Раскрой потенциал своего тела';

  @override
  String get weightSaved => 'Вес сохранен';

  @override
  String get proSubtitle => 'Неограниченный доступ к AI-коучу и рецептам';

  @override
  String get featureCoach => 'AI-коуч Fasty';

  @override
  String get featureCoachDesc => 'Персональные советы и мотивация 24/7';

  @override
  String get featureRecipes => 'Здоровые рецепты';

  @override
  String get featureRecipesDesc => 'Кето, низкоуглеводные и для голодания';

  @override
  String get featureNoAds => 'Без рекламы';

  @override
  String get featureNoAdsDesc => 'Фокусируйтесь на целях без отвлекающих факторов';

  @override
  String get bestValue => 'ВЫГОДНО';

  @override
  String get loadingOffers => 'Загрузка тарифов...';

  @override
  String get welcomePro => 'Добро пожаловать в Pro! 🚀';

  @override
  String get errorPro => 'Ошибка покупки. Попробуйте снова.';

  @override
  String get confirmDeleteMsg => 'Это действие нельзя отменить. Все ваши данные будут потеряны.';

  @override
  String get statusLocked => 'Закрыто';

  @override
  String get sectionLegal => 'Правовая информация';

  @override
  String get btnOverwriteLocal => 'Перезаписать';

  @override
  String get msgDeleteError => 'Ошибка удаления аккаунта';

  @override
  String get msgDeleteReauthCancelled => 'Удаление аккаунта отменено.';

  @override
  String get msgDeleteReauthFailed => 'Не удалось подтвердить вашу личность. Попробуйте ещё раз.';

  @override
  String get msgDeleteReauthUnavailable => 'Перед удалением этого аккаунта войдите снова через исходный способ входа.';

  @override
  String get stepLanguage => 'Выберите язык';

  @override
  String get stepBodyMetrics => 'Параметры тела';

  @override
  String get stepBodyMetricsDesc => 'Помогите нам рассчитать ваш ИМТ и цели';

  @override
  String get activityHint => 'Используется для расчета расхода энергии.';

  @override
  String get activitySedentaryDesc => 'Офисная работа, мало движения';

  @override
  String get activityModerateDesc => 'Активная работа или спорт 3-4 раза';

  @override
  String get activityActiveDesc => 'Физическая работа или ежедневные тренировки';

  @override
  String get stepGoal => 'Выберите цель';

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
  String get labelRecommended => 'РЕКОМЕНДУЕМ';

  @override
  String get permHealthConnect => 'Health Connect';

  @override
  String get permHealthConnectDesc => 'Синхронизация веса и шагов с Google Fit';

  @override
  String get planMonthly => 'Месячный';

  @override
  String get planAnnual => 'Годовой';

  @override
  String get planLifetime => 'Навсегда';

  @override
  String savePercent(String percent) {
    return 'СКИДКА $percent%';
  }

  @override
  String get medicalDisclaimerTitle => 'Отказ от ответственности';

  @override
  String get medicalDisclaimerHeading => 'Медицинский отказ';

  @override
  String get medicalDisclaimerBody => 'Fastable создан для помощи в отслеживании интервального голодания и предоставляет AI-коучинг на основе общедоступных знаний. Это НЕ медицинское устройство. Предоставленная информация носит исключительно образовательный характер и не должна заменять профессиональную медицинскую консультацию.\n\nПожалуйста, проконсультируйтесь с врачом перед началом любого режима голодания, особенно если вы беременны, кормите грудью, страдаете диабетом или имеете другие заболевания.';

  @override
  String get scientificSourcesHeading => 'Научные источники и статьи';

  @override
  String get sourceJohnsHopkins => 'Медицина Джонса Хопкинса';

  @override
  String get sourceJohnsHopkinsDesc => 'Интервальное голодание: что это такое и как оно работает?';

  @override
  String get sourceMayoClinic => 'Клиника Мэйо';

  @override
  String get sourceMayoClinicDesc => 'Диета с голоданием: может ли она улучшить здоровье сердца?';

  @override
  String get sourceHarvard => 'Гарвардская медицинская школа';

  @override
  String get sourceHarvardDesc => 'Интервальное голодание: новые факты';

  @override
  String get legalAgreementPrefix => 'Продолжая, вы соглашаетесь со стандартными ';

  @override
  String get legalTermsOfUse => 'Условиями использования (EULA)';

  @override
  String get legalAgreementAnd => ' от Apple и нашей ';

  @override
  String get legalPrivacyPolicy => 'Политикой конфиденциальности';

  @override
  String get comingSoonTitle => 'Скоро появится!';

  @override
  String get comingSoonDesc => 'Мы усердно работаем над созданием отличного контента. Следите за обновлениями!';

  @override
  String get statusNoRecipes => 'Рецепты не найдены';

  @override
  String get aboutAndLegal => 'О приложении и Правовая информация';

  @override
  String get settingsMedicalDisclaimer => 'Медицинский отказ и источники';

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
  String get planExtended => 'Длительный';

  @override
  String get zoneSugarRises => 'Рост сахара в крови';

  @override
  String get zoneSugarRisesDesc => 'Организм перерабатывает последнюю еду и запасает энергию.';

  @override
  String get zoneSugarDrops => 'Падение сахара в крови';

  @override
  String get zoneSugarDropsDesc => 'Пищеварение завершается. Уровень сахара в крови возвращается к норме.';

  @override
  String get zoneFatBurning => 'Сжигание жира';

  @override
  String get zoneFatBurningDesc => 'Организм начинает использовать накопленный жир как источник энергии.';

  @override
  String get zoneKetosis => 'Кетоз';

  @override
  String get zoneKetosisDesc => 'Сжигание жира ускоряется. Повышается ясность мышления.';

  @override
  String get zoneAutophagy => 'Аутофагия';

  @override
  String get zoneAutophagyDesc => 'Начинается восстановление и переработка клеток. Это даёт омолаживающий эффект.';

  @override
  String get zoneGrowthHormone => 'Гормон роста';

  @override
  String get zoneGrowthHormoneDesc => 'Пик жиросжигания, восстановления тканей и сохранения мышц.';

  @override
  String continueForPrice(String price) {
    return 'Продолжить за $price';
  }

  @override
  String get offersUnavailable => 'Предложения временно недоступны';

  @override
  String get billedMonthly => 'Списание каждый месяц';

  @override
  String get billedAnnually => 'Списание раз в год';

  @override
  String get oneTimePurchase => 'Разовая покупка';

  @override
  String get goalPriorityTitle => 'Что для вас сейчас важнее всего?';

  @override
  String get goalPriorityDesc => 'Это помогает нам сбалансировать скорость прогресса, восстановление и долгосрочную стабильность.';

  @override
  String get goalFatLossTitle => 'Быстрее снизить вес';

  @override
  String get goalFatLossDesc => 'Смещаем рекомендацию к более сильным окнам голодания, если профиль это допускает.';

  @override
  String get goalHealthTitle => 'Улучшить здоровье и энергию';

  @override
  String get goalHealthDesc => 'Выбираем более сбалансированный план для фокуса, энергии и устойчивости.';

  @override
  String get goalHabitTitle => 'Выстроить устойчивую привычку';

  @override
  String get goalHabitDesc => 'Начинаем мягче, чтобы режим действительно закрепился.';

  @override
  String get routineTitle => 'Расскажите о своём режиме';

  @override
  String get routineDesc => 'Сон и опыт голодания влияют на то, насколько агрессивным должен быть стартовый план.';

  @override
  String get fastingExperienceTitle => 'Опыт голодания';

  @override
  String get experienceBeginnerTitle => 'Новичок';

  @override
  String get experienceBeginnerDesc => 'Я только начинаю или часто срываюсь раньше времени.';

  @override
  String get experienceIntermediateTitle => 'Есть опыт';

  @override
  String get experienceIntermediateDesc => 'Я спокойно выдерживаю 14-16 часов без серьёзного дискомфорта.';

  @override
  String get experienceAdvancedTitle => 'Продвинутый';

  @override
  String get experienceAdvancedDesc => 'Я уже делал более длинные голодания и хочу более сильный протокол.';

  @override
  String get sleepPatternTitle => 'Режим сна';

  @override
  String get sleepRegularTitle => 'Стабильный сон';

  @override
  String get sleepRegularDesc => 'Я обычно ложусь и встаю примерно в одно и то же время.';

  @override
  String get sleepLateTitle => 'Поздние ночи';

  @override
  String get sleepLateDesc => 'Я часто ложусь поздно или сбиваю режим по выходным.';

  @override
  String get sleepIrregularTitle => 'Нерегулярно или смены';

  @override
  String get sleepIrregularDesc => 'Мой сон сильно меняется или я работаю по сменам.';

  @override
  String get smartPlanDashboardTitle => 'Ваша текущая стратегия';

  @override
  String get smartPlanProfileTitle => 'Ваша стратегия из onboarding';

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
  String get smartPlanHint => 'Позже это можно изменить в настройках.';

  @override
  String get smartPlanWhyRecovery => 'Более мягкое окно лучше для восстановления, стабильности и адаптации.';

  @override
  String get smartPlanWhyActive => 'Ваш уровень активности требует плана, который сохраняет энергию и качество тренировок.';

  @override
  String get smartPlanWhyBeginner => 'Ваша цель и текущий опыт подсказывают, что лучше начать с плана, который легко повторять стабильно.';

  @override
  String get smartPlanWhyBalanced => 'Этот вариант даёт более сильный эффект голодания, но не становится слишком жёстким.';

  @override
  String get smartPlanWhyAggressive => 'Ваш текущий профиль допускает более узкое окно питания, если нужен более быстрый прогресс.';

  @override
  String get smartPlanWhySleep => 'Ваш режим сна лучше сочетается с более ровным планом, который добавляет меньше стресса.';

  @override
  String get smartPlanWhySustainable => 'Устойчивый старт обычно даёт лучшую дисциплину в первые недели.';

  @override
  String smartPlanAlternativeEasier(String plan) {
    return '$plan будет более мягким вариантом, если хотите адаптироваться легче.';
  }

  @override
  String smartPlanAlternativeStronger(String plan) {
    return '$plan будет более сильным вариантом, если хотите более амбициозный режим.';
  }

  @override
  String smartPlanCoachGreeting(String plan, String goal, String experience, String sleep) {
    return 'Я Fasty 🥑. Сейчас у вас план $plan, а главный фокус — $goal. С вашим уровнем $experience и режимом сна $sleep я помогу держать стабильность.';
  }

  @override
  String get smartPlanUseRecommendation => 'Вернуться к умной рекомендации';

  @override
  String get labelAlternative => 'АЛЬТЕРНАТИВА';

  @override
  String perMonthEquivalent(String price, String period) {
    return '~$price/$period';
  }

  @override
  String get circadianProExclusive => 'ТОЛЬКО В PRO';

  @override
  String get circadianStartFast => 'Начать циркадное голодание';

  @override
  String get sunriseLabel => 'Восход';

  @override
  String get sunsetLabel => 'Закат';

  @override
  String get lastMeal => 'Последний прием пищи';

  @override
  String get circadianTotalWindow => 'Общее окно голодания';

  @override
  String get hoursLabel => 'часов';

  @override
  String get basedOnLocalCoordinates => 'На основе ваших координат';

  @override
  String get locationRequiredTitle => 'Нужна геолокация';

  @override
  String get locationRequiredDesc => 'Нам нужна ваша геолокация, чтобы рассчитать точное время заката в вашем городе.';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get circadianStarted => 'Циркадное голодание запущено! 🌅';

  @override
  String get planCircadianTitle => 'Циркадное голодание';

  @override
  String get planCircadianSubtitle => 'Синхронизируйте голодание с солнцем';

  @override
  String get planCustomSubtitle => 'Настройте свое окно';

  @override
  String get planPresets => 'ГОТОВЫЕ ПЛАНЫ';

  @override
  String durationHoursShort(int hours) {
    return '$hoursч';
  }

  @override
  String durationHoursMinutesShort(int hours, int minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String get endFastCongrats => 'У вас получилось! 🎉';

  @override
  String endFastTotalTime(String time) {
    return 'Общее время голодания: $time';
  }

  @override
  String get endFastHowFeel => 'Как вы себя чувствуете?';

  @override
  String get endFastSaveEat => 'Сохранить и поесть';

  @override
  String get endFastKeepFasting => 'Отмена, продолжаю голодать';

  @override
  String get proAccessLabel => 'PRO ДОСТУП';

  @override
  String get timerEndTitle => 'Когда вы прервали голодание?';

  @override
  String get timerCannotStartFuture => 'Нельзя начать голодание в будущем.';

  @override
  String get timerCannotEndFuture => 'Нельзя завершить голодание в будущем.';

  @override
  String get timerEndBeforeStart => 'Время завершения не может быть раньше времени начала.';

  @override
  String get timerGoalReachedExtra => '🔥 Цель достигнута (+ бонус)';

  @override
  String get timerWindowExtended => 'Окно продлено';

  @override
  String get timerRemainingInWindow => 'Осталось в окне';

  @override
  String get timerUnknownPlan => 'Неизвестный план';

  @override
  String get timerLogMoodSymptoms => 'Записать самочувствие и симптомы';

  @override
  String get timerBreakAlreadyActive => 'У вас уже перерыв. Наслаждайтесь отдыхом! ☕';

  @override
  String get timerRestDayStarted => 'Окно питания закрыто. Наслаждайтесь днём отдыха! 🏖️';

  @override
  String get timerTakeBreak => 'Сделать перерыв';

  @override
  String get timerLogStartEarlier => 'Отметить более ранний старт';

  @override
  String get timerLogEndEarlier => 'Отметить более раннее завершение';

  @override
  String get timerLogFastStartEarlier => 'Отметить более ранний старт голодания';

  @override
  String get bodyMeasureChest => 'Грудь';

  @override
  String get bodyMeasureWaist => 'Талия';

  @override
  String get bodyMeasureHips => 'Бёдра';

  @override
  String get bodyMeasureChestTitle => 'Обхват груди (см)';

  @override
  String get bodyMeasureWaistTitle => 'Обхват талии (см)';

  @override
  String get bodyMeasureHipsTitle => 'Обхват бёдер (см)';

  @override
  String get bodyMeasureAdd => 'Добавить';

  @override
  String get drinkWater => 'Вода';

  @override
  String get drinkBlackCoffee => 'Черный кофе';

  @override
  String get drinkLatteSweetCoffee => 'Латте / сладкий кофе';

  @override
  String get drinkGreenBlackTea => 'Зеленый / черный чай';

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
  String get waterBreakFastWarning => 'Этот напиток прервет текущее голодание и автоматически запустит окно питания. Продолжить?';

  @override
  String get waterConfirmDrinkBreakFast => 'Да, я это выпил(а)';

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
  String get learnQuickBites => 'Быстрые темы';

  @override
  String get storyFasting101 => 'Голодание 101';

  @override
  String get storyAutophagy => 'Аутофагия';

  @override
  String get storyKetoDiet => 'Кето-диета';

  @override
  String get storyHydration => 'Гидратация';

  @override
  String get storySleep => 'Сон';

  @override
  String storyOpening(String title) {
    return 'Открываем историю: $title...';
  }

  @override
  String recipeSelected(String title) {
    return 'Выбрано: $title';
  }

  @override
  String get aiUpdatingConfig => 'ИИ обновляет конфигурацию. Проверьте интернет и перезапустите приложение.';

  @override
  String get aiSessionExpired => 'Сессия коуча завершилась. Закройте и снова откройте чат.';

  @override
  String get aiEmptyResponse => 'Я еще думаю над ответом. Попробуйте еще раз.';

  @override
  String get authGoogleFailed => 'Не удалось войти через Google. Попробуйте еще раз.';

  @override
  String get authAppleUnavailable => 'Вход через Apple доступен только на iOS.';

  @override
  String get authAppleFailed => 'Не удалось войти через Apple. Попробуйте еще раз.';

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
  String get disclaimerCheckboxPrefix => 'I agree to the ';

  @override
  String get disclaimerCheckboxLink => 'Medical Disclaimer & Privacy Policy';

  @override
  String get pdfReportTitle => 'Medical Report';

  @override
  String get pdfReportSubtitle => 'Intermittent Fasting Summary';

  @override
  String get pdfReportGenerating => 'Generating your report...';

  @override
  String get pdfReportGenerate => 'Generate PDF Report';

  @override
  String get pdfReportShare => 'Share Report';

  @override
  String get pdfReportPreview => 'Preview Report';

  @override
  String get pdfReportPeriod => 'Report Period';

  @override
  String get pdfReportPeriod7 => 'Last 7 days';

  @override
  String get pdfReportPeriod30 => 'Last 30 days';

  @override
  String get pdfReportPeriodAll => 'All time';

  @override
  String get pdfReportProOnly => 'PDF Reports are a PRO feature';

  @override
  String get pdfReportProDesc => 'Upgrade to PRO to generate and share your personalized fasting reports.';

  @override
  String get pdfReportSectionProfile => 'Personal Profile';

  @override
  String get pdfReportSectionStats => 'Fasting Statistics';

  @override
  String get pdfReportSectionHistory => 'Fasting History';

  @override
  String get pdfReportSectionDisclaimer => 'Medical Disclaimer';

  @override
  String get pdfReportLabelAge => 'Age';

  @override
  String get pdfReportLabelGender => 'Gender';

  @override
  String get pdfReportLabelWeight => 'Weight';

  @override
  String get pdfReportLabelHeight => 'Height';

  @override
  String get pdfReportLabelBmi => 'BMI';

  @override
  String get pdfReportLabelTotalFasts => 'Total Fasts';

  @override
  String get pdfReportLabelTotalHours => 'Total Hours';

  @override
  String get pdfReportLabelAvgDuration => 'Avg Duration';

  @override
  String get pdfReportLabelLongest => 'Longest Fast';

  @override
  String get pdfReportLabelStreak => 'Best Streak';

  @override
  String get pdfReportLabelDate => 'Date';

  @override
  String get pdfReportLabelDuration => 'Duration';

  @override
  String get pdfReportLabelCompleted => 'Completed';

  @override
  String get pdfReportDisclaimerText => 'This report is generated by Fastable and is intended for personal tracking purposes only. It does not constitute medical advice. Please consult a qualified healthcare professional before making any health decisions.';

  @override
  String get pdfReportGeneratedBy => 'Generated by Fastable';

  @override
  String get pdfReportGenderMale => 'Male';

  @override
  String get pdfReportGenderFemale => 'Female';

  @override
  String get pdfReportNoData => 'No fasting records found for the selected period.';

  @override
  String pdfReportHours(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }
}
