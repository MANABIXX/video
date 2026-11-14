import 'package:flutter/material.dart';

void main() {
  runApp(const ManabixxVideoApp());
}

class ManabixxVideoApp extends StatelessWidget {
  const ManabixxVideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0B0D12);
    const surface = Color(0xFF151922);
    const accent = Color(0xFF8AB4F8);

    return MaterialApp(
      title: 'MANABIXX Video',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          surface: surface,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: const VideoHomePage(),
    );
  }
}

class VideoHomePage extends StatelessWidget {
  const VideoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MANABIXX Video',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: '検索',
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              '学びたいことから、動画を見つけよう。',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '教科・単元ごとに教材動画を整理する学習スペース。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 28),
            Text(
              '教科から探す',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SubjectChip(label: '数学', icon: Icons.calculate_outlined),
                SubjectChip(label: '英語', icon: Icons.translate_rounded),
                SubjectChip(label: '理科', icon: Icons.science_outlined),
                SubjectChip(label: '社会', icon: Icons.public_rounded),
                SubjectChip(label: '国語', icon: Icons.menu_book_rounded),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'マイライブラリ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.bookmarks_outlined, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '保存した動画はまだありません',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '気になる教材を保存すると、ここに表示されます。',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '動画検索・再生機能は次の開発段階で追加します。',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectChip extends StatelessWidget {
  const SubjectChip({
    required this.label,
    required this.icon,
    super.key,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {},
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
