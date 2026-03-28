import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_constants.dart';

class PreferencesService {
  PreferencesService._(this._prefs);

  final SharedPreferences _prefs;
  static PreferencesService? _instance;

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = PreferencesService._(prefs);
    return _instance!;
  }

  static PreferencesService get instance {
    assert(_instance != null, 'PreferencesService.init() must be called first');
    return _instance!;
  }

  // Biometric
  bool get biometricEnabled =>
      _prefs.getBool(AppConstants.kBiometricKey) ?? false;

  Future<void> setBiometricEnabled(bool value) =>
      _prefs.setBool(AppConstants.kBiometricKey, value);

  // Avatar
  String get avatarEmoji =>
      _prefs.getString(AppConstants.kAvatarKey) ?? AppConstants.kDefaultAvatar;

  Future<void> setAvatarEmoji(String emoji) =>
      _prefs.setString(AppConstants.kAvatarKey, emoji);

  // User name
  String? get userName => _prefs.getString(AppConstants.kUserNameKey);

  Future<void> setUserName(String name) =>
      _prefs.setString(AppConstants.kUserNameKey, name);

  Future<void> clearUserName() => _prefs.remove(AppConstants.kUserNameKey);

  //Generic primitives
  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clearAll() async {
    await clearUserName();
  }
}
