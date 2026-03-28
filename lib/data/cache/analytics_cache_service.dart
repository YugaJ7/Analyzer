import 'package:hive/hive.dart';
import '../../core/utils/app_constants.dart';
import '../../domain/entities/entry_entity.dart';

class AnalyticsCacheService {
  static const String boxName = AppConstants.kAnalyticsCacheBox;
  static const String key = 'history';

  final Box<dynamic> box;

  AnalyticsCacheService(this.box);

  DateTime? _lastEviction;

  void save(Map<DateTime, List<EntryEntity>> history) {
    final data = history.map(
      (date, entries) => MapEntry(
        date.toIso8601String(),
        entries
            .map(
              (e) => {
                'id': e.id,
                'parameterId': e.parameterId,
                'date': e.date.toIso8601String(),
                'value': e.value,
              },
            )
            .toList(),
      ),
    );

    box.put(key, data);
  }

  void saveIfFresh(
    Map<DateTime, List<EntryEntity>> history,
    DateTime fetchStartedAt,
  ) {
    final evictTime = _lastEviction;
    if (evictTime != null && evictTime.isAfter(fetchStartedAt)) {
      return;
    }
    save(history);
  }

  Map<DateTime, List<EntryEntity>> load() {
    final raw = box.get(key);
    if (raw == null) return {};

    final Map<DateTime, List<EntryEntity>> result = {};

    (raw as Map).forEach((k, v) {
      final date = DateTime.parse(k as String);
      result[date] = (v as List)
          .map(
            (e) => EntryEntity(
              id: e['id'] as String,
              userId: '',
              parameterId: e['parameterId'] as String,
              date: DateTime.parse(e['date'] as String),
              value: e['value'],
              createdAt: DateTime.parse(e['date'] as String),
            ),
          )
          .toList();
    });

    return result;
  }

  void evictParameter(String parameterId) {
    _lastEviction = DateTime.now();
    box.delete(key);
  }

  // Wipes the entire cache after logout.
  void clear() {
    _lastEviction = DateTime.now();
    box.delete(key);
  }
}
