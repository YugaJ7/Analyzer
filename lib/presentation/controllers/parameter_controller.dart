import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/entities/parameter_entity.dart';
import '../../domain/usecases/parameter_usecases.dart';
import '../../data/models/parameter_model.dart';

class ParameterController extends GetxController {
  final GetParameters getParameters;
  final AddParameter addParameter;
  final UpdateParameter updateParameter;
  final DeleteParameter deleteParameter;

  ParameterController({
    required this.getParameters,
    required this.addParameter,
    required this.updateParameter,
    required this.deleteParameter,
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

    getParameters.repository.watchParameters(userId).listen((list) {
      final models = list.map((e) => ParameterModel.fromEntity(e)).toList();

      parameters.value = models;

      _cache.clear();
      for (var p in models) {
        _cache[p.id] = p;
      }

      isLoading.value = false;
    });
  }

  /// 🔥 Instant read from memory
  ParameterModel? getFromCache(String id) {
    return _cache[id];
  }

  Future<void> addNewParameter(ParameterEntity parameter) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('parameters')
        .doc();

    final newParameter = ParameterEntity(
      id: docRef.id,
      userId: parameter.userId,
      createdAt: parameter.createdAt,
      name: parameter.name,
      description: parameter.description,
      type: parameter.type,
      order: parameter.order,
      isActive: parameter.isActive,
      checklistItems: parameter.checklistItems,
      options: parameter.options,
      unit: parameter.unit,
      valueType: parameter.valueType,
      icon: parameter.icon,
      color: parameter.color,
    );
    await addParameter(newParameter);
  }

  Future<void> updateExistingParameter(
    String id,
    Map<String, dynamic> updates,
  ) async {
    await updateParameter(userId, id, updates);
  }

  Future<void> deleteExistingParameter(String id) async {
    await deleteParameter(userId, id);
    parameters.removeWhere((p) => p.id == id);
    _cache.remove(id);
  }

  Future<void> reorderParameters(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final item = parameters.removeAt(oldIndex);
    parameters.insert(newIndex, item);

    for (int i = 0; i < parameters.length; i++) {
      parameters[i] = parameters[i].copyWith(order: i) as ParameterModel;
      _cache[parameters[i].id] = parameters[i];
    }

    final batch = FirebaseFirestore.instance.batch();

    for (final param in parameters) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('parameters')
          .doc(param.id);

      batch.update(docRef, {'order': param.order});
    }

    await batch.commit();
  }
}
