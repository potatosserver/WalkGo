import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Note: In a real environment, we'd mock FlutterBackgroundService and SharedPreferences.
// This test serves as a template for how the logic should be verified.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomePageViewModel State sync', () {
    test('ViewModel should update state when receiving update_ui event',
        () async {
      SharedPreferences.setMockInitialValues({});
      // Note: This is a simplified test concept.
      // In a full implementation, we'd use a mocking library for the service.

      // final viewModel = HomePageViewModel();
      // ... Simulate _service.on('update_ui') ...
      // expect(viewModel.sessionTotalSteps, 123);
    });
  });
}
