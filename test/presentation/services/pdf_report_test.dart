import 'dart:convert';
import 'dart:io';

import 'package:analyzer/core/utils/date_utils.dart';
import 'package:analyzer/data/cache/analytics_cache_service.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:analyzer/domain/repositories/entry_repository.dart';
import 'package:analyzer/domain/repositories/parameter_repository.dart';
import 'package:analyzer/domain/usecases/entry_usecases.dart';
import 'package:analyzer/domain/usecases/parameter_usecases.dart';
import 'package:analyzer/presentation/controllers/analytics_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:analyzer/presentation/services/export_service.dart';
import 'package:analyzer/presentation/services/pdf_report.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

final _today = DateTime(2026, 6, 15);

class _FakeEntryRepository implements EntryRepository {
  _FakeEntryRepository(this.history);

  final Map<DateTime, List<EntryEntity>> history;

  @override
  Future<Map<DateTime, List<EntryEntity>>> getEntriesForLastNDays(
    String u,
    int days,
  ) async => history;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeParameterRepository implements ParameterRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ParameterModel _habit(
  String id,
  ParameterType type, {
  String? description,
  bool isActive = true,
}) => ParameterModel(
  id: id,
  userId: 'uid-1',
  createdAt: DateTime(2025),
  name: id,
  type: type,
  order: 0,
  description: description,
  isActive: isActive,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;

  setUp(() async {
    Get.testMode = true;
    hiveDir = await Directory.systemTemp.createTemp('pdf_report_test');
    Hive.init(hiveDir.path);
  });

  tearDown(() async {
    Get.reset();
    await Hive.deleteFromDisk();
    await hiveDir.delete(recursive: true);
  });

  test('renders every section from local data alone', () async {
    final habits = [
      _habit('Read a long-named book', ParameterType.checklist),
      _habit('Water', ParameterType.value, description: 'Litres'),
      _habit('Mood', ParameterType.optionSelector, isActive: false),
    ];
    // More days than the log's page cap, so truncation is exercised too.
    final history = {
      for (var i = 0; i < 120; i++)
        AppDateUtils.addDays(_today, -i): [
          EntryEntity(
            id: 'e$i',
            userId: 'uid-1',
            parameterId: habits[i % 2].id,
            date: AppDateUtils.addDays(_today, -i),
            value: true,
            createdAt: _today,
          ),
        ],
    };
    final entryRepo = _FakeEntryRepository(history);
    final parameterRepo = _FakeParameterRepository();
    final parameters = ParameterController(
      getParameters: GetParameters(parameterRepo),
      addParameter: AddParameter(parameterRepo),
      updateParameter: UpdateParameter(parameterRepo),
      deleteParameter: DeleteParameter(parameterRepo),
      watchParameters: WatchParameters(parameterRepo),
      reorderParameters: ReorderParameters(parameterRepo),
      deleteAllEntriesForParameter: DeleteAllEntriesForParameter(entryRepo),
      userId: () => 'uid-1',
      syncWidget: () async {},
    )..parameters.value = habits;
    final analytics = AnalyticsController(
      entryRepository: entryRepo,
      parameterController: parameters,
      cacheService: AnalyticsCacheService(await Hive.openBox<dynamic>('a')),
      today: () => _today,
      userId: () => 'uid-1',
    );
    await analytics.loadAnalytics();

    final bytes = await PdfReport(
      theme: await ExportService.pdfTheme(),
      analytics: analytics,
      habits: habits,
      user: null,
      now: _today,
    ).build();

    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
  });
}
