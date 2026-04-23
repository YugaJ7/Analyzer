import 'package:hive/hive.dart';
import '../../core/utils/app_constants.dart';

class StreakCacheService {
  static const String boxName = AppConstants.kStreakCacheBox;

  final Box<dynamic> box;

  StreakCacheService(this.box);

  void save(String parameterId, int current, int best) {
    box.put(parameterId, {'current': current, 'best': best});
  }

  Map<String, dynamic>? load(String parameterId) {
    final data = box.get(parameterId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  Map<dynamic, dynamic> loadAll() {
    return box.toMap();
  }

  /// Wipes all streak data — call this on logout so the next user starts clean.
  Future<void> clear() => box.clear();
}
