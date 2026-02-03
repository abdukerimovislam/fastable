import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';

import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/l10n/app_localizations.dart';

import 'package:fastable/screens/history_screen.dart';
import 'package:fastable/screens/stats_screen.dart';
import 'package:fastable/screens/learn_screen.dart';
import 'package:fastable/screens/profile_screen.dart';
import 'package:fastable/screens/dashboard_screen.dart';

import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NotificationService _notificationService;
  late final HapticService _hapticService;

  int _selectedIndex = 2; // Таймер по центру
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _notificationService = getIt<NotificationService>();
    _hapticService = getIt<HapticService>();

    // ЕДИНЫЙ СПИСОК ДЛЯ ВСЕХ ПЛАТФОРМ
    // Рецепты теперь живут ВНУТРИ LearnScreen
    _pages = [
      HistoryScreen(
          historyRepository: getIt<HistoryRepository>(),
          waterRepository: getIt<WaterRepository>()
      ),
      StatsScreen(repository: getIt<HistoryRepository>()),
      const DashboardScreen(),
      const LearnScreen(), // Здесь внутри будет логика рецептов
      const ProfileScreen(),
    ];

    _notificationService.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: BlocBuilder<FastingBloc, FastingState>(
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
        color: Colors.transparent,
        child: GlassCard(
          height: 75,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDockItem(Icons.calendar_month_rounded, 0, l10n.navHistory),
              _buildDockItem(Icons.bar_chart_rounded, 1, l10n.navStats),
              _buildDockItem(Icons.timer_rounded, 2, l10n.navTimer, isCenter: true),
              _buildDockItem(Icons.menu_book_rounded, 3, l10n.navLearn), // Всегда Learn
              _buildDockItem(Icons.person_rounded, 4, l10n.navProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(IconData icon, int index, String label, {bool isCenter = false}) {
    final bool isSelected = _selectedIndex == index;
    final double iconSize = isCenter ? 32 : 26;
    final Color activeColor = isCenter ? Colors.blueAccent : Colors.white;

    return GestureDetector(
      onTap: () {
        _hapticService.selectionClick();
        setState(() => _selectedIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isCenter ? 14 : 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isCenter ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.2))
                  : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected && isCenter
                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 15)]
                  : [],
            ),
            child: Icon(icon, color: isSelected ? activeColor : Colors.white.withOpacity(0.4), size: iconSize),
          ),
        ],
      ),
    );
  }
}