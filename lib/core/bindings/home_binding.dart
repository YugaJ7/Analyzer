import 'package:analyzer/data/cache/analytics_cache_service.dart';
import 'package:analyzer/data/repositories/streak_repository_impl.dart';
import 'package:analyzer/domain/repositories/streak_repository.dart';
import 'package:analyzer/presentation/controllers/analytics_controller.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/streak_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../data/repositories/entry_repository_impl.dart';
import '../../data/repositories/parameter_repository_impl.dart';
import '../../domain/repositories/entry_repository.dart';
import '../../domain/repositories/parameter_repository.dart';
import '../../domain/usecases/entry_usecases.dart';
import '../../domain/usecases/parameter_usecases.dart';
import '../../presentation/controllers/parameter_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    //Cache Service
    Get.put<AnalyticsCacheService>(
    AnalyticsCacheService(
      Hive.box(AnalyticsCacheService.boxName),
    ),
    permanent: true,
  );

    // Repositories
    Get.put<EntryRepository>(
      EntryRepositoryImpl(
        FirebaseFirestore.instance,
        Get.find<AnalyticsCacheService>(),
      ),
      permanent: true,
    );
    Get.put<ParameterRepository>(ParameterRepositoryImpl());
    Get.put<StreakRepository>(StreakRepositoryImpl());

    // Parameter Use Cases
    Get.put<GetParameters>(GetParameters(Get.find<ParameterRepository>()));
    Get.put<AddParameter>(AddParameter(Get.find<ParameterRepository>()));
    Get.put<UpdateParameter>(UpdateParameter(Get.find<ParameterRepository>()));
    Get.put<DeleteParameter>(DeleteParameter(Get.find<ParameterRepository>()));

    // Entry Use Cases
    Get.put<GetEntriesForDate>(GetEntriesForDate(Get.find<EntryRepository>()));

    Get.put<SaveEntry>(SaveEntry(Get.find<EntryRepository>()));

    Get.put<UpdateEntry>(UpdateEntry(Get.find<EntryRepository>()));

    Get.put<DeleteEntry>(DeleteEntry(Get.find<EntryRepository>()));

    // Controllers
    Get.put<ParameterController>(
      ParameterController(
        getParameters: Get.find<GetParameters>(),
        addParameter: Get.find<AddParameter>(),
        updateParameter: Get.find<UpdateParameter>(),
        deleteParameter: Get.find<DeleteParameter>(),
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

    // Analytics Controller
    Get.put<AnalyticsController>(
      AnalyticsController(
        entryRepository: Get.find<EntryRepository>(),
        parameterController: Get.find<ParameterController>(),
      ),
      permanent: true,
    );

    //Streak Controller
    Get.put<StreakController>(
      StreakController(
        streakRepository: Get.find<StreakRepository>(),
      ),
      permanent: true,
    );
  }
}
