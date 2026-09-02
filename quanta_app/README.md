# quanta_app

> The Flutter mobile client. The companion to the top-level [README](../README.md); this file is the Flutter-specific setup, project layout, and conventions.

---

## 1 · TL;DR

```bash
cd quanta_app
flutter pub get
flutterfire configure --project=<your-firebase-project-id> --platforms=android,ios
flutter run
```

For the iQOO Hackathon dev loop, set the backend to dev mode (`ALLOW_DEV_AUTH_BYPASS=true`) and the phone will talk to `http://10.0.2.2:8001` without any Firebase setup.

---

## 2 · Project layout

```
quanta_app/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart       # generated, gitignored
│   ├── screens/                    # UI
│   ├── visualiser/                 # CustomPainter widgets
│   ├── services/                   # auth, gemini, history sync
│   ├── storage/                    # SharedPreferences-backed
│   ├── models/
│   ├── widgets/
│   ├── quiz/
│   └── theme/
├── assets/
│   ├── fonts/                      # Inter, JetBrains Mono
│   ├── team/                       # profile photos
│   └── images/
├── android/                        # Kotlin, Gradle KTS
├── ios/                            # Swift
├── web/
├── macos/ linux/ windows/
├── test/                           # flutter test
├── pubspec.yaml
├── analysis_options.yaml
└── vercel.json                     # web deploy
```

See [ARCHITECTURE.md § 2](../ARCHITECTURE.md) for what lives in each file.

---

## 3 · Pinned dependencies

The team uses a recent Flutter (3.35+) on Dart 3.9+. Notable packages:

- `firebase_core`, `firebase_auth` — auth and project init.
- `google_mlkit_text_recognition` — on-device OCR.
- `image_picker` — camera / gallery capture.
- `http` — backend client.
- `shared_preferences` — local persistence.
- `provider` — state management.
- `path_provider` — file paths.
- `http_parser` — multipart uploads.

For the full list, see [pubspec.yaml](pubspec.yaml).

---

## 4 · The dev loop

```bash
# Terminal 1 — backend
cd ../backend
ALLOW_DEV_AUTH_BYPASS=true .venv/bin/uvicorn main:app --reload --port 8001

# Terminal 2 — Flutter
cd quanta_app
flutter run
```

The phone build talks to `http://10.0.2.2:8001` (Android emulator → host `localhost`). For a physical device, change `_devUrl` in `lib/screens/main_screen.dart` to your laptop's LAN IP.

### 4.1 · Switching to production

```dart
// lib/screens/main_screen.dart
static const bool _isProduction = false;  // flip to true
```

…then set `static const String _prodUrl = "https://quanta-backend.vercel.app";` (or your own deploy URL).

---

## 5 · The dev auth bypass

`lib/services/firebase_auth_service.dart` returns the constant `test-token` when no Firebase user is signed in. The backend accepts it when `ALLOW_DEV_AUTH_BYPASS=true`. This is the loop that lets the app run end-to-end during the hackathon with no Firebase project.

```dart
static const String _kDevBypassToken = 'test-token';

Future<String> getIdToken() async {
  if (_cachedIdToken != null) return _cachedIdToken!;
  return _kDevBypassToken;
}
```

**Production:** remove the bypass, set up a real Firebase project, and follow [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

---

## 6 · Visualiser widgets

Each `lib/visualiser/<topic>.dart` is a `StatefulWidget` with a `CustomPainter`. The widget receives a `VisualiserTemplate` and reads `params` for the current values. Sliders update the params and call `setState()`.

| File | Topic | Inputs |
|---|---|---|
| `projectile_motion.dart` | Projectile motion | `v0`, `angle_deg`, `g` |
| `shm_component.dart` | Simple harmonic motion | `m`, `k`, `A` |
| `atom_component.dart` | Bohr atom | `Z`, `A` |
| `free_fall_component.dart` | Free fall | `h`, `g` |
| `graph_component.dart` | Sine wave / generic | `A`, `f`, `v` |
| `equation_plotter.dart` | Equation y = f(x) | `expression` |
| `kinematics_component.dart` | Generic kinematics | topic-keyed |
| `optics_component.dart` | Lens / mirror | `f`, `object_distance` |
| `generic_diagram.dart` | Fallback | text only |

To add a new topic: see [CONTRIBUTING.md § 6](../CONTRIBUTING.md).

---

## 7 · Local data

`SharedPreferences` keys the app uses:

- `quanta_history_v1` — JSON array of `ScanHistory`.
- `quanta_coins_balance_v1` — int.
- `quanta_coins_ledger_v1` — base64-encoded list of coin events.
- `quanta_coins_streak_v1` — int.
- `quanta_coins_last_date_v1` — ISO date.

The format is stable across the v1 line. A future v2 will add a version prefix and a migration path.

---

## 8 · Theme

`lib/theme/quanta_theme.dart` defines the dark and light palettes. We use dark as the default (it's how a textbook looks at 11 PM). The light palette exists; the toggle is in `lib/screens/settings_screen.dart`.

`BRANDING.md` (../BRANDING.md) is the source of truth for the visual identity.

---

## 9 · Tests

```bash
flutter test
```

The test suite is small (the team is racing the hackathon clock). The current `test/widget_test.dart` exercises the splash screen and the bottom nav.

For backend integration testing, see the backend's `pytest -q`.

---

## 10 · Build for the iQOO

```bash
flutter build apk --debug            # for the dev loaner
flutter build apk --release          # for a public deploy
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

For a production push we'd:

1. Set up a real Firebase project (see [FIREBASE_SETUP.md](FIREBASE_SETUP.md)).
2. Set `android/app/build.gradle.kts` to a release signing config.
3. Build a signed APK or App Bundle.
4. Upload to Play Console internal testing.

---

## 11 · Known issues

- **OCR accuracy on handwritten equations** — Google's ML Kit does well on printed text, less well on cursive handwriting. We treat the OCR as a hint; the user can edit the extracted text before submitting.
- **iOS Google sign-in** — needs the bundle ID to match the one in `GoogleService-Info.plist`. The CI for iOS is not yet set up.
- **Web build** — the visualiser widgets work in the browser, but the camera capture falls back to file picker. Useful for demos; not the primary target.

---

## 12 · Conventions

- `dart format .` before committing.
- `flutter analyze` must be clean.
- File names use `snake_case`; class names use `PascalCase`; constants use `lowerCamelCase` with `_k` prefix for module-level consts.
- Every screen has a corresponding test in `test/screens/<name>_test.dart`. (WIP during the hackathon sprint.)
- Avoid pulling in new third-party packages without a team discussion. The dependency surface is small on purpose.

---

## 13 · License

MIT — see [LICENSE](../LICENSE).
