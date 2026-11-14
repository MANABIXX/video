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

class VideoHomePage extends StatefulWidget {
  const VideoHomePage({super.key});

  @override
  State<VideoHomePage> createState() => _VideoHomePageState();
}

class _VideoHomePageState extends State<VideoHomePage> {
  static const subjects = [
    ('数学', Icons.calculate_outlined),
    ('英語', Icons.translate_rounded),
    ('理科', Icons.science_outlined),
    ('社会', Icons.public_rounded),
    ('国語', Icons.menu_book_rounded),
  ];

  String? selectedSubject;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MANABIXX Video',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
        actions: [
          IconButton(
            tooltip: '検索欄へ移動',
            onPressed: () => FocusScope.of(context).requestFocus(_searchFocus),
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1C2A40), Color(0xFF151922)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8AB4F8).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'LEARNING VIDEO SPACE',
                      style: TextStyle(
                        color: Color(0xFF9CC3FF),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '学びたいことを、\n動画でもっと深く。',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.18,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '教科や単元から教材を整理して、自分のペースで学習。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              focusNode: _searchFocus,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: '動画・単元・キーワードを検索',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: '検索をクリア',
                        onPressed: () => setState(() => searchQuery = ''),
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: const Color(0xFF151922),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Text(
                  '教科から探す',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (selectedSubject != null)
                  TextButton(
                    onPressed: () => setState(() => selectedSubject = null),
                    child: const Text('解除'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              runSpacing: 10,
              children: [
                for (final subject in subjects)
                  _SubjectChip(
                    label: subject.$1,
                    icon: subject.$2,
                    selected: selectedSubject == subject.$1,
                    onPressed: () => setState(() {
                      selectedSubject =
                          selectedSubject == subject.$1 ? null : subject.$1;
                    }),
                  ),
              ],
            ),
            if (selectedSubject != null || searchQuery.isNotEmpty) ...[
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: Color(0xFF9CC3FF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          [
                            if (selectedSubject != null) selectedSubject!,
                            if (searchQuery.isNotEmpty) '「$searchQuery」',
                          ].join(' ・ '),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Text(
                        '教材連携準備中',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            Text(
              'マイライブラリ',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8AB4F8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.bookmarks_outlined,
                        color: Color(0xFF9CC3FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '保存した動画はまだありません',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '教材を見つけたら保存して、ここからすぐに見返せるようにします。',
                            style: TextStyle(
                              color: Colors.white60,
                              height: 1.45,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'MANABIXX VIDEO  ·  EARLY ACCESS',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPressed(),
      showCheckmark: false,
      backgroundColor: const Color(0xFF151922),
      selectedColor: const Color(0xFF263B59),
      side: BorderSide(
        color: selected ? const Color(0xFF8AB4F8) : Colors.white12,
      ),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFFB8D4FF) : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
