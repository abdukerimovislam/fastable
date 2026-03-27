import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_event.dart';
import 'package:fastable/bloc/history/history_state.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
    getIt<HapticService>().lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final haptic = getIt<HapticService>();

    return BlocProvider(
      create: (context) => getIt<HistoryBloc>()..add(SubscribeHistory()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              if (state.status == HistoryStatus.loading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white24));
              }

              final fastingDatesSet = state.records.map((r) {
                return DateTime(r.endTime.year, r.endTime.month, r.endTime.day);
              }).toSet();

              final filteredRecords = state.records.where((r) {
                final rDate = DateTime(r.endTime.year, r.endTime.month, r.endTime.day);
                return rDate.isAtSameMomentAs(_selectedDate);
              }).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // --- ЗАГОЛОВОК ---
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.navHistory,
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.analytics_rounded, color: Colors.white54, size: 22),
                          )
                        ],
                      ),
                    ),
                  ),

                  // --- КАЛЕНДАРЬ ---
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                        borderRadius: BorderRadius.circular(24),
                        child: _ModernCalendar(
                          selectedDate: _selectedDate,
                          fastingDays: fastingDatesSet,
                          onDateSelected: _onDateSelected,
                          locale: l10n.localeName,
                        ),
                      ),
                    ),
                  ),

                  // --- ГРАФИК КОНСИСТЕНТНОСТИ ---
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.bar_chart_rounded, color: Color(0xFF43C6AC), size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.lblConsistency, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 140,
                              child: BarChart(_buildWeeklyChartData(state.records, l10n)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- ЗАГОЛОВОК СПИСКА ---
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Text(
                            DateFormat('EEEE, d MMMM', l10n.localeName).format(_selectedDate).toUpperCase(),
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          const Spacer(),
                          Text(
                            "${filteredRecords.length} sessions",
                            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                  ),

                  // --- СПИСОК ИЛИ ЗАГЛУШКА ---
                  if (filteredRecords.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 60),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle),
                                child: Icon(Icons.calendar_view_day_rounded, color: Colors.white.withOpacity(0.1), size: 40),
                              ),
                              const SizedBox(height: 16),
                              Text(l10n.lblNoRecordsForDay, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final record = filteredRecords[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildHistoryItem(context, record, haptic, l10n),
                          );
                        },
                        childCount: filteredRecords.length,
                      ),
                    ),

                  SliverPadding(padding: EdgeInsets.only(bottom: 120 + MediaQuery.of(context).padding.bottom)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- ГРАФИК ---
  BarChartData _buildWeeklyChartData(List<FastingRecord> records, AppLocalizations l10n) {
    Map<int, double> last7DaysDuration = {for (int i = 0; i < 7; i++) i: 0};
    Map<int, List<FastingRecord>> last7DaysRecords = {for (int i = 0; i < 7; i++) i: []};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var record in records) {
      final recordDate = DateTime(record.endTime.year, record.endTime.month, record.endTime.day);
      final diff = today.difference(recordDate).inDays;
      if (diff < 7 && diff >= 0) {
        int index = 6 - diff;
        last7DaysDuration[index] = (last7DaysDuration[index] ?? 0) + record.duration.inMinutes / 60.0;
        last7DaysRecords[index]!.add(record);
      }
    }

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < 7; i++) {
      double value = last7DaysDuration[i] ?? 0;
      double displayValue = value > 24 ? 24 : value;
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: displayValue,
            gradient: LinearGradient(
              colors: value >= 16
                  ? [const Color(0xFF43C6AC), const Color(0xFF191654)]
                  : [Colors.blueAccent.withOpacity(0.8), Colors.purpleAccent.withOpacity(0.6)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
            width: 14,
            borderRadius: BorderRadius.circular(7),
            backDrawRodData: BackgroundBarChartRodData(show: true, toY: 16, color: Colors.white.withOpacity(0.04)),
          ),
        ],
      ));
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      maxY: 24,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => const Color(0xFF2A2A2A),
          // 🔥 ИСПРАВЛЕНИЕ: Убрали tooltipRoundedRadius
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final dayRecords = last7DaysRecords[group.x.toInt()]!;

            List<String> notes = [];
            String moodEmojis = "";

            for(var r in dayRecords) {
              if (r.mood != null) moodEmojis += _getMoodEmoji(r.mood);
              if (r.note != null && r.note!.isNotEmpty) {
                notes.add(r.note!.replaceAll("Symptoms: ", ""));
              }
            }

            return BarTooltipItem(
                "${rod.toY.toStringAsFixed(1)}h\n",
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                children: [
                  if (moodEmojis.isNotEmpty)
                    TextSpan(text: "$moodEmojis\n", style: const TextStyle(fontSize: 16)),
                  if (notes.isNotEmpty)
                    TextSpan(
                        text: notes.join(", "),
                        style: const TextStyle(color: Color(0xFF43C6AC), fontSize: 11, fontWeight: FontWeight.w600)
                    )
                ]
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
          final date = now.subtract(Duration(days: 6 - value.toInt()));
          final isToday = value.toInt() == 6;
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
                DateFormat('E', l10n.localeName).format(date),
                style: TextStyle(
                    color: isToday ? const Color(0xFF43C6AC) : Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.w900 : FontWeight.w600
                )
            ),
          );
        })),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: barGroups,
    );
  }

  // --- КАРТОЧКА ИСТОРИИ ---
  Widget _buildHistoryItem(BuildContext context, FastingRecord record, HapticService haptic, AppLocalizations l10n) {
    final duration = record.duration;
    final timeFormat = DateFormat('HH:mm');
    final type = _getFastingType(duration.inHours, l10n);

    final hasSymptoms = record.note != null && record.note!.isNotEmpty;
    final symptomsText = hasSymptoms ? record.note!.replaceAll("Symptoms: ", "") : "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(record.startTime.toIso8601String()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
        ),
        onDismissed: (_) {
          haptic.mediumImpact();
          context.read<HistoryBloc>().add(DeleteRecordEvent(record));
        },
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Container(width: 4, decoration: BoxDecoration(color: _getStatusColor(duration.inHours), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("${duration.inHours}h ${duration.inMinutes % 60}m", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                                child: Text(type, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text("${timeFormat.format(record.startTime)} — ${timeFormat.format(record.endTime)}", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    if (record.mood != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                        child: Text(_getMoodEmoji(record.mood), style: const TextStyle(fontSize: 20)),
                      )
                    else
                      Icon(Icons.check_circle_rounded, color: Colors.white.withOpacity(0.05), size: 28),
                  ],
                ),
              ),
              if (hasSymptoms) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43C6AC).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF43C6AC).withOpacity(0.1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFF43C6AC), size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(symptomsText, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getFastingType(int hours, AppLocalizations l10n) {
    if (hours < 13) return l10n.lblFastingTypeCircadian;
    if (hours < 16) return "13:11";
    if (hours < 18) return "16:8";
    if (hours < 20) return "18:6";
    if (hours < 24) return l10n.lblFastingTypeWarrior;
    return l10n.lblFastingTypeOmad;
  }

  Color _getStatusColor(int hours) {
    if (hours < 16) return Colors.blueAccent;
    if (hours < 20) return const Color(0xFF43C6AC);
    return const Color(0xFFF9D423);
  }

  String _getMoodEmoji(FastingMood? mood) {
    switch (mood) {
      case FastingMood.terrible: return "😫";
      case FastingMood.bad: return "😕";
      case FastingMood.neutral: return "😐";
      case FastingMood.good: return "🙂";
      case FastingMood.great: return "🤩";
      default: return "";
    }
  }
}

// --- ПРЕМИАЛЬНЫЙ КАЛЕНДАРЬ ---
class _ModernCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Set<DateTime> fastingDays;
  final Function(DateTime) onDateSelected;
  final String locale;

  const _ModernCalendar({
    required this.selectedDate,
    required this.fastingDays,
    required this.onDateSelected,
    required this.locale,
  });

  @override
  State<_ModernCalendar> createState() => _ModernCalendarState();
}

class _ModernCalendarState extends State<_ModernCalendar> {
  late PageController _pageController;
  final int _initialPage = 1000;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
    _pageController = PageController(initialPage: _initialPage);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentMonth = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month + (index - _initialPage),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 24),
                  onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  DateFormat('MMMM yyyy', widget.locale).format(_currentMonth),
                  key: ValueKey(_currentMonth),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 24),
                  onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildWeekDays(),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final month = DateTime(
                widget.selectedDate.year,
                widget.selectedDate.month + (index - _initialPage),
              );
              return _buildMonthGrid(month);
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      return SizedBox(
        width: 40,
        child: Center(
          child: Text(
            DateFormat('E', widget.locale).format(date).toUpperCase(),
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0),
          ),
        ),
      );
    });
  }

  Widget _buildMonthGrid(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final int weekdayOffset = firstDayOfMonth.weekday - 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 0,
        childAspectRatio: 1.0,
      ),
      itemCount: daysInMonth + weekdayOffset,
      itemBuilder: (context, index) {
        if (index < weekdayOffset) {
          return const SizedBox();
        }

        final day = index - weekdayOffset + 1;
        final date = DateTime(month.year, month.month, day);
        final isSelected = DateUtils.isSameDay(date, widget.selectedDate);
        final isToday = DateUtils.isSameDay(date, DateTime.now());
        final hasFasting = widget.fastingDays.any((d) => DateUtils.isSameDay(d, date));

        return GestureDetector(
          onTap: () => widget.onDateSelected(date),
          child: _buildDayItem(day, isSelected, isToday, hasFasting),
        );
      },
    );
  }

  Widget _buildDayItem(int day, bool isSelected, bool isToday, bool hasFasting) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Colors.blueAccent, Color(0xFF43C6AC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : (isToday ? Colors.white.withOpacity(0.08) : Colors.transparent),
          shape: BoxShape.circle,
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF43C6AC).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
          border: (isToday && !isSelected) ? Border.all(color: Colors.white.withOpacity(0.2), width: 1) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "$day",
              style: TextStyle(
                color: isSelected ? Colors.white : (isToday ? Colors.white : Colors.white.withOpacity(0.8)),
                fontWeight: (isSelected || isToday) ? FontWeight.w800 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
            if (hasFasting)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFF43C6AC),
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(color: const Color(0xFF43C6AC).withOpacity(0.8), blurRadius: 6, spreadRadius: 1)
                      ]
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}