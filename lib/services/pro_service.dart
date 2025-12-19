import 'package:shared_preferences/shared_preferences.dart';

const String kProStatusKey = 'is_pro_user';
const String kProExpiryKey = 'pro_expiry_date';

class ProService {
  // Синглтон
  static final ProService _instance = ProService._internal();
  factory ProService() => _instance;
  ProService._internal();

  Future<bool> isPro() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isActive = prefs.getBool(kProStatusKey) ?? false;

    // В реальном приложении здесь будет логика проверки даты истечения
    return isActive;
  }

  Future<void> activateProSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kProStatusKey, true);
    await prefs.setString(kProExpiryKey, DateTime.now().add(const Duration(days: 365)).toIso8601String());
  }

  // --- НОВЫЙ МЕТОД: Отмена подписки ---
  Future<void> deactivateProSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kProStatusKey, false);
    await prefs.remove(kProExpiryKey);
  }
}