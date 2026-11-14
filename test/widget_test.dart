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

  test('video metadata survives local serialization', () {
    const original = Video(
      'video-id',
      '数学の解説',
      'MANABIXX',
      '学習用の説明',
      'https://example.com/thumb.jpg',
    );

    final restored = Video.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.channel, original.channel);
    expect(restored.description, original.description);
    expect(restored.thumbnail, original.thumbnail);
  });
}
