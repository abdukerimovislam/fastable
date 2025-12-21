import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryRepository historyRepository;
  final WaterRepository waterRepository;

  const HistoryScreen({
    super.key,
    required this.historyRepository,
    required this.waterRepository,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Храним поток в переменной, чтобы не пересоздавать его при каждом build
  late Stream<List<FastingRecord>> _recordsStream;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Инициализация потока один раз
    _recordsStream = widget.historyRepository.getRecordsStream();
  }

  Future<void> _deleteRecord(FastingRecord record) async {
    await widget.historyRepository.deleteRecord(record);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Record deleted"),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: "Undo",
            textColor: Colors.white,
            onPressed: () async {
              await widget.historyRepository.addRecord(record);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<FastingRecord>>(
      stream: _recordsStream, // Используем сохраненный поток
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent, // Transparent для MeshBackground
            body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
          );
        }

        final allRecords = snapshot.data ?? [];

        final selectedDayRecords = allRecords.where((record) {
          if (_selectedDay == null) return true;
          return isSameDay(record.endTime, _selectedDay) || isSameDay(record.startTime, _selectedDay);
        }).toList();

        selectedDayRecords.sort((a, b) => b.endTime.compareTo(a.endTime));

        List<FastingRecord> getEventsForDay(DateTime day) {
          return allRecords.where((record) {
            return isSameDay(record.endTime, day);
          }).toList();
        }

        return Scaffold(
          backgroundColor: Colors.transparent, // Важно для MeshBackground
          body: SafeArea( // MeshBackground уже есть в HomePage, тут нужен только контент?
            // Если HistoryScreen используется внутри MeshBackground в HomePage,
            // то тут MeshBackground не нужен.
            // В HomePage у нас: body: MeshBackground( child: IndexedStack(...) )
            // Значит здесь фон должен быть прозрачным.
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    l10n?.navHistory ?? "History",
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TableCalendar<FastingRecord>(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white70),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white70),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: const TextStyle(color: Colors.white),
                        weekendTextStyle: const TextStyle(color: Colors.white70),
                        outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                        selectedDecoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                        todayDecoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.3), shape: BoxShape.circle),
                        markerDecoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                      ),
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() => _calendarFormat = format);
                        }
                      },
                      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                      eventLoader: getEventsForDay,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDay != null ? DateFormat('EEEE, d MMM').format(_selectedDay!) : "All Records",
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      if (selectedDayRecords.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            "${selectedDayRecords.length} records",
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: selectedDayRecords.isEmpty
                      ? _buildEmptyDayState()
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: selectedDayRecords.length,
                    itemBuilder: (context, index) {
                      return _buildRecordItem(selectedDayRecords[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyDayState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.nights_stay_outlined, size: 48, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          Text(
            "Rest Day",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "No fasts recorded for this day.",
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(FastingRecord record) {
    final durationHours = record.duration.inHours;
    final durationMinutes = record.duration.inMinutes.remainder(60);
    final startTimeStr = DateFormat('HH:mm').format(record.startTime);
    final endTimeStr = DateFormat('HH:mm').format(record.endTime);
    final isLongFast = durationHours >= 16;

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
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        onDismissed: (_) => _deleteRecord(record),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          color: isLongFast ? Colors.amber.withOpacity(0.08) : null,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLongFast ? Colors.amber.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLongFast ? Icons.emoji_events : Icons.history_toggle_off,
                  color: isLongFast ? Colors.amber : Colors.blueAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${durationHours}h ${durationMinutes > 0 ? '${durationMinutes}m' : ''}",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (isLongFast) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$startTimeStr - $endTimeStr",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }
}