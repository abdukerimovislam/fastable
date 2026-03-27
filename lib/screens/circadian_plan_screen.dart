import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/circadian_service.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';

class CircadianPlanScreen extends StatefulWidget {
  const CircadianPlanScreen({super.key});

  @override
  State<CircadianPlanScreen> createState() => _CircadianPlanScreenState();
}

class _CircadianPlanScreenState extends State<CircadianPlanScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  SunriseSunsetResult? _sunTimes;

  @override
  void initState() {
    super.initState();
    _fetchSunTimes();
  }

  Future<void> _fetchSunTimes() async {
    setState(() { _isLoading = true; _hasError = false; });
    final times = await getIt<CircadianService>().getTodaySunTimes();

    if (mounted) {
      setState(() {
        _sunTimes = times;
        _isLoading = false;
        _hasError = times == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      isFasting: false, // Фон с оранжево-фиолетовыми закатными тонами
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Circadian Rhythm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- PRO БЕЙДЖ ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        SizedBox(width: 6),
                        Text("PRO EXCLUSIVE", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Align with Nature",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
                ),
                const SizedBox(height: 12),
                Text(
                  "Stop eating when the sun goes down to optimize your metabolism, improve sleep, and sync with your natural circadian clock.",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 40),

                // --- КАРТОЧКА С РЕЗУЛЬТАТАМИ ---
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                        : _hasError
                        ? _buildErrorState()
                        : _buildSunData(),
                  ),
                ),

                const SizedBox(height: 24),

                // --- КНОПКА СТАРТА ---
                ElevatedButton(
                  onPressed: _isLoading || _hasError ? null : () {
                    getIt<HapticService>().mediumImpact();
                    // TODO: Передать _sunTimes в FastingBloc для старта
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Circadian Fast Started!")));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    shadowColor: Colors.amber.withOpacity(0.5),
                  ),
                  child: const Text("START CIRCADIAN FAST", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSunData() {
    final format = DateFormat('HH:mm');
    final sunrise = _sunTimes!.sunrise;
    final sunset = _sunTimes!.sunset;

    // Высчитываем длительность окна голодания (от заката до рассвета следующего дня)
    // Упрощенно: берем разницу времени (рассвет обычно на след день, так что добавим 24 часа к рассвету для подсчета)
    final fastingDuration = (24 - sunset.hour) + sunrise.hour + ((sunrise.minute - sunset.minute) / 60);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTimeWidget(Icons.wb_sunny_rounded, Colors.orangeAccent, "Sunrise", format.format(sunrise), "Start Eating"),
            _buildTimeWidget(Icons.nights_stay_rounded, Colors.indigoAccent, "Sunset", format.format(sunset), "Start Fasting"),
          ],
        ),

        Container(height: 1, color: Colors.white.withOpacity(0.1)),

        Column(
          children: [
            Text("Your Adaptive Plan", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(fastingDuration.toStringAsFixed(1), style: const TextStyle(color: Colors.amber, fontSize: 48, fontWeight: FontWeight.w900)),
                const SizedBox(width: 4),
                const Text("hours fast", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text("Based on your local coordinates", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildTimeWidget(IconData icon, Color color, String title, String time, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Icon(icon, color: color, size: 36),
        ),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_off_rounded, color: Colors.white54, size: 60),
        const SizedBox(height: 16),
        const Text("Location Required", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          "We need your location to calculate the exact sunset time in your city.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: _fetchSunTimes,
          icon: const Icon(Icons.refresh_rounded, color: Colors.amber),
          label: const Text("Try Again", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}