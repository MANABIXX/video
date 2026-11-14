import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

const bg = Color(0xFF090B10);
const panel = Color(0xFF151B25);
const accent = Color(0xFF8AB4F8);
const muted = Color(0xFF929BAA);

void main() => runApp(const VideoApp());

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MANABIXX Video',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark, scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: accent, surface: panel),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: bg, surfaceTintColor: Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: panel, hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    ),
    home: const Shell(),
  );
}

class Video {
  const Video(this.id, this.title, this.channel, this.description, this.thumbnail);
  final String id, title, channel, description, thumbnail;
  factory Video.fromApi(Map<String,dynamic> j) {
    final s=j['snippet'] as Map<String,dynamic>;
    final t=s['thumbnails'] as Map<String,dynamic>;
    final image=(t['high']??t['medium']??t['default']) as Map<String,dynamic>;
    return Video((j['id'] as Map<String,dynamic>)['videoId'] as String,
      s['title'] as String? ?? '', s['channelTitle'] as String? ?? '',
      s['description'] as String? ?? '', image['url'] as String? ?? '');
  }
  factory Video.fromJson(Map<String,dynamic> j) => Video(j['id'],j['title'],j['channel'],j['description'],j['thumbnail']);
  Map<String,dynamic> toJson()=>{'id':id,'title':title,'channel':channel,'description':description,'thumbnail':thumbnail};
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override State<Shell> createState()=>_ShellState();
}
class _ShellState extends State<Shell> {
  int tab=0; String apiKey=''; bool ready=false; List<Video> saved=[]; List<Video> history=[];
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    if(!mounted)return;
    setState((){apiKey=p.getString('youtube_api_key')??'';saved=(p.getStringList('saved')??[]).map((s)=>Video.fromJson(jsonDecode(s))).toList();history=(p.getStringList('history')??[]).map((s)=>Video.fromJson(jsonDecode(s))).toList();ready=true;});
  }
  Future<void> _keyDialog() async {
    final c=TextEditingController(text:apiKey);
    final v=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(
      backgroundColor:panel,title:const Text('YouTube API設定'),
      content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('動画検索にはYouTube Data API v3のAPIキーが必要です。Google Cloudで発行し、APIを制限したキーを登録してください。',style:TextStyle(color:muted,fontSize:13,height:1.5)),
        const SizedBox(height:14),TextField(controller:c,obscureText:true,decoration:const InputDecoration(hintText:'APIキー')),
      ]),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('キャンセル')),FilledButton(onPressed:()=>Navigator.pop(ctx,c.text),child:const Text('保存'))],
    ));
    c.dispose();
    if(v!=null){final p=await SharedPreferences.getInstance();await p.setString('youtube_api_key',v.trim());if(mounted)setState(()=>apiKey=v.trim());}
  }
  Future<void> _toggle(Video v) async {
    final exists=saved.any((x)=>x.id==v.id);
    final next=[...saved.where((x)=>x.id!=v.id)];
    if(!exists)next.insert(0,v);
    final p=await SharedPreferences.getInstance();
    await p.setStringList('saved',next.map((x)=>jsonEncode(x.toJson())).toList());
    if(mounted)setState(()=>saved=next);
  }
  Future<void> _recordHistory(Video v) async {
    final next=[v,...history.where((x)=>x.id!=v.id)].take(20).toList();
    final p=await SharedPreferences.getInstance();
    await p.setStringList('history',next.map((x)=>jsonEncode(x.toJson())).toList());
    if(mounted)setState(()=>history=next);
  }\n  void _play(Video v){unawaited(_recordHistory(v));Navigator.push(context,MaterialPageRoute(builder:(_)=>PlayerPage(video:v,isSaved:saved.any((x)=>x.id==v.id),onSave:()=>_toggle(v))));}
  @override Widget build(BuildContext context){
    if(!ready)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(title:const Row(children:[Icon(Icons.play_circle_fill_rounded,color:accent),SizedBox(width:8),Text('MANABIXX',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:-.5)),SizedBox(width:6),Text('VIDEO',style:TextStyle(color:accent,fontSize:12,fontWeight:FontWeight.w900,letterSpacing:1.2))]),
        actions:[IconButton(onPressed:_keyDialog,icon:const Icon(Icons.tune_rounded),tooltip:'設定')]),
      body:IndexedStack(index:tab,children:[
        HomeTab(onSearch:()=>setState(()=>tab=1),saved:saved,history:history,onPlay:_play),
        SearchTab(apiKey:apiKey,saved:saved,onPlay:_play,onSave:_toggle,onSettings:_keyDialog),
        LibraryTab(saved:saved,onPlay:_play,onRemove:_toggle),
        const OfflineTab(),
      ]),
      bottomNavigationBar:NavigationBar(backgroundColor:panel,selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),
        destinations:const[
          NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'ホーム'),
          NavigationDestination(icon:Icon(Icons.search),label:'検索'),
          NavigationDestination(icon:Icon(Icons.bookmarks_outlined),selectedIcon:Icon(Icons.bookmarks),label:'ライブラリ'),
          NavigationDestination(icon:Icon(Icons.download_for_offline_outlined),selectedIcon:Icon(Icons.download_for_offline),label:'オフライン'),
        ]),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key,required this.onSearch,required this.saved,required this.onPlay});
  final VoidCallback onSearch; final List<Video> saved; final ValueChanged<Video> onPlay;
  static const subjects=[('数学',Icons.calculate_rounded),('英語',Icons.translate_rounded),('理科',Icons.science_rounded),('社会',Icons.public_rounded),('国語',Icons.menu_book_rounded)];
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.fromLTRB(18,8,18,28),children:[
    Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF203653),Color(0xFF151B27),Color(0xFF10141C)]),border:Border.all(color:Colors.white10)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('YOUR LEARNING, YOUR FLOW',style:TextStyle(color:accent,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.4)),
        const SizedBox(height:16),const Text('動画で学ぶ。\n集中を、止めない。',style:TextStyle(fontSize:28,height:1.2,fontWeight:FontWeight.w900,letterSpacing:-.8)),
        const SizedBox(height:10),const Text('見つける、再生する、あとで見返す。学習動画をひとつの場所に。',style:TextStyle(color:Colors.white70,height:1.5,fontSize:13)),
        const SizedBox(height:20),FilledButton.icon(onPressed:onSearch,icon:const Icon(Icons.search),label:const Text('動画を探す'),style:FilledButton.styleFrom(backgroundColor:accent,foregroundColor:bg)),
      ])),
    const SizedBox(height:28),const _Heading('教科から探す','学びたい分野へすぐアクセス'),const SizedBox(height:12),
    ...subjects.map((s)=>Padding(padding:const EdgeInsets.only(bottom:9),child:Material(color:panel,borderRadius:BorderRadius.circular(16),child:ListTile(
      leading:Container(width:42,height:42,decoration:BoxDecoration(color:accent.withValues(alpha:.12),borderRadius:BorderRadius.circular(13)),child:Icon(s.$2,color:accent)),
      title:Text(s.$1,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:const Text('学習動画を検索',style:TextStyle(color:muted,fontSize:11)),
      trailing:const Icon(Icons.chevron_right,color:muted),onTap:onSearch,
    )))),
    if(history.isNotEmpty)...[const SizedBox(height:20),const _Heading('最近見た動画','前回の学習をすぐ再開'),...history.take(5).map((v)=>VideoTile(video:v,onTap:()=>onPlay(v)))],
    if(saved.isNotEmpty)...[const SizedBox(height:20),const _Heading('保存した動画'),...saved.take(3).map((v)=>VideoTile(video:v,onTap:()=>onPlay(v)))],
  ]);
}

class SearchTab extends StatefulWidget {
  const SearchTab({super.key,required this.apiKey,required this.saved,required this.onPlay,required this.onSave,required this.onSettings});
  final String apiKey; final List<Video> saved; final ValueChanged<Video> onPlay,onSave; final VoidCallback onSettings;
  @override State<SearchTab> createState()=>_SearchTabState();
}
class _SearchTabState extends State<SearchTab>{
  final c=TextEditingController();List<Video> results=[];bool loading=false;String? error;
  Future<void> search([String? preset]) async {
    final q=(preset??c.text).trim();if(q.isEmpty)return;
    if(widget.apiKey.isEmpty){setState(()=>error='検索するには先にYouTube APIキーを設定してください。');return;}
    setState((){loading=true;error=null;results=[];});
    try{
      final uri=Uri.https('www.googleapis.com','/youtube/v3/search',{'part':'snippet','type':'video','maxResults':'25','q':q,'regionCode':'JP','relevanceLanguage':'ja','safeSearch':'moderate','key':widget.apiKey});
      final r=await http.get(uri).timeout(const Duration(seconds:20));final data=jsonDecode(r.body) as Map<String,dynamic>;
      if(r.statusCode!=200){final msg=(data['error'] as Map<String,dynamic>?)?['message'];throw Exception(msg??'API error ${r.statusCode}');}
      final list=(data['items'] as List<dynamic>? ?? []).map((x)=>Video.fromApi(x as Map<String,dynamic>)).toList();
      if(mounted)setState(()=>results=list);
    }catch(e){if(mounted)setState(()=>error='検索できませんでした。APIキーと通信環境を確認してください。\n$e');}
    finally{if(mounted)setState(()=>loading=false);}
  }
  @override void dispose(){c.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.fromLTRB(18,18,18,28),children:[
    const _Heading('動画を検索','YouTube上の学習動画を探す'),const SizedBox(height:16),
    Row(children:[Expanded(child:TextField(controller:c,textInputAction:TextInputAction.search,onSubmitted:(_)=>search(),decoration:const InputDecoration(hintText:'例：中学理科 天体 解説',prefixIcon:Icon(Icons.search)))),
      const SizedBox(width:8),IconButton.filled(onPressed:loading?null:()=>search(),icon:const Icon(Icons.arrow_forward),style:IconButton.styleFrom(backgroundColor:accent,foregroundColor:bg,minimumSize:const Size(52,52)))]),
    const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:['中学数学','英検準2級','高校入試 理科','歴史 解説'].map((q)=>ActionChip(label:Text(q),backgroundColor:panel,side:BorderSide.none,onPressed:loading?null:(){c.text=q;search(q);})).toList()),
    if(widget.apiKey.isEmpty)...[const SizedBox(height:20),_Info(icon:Icons.key,title:'APIキーを設定',message:'Google CloudでYouTube Data API v3を有効にし、APIキーを登録してください。',action:TextButton(onPressed:widget.onSettings,child:const Text('設定を開く')))],
    if(loading)const Padding(padding:EdgeInsets.all(30),child:Center(child:CircularProgressIndicator())),
    if(error!=null)...[const SizedBox(height:18),_Info(icon:Icons.info_outline,title:'検索できません',message:error!)],
    if(results.isNotEmpty)...[const SizedBox(height:22),_Heading('検索結果','${results.length}件'),const SizedBox(height:10),...results.map((v)=>VideoTile(video:v,onTap:()=>widget.onPlay(v),trailing:IconButton(onPressed:()=>widget.onSave(v),icon:Icon(widget.saved.any((x)=>x.id==v.id)?Icons.bookmark:Icons.bookmark_add_outlined,color:accent))))],
  ]);
}

class LibraryTab extends StatelessWidget{
  const LibraryTab({super.key,required this.saved,required this.onPlay,required this.onRemove});
  final List<Video> saved;final ValueChanged<Video> onPlay,onRemove;
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.fromLTRB(18,18,18,28),children:[
    const _Heading('マイライブラリ','保存した動画をいつでも見返す'),const SizedBox(height:16),
    if(saved.isEmpty)const _Info(icon:Icons.bookmarks_outlined,title:'保存した動画はまだありません',message:'検索結果のブックマークから動画を保存できます。')
    else ...saved.map((v)=>VideoTile(video:v,onTap:()=>onPlay(v),trailing:IconButton(onPressed:()=>onRemove(v),icon:const Icon(Icons.bookmark_remove_outlined,color:muted)))),
  ]);
}


class OfflineVideo {
  const OfflineVideo({required this.id, required this.title, required this.path, required this.bytes});
  final String id, title, path;
  final int bytes;
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'path': path, 'bytes': bytes};
  factory OfflineVideo.fromJson(Map<String, dynamic> json) => OfflineVideo(
    id: json['id'] as String,
    title: json['title'] as String,
    path: json['path'] as String,
    bytes: json['bytes'] as int? ?? 0,
  );
}

class OfflineTab extends StatefulWidget {
  const OfflineTab({super.key});
  @override State<OfflineTab> createState() => _OfflineTabState();
}

class _OfflineTabState extends State<OfflineTab> {
  static const _storageKey = 'offline_videos_v1';
  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 20), receiveTimeout: const Duration(minutes: 30)));
  List<OfflineVideo> _items = [];
  bool _loading = true, _downloading = false;
  double _progress = 0;
  String? _downloadError;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_storageKey) ?? [];
    final docs = await getApplicationDocumentsDirectory();
    final found = <OfflineVideo>[];
    for (final raw in values) {
      try {
        final item = OfflineVideo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        if (await File(item.path).exists()) found.add(item);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() { _items = found; _loading = false; });
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _items.map((v) => jsonEncode(v.toJson())).toList());
  }

  Future<void> _addDownload() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final input = await showDialog<(String, String)>(context: context, builder: (dialogContext) => AlertDialog(
      backgroundColor: panel,
      title: const Text('動画を端末に保存'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleController, decoration: const InputDecoration(labelText: '動画タイトル')),
        const SizedBox(height: 12),
        TextField(controller: urlController, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: '動画ファイルのURL', hintText: 'https://example.com/lesson.mp4')),
        const SizedBox(height: 10),
        const Text('自分が所有する動画、または配布元がダウンロードを許可しているMP4等の直リンクに対応。YouTubeの動画URLや配信ストリームは対象外です。', style: TextStyle(color: muted, fontSize: 11, height: 1.45)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('キャンセル')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, (titleController.text.trim(), urlController.text.trim())), child: const Text('ダウンロード')),
      ],
    ));
    titleController.dispose(); urlController.dispose();
    if (input == null || !mounted) return;
    await _download(input.$1, input.$2);
  }

  Future<void> _download(String title, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !['http', 'https'].contains(uri.scheme) || uri.host.isEmpty) {
      setState(() => _downloadError = '有効なHTTPS/HTTP動画ファイルURLを入力してください。');
      return;
    }
    final host = uri.host.toLowerCase();
    if (host == 'youtube.com' || host.endsWith('.youtube.com') || host == 'youtu.be' || host.endsWith('.googlevideo.com')) {
      setState(() => _downloadError = 'YouTubeの動画はこの機能でダウンロードできません。公式プレイヤーで視聴してください。');
      return;
    }
    final ext = uri.path.toLowerCase().split('.').last;
    if (!['mp4', 'm4v', 'mov', 'webm'].contains(ext)) {
      setState(() => _downloadError = '対応形式はMP4・M4V・MOV・WebMです。');
      return;
    }
    setState(() { _downloading = true; _progress = 0; _downloadError = null; });
    String? target;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final safeName = 'manabixx_${DateTime.now().microsecondsSinceEpoch}.$ext';
      target = '${directory.path}/$safeName';
      final response = await _dio.download(rawUrl, target, deleteOnError: true,
        onReceiveProgress: (received, total) {
          if (mounted && total > 0) setState(() => _progress = received / total);
        });
      final contentType = response.headers.value(Headers.contentTypeHeader)?.toLowerCase() ?? '';
      final file = File(target);
      if (response.statusCode != 200 && response.statusCode != 206) throw Exception('HTTP ${response.statusCode}');
      if (!(contentType.startsWith('video/') || contentType == 'application/octet-stream')) {
        throw Exception('動画ファイルとして確認できませんでした（$contentType）');
      }
      final length = await file.length();
      if (length == 0) throw Exception('ファイルが空です');
      final item = OfflineVideo(id: safeName, title: title.isEmpty ? '保存した動画' : title, path: target, bytes: length);
      if (!mounted) return;
      setState(() => _items = [item, ..._items]);
      await _persist();
    } catch (error) {
      if (target != null) { final file = File(target); if (await file.exists()) await file.delete(); }
      if (mounted) setState(() => _downloadError = '保存できませんでした: $error');
    } finally {
      if (mounted) setState(() { _downloading = false; _progress = 0; });
    }
  }

  Future<void> _delete(OfflineVideo item) async {
    final file = File(item.path);
    if (await file.exists()) await file.delete();
    if (!mounted) return;
    setState(() => _items = _items.where((v) => v.id != item.id).toList());
    await _persist();
  }

  String _size(int bytes) => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
      : '${(bytes / 1024).toStringAsFixed(0)} KB';

  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 28), children: [
    const _Heading('オフライン','保存した教材動画は通信なしで再生できます'),
    const SizedBox(height: 12),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18)), child: Row(children: [
      const Icon(Icons.wifi_off_rounded, color: accent, size: 26), const SizedBox(width: 12),
      const Expanded(child: Text('端末内に保存した動画を、圏外や移動中でも再生。保存データはこのアプリ内に保管されます。', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.45))),
    ])),
    const SizedBox(height: 14),
    FilledButton.icon(onPressed: _downloading ? null : _addDownload, icon: const Icon(Icons.download_rounded), label: const Text('動画ファイルを追加')),
    if (_downloading) ...[
      const SizedBox(height: 14), LinearProgressIndicator(value: _progress == 0 ? null : _progress),
      const SizedBox(height: 6), Text(_progress == 0 ? 'ダウンロード準備中…' : '${(_progress * 100).toStringAsFixed(0)}% 保存中', style: const TextStyle(color: muted, fontSize: 12)),
    ],
    if (_downloadError != null) ...[const SizedBox(height: 12), _Info(icon: Icons.error_outline, title: 'ダウンロードできません', message: _downloadError!)],
    const SizedBox(height: 24),
    _Heading('保存済み','${_items.length}本'),
    const SizedBox(height: 10),
    if (_loading) const Center(child: CircularProgressIndicator())
    else if (_items.isEmpty) const _Info(icon: Icons.download_for_offline_outlined, title: 'まだ動画がありません', message: '「動画ファイルを追加」から、ダウンロードが許可された教材動画を保存できます。')
    else ..._items.map((item) => Card(color: panel, child: ListTile(
      leading: const Icon(Icons.movie_outlined, color: accent),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(_size(item.bytes), style: const TextStyle(color: muted)),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfflinePlayerPage(item: item))),
      trailing: IconButton(tooltip: '削除', onPressed: () => _delete(item), icon: const Icon(Icons.delete_outline, color: muted)),
    ))),
  ]);
}

class OfflinePlayerPage extends StatefulWidget {
  const OfflinePlayerPage({super.key, required this.item});
  final OfflineVideo item;
  @override State<OfflinePlayerPage> createState() => _OfflinePlayerPageState();
}

class _OfflinePlayerPageState extends State<OfflinePlayerPage> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  @override void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.item.path))
      ..initialize().then((_) { if (mounted) setState(() => _ready = true); })
      ..addListener(() { if (mounted) setState(() {}); });
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  String _time(Duration value) => '${value.inMinutes.toString().padLeft(2, '0')}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';
  @override Widget build(BuildContext context) {
    final value = _controller.value;
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: _ready ? ListView(padding: const EdgeInsets.all(16), children: [
        AspectRatio(aspectRatio: value.aspectRatio, child: VideoPlayer(_controller)),
        const SizedBox(height: 12),
        Row(children: [
          IconButton.filled(onPressed: () => setState(() => value.isPlaying ? _controller.pause() : _controller.play()),
            icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow), style: IconButton.styleFrom(backgroundColor: accent, foregroundColor: bg)),
          Expanded(child: Slider(value: value.duration.inMilliseconds == 0 ? 0 : value.position.inMilliseconds.clamp(0, value.duration.inMilliseconds).toDouble(),
            max: value.duration.inMilliseconds == 0 ? 1 : value.duration.inMilliseconds.toDouble(),
            onChanged: (v) => _controller.seekTo(Duration(milliseconds: v.round())))),
        ]),
        Text('${_time(value.position)} / ${_time(value.duration)}', textAlign: TextAlign.end, style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 8),
        const Text('端末内の保存ファイルを再生中 · インターネット接続不要', style: TextStyle(color: muted, fontSize: 12)),
      ]) : const Center(child: CircularProgressIndicator()),
    );
  }
}

class PlayerPage extends StatefulWidget{
  const PlayerPage({super.key,required this.video,required this.isSaved,required this.onSave});
  final Video video;final bool isSaved;final VoidCallback onSave;
  @override State<PlayerPage> createState()=>_PlayerPageState();
}
class _PlayerPageState extends State<PlayerPage>{
  late final YoutubePlayerController controller;
  final noteController=TextEditingController();
  Timer? progressTimer;
  double speed=1;
  double resumeAt=0;
  bool isSaved=false;

  String get _progressKey=>'progress_${widget.video.id}';
  String get _noteKey=>'note_${widget.video.id}';

  @override void initState(){
    super.initState();
    isSaved=widget.isSaved;
    controller=YoutubePlayerController.fromVideoId(videoId:widget.video.id,autoPlay:true,params:const YoutubePlayerParams(showControls:true,showFullscreenButton:true,interfaceLanguage:'ja',captionLanguage:'ja',enableCaption:true,playsInline:true,strictRelatedVideos:true));
    _restoreLearningData();
    progressTimer=Timer.periodic(const Duration(seconds:8),(_){unawaited(_saveProgress());});
  }

  Future<void> _restoreLearningData() async {
    final p=await SharedPreferences.getInstance();
    final position=p.getDouble(_progressKey)??0;
    final note=p.getString(_noteKey)??'';
    if(!mounted)return;
    setState(()=>noteController.text=note);
    if(position>5){
      await Future.delayed(const Duration(seconds:2));
      if(!mounted)return;
      resumeAt=position;
      await controller.seekTo(seconds:position);
      if(mounted)setState((){});
    }
  }

  Future<void> _saveProgress() async {
    try{
      final current=await controller.currentTime;
      final duration=await controller.duration;
      if(current>0 && duration>0 && current<duration-3){
        final p=await SharedPreferences.getInstance();
        await p.setDouble(_progressKey,current);
        if(mounted && (current-resumeAt).abs()>8)setState(()=>resumeAt=current);
      }else if(duration>0 && current>=duration-3){
        final p=await SharedPreferences.getInstance();
        await p.remove(_progressKey);
      }
    }catch(_){}
  }

  Future<void> _saveNote() async {
    final p=await SharedPreferences.getInstance();
    await p.setString(_noteKey,noteController.text.trim());
    if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('メモを保存しました')));}
  }

  Future<void> _changeSpeed(double value) async {
    await controller.setPlaybackRate(value);
    if(mounted)setState(()=>speed=value);
  }

  @override void dispose(){
    progressTimer?.cancel();
    unawaited(_saveProgress());
    noteController.dispose();
    unawaited(controller.close());
    super.dispose();
  }

  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('再生中')),body:ListView(children:[
    YoutubePlayer(controller:controller,aspectRatio:16/9),
    Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(widget.video.title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w800,height:1.35)),
      const SizedBox(height:8),Text(widget.video.channel,style:const TextStyle(color:muted)),
      const SizedBox(height:14),
      Wrap(spacing:10,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:[
        OutlinedButton.icon(onPressed:(){setState(()=>isSaved=!isSaved);widget.onSave();},icon:Icon(isSaved?Icons.bookmark:Icons.bookmark_add_outlined),label:Text(isSaved?'保存済み':'保存する')),
        const Text('再生速度',style:TextStyle(color:muted,fontSize:12)),
        DropdownButton<double>(value:speed,items:const [0.5,0.75,1,1.25,1.5,2].map((v)=>DropdownMenuItem(value:v,child:Text('${v}x'))).toList(),onChanged:(v){if(v!=null)_changeSpeed(v);}),
      ]),
      if(resumeAt>5)Padding(padding:const EdgeInsets.only(top:8),child:Text('続きから再生中 · ${(resumeAt/60).floor()}分${(resumeAt%60).floor()}秒',style:const TextStyle(color:accent,fontSize:12))),
      const Divider(height:32,color:Colors.white12),
      const Text('学習メモ',style:TextStyle(fontWeight:FontWeight.w800)),
      const SizedBox(height:8),
      TextField(controller:noteController,minLines:3,maxLines:6,decoration:const InputDecoration(hintText:'重要なポイントや疑問点をメモ...',alignLabelWithHint:true)),
      const SizedBox(height:8),Align(alignment:Alignment.centerRight,child:FilledButton.icon(onPressed:_saveNote,icon:const Icon(Icons.save_outlined),label:const Text('メモを保存'))),
      const Divider(height:32,color:Colors.white12),const Text('概要',style:TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:8),
      Text(widget.video.description.isEmpty?'説明はありません。':widget.video.description,style:const TextStyle(color:Colors.white70,height:1.55)),
      const SizedBox(height:18),const Text('YouTube公式IFrame Player APIを使用しています。広告除去や有料機能の回避は行いません。',style:TextStyle(color:muted,fontSize:11,height:1.5)),
    ])),
  ]));
}

class VideoTile extends StatelessWidget{
  const VideoTile({super.key,required this.video,required this.onTap,this.trailing});
  final Video video;final VoidCallback onTap;final Widget? trailing;
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:11),child:Material(color:panel,borderRadius:BorderRadius.circular(16),clipBehavior:Clip.antiAlias,child:InkWell(onTap:onTap,child:Row(children:[
    SizedBox(width:128,height:84,child:Stack(fit:StackFit.expand,children:[
      Image.network(video.thumbnail,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const ColoredBox(color:panel,child:Icon(Icons.video_library_outlined))),
      const Align(alignment:Alignment.center,child:Icon(Icons.play_circle_fill,color:Colors.white,size:34)),
    ])),
    Expanded(child:Padding(padding:const EdgeInsets.fromLTRB(11,9,3,9),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(video.title,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13,height:1.3)),
      const SizedBox(height:6),Text(video.channel,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:muted,fontSize:11)),
    ]))),
    if(trailing!=null)trailing!,
  ]))));
}

class _Heading extends StatelessWidget{
  const _Heading(this.title,[this.sub]);final String title;final String? sub;
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900,letterSpacing:-.4)),
    if(sub!=null)...[const SizedBox(height:4),Text(sub!,style:const TextStyle(color:muted,fontSize:12))],
  ]);
}
class _Info extends StatelessWidget{
  const _Info({required this.icon,required this.title,required this.message,this.action});
  final IconData icon;final String title,message;final Widget? action;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Icon(icon,color:accent,size:25),const SizedBox(height:12),Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:7),
    Text(message,style:const TextStyle(color:muted,fontSize:12,height:1.5)),if(action!=null)action!,
  ]));
}
