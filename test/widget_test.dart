import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manabixx_video/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the MANABIXX Video learning home', (tester) async {
    await tester.pumpWidget(const VideoApp());
    await tester.pumpAndSettle();

    expect(find.text('MANABIXX'), findsOneWidget);
    expect(find.text('教科から探す'), findsOneWidget);
    expect(find.text('動画を探す'), findsOneWidget);
    expect(find.text('ライブラリ'), findsOneWidget);
  });

  testWidgets('shows saved videos library empty state', (tester) async {
    await tester.pumpWidget(const VideoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('ライブラリ'));
    await tester.pumpAndSettle();

    expect(find.text('保存した動画はまだありません'), findsOneWidget);
  });
}
