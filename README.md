# SwipeClean (スマート・フォト・クリーナー ＆ トイ・カジノ)

「A Little to the Left」のような、手触り感のある物理カードスワイプとリアルタイム音響合成を搭載した、純ネイティブiOS/SwiftUIアプリです。

## 🛠️ 開発環境 / セットアップ

* **Xcode**: 15以上
* **iOS**: 17以上
* **XcodeGen**: インストール済みであること (`brew install xcodegen`)

### プロジェクトファイルの生成 (macOS)

本プロジェクトは `.xcodeproj` ファイルをコミット管理していません。Mac上で以下のコマンドを実行してプロジェクトファイルを動的生成します：

```sh
# 1. Xcodeプロジェクトを生成
xcodegen generate

# 2. 生成されたプロジェクトを開く
open SwipeClean.xcodeproj
```

---

## 📂 ディレクトリ構成

```text
swipeclean_swift/
  project.yml              # XcodeGenプロジェクト構成ファイル
  SwipeClean/
    App/
      SwipeCleanApp.swift  # アプリ起動エントリー (SwiftData設定)
    Models/
      AppState.swift       # SwiftDataモデル (コイン数、整理済みMB、アンロックテーマ)
      PhotoItem.swift      # 整理する写真オブジェクト構造
    Services/
      CozyAudioSynth.swift # AVAudioEngineを用いた物理音響リアルタイム合成
      PhotoScanner.swift   # PHPhotoLibraryアクセス ＆ シミュレータ用ダミー生成器
    Features/
      MainTabView.swift    # カスタムナビゲーション ＆ テーマ色適用
      Organizer/
        SwipeCardView.swift # SwiftUIのDragGestureによるバネアニメーションカード
      Casino/
        SlotMachineView.swift # 木製スロットとおもちゃレバーのアニメーション
      Shop/
        ThemeShopView.swift # コインを使った限定テーマのアンロックショップ
    Support/
      Info.plist           # 権限及びplist設定
      SwipeClean.entitlements # App Group等の認証設定
      ThemeColors.swift    # 各テーマに対応するカラーカラーマップ定義
  Tests/
    SwipeCleanTests/       # コイン加算やテーマ解放ロジックの単体テスト
    SwipeCleanUITests/     # 各タブ遷移や主要ボタンのUI自動化テスト
  .github/
    workflows/
      ios.yml              # GitHub ActionsのmacOSランナーによるCI設定
```

---

## 🧪 テストの実行

### ローカル (macOS ターミナル)
```sh
xcodebuild test \
  -project SwipeClean.xcodeproj \
  -scheme SwipeClean \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 自動検証 (GitHub Actions)
GitHubにプッシュするたびに、`.github/workflows/ios.yml` で設定されたCIワークフローが自動起動します。
* macOS環境のランナーを起動
* XcodeGenでプロジェクトを動的生成
* iOSシミュレータ上でビルドし、Unit Test ＆ UI Testを全自動実行してビルドの健全性を検証します。
