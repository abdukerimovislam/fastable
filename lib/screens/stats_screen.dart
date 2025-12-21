import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/widgets/glass_card.dart';

class StatsScreen extends StatefulWidget {
  final HistoryRepository repository;

  const StatsScreen({super.key, required this.repository});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // Кэшируем поток
  late Stream<List<FastingRecord>> _recordsStream;

  @override
  void initState() {
    super.initState();
    _recordsStream = widget.repository.getRecordsStream();
  }

  Color _getRateColor(double rate) {
    if (rate >= 80) return Colors.greenAccent;
    if (rate >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder<List<FastingRecord>>(
          stream: _recordsStream, // Используем кэшированный поток
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
            }

            final records = snapshot.data ?? [];

            // --- РАСЧЕТЫ СТАТИСТИКИ ---
            final int totalFasts = records.length;
            final int totalMinutes = records.fold(0, (sum, item) => sum + item.duration.inMinutes);
            final double totalHours = totalMinutes / 60;
            final double avgHours = totalFasts > 0 ? totalHours / totalFasts : 0;

            double maxHours = 0;
            if (records.isNotEmpty) {
              final maxDuration = records.reduce((a, b) => a.duration > b.duration ? a : b).duration;
              maxHours = maxDuration.inMinutes / 60;
            }

            final int successCount = records.where((r) => r.duration.inHours >= 16).length;
            final double successRate = totalFasts > 0 ? (successCount / totalFasts) * 100 : 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.navStats,
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // ГЛАВНАЯ КАРТОЧКА: SUCCESS RATE
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 80, height: 80,
                                  child: CircularProgressIndicator(
                                    value: successRate / 100,
                                    backgroundColor: Colors.white10,
                                    color: _getRateColor(successRate),
                                    strokeWidth: 8,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "${successRate.toInt()}%",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.statsSuccessRate,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                totalFasts > 0
                                    ? l10n.statsSuccessDesc(successCount, totalFasts)
                                    : "Start your first fast!",
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // СЕТКА С ДРУГИМИ ДАННЫМИ
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(l10n.statsTotalFasts, "$totalFasts", Icons.check_circle_outline, Colors.blueAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(l10n.statsTotalHours, totalHours.toStringAsFixed(1), Icons.access_time, Colors.purpleAccent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(l10n.statsAverage, "${avgHours.toStringAsFixed(1)} h", Icons.functions, Colors.orangeAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(l10n.statsLongest, "${maxHours.toStringAsFixed(1)} h", Icons.emoji_events_outlined, Colors.yellowAccent)),
                    ],
                  ),

                  const SizedBox(height: 30),

                  if (records.isNotEmpty) ...[
                    Text(
                      "History Trend",
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _buildChartBars(records),
                      ),
                    ),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars(List<FastingRecord> records) {
    final recent = records.take(7).toList().reversed.toList();
    if (recent.isEmpty) return [];

    double maxH = recent.map((e) => e.duration.inMinutes.toDouble()).reduce((a, b) => a > b ? a : b);
    if (maxH == 0) maxH = 1;

    return recent.map((record) {
      final hours = record.duration.inMinutes / 60;
      final double percentage = (record.duration.inMinutes / maxH).clamp(0.1, 1.0);
      final bool isSuccess = hours >= 16;

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(hours.toStringAsFixed(0), style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 4),
          Container(
            width: 16,
            height: 100 * percentage,
            decoration: BoxDecoration(
              color: isSuccess ? Colors.greenAccent : Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
}