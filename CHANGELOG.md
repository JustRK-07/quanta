# Changelog

All notable changes to Quanta are documented in this file. Dates are ISO-8601.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project adheres to [Semantic Versioning](https://semver.org/) as far as a hackathon build can.

---

## [Unreleased]

### Added
- Dev-bypass auth flow: `Bearer test-token` is accepted when `ALLOW_DEV_AUTH_BYPASS=true` on the backend, and `firebase_auth_service.dart` returns the same constant when no Firebase session is active.
- `seedDemoData()` in `quanta_app/lib/storage/history_store.dart` populates six representative scans (projectile, quadratic, water, Bohr atom, SHM, wave) so a fresh install has something to look at.
- Demo placeholder detection in `history_detail_screen.dart` so seeded scans don't render a broken-image box.
- Project renamed from **Stemly** to **Quanta** across LICENSE, env templates, and the GitHub remote.

### Changed
- Backend now serves on port `8001` by default during the hackathon (port `8000` was occupied by another service on the dev machine).
- `lib/screens/main_screen.dart` and the Firebase client point at `http://10.0.2.2:8001` for Android emulators; `_devUrl` is the only place to change this.

### Removed
- 11 top-level and app-level Markdown docs consolidated into this single set. The old files (`ARCHITECTURE.md`, `BRANDING.md`, `CODE_OF_CONDUCT.md`, etc.) are recreated in this commit with iQOO-hackathon-aware content.
- 118 user-uploaded JPEGs (`backend/static/uploads/*.jpg`) untracked — they are runtime artefacts, not source.

---

## [0.1.0] — 2026-09-02 · "Bengaluru cut"

The build that went to the iQOO Hackathon City Battle in Bengaluru on Aug 29–30, 2026.

### Added
- Flutter mobile client (`quanta_app/`) targeting Android, iOS, web, macOS, Linux, Windows.
  - On-device OCR via `google_mlkit_text_recognition`.
  - Custom `CustomPainter` visualiser widgets: projectile, SHM, atom, free-fall, wave, equation plotter, generic diagram.
  - Three-tab Scan Result view: **AI Visualiser / AI Quiz / AI Notes**.
  - Local-first history with `SharedPreferences` and a `Quanta` coin reward loop.
  - Dark theme with the teal/mint/amber palette.
- FastAPI backend (`backend/`).
  - Routers: `scan`, `visualiser`, `history`, `notes`, `quiz`, `chat`, `users`.
  - Hardcoded visualiser template dispatcher in `routers/visualiser.py` covering projectile, SHM, atom, water/methane/ammonia/CO2, free fall, sine wave, circuits, optics, generic.
  - Firebase ID-token middleware with dev bypass.
  - Local-disk storage of uploads (`static/uploads/`).
  - Vercel-ready (`vercel.json` + `api/index.py`).
- GitHub-side scaffolding: workflows (`backend-ci`, `flutter-ci`, `docs-check`, `stale`, `labeler`, `greet-first-timers`), issue templates, PR template, dependabot.

### Known issues
- Demo placeholder image paths render as a blue box if not detected by the placeholder filter — fixed in the unreleased section above.
- Backend on port `8000` collides with a system service; the team uses `8001`.
- The iOS build needs a real bundle ID in the Firebase console before a TestFlight upload.
- No on-device model for topic classification yet — falls back to keyword matching on the backend.

---

## [0.0.1] — 2026-08-12 · "Pre-Bengaluru spike"

The first runnable spike: a Flutter app that captures an image, OCRs it, and shows the raw text. No visualiser, no notes, no quiz. Built in three evenings before the hackathon weekend.

### Added
- Flutter app shell, dark theme, bottom nav.
- `image_picker` capture → ML Kit OCR → display.
- FastAPI `POST /scan` that accepts the OCR text and echoes it back.

---

## Pre-history — before 2026-08-12

The project was prototyped as **Stemly** in early 2025 as a class XII physics revision tool. The team kept the OCR pipeline and the visualiser idea; everything else (auth, coin, quiz, multi-subject) was added in the run-up to the iQOO Hackathon.

---

## Versioning notes

- We will bump the **minor** version for any user-visible feature.
- We will bump the **patch** version for fixes that don't change the user-facing flow.
- We reserve **major** versions for breaking changes to the on-device history schema, the visualiser template format, or the auth contract.
