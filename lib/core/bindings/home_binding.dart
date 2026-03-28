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
import '../../domain/repositories/entry_repository.dart';
import '../../domain/repositories/parameter_repository.dart';
import '../../domain/repositories/streak_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/entry_usecases.dart';
import '../../domain/usecases/parameter_usecases.dart';
import '../../domain/usecases/user_usecases.dart';
import '../../presentation/controllers/analytics_controller.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/entry_controller.dart';
import '../../presentation/controllers/parameter_controller.dart';
import '../../presentation/controllers/profile_controller.dart';
import '../../presentation/controllers/streak_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
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
        streakCache: Get.find<StreakCacheService>(),
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

    Get.put<AnalyticsController>(
      AnalyticsController(
        entryRepository: Get.find<EntryRepository>(),
        parameterController: Get.find<ParameterController>(),
        cacheService: Get.find<AnalyticsCacheService>(),
      ),
      permanent: true,
    );

    Get.put<StreakController>(
      StreakController(
        streakRepository: Get.find<StreakRepository>(),
        streakCache: Get.find<StreakCacheService>(),
      ),
      permanent: true,
    );

    Get.put<ProfileController>(
      ProfileController(userRepository: Get.find<UserRepository>()),
      permanent: true,
    );

    if (!Get.isRegistered<AuthController>()) {}
  }
}
