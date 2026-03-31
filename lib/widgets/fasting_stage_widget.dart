import 'dart:ui';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:fastable/models/fasting_stage.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/glass_card.dart';

class FastingStageWidget extends StatelessWidget {
  final Duration elapsedDuration;

  const FastingStageWidget({
    super.key,
    required this.elapsedDuration,
  });

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return "${h}h ${m}m";
    return "${m}m";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final elapsedHours = elapsedDuration.inMinutes / 60.0;

    final currentStage = FastingStage.getCurrentStage(elapsedHours);
    final currentIndex = FastingStage.allStages.indexOf(currentStage);
    final nextStage = (currentIndex + 1 < FastingStage.allStages.length)
        ? FastingStage.allStages[currentIndex + 1]
        : null;

    final progress =
    FastingStage.getStageProgress(elapsedHours).clamp(0.0, 1.0);

    final accent = currentStage.color;

    String timeLeftText = "";
    String nextStageTitle = "";

    if (nextStage != null && currentStage.endHour != null) {
      final timeUntilNext =
          Duration(hours: currentStage.endHour!) - elapsedDuration;

      timeLeftText =
      !timeUntilNext.isNegative ? _formatDuration(timeUntilNext) : "0m";

      nextStageTitle = nextStage.getTitle(l10n);
    }

    final title = currentStage.getTitle(l10n);
    final desc = currentStage.getDescription(l10n);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withOpacity(0.18),
              const Color(0xFF181A22),
              const Color(0xFF101218),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
          border: Border.all(
            color: accent.withOpacity(0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.34),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                children: [
                  _HeroStageIcon(
                    color: accent,
                    icon: currentStage.icon,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.74),
                            fontSize: 13.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // METRICS
              Row(
                children: [
                  Expanded(
                    child: _ColorMetricCard(
                      label: l10n.elapsed.toUpperCase(),
                      value: _formatDuration(elapsedDuration),
                      color: accent,
                      icon: Icons.timelapse_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ColorMetricCard(
                      label: nextStage != null
                          ? l10n.timeLeft.toUpperCase()
                          : l10n.status.toUpperCase(),
                      value: nextStage != null
                          ? timeLeftText
                          : l10n.complete.toUpperCase(),
                      color: nextStage != null ? nextStage.color : Colors.amber,
                      icon: nextStage != null
                          ? Icons.bolt_rounded
                          : Icons.workspace_premium_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // BIG PROGRESS BLOCK
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      accent.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.currentStage.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.48),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${(progress * 100).round()}%",
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: SizedBox(
                        height: 14,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.06),
                                    Colors.white.withOpacity(0.02),
                                  ],
                                ),
                              ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: progress),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return FractionallySizedBox(
                                  widthFactor: value <= 0 ? 0.001 : value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(99),
                                      gradient: LinearGradient(
                                        colors: [
                                          accent.withOpacity(0.65),
                                          accent,
                                          Colors.white.withOpacity(0.92),
                                        ],
                                        stops: const [0.0, 0.72, 1.0],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withOpacity(0.45),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (nextStage != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: nextStage.color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${l10n.nextStage}: $nextStageTitle",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // STAGE TIMELINE
              _StagesTimeline(
                stages: FastingStage.allStages,
                currentIndex: currentIndex,
                l10n: l10n,
              ),

              const SizedBox(height: 18),

              if (nextStage == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.22),
                        Colors.orange.withOpacity(0.10),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.12),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.amber,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.maxBenefitsReached,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStageIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _HeroStageIcon({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.32),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.34),
                color.withOpacity(0.10),
              ],
            ),
            border: Border.all(
              color: color.withOpacity(0.50),
              width: 1.2,
            ),
          ),
          child: Icon(
            icon,
            size: 30,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ColorMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ColorMetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.18),
            color.withOpacity(0.06),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.18),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.48),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StagesTimeline extends StatelessWidget {
  final List<FastingStage> stages;
  final int currentIndex;
  final AppLocalizations l10n;

  const _StagesTimeline({
    required this.stages,
    required this.currentIndex,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.fastingStages.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.48),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 136, // 🔥 ИСПРАВЛЕНИЕ: Увеличили высоту со 104 до 136 пикселей
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final stage = stages[index];
              final isDone = index < currentIndex;
              final isCurrent = index == currentIndex;
              final isNext = index == currentIndex + 1;
              final isLocked = index > currentIndex + 1;

              return _StageChip(
                title: stage.getTitle(l10n),
                color: stage.color,
                icon: stage.icon,
                isDone: isDone,
                isCurrent: isCurrent,
                isNext: isNext,
                isLocked: isLocked,
                l10n: l10n,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StageChip extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final bool isDone;
  final bool isCurrent;
  final bool isNext;
  final bool isLocked;
  final AppLocalizations l10n;

  const _StageChip({
    required this.title,
    required this.color,
    required this.icon,
    required this.isDone,
    required this.isCurrent,
    required this.isNext,
    required this.isLocked,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isCurrent
        ? LinearGradient(
      colors: [color.withOpacity(0.30), color.withOpacity(0.12)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : isNext
        ? LinearGradient(
      colors: [
        color.withOpacity(0.18),
        color.withOpacity(0.08),
      ],
    )
        : isDone
        ? LinearGradient(
      colors: [
        Colors.greenAccent.withOpacity(0.18),
        Colors.green.withOpacity(0.08),
      ],
    )
        : LinearGradient(
      colors: [
        Colors.white.withOpacity(0.04),
        Colors.white.withOpacity(0.02),
      ],
    );

    final borderColor = isCurrent
        ? color.withOpacity(0.45)
        : isNext
        ? color.withOpacity(0.25)
        : isDone
        ? Colors.greenAccent.withOpacity(0.28)
        : Colors.white.withOpacity(0.08);

    final iconColor = isDone
        ? Colors.greenAccent
        : isCurrent || isNext
        ? color
        : Colors.white.withOpacity(0.40);

    final statusText = isCurrent
        ? l10n.statusNow.toUpperCase()
        : isNext
        ? l10n.statusNext.toUpperCase()
        : isDone
        ? l10n.statusDone.toUpperCase()
        : l10n.statusLocked.toUpperCase();

    return Container(
      width: 108,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: bg,
        border: Border.all(color: borderColor),
        boxShadow: isCurrent
            ? [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.16),
            ),
            child: Icon(
              isDone ? Icons.check_rounded : icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const Spacer(), // Spacer теперь работает безопасно, так как высота увеличена
          Text(
            statusText,
            style: TextStyle(
              color: iconColor.withOpacity(0.90),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isLocked
                  ? Colors.white.withOpacity(0.50)
                  : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}