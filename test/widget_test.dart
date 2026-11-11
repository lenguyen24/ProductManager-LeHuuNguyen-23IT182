import 'package:flutter_test/flutter_test.dart';
import 'package:admin_user_manager/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProductManagerApp());
    expect(find.byType(ProductManagerApp), findsOneWidget);
  });
}
