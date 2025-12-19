import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Анимация парения карты (вверх-вниз)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. ФОН: Золотой Mesh Gradient
          const MeshBackground(
            isFasting: true, // Используем теплые цвета
            child: SizedBox.expand(),
          ),

          // 2. КОНТЕНТ
          SafeArea(
            child: Column(
              children: [
                // Кнопка закрыть
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  l10n.proTitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const Spacer(),

                // 3. ПАРЯЩАЯ ЗОЛОТАЯ КАРТА
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * sin(_controller.value * 2 * pi)), // Плавное движение
                      child: child,
                    );
                  },
                  child: Container(
                    height: 220,
                    width: 340,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Золотой градиент
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Декоративные круги на карте
                        Positioned(
                          top: -50, right: -50,
                          child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1)),
                        ),
                        Positioned(
                          bottom: -30, left: -30,
                          child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
                        ),

                        // Текст на карте
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 32),
                                  Text("PRO ACCESS", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.unlockAll, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text("Analytics • Insights • No Ads", style: TextStyle(color: Colors.white70)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // 4. ОПИСАНИЕ ПРЕИМУЩЕСТВ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _buildFeatureRow(Icons.check_circle, l10n.premiumContentDesc),
                      const SizedBox(height: 12),
                      _buildFeatureRow(Icons.block, "No ads, pure focus"),
                      const SizedBox(height: 12),
                      _buildFeatureRow(Icons.insights, "Unlimited stats & history"),
                    ],
                  ),
                ),

                const Spacer(),

                // 5. КНОПКИ ПОКУПКИ (GLASS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      // Годовая (Выгодная)
                      GlassCard(
                        onTap: () {}, // Логика покупки
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Row(
                          children: [
                            Radio(value: true, groupValue: true, onChanged: (_) {}, activeColor: Colors.amber),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.proAnnual, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text("7 days free, then \$39.99/${l10n.year}", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                              child: const Text("-40%", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Месячная
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Radio(value: false, groupValue: true, onChanged: (_) {}, activeColor: Colors.white),
                              Text(l10n.proMonthly, style: const TextStyle(color: Colors.white)),
                              const Spacer(),
                              Text("\$4.99/${l10n.month}", style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Кнопка продолжить
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))
                          ],
                        ),
                        child: Center(
                          child: Text(
                            l10n.continueAction.toUpperCase(),
                            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(l10n.restorePurchases, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15))),
      ],
    );
  }
}