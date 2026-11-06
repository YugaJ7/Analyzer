import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../core/utils/app_constants.dart';
import '../../data/cache/analytics_cache_service.dart';
import '../../data/cache/streak_cache_service.dart';
import '../../data/repositories/entry_repository_impl.dart';
import '../../data/repositories/parameter_repository_impl.dart';
import '../../data/repositories/streak_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/entry_repository.dart';
import '../../domain/repositories/parameter_repository.dart';
import '../../domain/repositories/streak_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/entry_usecases.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/parameter_usecases.dart';
import '../../domain/usecases/user_usecases.dart';
import '../../presentation/controllers/analytics_controller.dart';
import '../../presentation/controllers/entry_controller.dart';
import '../../presentation/controllers/parameter_controller.dart';
import '../../presentation/controllers/profile_controller.dart';
import '../../presentation/controllers/streak_controller.dart';

/// Composition root for the signed-in session. Registration and [tearDown]
/// live together so the two lists can't drift.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Three routes share this binding; the session scope is built once.
    if (Get.isRegistered<ParameterController>()) return;

    //Cache services
    Get.put<AnalyticsCacheService>(
      AnalyticsCacheService(Hive.box<dynamic>(AppConstants.kAnalyticsCacheBox)),
      permanent: true,
    );

    Get.put<StreakCacheService>(
      StreakCacheService(Hive.box<dynamic>(AppConstants.kStreakCacheBox)),
      permanent: true,
    );

    //Repositories
    Get.put<EntryRepository>(
      EntryRepositoryImpl(
        FirebaseFirestore.instance,
        Get.find<AnalyticsCacheService>(),
      ),
      permanent: true,
    );

    Get.put<ParameterRepository>(ParameterRepositoryImpl(), permanent: true);
    Get.put<StreakRepository>(StreakRepositoryImpl(), permanent: true);

    if (!Get.isRegistered<UserRepository>()) {
      Get.put<UserRepository>(UserRepositoryImpl(), permanent: true);
    }

    //Use cases
    Get.put<GetParameters>(
      GetParameters(Get.find<ParameterRepository>()),
      permanent: true,
    );
    Get.put<WatchParameters>(
      WatchParameters(Get.find<ParameterRepository>()),
      permanent: true,
    );
    Get.put<AddParameter>(
      AddParameter(Get.find<ParameterRepository>()),
      permanent: true,
    );
    Get.put<UpdateParameter>(
      UpdateParameter(Get.find<ParameterRepository>()),
      permanent: true,
    );
    Get.put<DeleteParameter>(
      DeleteParameter(Get.find<ParameterRepository>()),
      permanent: true,
    );
    Get.put<ReorderParameters>(
      ReorderParameters(Get.find<ParameterRepository>()),
      permanent: true,
    );

    Get.put<GetEntriesForDate>(
      GetEntriesForDate(Get.find<EntryRepository>()),
      permanent: true,
    );
    Get.put<GetEntriesForLastNDays>(
      GetEntriesForLastNDays(Get.find<EntryRepository>()),
      permanent: true,
    );
    Get.put<SaveEntry>(SaveEntry(Get.find<EntryRepository>()), permanent: true);
    Get.put<UpdateEntry>(
      UpdateEntry(Get.find<EntryRepository>()),
      permanent: true,
    );
    Get.put<DeleteEntry>(
      DeleteEntry(Get.find<EntryRepository>()),
      permanent: true,
    );
    Get.put<DeleteAllEntriesForParameter>(
      DeleteAllEntriesForParameter(Get.find<EntryRepository>()),
      permanent: true,
    );

    Get.put<GetUserProfile>(
      GetUserProfile(Get.find<UserRepository>()),
      permanent: true,
    );
    Get.put<UpdateUserProfile>(
      UpdateUserProfile(Get.find<UserRepository>()),
      permanent: true,
    );

    //Controllers
    Get.put<ParameterController>(
      ParameterController(
        getParameters: Get.find<GetParameters>(),
        addParameter: Get.find<AddParameter>(),
        updateParameter: Get.find<UpdateParameter>(),
        deleteParameter: Get.find<DeleteParameter>(),
        watchParameters: Get.find<WatchParameters>(),
        reorderParameters: Get.find<ReorderParameters>(),
        deleteAllEntriesForParameter: Get.find<DeleteAllEntriesForParameter>(),
      ),
      permanent: true,
    );

    Get.put<EntryController>(
      EntryController(
        getEntriesForDate: Get.find<GetEntriesForDate>(),
        saveEntry: Get.find<SaveEntry>(),
        updateEntry: Get.find<UpdateEntry>(),
        deleteEntry: Get.find<DeleteEntry>(),
      ),
      permanent: true,
    );

    Get.lazyPut<AnalyticsController>(
      () => AnalyticsController(
        entryRepository: Get.find<EntryRepository>(),
        parameterController: Get.find<ParameterController>(),
        cacheService: Get.find<AnalyticsCacheService>(),
      ),
      fenix: true,
    );

    Get.put<StreakController>(
      StreakController(
        streakRepository: Get.find<StreakRepository>(),
        streakCache: Get.find<StreakCacheService>(),
        getEntriesForLastNDays: Get.find<GetEntriesForLastNDays>(),
      ),
      permanent: true,
    );

    Get.lazyPut<ProfileController>(
      () => ProfileController(
        userRepository: Get.find<UserRepository>(),
        logoutUser: LogoutUser(Get.find<AuthRepository>()),
      ),
      fenix: true,
    );
  }

  /// Disposes everything [dependencies] registered so the next sign-in
  /// starts from a clean scope. Permanent instances need `force`.
  static void tearDown() {
    Get.delete<ProfileController>(force: true);
    Get.delete<ParameterController>(force: true);
    Get.delete<EntryController>(force: true);
    Get.delete<StreakController>(force: true);
    Get.delete<AnalyticsController>(force: true);

    Get.delete<GetParameters>(force: true);
    Get.delete<WatchParameters>(force: true);
    Get.delete<AddParameter>(force: true);
    Get.delete<UpdateParameter>(force: true);
    Get.delete<DeleteParameter>(force: true);
    Get.delete<ReorderParameters>(force: true);
    Get.delete<GetEntriesForDate>(force: true);
    Get.delete<GetEntriesForLastNDays>(force: true);
    Get.delete<SaveEntry>(force: true);
    Get.delete<UpdateEntry>(force: true);
    Get.delete<DeleteEntry>(force: true);
    Get.delete<DeleteAllEntriesForParameter>(force: true);
    Get.delete<GetUserProfile>(force: true);
    Get.delete<UpdateUserProfile>(force: true);

    Get.delete<EntryRepository>(force: true);
    Get.delete<ParameterRepository>(force: true);
    Get.delete<StreakRepository>(force: true);

    Get.delete<AnalyticsCacheService>(force: true);
    Get.delete<StreakCacheService>(force: true);
  }
}
