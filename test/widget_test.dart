import 'package:ath615/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders splash screen', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Professional multi-gym app foundation'), findsOneWidget);
  });
}
