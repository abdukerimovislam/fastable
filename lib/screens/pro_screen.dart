import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

// 🔥 ИСПРАВЛЕНИЕ: Выносим ссылки в константы.
// Замени эти ссылки на РЕАЛЬНЫЕ адреса твоих политик перед финальной сборкой!
const String _privacyPolicyUrl = 'https://sites.google.com/view/fastable-privacy-policy';
// Apple часто отклоняет дефолтную ссылку EULA на Paywall'е. Рекомендуется использовать свою.
const String _termsOfUseUrl = 'https://sites.google.com/view/fastabletermsofuse';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Package? _selectedPackage;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    context.read<ProBloc>().add(LoadOfferings());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final uri = Uri.parse(_termsOfUseUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $_termsOfUseUrl");
        }
      };

    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final uri = Uri.parse(_privacyPolicyUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $_privacyPolicyUrl");
        }
      };
  }

  @override
  void dispose() {
    _controller.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const MeshBackground(isFasting: false, child: SizedBox.expand()),

          BlocConsumer<ProBloc, ProState>(
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
                  SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              if (_selectedPackage == null && state.packages.isNotEmpty) {
                try {
                  _selectedPackage = state.packages.firstWhere((p) => p.packageType == PackageType.annual);
                } catch (e) {
                  _selectedPackage = state.packages.first;
                }
              }

              final bool isLoading = state.status == ProStatus.loading;
              final List<Package> packages = state.packages;

              return SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // --- HEADER (CLOSE BUTTON) ---
                      Padding(
                        padding: const EdgeInsets.only(right: 16, top: 8),
                        child: Align(
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
                      ),

                      // --- TITLE ---
                      Text(
                        l10n.proTitle.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // --- ANIMATED GOLD CARD ---
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 10 * sin(_controller.value * 2 * pi)),
                            child: child,
                          );
                        },
                        child: Container(
                          height: 180,
                          width: MediaQuery.of(context).size.width * 0.85,
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
                              Positioned(top: -50, right: -50, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.2))),
                              Positioned(bottom: -30, left: -30, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.2))),
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
                                        Text("PRO ACCESS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.unlockAll, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(l10n.proSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // --- FEATURES LIST ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            _buildFeatureRow(Icons.smart_toy_rounded, l10n.featureCoach, l10n.featureCoachDesc),
                            const SizedBox(height: 16),
                            _buildFeatureRow(Icons.restaurant_menu_rounded, l10n.featureRecipes, l10n.featureRecipesDesc),
                            const SizedBox(height: 16),
                            _buildFeatureRow(Icons.block_flipped, l10n.featureNoAds, l10n.featureNoAdsDesc),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      // --- PACKAGES & ACTION ---
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (packages.isEmpty && isLoading)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(l10n.loadingOffers, style: const TextStyle(color: Colors.white54)),
                              )
                            else
                              ...packages.map((package) => _buildPackageItem(package, l10n)),

                            const SizedBox(height: 20),

                            // BUY BUTTON
                            GestureDetector(
                              onTap: isLoading ? null : () => _handlePurchase(context),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: isLoading
                                      ? const LinearGradient(colors: [Colors.grey, Colors.black45])
                                      : const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    if (!isLoading)
                                      BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))
                                  ],
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text(
                                    l10n.continueAction.toUpperCase(),
                                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // RESTORE
                            GestureDetector(
                              onTap: isLoading ? null : () => _handleRestore(context),
                              child: Text(
                                l10n.restorePurchases,
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, decoration: TextDecoration.underline),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // --- LEGAL LINKS (EULA & PRIVACY) ---
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text.rich(
                                TextSpan(
                                  text: l10n.legalAgreementPrefix,
                                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                                  children: [
                                    TextSpan(
                                      text: l10n.legalTermsOfUse,
                                      style: const TextStyle(decoration: TextDecoration.underline, color: Colors.white54),
                                      recognizer: _termsRecognizer,
                                    ),
                                    TextSpan(text: l10n.legalAgreementAnd),
                                    TextSpan(
                                      text: l10n.legalPrivacyPolicy,
                                      style: const TextStyle(decoration: TextDecoration.underline, color: Colors.white54),
                                      recognizer: _privacyRecognizer,
                                    ),
                                    const TextSpan(text: "."),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.amber, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageItem(Package package, AppLocalizations l10n) {
    final isSelected = _selectedPackage == package;

    String title = l10n.planMonthly;
    if (package.packageType == PackageType.annual) title = l10n.planAnnual;
    if (package.packageType == PackageType.lifetime) title = l10n.planLifetime;

    bool isBestValue = package.packageType == PackageType.annual;
    bool isLifetime = package.packageType == PackageType.lifetime;

    return GestureDetector(
      onTap: () {
        getIt<HapticService>().selectionClick();
        setState(() => _selectedPackage = package);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          border: Border.all(
              color: isSelected ? Colors.amber : Colors.transparent,
              width: 1.5
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.amber : Colors.white54, width: 2),
                color: isSelected ? Colors.amber : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: TextStyle(color: isLifetime ? Colors.amber : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      if (isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                          child: Text(l10n.bestValue, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(package.storeProduct.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ),

            Text(
                package.storeProduct.priceString,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}