import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// DI & Bloc
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_event.dart';
import 'package:fastable/bloc/history/history_state.dart';
import 'package:fastable/services/haptic_service.dart';

// Models
import 'package:fastable/models/fasting_record.dart';

// Widgets
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

              // 1. Точки для календаря
              final fastingDatesSet = state.records.map((r) {
                return DateTime(r.endTime.year, r.endTime.month, r.endTime.day);
              }).toSet();

              // 2. Фильтрация списка
              final filteredRecords = state.records.where((r) {
                final rDate = DateTime(r.endTime.year, r.endTime.month, r.endTime.day);
                return rDate.isAtSameMomentAs(_selectedDate);
              }).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // --- ЗАГОЛОВОК ---
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        l10n.navHistory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),

                  // --- КАЛЕНДАРЬ ---
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _ModernCalendar(
                          selectedDate: _selectedDate,
                          fastingDays: fastingDatesSet,
                          onDateSelected: _onDateSelected,
                          locale: l10n.localeName,
                        ),
                      ),
                    ),
                  ),

                  // --- ГРАФИК ---
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.lblConsistency, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 100,
                              // 🔥 ИСПРАВЛЕНИЕ: Передаем l10n сюда
                              child: BarChart(_buildWeeklyChartData(state.records, l10n)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- ЗАГОЛОВОК ДНЯ ---
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        DateFormat('EEEE, d MMMM', l10n.localeName).format(_selectedDate).toUpperCase(),
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ),
                  ),

                  // --- СПИСОК ---
                  if (filteredRecords.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.calendar_view_day_rounded, color: Colors.white.withOpacity(0.1), size: 48),
                              const SizedBox(height: 12),
                              Text(l10n.lblNoRecordsForDay, style: TextStyle(color: Colors.white.withOpacity(0.3))),
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

                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- CHART LOGIC ---
  // 🔥 ИСПРАВЛЕНИЕ: Добавлен аргумент l10n
  BarChartData _buildWeeklyChartData(List<FastingRecord> records, AppLocalizations l10n) {
    Map<int, double> last7Days = {};
    for (int i = 0; i < 7; i++) last7Days[i] = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var record in records) {
      final recordDate = DateTime(record.endTime.year, record.endTime.month, record.endTime.day);
      final diff = today.difference(recordDate).inDays;
      if (diff < 7 && diff >= 0) {
        int index = 6 - diff;
        last7Days[index] = (last7Days[index] ?? 0) + record.duration.inMinutes / 60.0;
      }
    }

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < 7; i++) {
      double value = last7Days[i] ?? 0;
      double displayValue = value > 24 ? 24 : value;
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: displayValue,
            gradient: LinearGradient(
              colors: value >= 16
                  ? [const Color(0xFF43C6AC), const Color(0xFF191654)]
                  : [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
            width: 12, borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(show: true, toY: 16, color: Colors.white.withOpacity(0.05)),
          ),
        ],
      ));
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      maxY: 24,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: const Color(0xFF1E1E1E),
          getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem("${rod.toY.toStringAsFixed(1)}h", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
          final date = now.subtract(Duration(days: 6 - value.toInt()));
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            // 🔥 Теперь l10n доступен здесь
            child: Text(DateFormat('E', l10n.localeName).format(date), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
          );
        })),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: barGroups,
    );
  }

  // --- ITEM WIDGET ---
  Widget _buildHistoryItem(BuildContext context, FastingRecord record, HapticService haptic, AppLocalizations l10n) {
    final duration = record.duration;
    final timeFormat = DateFormat('HH:mm');
    final type = _getFastingType(duration.inHours, l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(record.startTime.toIso8601String()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
        ),
        onDismissed: (_) {
          haptic.mediumImpact();
          context.read<HistoryBloc>().add(DeleteRecordEvent(record));
        },
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, decoration: BoxDecoration(color: _getStatusColor(duration.inHours), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("${duration.inHours}h ${duration.inMinutes % 60}m", style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(type, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("${timeFormat.format(record.startTime)} — ${timeFormat.format(record.endTime)}", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                    ],
                  ),
                ),
                if (record.mood != null) Text(_getMoodEmoji(record.mood), style: const TextStyle(fontSize: 22))
                else Icon(Icons.check_circle, color: Colors.white.withOpacity(0.1), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---
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
      case FastingMood.bad: return "😐";
      case FastingMood.neutral: return "🙂";
      case FastingMood.good: return "😁";
      case FastingMood.great: return "🔥";
      default: return "";
    }
  }
}

// --------------------------------------------------------------------------
// 🔥 MODERN CALENDAR (LLLL FIX)
// --------------------------------------------------------------------------

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
        // --- HEADER ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white70),
                onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
              ),
              // Анимированный текст месяца
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  DateFormat('LLLL yyyy', widget.locale).format(_currentMonth).toUpperCase(),
                  key: ValueKey(_currentMonth),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white70),
                onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // --- ДНИ НЕДЕЛИ ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildWeekDays(),
          ),
        ),
        const SizedBox(height: 8),

        // --- СЕТКА ---
        SizedBox(
          height: 260,
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
    // Находим понедельник, чтобы правильно отобразить дни недели
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      return SizedBox(
        width: 40,
        child: Center(
          child: Text(
            DateFormat('E', widget.locale).format(date).toUpperCase(),
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Colors.blueAccent, Color(0xFF43C6AC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : (isToday ? Colors.white.withOpacity(0.1) : Colors.transparent),
          shape: BoxShape.circle,
          border: (isToday && !isSelected) ? Border.all(color: Colors.white.withOpacity(0.3), width: 1) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "$day",
              style: TextStyle(
                color: isSelected ? Colors.white : (isToday ? Colors.white : Colors.white70),
                fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            if (hasFasting)
              Positioned(
                bottom: 6,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFF43C6AC),
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(color: const Color(0xFF43C6AC).withOpacity(0.5), blurRadius: 4)
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