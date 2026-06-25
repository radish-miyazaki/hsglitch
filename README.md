English | [日本語](README.ja.md)

# hsglitch

A composable, deterministic glitch-art pipeline CLI built in Haskell.

## Overview

`hsglitch` is a type-safe, reproducible glitch-art transformation tool. It lets you
compose multiple image transformation passes into a single pipeline, controlled by a
simple DSL. Because every pass is seeded deterministically, the same command always
produces the same output.

## Build & Install

Requires GHC 9.6+ and cabal 3.0+.

```bash
cabal update
cabal build all
cabal test all
```

Run directly without installing:

```bash
cabal run hsglitch -- -i in.png -o out.png -p "pixelsort | rgbshift" -s 42
```

## Usage

```
hsglitch -i <FILE> -o <FILE> -p <DSL> [-s <INT>]
```

**Flags**

| Flag | Long form | Required | Description |
|------|-----------|----------|-------------|
| `-i` | `--input`    | Yes | Input image path (PNG or JPEG) |
| `-o` | `--output`   | Yes | Output image path (PNG or JPEG) |
| `-p` | `--pipeline` | Yes | Filter pipeline DSL string |
| `-s` | `--seed`     | No  | Random seed (integer); omit for system randomness |

**Concrete example**

```bash
cabal run hsglitch -- \
  -i photo.jpg \
  -o glitched.png \
  -p "pixelsort:threshold=0.3,direction=vertical | rgbshift:shift=8,random=true" \
  -s 42
```

## Pipeline DSL

Steps are separated by `|`. Each step has the form:

```
name[:key=value[,key=value...]]
```

### pixelsort

Sort contiguous pixel runs by brightness within each row or column.

| Parameter   | Type            | Default      | Range / Values          |
|-------------|-----------------|--------------|-------------------------|
| `threshold` | float           | `0.5`        | `0.0` – `1.0`           |
| `direction` | string          | `horizontal` | `horizontal`, `vertical` |
| `jitter`    | float           | `0.0`        | `0.0` – `1.0`           |

Example:

```
pixelsort:threshold=0.4,direction=vertical,jitter=0.1
```

### rgbshift

Horizontally shift the red channel right and the blue channel left by `shift` pixels (the green channel stays fixed), wrapping around at the edges. With `random=true`, each channel's offset is drawn from `[-shift, shift]` using the seed.

| Parameter | Type    | Default | Range / Values      |
|-----------|---------|---------|---------------------|
| `shift`   | integer | `5`     | any integer (pixels)|
| `random`  | bool    | `false` | `true`, `false`     |

Example:

```
rgbshift:shift=12,random=true
```

### Composing steps

Multiple steps are chained with `|`; they execute left to right, each receiving
the output of the previous step:

```
pixelsort:threshold=0.6 | rgbshift:shift=4 | pixelsort:direction=vertical
```

## Reproducibility

Passing `-s <INT>` (any integer seed) guarantees **binary-level identical output**
across runs on the same machine and across platforms. This means:

- Same input file + same pipeline string + same seed → identical output bytes.
- Useful for version-controlling glitch recipes and sharing them reproducibly.

Omitting `-s` draws from the system random generator, so each run differs.

## Exit Codes

| Code | Meaning |
|------|---------|
| `0`  | Success |
| `1`  | Pipeline DSL parse error |
| `2`  | Image read or write error (codec / IO failure) |
| `3`  | Unexpected error |

Error messages are written to `stderr`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

BSD-3-Clause. See [LICENSE](LICENSE).
