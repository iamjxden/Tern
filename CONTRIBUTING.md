# Contributing to HumanNode

## Development Setup

```bash
git clone --recursive https://github.com/iamjxden/nomad.git
cd nomad
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Code Style

- Dart conventions per `analysis_options.yaml`
- No comments in code (code should be self-documenting)
- Prefer `const` constructors
- Single quotes for strings
- Trailing commas on multi-line widgets
- Order: imports → constants → widgets → logic

## Commit Convention

```
type(scope): description

Types: feat, fix, refactor, docs, test, chore, perf, ci
Scopes: inference, agent, tools, chat, models, notes, settings, storage, ui, native, docs, ci
```

## Pull Request Process

1. Fork the repo
2. Create a feature branch from `main`
3. Implement with tests
4. Run `flutter analyze` — must pass
5. Run `flutter test` — must pass
6. Submit PR with description and screenshots if UI changes

## Project Architecture

See [README.md](README.md#architecture) for the full architecture diagram and data flow.
