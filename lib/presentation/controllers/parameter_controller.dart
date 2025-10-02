import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/entities/parameter_entity.dart';
import '../../domain/usecases/parameter_usecases.dart';

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

  final RxList<ParameterEntity> parameters = <ParameterEntity>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadParameters();
  }

  Future<void> loadParameters() async {
    try {
      isLoading.value = true;
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final params = await getParameters(userId);
      parameters.value = params;
    } catch (e) {
      log(e.toString());
      Get.snackbar('Error', 'Failed to load parameters: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNewParameter(ParameterEntity parameter) async {
    try {
      isLoading.value = true;
      await addParameter(parameter);
      await loadParameters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add parameter: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
      rethrow; 
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExistingParameter(
      String id, Map<String, dynamic> updates) async {
    try {
      isLoading.value = true;
      await updateParameter(id, updates);
      await loadParameters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update parameter: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExistingParameter(String id) async {
    try {
      isLoading.value = true;
      await deleteParameter(id);
      await loadParameters();
      Get.snackbar('Success', 'Parameter deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete parameter: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reorderParameters(int oldIndex, int newIndex) async {
    try {
      if (newIndex > oldIndex) newIndex--;
      
      final item = parameters.removeAt(oldIndex);
      parameters.insert(newIndex, item);

      for (int i = 0; i < parameters.length; i++) {
        await updateParameter(parameters[i].id, {'order': i});
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reorder: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
      await loadParameters();
    }
  }
}