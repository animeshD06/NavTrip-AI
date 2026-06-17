# NavTrip AI Frontend

Flutter app for the AI Tourist Map and Smart Travel Planner.

## Tooling

This repo currently uses a local Flutter SDK at `../tools/flutter`.

```bash
cd frontend
..\tools\flutter\bin\flutter.bat pub get
..\tools\flutter\bin\flutter.bat run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:4000/api
```

For Android emulator, use:

```bash
..\tools\flutter\bin\flutter.bat run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

Validation:

```bash
..\tools\flutter\bin\flutter.bat analyze
..\tools\flutter\bin\flutter.bat test
```
