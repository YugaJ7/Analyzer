abstract final class AppConstants {
  //Firestore collection names
  static const String kUsersCollection = 'users';
  static const String kParametersCollection = 'parameters';
  static const String kEntriesCollection = 'entries';
  static const String kStreaksCollection = 'streaks';

  //Hive box names
  static const String kAnalyticsCacheBox = 'analytics_cache';
  static const String kStreakCacheBox = 'streak_cache';

  //SharedPreferences keys
  static const String kLegacyAppLockKey = 'app_lock_enabled';
  static const String kAppLockKeyPrefix = 'app_lock_enabled';
  static const String kAvatarKey = 'avatar_emoji';
  static const String kUserNameKey = 'user_name';

  // Defaults
  static const String kDefaultAvatar = '🧠';
  static const String kDefaultUserName = 'User';
}
