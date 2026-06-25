# Contributing

## Commit messages

This project follows [Conventional Commits](https://www.conventionalcommits.org/).
Use one of: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`.

Example: `feat(parser): support vertical direction`

## Development

- Package manager: **cabal only** (do not use stack).
- Format: `cabal run -- fourmolu --mode inplace src app test` (or use the installed `fourmolu`).
- Lint: `hlint src app test`.
- Test: `cabal test`.
