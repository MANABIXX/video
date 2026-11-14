# MANABIXX Video

Flutter製の学習向けYouTubeクライアント。軽快なダークUIで、検索・アプリ内再生・日本語字幕・ブックマークをまとめます。

## Features
- YouTube Data API v3による日本語動画検索
- YouTube公式IFrame Player APIによるアプリ内再生
- 日本語字幕・全画面再生
- ブックマークの端末内保存
- Android Release APKのGitHub Actionsビルド

## Setup
1. Google CloudでYouTube Data API v3を有効化し、APIキーを発行します。
2. APIキーをYouTube Data API v3に制限し、アプリ内の設定画面で登録します。
3. `flutter pub get` → `flutter run`

APIキーは端末内に保存されますが、APKから取り出される可能性があります。個人用キーを使い、API制限と利用量上限を設定してください。

## APK
GitHub Actionsの **Build Android APK** を実行すると、Release APKがArtifactとして生成されます。

## Compliance
YouTube公式IFrame Player APIとYouTube Data API v3を使用します。広告除去、認証・有料機能の回避、DRM回避、学校ネットワーク制限の回避は実装しません。YouTube API Services Terms of ServiceおよびYouTube利用規約に従います。
