import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';

enum NotificationCategory { bio, progress, water, weight }

class FastingNotificationData {
  final Duration triggerDuration; // Смещение от старта
  final String Function(AppLocalizations) getTitle;
  final String Function(AppLocalizations) getBody;
  final int id; // Уникальный ID

  FastingNotificationData({
    required this.triggerDuration,
    required this.getTitle,
    required this.getBody,
    required this.id,
  });
}

// Статический список био-этапов
final List<FastingNotificationData> bioMilestones = [
  FastingNotificationData(
    id: 104,
    triggerDuration: const Duration(hours: 4),
    getTitle: (l10n) => l10n.notifBio4hTitle,
    getBody: (l10n) => l10n.notifBio4hBody,
  ),
  FastingNotificationData(
    id: 108,
    triggerDuration: const Duration(hours: 8),
    getTitle: (l10n) => l10n.notifBio8hTitle,
    getBody: (l10n) => l10n.notifBio8hBody,
  ),
  FastingNotificationData(
    id: 112,
    triggerDuration: const Duration(hours: 12),
    getTitle: (l10n) => l10n.notifBio12hTitle,
    getBody: (l10n) => l10n.notifBio12hBody,
  ),
  FastingNotificationData(
    id: 116,
    triggerDuration: const Duration(hours: 16),
    getTitle: (l10n) => l10n.notifBio16hTitle,
    getBody: (l10n) => l10n.notifBio16hBody,
  ),
  FastingNotificationData(
    id: 118,
    triggerDuration: const Duration(hours: 18),
    getTitle: (l10n) => l10n.notifBio18hTitle,
    getBody: (l10n) => l10n.notifBio18hBody,
  ),
  FastingNotificationData(
    id: 124,
    triggerDuration: const Duration(hours: 24),
    getTitle: (l10n) => l10n.notifBio24hTitle,
    getBody: (l10n) => l10n.notifBio24hBody,
  ),
];