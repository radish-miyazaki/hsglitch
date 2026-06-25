English | [日本語](README.ja.md)

# hsglitch

A composable, deterministic glitch-art pipeline CLI built in Haskell.

## Overview

`hsglitch` is a type-safe, reproducible glitch-art transformation tool. It lets you
compose multiple image transformation passes into a single pipeline, controlled by a
simple DSL. Because every pass is seeded deterministically, the same command always
produces the same output.

## Build

Requires GHC 9.6+ and cabal 3.0+.

```bash
cabal update
cabal build all
cabal test all
```

## Usage

```bash
hsglitch -i in.png -o out.png -p "pixelsort:threshold=0.5 | rgbshift:shift=10" -s 42
```

**Flags**

| Flag | Description |
|------|-------------|
| `-i` | Input image path |
| `-o` | Output image path |
| `-p` | Pipeline DSL string (passes separated by `\|`) |
| `-s` | Random seed (integer; omit for a random seed) |

## Pipeline DSL

Passes are separated by `|`. Each pass is `name:key=value,key=value,...`.

Example passes:

- `pixelsort:threshold=0.5` — sort pixels by brightness above threshold
- `rgbshift:shift=10` — shift RGB channels by N pixels
- `noise:amount=0.1,seed=7` — add uniform noise

## Reproducibility

Setting `-s <seed>` guarantees bit-for-bit identical output across runs and platforms,
making it easy to version-control your glitch recipes.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

BSD-3-Clause. See [LICENSE](LICENSE).
