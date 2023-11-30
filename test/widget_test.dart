
import 'package:collectify/VentanaLogin.dart';
import 'package:collectify/VentanaRegister.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  testWidgets("Test Ventana Login", (WidgetTester tester) async {
        await tester.pumpWidget(const VentanaLogin());
  });
  testWidgets("Test Ventana Register", (WidgetTester tester) async {
        await tester.pumpWidget(VentanaRegister());
  });
}
