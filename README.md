# MANABIXX Video

Flutter製の学習向けYouTubeクライアント。軽快なダークUIで、検索・アプリ内再生・日本語字幕・ブックマークをまとめます。

## Features
- YouTube Data API v3による日本語動画検索
- YouTube公式IFrame Player APIによるアプリ内再生
- 日本語字幕・全画面再生
- ブックマークの端末内保存
- 最近見た動画の履歴（最大20件）
- 動画ごとの学習メモ保存
- 再生位置の自動保存・続きから再生
- YouTube側が提供する範囲での再生速度変更
- Android Release APKのGitHub Actionsビルド
- 自分が所有・配布許可を得たMP4/M4V/MOV/WebMの端末内保存とオフライン再生

## Setup
1. Google CloudでYouTube Data API v3を有効化し、APIキーを発行します。
2. APIキーをYouTube Data API v3に制限し、アプリ内の設定画面で登録します。
3. `flutter pub get` → `flutter run`

APIキーは端末内に保存されますが、APKから取り出される可能性があります。個人用キーを使い、API制限と利用量上限を設定してください。

## APK
GitHub Actionsの **Build Android APK** を実行すると、Release APKがArtifactとして生成されます。

## Offline video

The offline library stores authorized direct video-file URLs in the app's private documents directory. It does not download YouTube videos, extract player streams, bypass ads, Premium restrictions, DRM, or provider controls. Offline playback is limited to video files whose owner permits downloading.

## Compliance
YouTube公式IFrame Player APIとYouTube Data API v3を使用します。広告除去、認証・有料機能の回避、DRM回避、学校ネットワーク制限の回避は実装しません。YouTube API Services Terms of ServiceおよびYouTube利用規約に従います。
