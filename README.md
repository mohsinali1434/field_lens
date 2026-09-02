# FieldLens

Offline-first field inspection and reporting app built with Flutter.

## Features

- **Dashboard** — overview stats, recent inspections, quick actions
- **Inspections** — create, manage, and archive field inspections
- **Observations** — structured findings with categories, severity, and AI suggestions
- **Media** — photo capture, voice notes, OCR text extraction
- **Checklists** — template-based execution with pass/fail tracking
- **Timeline** — activity log per inspection
- **Reports** — on-device PDF generation with optional signature
- **Search** — debounced local search across inspections and observations
- **Backup** — export ZIP archive and share
- **Offline-first** — SQLite via Drift, no network required

## Architecture

```
lib/
├── app/           # App shell, router, DI, theme
├── core/          # Database, services, widgets, utils
└── features/      # Feature-first Clean Architecture
    ├── dashboard/
    ├── inspections/
    ├── observations/
    ├── media/
    ├── checklists/
    ├── reports/
    ├── search/
    ├── settings/
    └── onboarding/
```

**Stack:** Flutter 3.47 (FVM `stable`), BLoC, GetIt, GoRouter, Drift/SQLite, `material_ui`

## Getting Started

```bash
# Install FVM and use stable channel
fvm use stable
fvm flutter pub get

# Run code generation (if schema changes)
fvm dart run build_runner build --delete-conflicting-outputs

# Run tests
fvm flutter test

# Run the app
fvm flutter run
```

## Platform Notes

- **Android:** Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, 16KB page size support
- **iOS:** Minimum deployment target 15.0
- **Permissions:** Camera, microphone, and location are requested at runtime
