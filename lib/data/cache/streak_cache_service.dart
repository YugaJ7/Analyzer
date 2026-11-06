import 'package:hive/hive.dart';
import '../../core/utils/app_constants.dart';

class StreakCacheService {
  static const String boxName = AppConstants.kStreakCacheBox;

  final Box<dynamic> box;

  StreakCacheService(this.box);

  void save(
    String parameterId,
    int current,
    int best,
    DateTime? lastCompletedDate,
  ) {
    box.put(parameterId, {
      'current': current,
      'best': best,
      'last': lastCompletedDate?.toIso8601String(),
    });
  }

  Map<String, dynamic>? load(String parameterId) {
    final data = box.get(parameterId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  Map<dynamic, dynamic> loadAll() {
    return box.toMap();
  }

  Future<void> remove(String parameterId) => box.delete(parameterId);

  /// Wipes all streak data — call this on logout so the next user starts clean.
  Future<void> clear() => box.clear();
}
