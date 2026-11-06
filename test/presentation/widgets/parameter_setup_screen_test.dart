import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:analyzer/domain/repositories/entry_repository.dart';
import 'package:analyzer/domain/repositories/parameter_repository.dart';
import 'package:analyzer/domain/usecases/entry_usecases.dart';
import 'package:analyzer/domain/usecases/parameter_usecases.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:analyzer/presentation/screens/auth/parameter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeParameterRepository implements ParameterRepository {
  @override
  Stream<List<ParameterEntity>> watchParameters(String u) =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEntryRepository implements EntryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ParameterController habits;

  setUp(() {
    Get.testMode = true;
    final repo = _FakeParameterRepository();
    habits = Get.put(
      ParameterController(
        getParameters: GetParameters(repo),
        addParameter: AddParameter(repo),
        updateParameter: UpdateParameter(repo),
        deleteParameter: DeleteParameter(repo),
        watchParameters: WatchParameters(repo),
        reorderParameters: ReorderParameters(repo),
        deleteAllEntriesForParameter: DeleteAllEntriesForParameter(
          _FakeEntryRepository(),
        ),
        userId: () => 'uid-1',
        syncWidget: () async {},
      ),
    );
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: ParameterSetupScreen()));
    await tester.pump();
  }

  testWidgets('offers add as a FAB and hides Done until a habit exists', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text(AppStrings.paramSetupDoneButton), findsNothing);
    expect(find.text(AppStrings.paramSetupEmptyHint), findsOneWidget);
  });

  testWidgets('shows Done in the app bar once a habit is added', (
    tester,
  ) async {
    await pumpScreen(tester);

    habits.parameters.value = [
      ParameterModel(
        id: 'h1',
        userId: 'uid-1',
        createdAt: DateTime(2026),
        name: 'Read',
        type: ParameterType.checklist,
        order: 0,
      ),
    ];
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(AppStrings.paramSetupDoneButton),
      ),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tile entrance animations leave timers; unmount to settle them.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
