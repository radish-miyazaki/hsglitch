# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.1.0.0] - 2026-06-25

### Added
- Initial project scaffolding.
- PNG and JPEG image read/write with automatic RGB8 normalisation via JuicyPixels.
- `pixelsort` filter: sort pixel runs by brightness with configurable `threshold` (default 0.5), `direction` (`horizontal`|`vertical`, default `horizontal`), and `jitter` (default 0.0).
- `rgbshift` filter: shift RGB channels by a fixed or random offset with configurable `shift` (default 5) and `random` (`true`|`false`, default `false`).
- Composable pipeline DSL: chain any number of filter steps with `|` separators.
- `--seed` / `-s` flag for deterministic reproducibility: same input + same pipeline + same seed guarantees binary-identical output across runs and platforms.
