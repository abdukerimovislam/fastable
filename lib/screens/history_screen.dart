import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryRepository? historyRepository;
  final WaterRepository? waterRepository;

  const HistoryScreen({
    super.key,
    this.historyRepository,
    this.waterRepository,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryRepository _historyRepo = widget.historyRepository ?? HistoryRepository();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<FastingRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    // ИСПРАВЛЕНИЕ 1: Используем loadRecords вместо getAllRecords
    final records = await _historyRepo.loadRecords();
    setState(() {
      _records = records;
    });
  }

  List<FastingRecord> _getEventsForDay(DateTime day) {
    return _records.where((record) {
      return isSameDay(record.startTime, day) || isSameDay(record.endTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ВАЖНО: Scaffold прозрачный, чтобы был виден MeshBackground из HomePage
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    "History",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),

            // КАЛЕНДАРЬ В СТЕКЛЕ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                padding: const EdgeInsets.only(bottom: 10),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,

                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    weekendStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.2)),

                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFFFF4E50),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFFF9D423),
                      shape: BoxShape.circle,
                    ),
                  ),

                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                  eventLoader: _getEventsForDay,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // СПИСОК ЗАПИСЕЙ
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _getEventsForDay(_selectedDay!).length,
                itemBuilder: (context, index) {
                  final record = _getEventsForDay(_selectedDay!)[index];
                  final duration = record.duration;
                  final hours = duration.inHours;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: hours >= 16
                                    ? [const Color(0xFFFF4E50), const Color(0xFFF9D423)]
                                    : [Colors.blueGrey, Colors.grey],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${hours}h Fast",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  "${DateFormat.Hm().format(record.startTime)} - ${DateFormat.Hm().format(record.endTime)}",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          // ИСПРАВЛЕНИЕ 2: Убрали обращение к record.rating, так как поля нет
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}