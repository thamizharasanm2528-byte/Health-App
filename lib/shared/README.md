# Shared

Cross-cutting code shared by multiple features. Nothing in this directory
should depend on any specific feature module.

## Sub-directories

| Directory      | Purpose                                                                 |
|----------------|-------------------------------------------------------------------------|
| `widgets/`     | Reusable UI components (cards, buttons, charts, progress rings, etc.).  |
| `models/`      | Data classes / entities used across features (e.g. `UserProfile`).     |
| `providers/`   | App-level providers not tied to a single feature (e.g. theme provider).|
| `extensions/`  | Dart extension methods on built-in types (DateTime, String, etc.).      |
