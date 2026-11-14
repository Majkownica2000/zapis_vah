import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _unitKey = 'unit';

  Future<String> getUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_unitKey) ?? 'kg';
  }

  Future<void> setUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitKey, unit);
  }
}
