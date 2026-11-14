import 'package:flutter_test/flutter_test.dart';
import 'package:manabixx_video/main.dart';

void main() {
  testWidgets('shows the MANABIXX Video home screen', (tester) async {
    await tester.pumpWidget(const ManabixxVideoApp());

    expect(find.text('MANABIXX Video'), findsOneWidget);
    expect(find.text('教科から探す'), findsOneWidget);
    expect(find.text('数学'), findsOneWidget);
    expect(find.text('マイライブラリ'), findsOneWidget);
  });

  testWidgets('allows selecting and clearing a subject', (tester) async {
    await tester.pumpWidget(const ManabixxVideoApp());

    await tester.tap(find.text('数学'));
    await tester.pumpAndSettle();

    expect(find.text('教材連携準備中'), findsOneWidget);
    expect(find.text('解除'), findsOneWidget);

    await tester.tap(find.text('解除'));
    await tester.pumpAndSettle();

    expect(find.text('教材連携準備中'), findsNothing);
  });

  testWidgets('shows the entered search query', (tester) async {
    await tester.pumpWidget(const ManabixxVideoApp());

    await tester.enterText(find.byType(TextField), '一次関数');
    await tester.pumpAndSettle();

    expect(find.text('「一次関数」'), findsOneWidget);
    expect(find.text('教材連携準備中'), findsOneWidget);
  });
}
