import 'package:analyzer/data/models/parameter_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final RxList<ParameterModel> parameters = <ParameterModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initParameterListener();
  }

  void _initParameterListener() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('parameters')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .listen((snapshot) {
      parameters.value = snapshot.docs
          .map((doc) => ParameterModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Add a new parameter with optimistic UI update
  Future<void> addNewParameter(ParameterEntity parameter) async {
    try {
      // Temporary key for UI
      final tempId = parameter.id.isNotEmpty ? parameter.id : UniqueKey().toString();
      final tempParam = ParameterModel.fromEntity(parameter).copyWithFromMap({'id': tempId});

      // Optimistic add
      parameters.add(tempParam);

      // Add to Firestore
      final added = await addParameter(parameter);

      // Replace temporary item with Firestore ID
      final index = parameters.indexWhere((p) => p.id == tempId);
      if (index != -1) {
        parameters[index] = ParameterModel.fromEntity(added);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add parameter: $e', snackPosition: SnackPosition.BOTTOM);
      rethrow;
    }
  }

  /// Update existing parameter with local update
  Future<void> updateExistingParameter(String id, Map<String, dynamic> updates) async {
    try {
      await updateParameter(id, updates);

      final index = parameters.indexWhere((p) => p.id == id);
      if (index != -1) {
        parameters[index] = parameters[index].copyWithFromMap(updates);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update parameter: $e', snackPosition: SnackPosition.BOTTOM);
      rethrow;
    }
  }

  /// Delete parameter with hard delete
  Future<void> deleteExistingParameter(String id) async {
    try {
      
      // Optimistically remove locally
      parameters.removeWhere((p) => p.id == id);
      Get.snackbar('Success', 'Parameter deleted', snackPosition: SnackPosition.BOTTOM);
      // Firestore hard delete
      await deleteParameter(id);
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete parameter: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Reorder parameters with batch Firestore update
  Future<void> reorderParameters(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final item = parameters.removeAt(oldIndex);
    parameters.insert(newIndex, item);

    // Update local order
    for (int i = 0; i < parameters.length; i++) {
      parameters[i] = parameters[i].copyWithFromMap({'order': i});
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final param in parameters) {
        final docRef = FirebaseFirestore.instance.collection('parameters').doc(param.id);
        batch.update(docRef, {'order': param.order});
      }
      await batch.commit();
    } catch (e) {
      Get.snackbar('Error', 'Failed to reorder parameters: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}

