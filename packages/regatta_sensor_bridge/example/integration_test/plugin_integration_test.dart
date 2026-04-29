import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('health stream yields a bridge snapshot', (
    WidgetTester tester,
  ) async {
    final plugin = RegattaSensorBridge();
    final health = await plugin.streamHealth().first;

    expect(health.recordedAt, isNotNull);
    expect(health.locationPermission, isA<PermissionStatus>());
  });
}
