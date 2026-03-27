import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/circadian_service.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';

import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';

class CircadianPlanScreen extends StatefulWidget {
  const CircadianPlanScreen({super.key});

  @override
  State<CircadianPlanScreen> createState() => _CircadianPlanScreenState();
}

class _CircadianPlanScreenState extends State<CircadianPlanScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, DateTime>? _sunTimes;

  @override
  void initState() {
    super.initState();
    _fetchSunTimes();
  }

  Future<void> _fetchSunTimes() async {
    setState(() { _isLoading = true; _hasError = false; });

    // Получаем идеальные локальные даты из обновленного сервиса
    final times = await getIt<CircadianService>().getAccurateSunTimes();

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
    double theoreticalHours = 14.0;
    Duration exactDurationToSunrise = const Duration(hours: 14);
    DateTime displaySunrise = DateTime.now();
    DateTime displaySunset = DateTime.now();

    if (_sunTimes != null) {
      displaySunrise = _sunTimes!['sunrise']!;
      displaySunset = _sunTimes!['sunset']!;
      final now = DateTime.now();

      // Сколько всего длится ночь (от заката до рассвета)
      final theoreticalWindow = displaySunrise.difference(displaySunset);
      theoreticalHours = theoreticalWindow.inMinutes / 60.0;

      // Точное время голодания от СЕЙЧАС до Рассвета
      exactDurationToSunrise = displaySunrise.difference(now);
      if (exactDurationToSunrise.isNegative) {
        exactDurationToSunrise = const Duration(minutes: 1); // Страховка
      }
    }

    return MeshBackground(
      isFasting: false,
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

                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                        : _hasError
                        ? _buildErrorState()
                        : _buildSunData(displaySunrise, displaySunset, theoreticalHours),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading || _hasError ? null : () {
                    getIt<HapticService>().mediumImpact();

                    // 🔥 ЗАПУСКАЕМ ТАЙМЕР РОВНО ДО РАССВЕТА
                    context.read<FastingBloc>().add(StartCircadianFast(exactDurationToSunrise));

                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Circadian Fast Started! 🌅", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.amber,
                            behavior: SnackBarBehavior.floating
                        )
                    );

                    Navigator.of(context).popUntil((route) => route.isFirst);
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

  Widget _buildSunData(DateTime sunrise, DateTime sunset, double theoreticalHours) {
    final format = DateFormat('HH:mm');

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
            Text("Full Night Window", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(theoreticalHours.toStringAsFixed(1), style: const TextStyle(color: Colors.amber, fontSize: 48, fontWeight: FontWeight.w900)),
                const SizedBox(width: 4),
                const Text("hours", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
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