import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// BLoC
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_event.dart';
import 'package:fastable/bloc/pro/pro_state.dart';

// Services & Widgets
import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';
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
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    context.read<ProBloc>().add(LoadOfferings());

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

  void _handlePurchase(BuildContext context) {
    if (_selectedPackage == null) return;
    getIt<HapticService>().mediumImpact();
    context.read<ProBloc>().add(PurchasePackageEvent(_selectedPackage!));
  }

  void _handleRestore(BuildContext context) {
    getIt<HapticService>().lightImpact();
    context.read<ProBloc>().add(RestorePurchasesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<ProBloc, ProState>(
        listener: (context, state) {
          if (state.status == ProStatus.proActive) {
            getIt<HapticService>().success();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.welcomePro), backgroundColor: Colors.green),
            );
          }
          if (state.status == ProStatus.failure && state.errorMessage != null) {
            getIt<HapticService>().error();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? l10n.errorPro), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (_selectedPackage == null && state.packages.isNotEmpty) {
            _selectedPackage = state.packages.first;
          }

          if (state.status == ProStatus.loading && state.packages.isEmpty) {
            return const MeshBackground(
              isFasting: true,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          }

          return Stack(
            children: [
              const MeshBackground(isFasting: true, child: SizedBox.expand()),

              SafeArea(
                child: Column(
                  children: [
                    // --- CLOSE BUTTON ---
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

                    // --- GOLD CARD ---
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 10 * sin(_controller.value * 2 * pi)),
                          child: child,
                        );
                      },
                      child: Container(
                        height: 200, // Чуть компактнее
                        width: 340,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
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
                            Positioned(top: -50, right: -50, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1))),
                            Positioned(bottom: -30, left: -30, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1))),
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
                                      Text(l10n.proSubtitle, style: const TextStyle(color: Colors.white70)),
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

                    // --- FEATURES (AI & Recipes) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          _buildFeatureRow(Icons.smart_toy, l10n.featureCoach, l10n.featureCoachDesc),
                          const SizedBox(height: 16),
                          _buildFeatureRow(Icons.restaurant_menu, l10n.featureRecipes, l10n.featureRecipesDesc),
                          const SizedBox(height: 16),
                          _buildFeatureRow(Icons.block, l10n.featureNoAds, l10n.featureNoAdsDesc),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // --- PACKAGES & BUTTON ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          if (state.packages.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(l10n.loadingOffers, style: const TextStyle(color: Colors.white54)),
                            )
                          else
                            ...state.packages.map((package) {
                              final isSelected = _selectedPackage == package;
                              final isBestValue = package.packageType == PackageType.annual;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: isBestValue
                                    ? GlassCard(
                                  onTap: () => setState(() => _selectedPackage = package),
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                  child: _buildPackageContent(package, true, isSelected, l10n),
                                )
                                    : GestureDetector(
                                  onTap: () => setState(() => _selectedPackage = package),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                                      border: Border.all(color: isSelected ? Colors.amber : Colors.white.withOpacity(0.2)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: _buildPackageContent(package, false, isSelected, l10n),
                                  ),
                                ),
                              );
                            }),

                          const SizedBox(height: 10),

                          GestureDetector(
                            onTap: state.status == ProStatus.loading ? null : () => _handlePurchase(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: state.status == ProStatus.loading
                                    ? const LinearGradient(colors: [Colors.grey, Colors.black45])
                                    : const LinearGradient(colors: [Colors.amber, Colors.orange]),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))
                                ],
                              ),
                              child: Center(
                                child: state.status == ProStatus.loading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(
                                  l10n.continueAction.toUpperCase(),
                                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () => _handleRestore(context),
                            child: Text(l10n.restorePurchases, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.amber, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageContent(Package package, bool isBest, bool isSelected, AppLocalizations l10n) {
    return Row(
      children: [
        Radio<Package>(
          value: package,
          groupValue: _selectedPackage,
          onChanged: (val) => setState(() => _selectedPackage = val),
          activeColor: Colors.amber,
          fillColor: MaterialStateProperty.resolveWith((states) => isSelected ? Colors.amber : Colors.white54),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package.storeProduct.title.replaceAll(RegExp(r"\(.*\)"), "").trim(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (isBest)
              Text(package.storeProduct.description, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(package.storeProduct.priceString, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            if (isBest)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                child: Text(l10n.bestValue, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
              )
          ],
        )
      ],
    );
  }
}