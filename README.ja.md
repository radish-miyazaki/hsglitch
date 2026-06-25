[English](README.md) | 日本語

# hsglitch

Haskell で書かれた、コンポーザブルで決定論的なグリッチアート・パイプライン CLI です。

## 概要

`hsglitch` は型安全で再現可能なグリッチアート変換ツールです。シンプルな DSL で複数の
画像変換ステップを 1 つのパイプラインに組み合わせることができます。各ステップはシードで
決定論的に制御されるため、同じコマンドは常に同じ出力を生成します。

## インストール

### プレビルドバイナリ（推奨）

[最新リリース](https://github.com/radish-miyazaki/hsglitch/releases/latest)からお使いのプラットフォーム向けバイナリをダウンロードし、実行権限を付与して PATH に配置します:

```bash
# Linux (x86_64)
curl -L -o hsglitch https://github.com/radish-miyazaki/hsglitch/releases/latest/download/hsglitch-linux-x86_64
# macOS (Apple Silicon)
curl -L -o hsglitch https://github.com/radish-miyazaki/hsglitch/releases/latest/download/hsglitch-macos-arm64

chmod +x hsglitch
sudo mv hsglitch /usr/local/bin/
```

> macOS では、署名なしバイナリの初回実行時に Gatekeeper がブロックする場合があります。`xattr -d com.apple.quarantine /usr/local/bin/hsglitch` で隔離属性を解除してください。

### ソースからビルド

GHC 9.6 以上と cabal 3.0 以上が必要です。

```bash
cabal update
cabal build all
cabal test all
```

`hsglitch` 実行ファイルを PATH（cabal の bindir、例: `~/.local/bin` や `~/.cabal/bin`）にインストールする場合:

```bash
cabal install exe:hsglitch
```

インストールせずにソースツリーから直接実行する場合:

```bash
cabal run hsglitch -- -i in.png -o out.png -p "pixelsort | rgbshift" -s 42
```

## 使い方

```
hsglitch -i <FILE> -o <FILE> -p <DSL> [-s <INT>]
```

**フラグ一覧**

| フラグ | ロングフォーム | 必須 | 説明 |
|--------|----------------|------|------|
| `-i` | `--input`    | Yes | 入力画像パス（PNG または JPEG） |
| `-o` | `--output`   | Yes | 出力画像パス（PNG または JPEG） |
| `-p` | `--pipeline` | Yes | フィルタパイプライン DSL 文字列 |
| `-s` | `--seed`     | No  | 乱数シード（整数）。省略するとシステムの乱数を使用 |

**具体的な使用例**

```bash
cabal run hsglitch -- \
  -i photo.jpg \
  -o glitched.png \
  -p "pixelsort:threshold=0.3,direction=vertical | rgbshift:shift=8,random=true" \
  -s 42
```

## パイプライン DSL

ステップは `|` で区切ります。各ステップの形式は次のとおりです:

```
name[:key=value[,key=value...]]
```

### pixelsort

各行または列の中で、輝度に基づいて連続するピクセルの区間をソートします。

| パラメータ   | 型       | デフォルト    | 値の範囲・選択肢           |
|--------------|----------|---------------|---------------------------|
| `threshold`  | 浮動小数 | `0.5`         | `0.0` ～ `1.0`             |
| `direction`  | 文字列   | `horizontal`  | `horizontal`, `vertical`  |
| `jitter`     | 浮動小数 | `0.0`         | `0.0` ～ `1.0`             |

例:

```
pixelsort:threshold=0.4,direction=vertical,jitter=0.1
```

### rgbshift

赤チャンネルを右へ、青チャンネルを左へ `shift` ピクセル水平にずらします（緑チャンネルは固定、端は wrap-around）。`random=true` のとき、各チャンネルのオフセットをシードを用いて `[-shift, shift]` から抽選します。

| パラメータ | 型     | デフォルト | 値の範囲・選択肢      |
|------------|--------|------------|----------------------|
| `shift`    | 整数   | `5`        | 任意の整数（ピクセル数）|
| `random`   | 真偽値 | `false`    | `true`, `false`      |

例:

```
rgbshift:shift=12,random=true
```

### ステップの合成

複数のステップを `|` でつなぐと、左から右の順に各ステップへ前ステップの出力が渡されます:

```
pixelsort:threshold=0.6 | rgbshift:shift=4 | pixelsort:direction=vertical
```

## 再現性

`-s <INT>`（任意の整数シード）を指定すると、同一マシン上だけでなくプラットフォームをまたいでも
**バイナリレベルで同一の出力**が保証されます。具体的には:

- 同じ入力ファイル ＋ 同じパイプライン文字列 ＋ 同じシード → 出力バイト列が完全に一致します。
- グリッチレシピをバージョン管理・共有する際に便利です。

`-s` を省略した場合はシステムの乱数ジェネレータを使用するため、実行ごとに結果が変わります。

## 終了コード

| コード | 意味 |
|--------|------|
| `0`    | 正常終了 |
| `1`    | パイプライン DSL のパースエラー |
| `2`    | 画像の読み込みまたは書き込みエラー（コーデック／IO の失敗） |
| `3`    | 想定外のエラー |

エラーメッセージは `stderr` に出力されます。

## コントリビュート

[CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## ライセンス

BSD-3-Clause。[LICENSE](LICENSE) を参照してください。
