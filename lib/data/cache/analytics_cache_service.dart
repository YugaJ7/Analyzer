import 'package:hive/hive.dart';
import '../../domain/entities/entry_entity.dart';

class AnalyticsCacheService {
  static const String boxName = 'analytics_cache';
  static const String key = 'history';

  final Box box;

  AnalyticsCacheService(this.box);

  void save(Map<DateTime, List<EntryEntity>> history) {
    final data = history.map(
      (date, entries) => MapEntry(
        date.toIso8601String(),
        entries
            .map((e) => {
                  'id': e.id,
                  'parameterId': e.parameterId,
                  'date': e.date.toIso8601String(),
                  'value': e.value,
                })
            .toList(),
      ),
    );

    box.put(key, data);
  }

  Map<DateTime, List<EntryEntity>> load() {
    final raw = box.get(key);
    if (raw == null) return {};

    final Map<DateTime, List<EntryEntity>> result = {};

    raw.forEach((k, v) {
      final date = DateTime.parse(k);
      result[date] = (v as List)
          .map((e) => EntryEntity(
                id: e['id'],
                userId: '',
                parameterId: e['parameterId'],
                date: DateTime.parse(e['date']),
                value: e['value'],
                createdAt: DateTime.parse(e['date']),
              ))
          .toList();
    });

    return result;
  }
}