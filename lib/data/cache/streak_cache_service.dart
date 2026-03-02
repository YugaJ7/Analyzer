import 'package:hive/hive.dart';

class StreakCacheService {
  static const String boxName = 'streak_cache';

  final Box box;

  StreakCacheService(this.box);

  void save(String parameterId, int current, int best) {
    box.put(parameterId, {
      'current': current,
      'best': best,
    });
  }

  Map<String, dynamic>? load(String parameterId) {
    final data = box.get(parameterId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  Map<dynamic, dynamic> loadAll() {
    return box.toMap();
  }
}