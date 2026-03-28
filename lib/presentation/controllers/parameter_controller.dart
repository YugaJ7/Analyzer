import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/entities/parameter_entity.dart';
import '../../domain/usecases/parameter_usecases.dart';
import '../../domain/usecases/entry_usecases.dart';
import '../../data/models/parameter_model.dart';
import '../../data/cache/streak_cache_service.dart';
import 'analytics_controller.dart';

class ParameterController extends GetxController {
  final GetParameters getParameters;
  final AddParameter addParameter;
  final UpdateParameter updateParameter;
  final DeleteParameter deleteParameter;
  final WatchParameters watchParameters;
  final ReorderParameters reorderParameters;
  final DeleteAllEntriesForParameter deleteAllEntriesForParameter;
  final StreakCacheService streakCache;

  ParameterController({
    required this.getParameters,
    required this.addParameter,
    required this.updateParameter,
    required this.deleteParameter,
    required this.watchParameters,
    required this.reorderParameters,
    required this.deleteAllEntriesForParameter,
    required this.streakCache,
  });

  final RxList<ParameterModel> parameters = <ParameterModel>[].obs;

  late final String userId;
  final RxBool isLoading = true.obs;

  final Map<String, ParameterModel> _cache = {};

  @override
  void onInit() {
    super.onInit();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _listen();
  }

  void _listen() {
    isLoading.value = true;

    watchParameters(userId).listen((list) {
      final models = list.map((e) => ParameterModel.fromEntity(e)).toList();
      parameters.value = models;
      _cache
        ..clear()
        ..addEntries(models.map((p) => MapEntry(p.id, p)));
      isLoading.value = false;
    });
  }

  // Instant read from in-memory cache.
  ParameterModel? getFromCache(String id) => _cache[id];

  Future<void> addNewParameter(ParameterEntity parameter) async {
    await addParameter(parameter);
  }

  Future<void> updateExistingParameter(
    String id,
    Map<String, dynamic> updates,
  ) async {
    await updateParameter(userId, id, updates);
  }

  Future<void> deleteExistingParameter(String id) async {
    await deleteParameter(userId, id);
    await deleteAllEntriesForParameter(userId, id);
    Get.find<AnalyticsController>().removeHabitEntries(id);

    streakCache.save(id, 0, 0);

    parameters.removeWhere((p) => p.id == id);
    _cache.remove(id);
  }

  Future<void> reorderParameterList(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final item = parameters.removeAt(oldIndex);
    parameters.insert(newIndex, item);

    for (int i = 0; i < parameters.length; i++) {
      parameters[i] = parameters[i].copyWith(order: i) as ParameterModel;
      _cache[parameters[i].id] = parameters[i];
    }

    await reorderParameters(userId, List<ParameterEntity>.from(parameters));
  }
}
