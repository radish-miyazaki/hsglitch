[English](README.md) | 日本語

# hsglitch

Haskell で書かれた、コンポーザブルで決定論的なグリッチアート・パイプライン CLI です。

## 概要

`hsglitch` は型安全で再現可能なグリッチアート変換ツールです。シンプルな DSL で複数の
画像変換パスを 1 つのパイプラインに組み合わせることができます。各パスはシードで
決定論的に制御されるため、同じコマンドは常に同じ出力を生成します。

## ビルド

GHC 9.6 以上と cabal 3.0 以上が必要です。

```bash
cabal update
cabal build all
cabal test all
```

## 使い方

```bash
hsglitch -i in.png -o out.png -p "pixelsort:threshold=0.5 | rgbshift:shift=10" -s 42
```

**フラグ一覧**

| フラグ | 説明 |
|--------|------|
| `-i` | 入力画像パス |
| `-o` | 出力画像パス |
| `-p` | パイプライン DSL 文字列（パスを `\|` で区切る） |
| `-s` | 乱数シード（整数。省略するとランダムなシードを使用） |

## パイプライン DSL

パスは `|` で区切ります。各パスの形式は `name:key=value,key=value,...` です。

パスの例:

- `pixelsort:threshold=0.5` — 明度のしきい値を超えるピクセルをソート
- `rgbshift:shift=10` — RGB チャンネルを N ピクセルずらす
- `noise:amount=0.1,seed=7` — 一様ノイズを加算

## 再現性

`-s <seed>` を指定すると、実行環境・プラットフォームにかかわらず
ビット単位で同一の出力が得られます。グリッチレシピをバージョン管理するのに便利です。

## コントリビュート

[CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## ライセンス

BSD-3-Clause。[LICENSE](LICENSE) を参照してください。
