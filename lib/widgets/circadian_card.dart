import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fastable/services/circadian_service.dart';
import 'package:fastable/widgets/glass_card.dart';

class CircadianCard extends StatefulWidget {
  final VoidCallback onClose; // Чтобы выключить режим

  const CircadianCard({super.key, required this.onClose});

  @override
  State<CircadianCard> createState() => _CircadianCardState();
}

class _CircadianCardState extends State<CircadianCard> {
  final CircadianService _service = CircadianService();
  CircadianData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.getCircadianData();
    if (mounted) {
      setState(() {
        _data = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const GlassCard(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator(color: Colors.orange)),
        ),
      );
    }

    if (_data == null) {
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.location_disabled, color: Colors.grey),
              const SizedBox(width: 12),
              const Expanded(child: Text("Enable location to see Circadian data.", style: TextStyle(color: Colors.white70))),
              IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close, color: Colors.white54)),
            ],
          ),
        ),
      );
    }

    // Цвета для разных фаз
    Color phaseColor;
    IconData phaseIcon;
    switch (_data!.currentPhase) {
      case CircadianPhase.sunrise:
        phaseColor = Colors.orangeAccent;
        phaseIcon = Icons.wb_twilight;
        break;
      case CircadianPhase.day:
        phaseColor = Colors.yellowAccent;
        phaseIcon = Icons.wb_sunny;
        break;
      case CircadianPhase.sunset:
        phaseColor = Colors.deepOrangeAccent;
        phaseIcon = Icons.wb_twilight;
        break;
      case CircadianPhase.evening:
        phaseColor = Colors.purpleAccent;
        phaseIcon = Icons.nights_stay;
        break;
      case CircadianPhase.night:
        phaseColor = Colors.blueGrey;
        phaseIcon = Icons.bedtime;
        break;
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      color: phaseColor.withOpacity(0.1),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ЗАГОЛОВОК ФАЗЫ
                Row(
                  children: [
                    Icon(phaseIcon, color: phaseColor, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      _data!.phaseName,
                      style: TextStyle(color: phaseColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    // Время заката/восхода
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSunTime(Icons.wb_sunny_rounded, "Sunrise", _data!.sunrise),
                        const SizedBox(height: 4),
                        _buildSunTime(Icons.nights_stay_rounded, "Sunset", _data!.sunset),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ПРОГРЕСС БАР ДНЯ
                _buildDayProgressBar(),

                const SizedBox(height: 16),

                // СОВЕТ
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: phaseColor, width: 3)),
                  ),
                  child: Text(
                    _data!.advice,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          // Кнопка закрытия
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunTime(IconData icon, String label, DateTime time) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 12),
        const SizedBox(width: 4),
        Text(
          DateFormat('HH:mm').format(time),
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDayProgressBar() {
    final now = DateTime.now();
    // Нормализуем день: 0.0 (полночь) -> 1.0 (следующая полночь)
    final double progress = (now.hour * 60 + now.minute) / (24 * 60);

    // Позиции солнца и заката (примерно)
    double sunStart = (_data!.sunrise.hour * 60 + _data!.sunrise.minute) / (24 * 60);
    double sunEnd = (_data!.sunset.hour * 60 + _data!.sunset.minute) / (24 * 60);

    return Column(
      children: [
        SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                // Фон (Ночь)
                Container(color: Colors.blueGrey.withOpacity(0.3)),
                // День (Желтая полоса)
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.85 * sunStart, // approximate width logic
                  width: MediaQuery.of(context).size.width * 0.85 * (sunEnd - sunStart),
                  top: 0, bottom: 0,
                  child: Container(color: Colors.orangeAccent.withOpacity(0.3)),
                ),
                // Текущее время (Бегунок)
                Align(
                  alignment: Alignment(progress * 2 - 1, 0), // -1 to 1
                  child: Container(
                    width: 12, height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.white, blurRadius: 5)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("00:00", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10)),
            Text("12:00", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10)),
            Text("23:59", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10)),
          ],
        )
      ],
    );
  }
}