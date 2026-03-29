import 'package:fastable/l10n/app_localizations.dart';

class FastingSymptomOption {
  final String id;
  final String icon;

  const FastingSymptomOption({required this.id, required this.icon});
}

class FastingSymptoms {
  const FastingSymptoms._();

  static const String energy = 'energy';
  static const String focus = 'focus';
  static const String hungry = 'hungry';
  static const String fatigue = 'fatigue';
  static const String headache = 'headache';
  static const String thirsty = 'thirsty';

  static const List<FastingSymptomOption> options = <FastingSymptomOption>[
    FastingSymptomOption(id: energy, icon: '⚡️'),
    FastingSymptomOption(id: focus, icon: '🧠'),
    FastingSymptomOption(id: hungry, icon: '🤤'),
    FastingSymptomOption(id: fatigue, icon: '😫'),
    FastingSymptomOption(id: headache, icon: '🤕'),
    FastingSymptomOption(id: thirsty, icon: '🧊'),
  ];

  static List<String> normalizeStoredValues(List<String> rawValues) {
    final normalized = <String>[];
    for (final value in rawValues) {
      final normalizedValue = _normalizeId(value);
      if (normalizedValue == null || normalized.contains(normalizedValue)) {
        continue;
      }
      normalized.add(normalizedValue);
    }
    return normalized;
  }

  static String labelFor(AppLocalizations l10n, String id) {
    switch (id) {
      case energy:
        return l10n.symptomEnergy;
      case focus:
        return l10n.symptomFocus;
      case hungry:
        return l10n.symptomHungry;
      case fatigue:
        return l10n.symptomFatigue;
      case headache:
        return l10n.symptomHeadache;
      case thirsty:
        return l10n.symptomThirsty;
    }
    return id;
  }

  static String? _normalizeId(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();
    switch (normalized) {
      case energy:
        return energy;
      case focus:
        return focus;
      case hungry:
        return hungry;
      case fatigue:
        return fatigue;
      case headache:
        return headache;
      case thirsty:
        return thirsty;
    }
    return null;
  }
}
