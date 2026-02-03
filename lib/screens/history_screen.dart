import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// DI & Bloc
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_event.dart';
import 'package:fastable/bloc/history/history_state.dart';
import 'package:fastable/services/haptic_service.dart';

// Models
import 'package:fastable/models/fasting_record.dart';

// Repo
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/water_repository.dart';

// Widgets
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryRepository historyRepository;
  final WaterRepository waterRepository;

  const HistoryScreen({
    super.key,
    required this.historyRepository,
    required this.waterRepository,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => getIt<HistoryBloc>()..add(SubscribeHistory()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ЗАГОЛОВОК
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      l10n.navHistory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // СТАТИСТИКА (HEADER)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    final totalHours = state.totalFastingTime.inHours;
                    final totalFasts = state.records.length;

                    return GlassCard(
                      // FIX: Убрали фиксированную высоту (height: 100), чтобы не было Overflow
                      // Теперь высота зависит от контента + отступов
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(totalFasts.toString(), "Total Fasts", Colors.blueAccent),
                          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                          _buildStatItem("$totalHours h", "Total Hours", Colors.greenAccent),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // СПИСОК
              Expanded(
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state.status == HistoryStatus.loading) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (state.records.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 64, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text(
                              "No history yet",
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: state.records.length,
                      itemBuilder: (context, index) {
                        final record = state.records[index];
                        return _buildHistoryItem(context, record, l10n);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min, // FIX: Занимаем минимум места по вертикали
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, FastingRecord record, AppLocalizations l10n) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final duration = record.duration;

    Color iconColor = Colors.blueAccent;
    if (duration.inHours >= 16) iconColor = Colors.greenAccent;
    if (duration.inHours >= 20) iconColor = Colors.orangeAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(record.startTime.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (direction) {
          getIt<HapticService>().mediumImpact();
          context.read<HistoryBloc>().add(DeleteRecordEvent(record));
        },
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${duration.inHours}h",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(record.startTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${timeFormat.format(record.startTime)} - ${timeFormat.format(record.endTime)}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}