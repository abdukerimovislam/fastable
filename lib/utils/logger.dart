import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Wraps debugPrint and sends logs to Crashlytics in Release mode
void appLog(String message, {dynamic error, StackTrace? stackTrace}) {
  debugPrint(message);
  if (kReleaseMode) {
    FirebaseCrashlytics.instance.log(message);
    if (error != null) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace ?? StackTrace.current);
    }
  }
}
