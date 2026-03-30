// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'bloc/article/article_bloc.dart' as _i254;
import 'bloc/coach/coach_bloc.dart' as _i635;
import 'bloc/fasting/fasting_bloc.dart' as _i1055;
import 'bloc/history/history_bloc.dart' as _i1037;
import 'bloc/insight/insight_bloc.dart' as _i159;
import 'bloc/pro/pro_bloc.dart' as _i618;
import 'bloc/recipe/recipe_bloc.dart' as _i13;
import 'bloc/settings/settings_bloc.dart' as _i659;
import 'bloc/stats/stats_bloc.dart' as _i764;
import 'bloc/water/water_bloc.dart' as _i257;
import 'bloc/weight/weight_bloc.dart' as _i325;
import 'repositories/article_repository.dart' as _i813;
import 'repositories/history_repository.dart' as _i427;
import 'repositories/recipe_repository.dart' as _i792;
import 'repositories/water_repository.dart' as _i19;
import 'repositories/weight_repository.dart' as _i459;
import 'services/achievement_service.dart' as _i552;
import 'services/ai_service.dart' as _i262;
import 'services/auth_service.dart' as _i706;
import 'services/circadian_service.dart' as _i773;
import 'services/haptic_service.dart' as _i419;
import 'services/health_service.dart' as _i1007;
import 'services/live_activity_services.dart' as _i37;
import 'services/notification_service.dart' as _i98;
import 'services/pro_service.dart' as _i78;
import 'services/sound_service.dart' as _i743;
import 'services/storage_service.dart' as _i318;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i813.ArticleRepository>(() => _i813.ArticleRepository());
    gh.lazySingleton<_i427.HistoryRepository>(
      () => _i427.HistoryRepository(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i792.RecipeRepository>(() => _i792.RecipeRepository());
    gh.lazySingleton<_i19.WaterRepository>(() => _i19.WaterRepository());
    gh.lazySingleton<_i459.WeightRepository>(() => _i459.WeightRepository());
    gh.lazySingleton<_i552.AchievementService>(
      () => _i552.AchievementService(),
    );
    gh.lazySingleton<_i262.AiService>(() => _i262.AiService());
    gh.lazySingleton<_i706.AuthService>(() => _i706.AuthService());
    gh.lazySingleton<_i773.CircadianService>(() => _i773.CircadianService());
    gh.lazySingleton<_i419.HapticService>(() => _i419.HapticService());
    gh.lazySingleton<_i1007.HealthService>(() => _i1007.HealthService());
    gh.lazySingleton<_i37.LiveActivityService>(
      () => _i37.LiveActivityService(),
    );
    gh.lazySingleton<_i98.NotificationService>(
      () => _i98.NotificationService(),
    );
    gh.lazySingleton<_i78.ProService>(() => _i78.ProService());
    gh.lazySingleton<_i743.SoundService>(() => _i743.SoundService());
    gh.lazySingleton<_i318.StorageService>(() => _i318.StorageService());
    gh.factory<_i1037.HistoryBloc>(
      () => _i1037.HistoryBloc(gh<_i427.HistoryRepository>()),
    );
    gh.factory<_i257.WaterBloc>(
      () => _i257.WaterBloc(
        gh<_i19.WaterRepository>(),
        gh<_i1007.HealthService>(),
      ),
    );
    gh.factory<_i13.RecipeBloc>(
      () => _i13.RecipeBloc(gh<_i792.RecipeRepository>()),
    );
    gh.factory<_i618.ProBloc>(() => _i618.ProBloc(gh<_i78.ProService>()));
    gh.factory<_i659.SettingsBloc>(
      () => _i659.SettingsBloc(
        gh<_i1007.HealthService>(),
        gh<_i98.NotificationService>(),
        gh<_i318.StorageService>(),
      ),
    );
    gh.factory<_i764.StatsBloc>(
      () => _i764.StatsBloc(
        gh<_i427.HistoryRepository>(),
        gh<_i552.AchievementService>(),
      ),
    );
    gh.factory<_i325.WeightBloc>(
      () => _i325.WeightBloc(
        gh<_i459.WeightRepository>(),
        gh<_i1007.HealthService>(),
      ),
    );
    gh.factory<_i1055.FastingBloc>(
      () => _i1055.FastingBloc(
        gh<_i98.NotificationService>(),
        gh<_i419.HapticService>(),
        gh<_i427.HistoryRepository>(),
        gh<_i37.LiveActivityService>(),
        gh<_i773.CircadianService>(),
        gh<_i318.StorageService>(),
      ),
    );
    gh.factory<_i159.InsightBloc>(
      () => _i159.InsightBloc(
        gh<_i262.AiService>(),
        gh<_i427.HistoryRepository>(),
        gh<_i459.WeightRepository>(),
      ),
    );
    gh.factory<_i635.CoachBloc>(() => _i635.CoachBloc(gh<_i262.AiService>()));
    gh.factory<_i254.ArticleBloc>(
      () => _i254.ArticleBloc(gh<_i813.ArticleRepository>()),
    );
    return this;
  }
}
