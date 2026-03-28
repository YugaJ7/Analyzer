import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';

import '../../data/services/preferences_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Registers global singleton services available across the entire app.
class CoreBinding extends Bindings {
  @override
  void dependencies() {
    // Services — permanent singletons
    Get.put<PreferencesService>(PreferencesService.instance, permanent: true);

    // Core repositories — registered here so AuthBinding and HomeBinding.
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(), fenix: true);

    Get.lazyPut<UserRepository>(() => UserRepositoryImpl(), fenix: true);

    // Firestore instance — shared singleton
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);
  }
}
