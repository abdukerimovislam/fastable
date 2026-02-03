import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/services/notification_service.dart';

import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/l10n/app_localizations.dart';

// ЭКРАНЫ
import 'package:fastable/screens/history_screen.dart';
import 'package:fastable/screens/stats_screen.dart';
import 'package:fastable/screens/learn_screen.dart';
import 'package:fastable/screens/profile_screen.dart';
import 'package:fastable/screens/dashboard_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NotificationService _notificationService;
  late final HapticService _hapticService;

  int _selectedIndex = 2; // Таймер по центру

  // ИСПРАВЛЕНИЕ: Убрали late final и создание списка в initState,
  // так как экраны теперь const и не требуют параметров (репозиториев).
  // Это делает код чище и безопаснее.
  final List<Widget> _pages = const [
    HistoryScreen(), // Больше не нужно передавать historyRepository
    StatsScreen(),   // Больше не нужно передавать repository
    DashboardScreen(),
    LearnScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _notificationService = getIt<NotificationService>();
    _hapticService = getIt<HapticService>();
    _notificationService.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: BlocBuilder<FastingBloc, FastingState>(
        // Оптимизация: перерисовываем фон только если сменилась фаза (голод/еда)
        buildWhen: (previous, current) => previous.phase != current.phase,
        builder: (context, state) {
          return MeshBackground(
            isFasting: state.phase == FastingPhase.fasting,
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          color: Colors.transparent,
          child: GlassCard(
            height: 70, // Чуть компактнее
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDockItem(Icons.history_rounded, 0, l10n.navHistory),
                _buildDockItem(Icons.bar_chart_rounded, 1, l10n.navStats),
                _buildDockItem(Icons.timer_rounded, 2, l10n.navTimer, isCenter: true), // Используем ключ navHome, так привычнее
                _buildDockItem(Icons.school_rounded, 3, l10n.navLearn),
                _buildDockItem(Icons.person_rounded, 4, l10n.navProfile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(IconData icon, int index, String label, {bool isCenter = false}) {
    final bool isSelected = _selectedIndex == index;
    final double iconSize = isCenter ? 30 : 24;
    final Color activeColor = isCenter ? Colors.blueAccent : Colors.white;

    return GestureDetector(
      onTap: () {
        _hapticService.selectionClick();
        setState(() => _selectedIndex = index);
      },
      behavior: HitTestBehavior.opaque, // Важно для кликабельности
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isCenter ? 12 : 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isCenter ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1))
                  : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected && isCenter
                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10)]
                  : [],
            ),
            child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.white.withOpacity(0.4),
                size: iconSize
            ),
          ),
        ],
      ),
    );
  }
}