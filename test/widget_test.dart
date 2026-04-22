import 'package:analyzer/data/services/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PreferencesService initializes mock preferences', () async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Tester',
    });

    final service = await PreferencesService.init();

    expect(service.userName, 'Tester');
    expect(PreferencesService.instance.userName, 'Tester');
  });
}
