import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_event.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_event.dart';
import 'package:fastable/bloc/stats/stats_bloc.dart';
import 'package:fastable/bloc/stats/stats_event.dart';
import 'package:fastable/bloc/water/water_bloc.dart';
import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/onboarding_profile/onboarding_profile_cubit.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/repositories/history_repository.dart';

class AppSessionRefresh {
  const AppSessionRefresh._();

  static Future<void> refresh(BuildContext context) async {
    await getIt<HistoryRepository>().getAllRecords();

    if (!context.mounted) return;

    _dispatch(() => context.read<SettingsBloc>().add(LoadSettings()));
    _dispatch(() => context.read<FastingBloc>().add(CheckFastingState()));
    _dispatch(() => context.read<HistoryBloc>().add(SubscribeHistory()));
    _dispatch(() => context.read<WeightBloc>().add(LoadWeightData()));
    _dispatch(() => context.read<WaterBloc>().add(LoadWaterData()));
    _dispatch(() => context.read<StatsBloc>().add(LoadStats()));
    _dispatch(() => context.read<ProBloc>().add(CheckProStatus()));
    _dispatch(() => context.read<OnboardingProfileCubit>().load());
  }

  static void _dispatch(VoidCallback action) {
    try {
      action();
    } catch (_) {
      // Some screens can be outside parts of the root tree during auth flows.
    }
  }
}
