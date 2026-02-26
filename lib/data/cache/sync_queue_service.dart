import 'package:hive/hive.dart';

class SyncQueueService {
  static const String boxName = 'sync_queue';
  static const String key = 'queue';

  final Box box;

  SyncQueueService(this.box);

  void add(Map<String, dynamic> operation) {
    final list = box.get(key, defaultValue: []) as List;
    list.add(operation);
    box.put(key, list);
  }

  List<Map<String, dynamic>> getAll() {
    return List<Map<String, dynamic>>.from(
        box.get(key, defaultValue: []));
  }

  void clear() {
    box.put(key, []);
  }
}