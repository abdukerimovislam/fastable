import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_event.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/l10n/app_localizations.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    // Загружаем тарифы при открытии экрана
    context.read<ProBloc>().add(LoadOfferings());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final haptic = getIt<HapticService>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: true, // Красивый фон
        child: BlocConsumer<ProBloc, ProState>(
          listener: (context, state) {
            if (state.status == ProStatus.proActive) {
              haptic.success();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Welcome to Pro! 🌟"), backgroundColor: Colors.green),
              );
              Navigator.pop(context); // Закрываем экран после покупки
            }
            if (state.status == ProStatus.failure && state.errorMessage != null) {
              haptic.error();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ProStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            // Если пакет еще не выбран, выбираем первый доступный (обычно годовой)
            if (_selectedPackage == null && state.packages.isNotEmpty) {
              _selectedPackage = state.packages.first;
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Кнопка закрытия
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const Spacer(),

                    // Заголовок
                    const Icon(Icons.star, size: 60, color: Colors.amber),
                    const SizedBox(height: 20),
                    Text(
                      l10n.proTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Unlock unlimited access to all features, advanced stats, and remove ads.",
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.4),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // Список тарифов
                    if (state.packages.isEmpty)
                      const Text("No offerings configured", style: TextStyle(color: Colors.white54))
                    else
                      ...state.packages.map((package) {
                        final isSelected = _selectedPackage == package;
                        return GestureDetector(
                          onTap: () {
                            haptic.selectionClick();
                            setState(() => _selectedPackage = package);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                                  width: 2
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package.storeProduct.title, // Название из стора
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        package.storeProduct.description,
                                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  package.storeProduct.priceString,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 24),

                    // Кнопка покупки
                    GestureDetector(
                      onTap: () {
                        if (_selectedPackage != null) {
                          haptic.mediumImpact();
                          context.read<ProBloc>().add(PurchasePackageEvent(_selectedPackage!));
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFF9D423), Color(0xFFE65C00)]),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))],
                        ),
                        child: Center(
                          child: Text(
                            l10n.getPro.toUpperCase(), // "GET PRO ACCESS"
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Restore Purchases
                    TextButton(
                      onPressed: () {
                        haptic.lightImpact();
                        context.read<ProBloc>().add(RestorePurchasesEvent());
                      },
                      child: Text(
                        l10n.restorePurchases,
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}