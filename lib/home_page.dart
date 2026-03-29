import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';

import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_event.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/ui/app_layout.dart';

// ЭКРАНЫ
import 'package:fastable/screens/history_screen.dart';
import 'package:fastable/screens/stats_screen.dart';
import 'package:fastable/screens/learn_screen.dart';
import 'package:fastable/screens/settings_screen.dart'; // 🔥 ИСПРАВЛЕНИЕ: Теперь тут Настройки
import 'package:fastable/screens/dashboard_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HapticService _hapticService;

  int _selectedIndex = 2; // Таймер по центру

  // 🔥 ИСПРАВЛЕНИЕ: Вкладка 4 теперь SettingsScreen
  final List<Widget> _pages = const [
    HistoryScreen(),
    StatsScreen(),
    DashboardScreen(),
    LearnScreen(),
    SettingsScreen(), // Заменили ProfileScreen на SettingsScreen
  ];

  @override
  void initState() {
    super.initState();
    _hapticService = getIt<HapticService>();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final edgePadding = AppLayout.edgePadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: BlocBuilder<FastingBloc, FastingState>(
        buildWhen: (previous, current) => previous.phase != current.phase,
        builder: (context, state) {
          return MeshBackground(
            isFasting: state.phase == FastingPhase.fasting,
            child: IndexedStack(index: _selectedIndex, children: _pages),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            edgePadding,
            0,
            edgePadding,
            AppLayout.sectionGap(context) + 2,
          ),
          color: Colors.transparent,
          child: GlassCard(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDockItem(Icons.history_rounded, 0, l10n.navHistory),
                _buildDockItem(Icons.bar_chart_rounded, 1, l10n.navStats),
                _buildDockItem(
                  Icons.timer_rounded,
                  2,
                  l10n.navTimer,
                  isCenter: true,
                ),
                _buildDockItem(Icons.school_rounded, 3, l10n.navLearn),
                // 🔥 ИСПРАВЛЕНИЕ: Иконка шестеренки для настроек
                _buildDockItem(Icons.settings_rounded, 4, l10n.navSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(
    IconData icon,
    int index,
    String label, {
    bool isCenter = false,
  }) {
    final bool isSelected = _selectedIndex == index;
    final double iconSize = isCenter ? 30 : 24;
    final Color activeColor = isCenter ? Colors.blueAccent : Colors.white;

    return GestureDetector(
      onTap: () {
        _hapticService.selectionClick();
        if (index == 0) {
          context.read<HistoryBloc>().add(SubscribeHistory());
        }
        setState(() => _selectedIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isCenter ? 12 : 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isCenter
                        ? Colors.blueAccent.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1))
                  : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected && isCenter
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? activeColor
                  : Colors.white.withValues(alpha: 0.4),
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}
