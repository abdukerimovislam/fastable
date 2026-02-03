import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/injection.config.dart';

// СЕРВИСЫ (Legacy - если у них нет аннотаций, регистрируем руками)
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/services/firestore_service.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/locale_service.dart';

// РЕПОЗИТОРИИ ИМПОРТИРОВАТЬ НЕ НУЖНО
// Injectable сам найдет их благодаря аннотациям @lazySingleton

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // 1. Инициализация ВСЕХ сгенерированных зависимостей
  // (теперь это включает: Repositories, BLoCs, ProService и т.д.)
  getIt.init();

  // 2. Регистрация Legacy Сервисов
  // (Оставляем только те, у которых нет @lazySingleton внутри файла класса)

  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerLazySingleton<AuthService>(() => AuthService());
  }
  if (!getIt.isRegistered<FirestoreService>()) {
    getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
  }
  if (!getIt.isRegistered<NotificationService>()) {
    getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  }
  if (!getIt.isRegistered<LocaleService>()) {
    getIt.registerLazySingleton<LocaleService>(() => LocaleService());
  }
}