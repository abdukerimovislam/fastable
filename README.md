# Fastable

Fastable is a Flutter fasting tracker focused on premium mobile UX: fasting timers, circadian plans, progress stages, history, stats, reminders, AI coaching, subscriptions, and health-oriented habit tracking.

## Stack

- Flutter 3 / Dart 3
- `flutter_bloc` + `get_it` + `injectable`
- Firebase Core / Auth / Firestore / Remote Config
- RevenueCat via `purchases_flutter`
- Local notifications, live activities, ads, and health integrations

## Current Product Areas

- Fasting timer with presets, custom plans, and circadian mode
- History and streak tracking
- Weight and water tracking
- Dashboard insights and coaching
- Localization: English, Spanish, Portuguese, Russian
- PRO paywall and update prompts

## Project Structure

```text
lib/
  bloc/           State management
  models/         Domain models
  repositories/   Local/cloud data access
  screens/        App flows and UI screens
  services/       Integrations and platform services
  widgets/        Shared UI components
```

## Local Setup

1. Install Flutter SDK compatible with the version in `pubspec.yaml`.
2. Run `flutter pub get`.
3. Ensure Firebase platform configs are present for the target platform.
4. Run the app with `flutter run`.

## Quality Commands

```bash
flutter test
flutter analyze --no-fatal-infos --no-fatal-warnings
```

## Notes

- This repo currently contains product integrations that expect platform-side setup, including Firebase, RevenueCat, local notifications, ads, and health permissions.
- Analyzer output still includes a legacy cleanup backlog, mostly deprecated `withOpacity` usage and smaller lint issues across older UI files.
