# Firebase setup

> Quanta uses Firebase for two things: **Authentication** (so scans are scoped to a user) and **Firestore / Storage** (the optional cloud mirror of the on-device history). This doc walks through both.

The repo **does not** ship Firebase project credentials. The .gitignore blocks `firebase_options.dart`, `firebase.json`, `google-services.json`, and `GoogleService-Info.plist` so they never accidentally leak. You must generate them locally.

---

## 1 · One-time setup

### 1.1 · Install the CLI tools

```bash
# FlutterFire (preferred for the Flutter side)
dart pub global activate flutterfire_cli

# Firebase CLI
npm install -g firebase-tools
firebase login
```

### 1.2 · Create the Firebase project

1. Go to <https://console.firebase.google.com>.
2. Click **Add project** → name it `quanta-<your-name-or-team>` (e.g. `quanta-hackathon-demo`).
3. Disable Google Analytics if you want a smaller blast radius (you can re-enable it later).
4. Wait for the project to provision, then note the **Project ID** — you'll need it in the next steps.

### 1.3 · Enable Authentication

1. In the new project, go to **Build → Authentication → Get started**.
2. Enable the **Email/Password** and **Google** sign-in providers.
3. Under **Settings → Authorized domains**, add `localhost` (for local dev) and any preview domains you plan to use.

### 1.4 · (Optional) Create Firestore and Storage

1. **Build → Firestore Database → Create database** → start in *test mode* (we'll lock it down later).
2. **Build → Storage → Get started** → default bucket, test-mode rules for now.
3. Note the bucket name (`<project-id>.appspot.com`).

---

## 2 · Wire the Flutter app

From the `quanta_app/` directory:

```bash
flutter pub get
flutterfire configure \
  --project=<project-id> \
  --platforms=android,ios,web,macos,windows
```

`flutterfire configure` does four things:

1. Creates `lib/firebase_options.dart` with the per-platform config.
2. Drops `android/app/google-services.json` (Android).
3. Drops `ios/Runner/GoogleService-Info.plist` (iOS / macOS).
4. Updates `firebase.json` at the project root with the platform map.

All four files are matched by patterns in `.gitignore`, so they stay local. **Do not commit them.**

### 2.1 · Android specifics

If `flutterfire configure` does not place `google-services.json` for you, do it manually:

```bash
# Download from Firebase console → Project settings → Android app
cp ~/Downloads/google-services.json quanta_app/android/app/google-services.json
```

The Gradle config in `quanta_app/android/app/build.gradle.kts` already includes the `com.google.gms.google-services` plugin. No edits needed.

### 2.2 · iOS specifics

```bash
cd quanta_app/ios
pod install
```

Open `Runner.xcworkspace` in Xcode and verify the iOS bundle ID matches the one in the Firebase console.

---

## 3 · Wire the backend

The backend's `auth/firebase.py` uses `firebase-admin` to verify ID tokens sent from the phone.

### 3.1 · Service account

1. Firebase console → **Project settings → Service accounts → Generate new private key**.
2. Save the JSON as `backend/firebase_service_account.json`. The file is matched by the `*firebase-adminsdk*.json` and `*service-account*.json` patterns in `.gitignore` and is never committed.
3. Either:
   - Point `FIREBASE_CREDENTIALS_FILE=firebase_service_account.json` in `backend/.env`, **or**
   - Paste the entire JSON into `FIREBASE_CREDENTIALS_JSON` (single-line, escaped). This is useful for Vercel.

### 3.2 · Local dev shortcut

For local development, set `ALLOW_DEV_AUTH_BYPASS=true` in `backend/.env`. The phone's `firebase_auth_service.dart` falls back to a `test-token` constant when no Firebase user is signed in, and the backend's `auth_middleware.py` accepts it.

```ini
# backend/.env
GOOGLE_API_KEY=...
ALLOW_DEV_AUTH_BYPASS=true
FIREBASE_CREDENTIALS_FILE=firebase_service_account.json
```

**Do not enable the bypass in production.** The dev token is a hard-coded string and any client can claim to be a dev user.

---

## 4 · Firestore data model (optional cloud mirror)

We keep a thin Firestore mirror of the local history for cross-device sync. The on-device `SharedPreferences` is the source of truth; the cloud copy is best-effort.

```
/users/{uid}/
    /scans/{scanId}     — full ScanHistory document
    /coins/ledger       — last N coin events
    /profile            — display name, avatar URL, streak
```

Firestore rules (lock these down before going public):

```
match /users/{uid}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

---

## 5 · Troubleshooting

### 5.1 · "No Firebase App '[DEFAULT]' has been initialized"

You ran the app without `firebase_options.dart` present. Run `flutterfire configure` or copy the file from another teammate.

### 5.2 · Android build fails with "google-services.json missing"

Re-run `flutterfire configure` or copy the JSON manually. The Gradle plugin silently skips configuration when the file is absent, leading to runtime auth failures instead of compile-time errors.

### 5.3 · iOS sign-in returns "developer_error"

The `GoogleService-Info.plist` was generated against a different bundle ID than the one in Xcode. Match them.

### 5.4 · Backend can't verify the ID token

The `firebase-admin` SDK needs the service account JSON. Check `backend/.env`:

```bash
cd backend
. .venv/bin/activate
python -c "import firebase_admin; from firebase_admin import credentials; firebase_admin.initialize_app(credentials.Certificate('firebase_service_account.json'))"
```

If that errors, the JSON is corrupted or revoked. Re-download from the console.

### 5.5 · "The default Firebase app does not exist" on the backend

A second `initialize_app()` call in the same process. Guard it:

```python
if not firebase_admin._apps:
    firebase_admin.initialize_app(credential)
```

`backend/auth/firebase.py` already does this.

---

## 6 · What we deliberately don't use

- **Firebase Cloud Messaging** — no push notifications in v1. The team's roadmap has a "daily streak reminder" feature for v0.2.
- **Firebase Crashlytics** — useful, but adds another SDK. We rely on the team's own logging for now.
- **Firebase Remote Config** — the visualiser templates are checked into the repo for v1.

---

## 7 · Production checklist

Before pointing the app at a real Firebase project:

- [ ] Disable `ALLOW_DEV_AUTH_BYPASS` in `backend/.env`.
- [ ] Tighten Firestore rules to the per-user pattern above.
- [ ] Enable App Check on the phone (`firebase_app_check`) to stop scrapers from generating tokens.
- [ ] Set up a budget alert in the Google Cloud console for the project's Gemini / Cloud Storage spend.
- [ ] Rotate the service account key after the hackathon if it was shared with anyone outside the team.
