import 'dart:async';
import 'dart:developer';

import 'package:analyzer/core/utils/app_logger.dart';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/presentation/services/widget_sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/parameter_model.dart';
import '../../domain/entities/parameter_entity.dart';
import '../../domain/usecases/entry_usecases.dart';
import '../../domain/usecases/parameter_usecases.dart';
import 'analytics_controller.dart';
import 'streak_controller.dart';

class ParameterController extends GetxController {
  final GetParameters getParameters;
  final AddParameter addParameter;
  final UpdateParameter updateParameter;
  final DeleteParameter deleteParameter;
  final WatchParameters watchParameters;
  final ReorderParameters reorderParameters;
  final DeleteAllEntriesForParameter deleteAllEntriesForParameter;
  final String Function() _userId;
  // Resolved lazily: both are registered after this controller.
  final StreakController Function() _streaks;
  final AnalyticsController Function() _analytics;
  final Future<void> Function() _syncWidget;

  ParameterController({
    required this.getParameters,
    required this.addParameter,
    required this.updateParameter,
    required this.deleteParameter,
    required this.watchParameters,
    required this.reorderParameters,
    required this.deleteAllEntriesForParameter,
    String Function()? userId,
    StreakController Function()? streaks,
    AnalyticsController Function()? analytics,
    Future<void> Function()? syncWidget,
  }) : _userId = userId ?? (() => FirebaseAuth.instance.currentUser!.uid),
       _streaks = streaks ?? Get.find<StreakController>,
       _analytics = analytics ?? Get.find<AnalyticsController>,
       _syncWidget = syncWidget ?? WidgetSyncService.syncNow;

  final RxList<ParameterModel> parameters = <ParameterModel>[].obs;

  String get userId => _userId();
  final RxBool isLoading = true.obs;

  final Map<String, ParameterModel> _cache = {};
  // Hidden from stream emissions until their delete settles.
  final Set<String> _pendingDeletes = {};
  bool _hasLoggedFirstEmission = false;
  StreamSubscription<List<ParameterEntity>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  @override
  void onClose() {
    // Otherwise the listener outlives logout and fails on permission-denied.
    _subscription?.cancel();
    super.onClose();
  }

  void _listen() {
    isLoading.value = true;
    final listenStopwatch = Stopwatch()..start();

    _subscription = watchParameters(userId).listen(onError: _onStreamError, (
      list,
    ) async {
      final models = list
          .where((p) => !_pendingDeletes.contains(p.id))
          .map(ParameterModel.fromEntity)
          .toList();

      parameters.value = models;

      _cache
        ..clear()
        ..addEntries(models.map((p) => MapEntry(p.id, p)));

      isLoading.value = false;

      if (!_hasLoggedFirstEmission) {
        _hasLoggedFirstEmission = true;
        log(
          'startup: first parameter emission in ${listenStopwatch.elapsedMilliseconds}ms with ${models.length} params',
          name: 'PERF',
        );
      }

      await _syncWidget();
    });
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Parameter stream failed',
      name: 'ParameterController',
      error: error,
      stackTrace: stackTrace,
    );
    isLoading.value = false;
    if (Get.testMode) return;
    Get.snackbar(
      AppStrings.errorTitle,
      AppStrings.habitsLoadFailedMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Instant read from in-memory cache.
  ParameterModel? getFromCache(String id) => _cache[id];

  Future<bool> addNewParameter(ParameterEntity parameter) async {
    try {
      await addParameter(parameter);
    } catch (error, stackTrace) {
      _reportFailure('Add habit failed', error, stackTrace);
      return false;
    }
    await _syncWidget();
    return true;
  }

  Future<bool> updateExistingParameter(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      await updateParameter(userId, id, updates);
    } catch (error, stackTrace) {
      _reportFailure('Update habit failed', error, stackTrace);
      return false;
    }
    await _syncWidget();
    return true;
  }

  /// Removes the habit from the list immediately (a dismissed tile must leave
  /// the tree) and restores it if the delete fails.
  Future<bool> deleteExistingParameter(String id) async {
    final index = parameters.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    final removed = parameters.removeAt(index);
    _cache.remove(id);
    _pendingDeletes.add(id);

    try {
      // Dependents first, habit doc last: a failure part-way leaves the
      // habit in place, and a retry is idempotent.
      await deleteAllEntriesForParameter(userId, id);
      await _streaks().removeHabit(id);
      await deleteParameter(userId, id);
    } catch (error, stackTrace) {
      parameters.insert(index, removed);
      _cache[id] = removed;
      _reportFailure('Delete habit failed', error, stackTrace);
      return false;
    } finally {
      _pendingDeletes.remove(id);
    }

    _analytics().removeHabitEntries(id);
    await _syncWidget();
    return true;
  }

  Future<bool> reorderParameterList(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final previous = List<ParameterModel>.of(parameters);
    final reordered = List<ParameterModel>.of(parameters);
    reordered.insert(newIndex, reordered.removeAt(oldIndex));
    _applyOrder([
      for (final (i, p) in reordered.indexed)
        ParameterModel.fromEntity(p.copyWith(order: i)),
    ]);

    try {
      await reorderParameters(userId, [for (final p in reordered) p.id]);
      return true;
    } catch (error, stackTrace) {
      _applyOrder(previous);
      _reportFailure('Reorder habits failed', error, stackTrace);
      return false;
    }
  }

  void _applyOrder(List<ParameterModel> ordered) {
    parameters.assignAll(ordered);
    for (final p in ordered) {
      _cache[p.id] = p;
    }
  }

  void _reportFailure(String context, Object error, StackTrace stackTrace) {
    AppLogger.error(
      context,
      name: 'ParameterController',
      error: error,
      stackTrace: stackTrace,
    );
    if (Get.testMode) return;
    Get.snackbar(
      AppStrings.errorTitle,
      error is AppException ? error.message : AppStrings.unexpectedError,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
