import 'package:flutter_test/flutter_test.dart';
import 'package:manabixx_video/main.dart';

void main() {
  testWidgets('shows the MANABIXX Video home screen', (tester) async {
    await tester.pumpWidget(const ManabixxVideoApp());

    expect(find.text('MANABIXX Video'), findsOneWidget);
    expect(find.text('教科から探す'), findsOneWidget);
    expect(find.text('数学'), findsOneWidget);
  });
}
