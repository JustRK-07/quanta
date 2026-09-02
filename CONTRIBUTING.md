# Contributing

Thanks for opening this. Quanta is a hackathon-built project, but we'd like it to outlive the weekend. This guide explains how to set up your dev environment, the branch model we use, and the rules of the road for a PR.

---

## 1 · Code of conduct

By participating, you agree to the [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). Be kind. The team will enforce it.

---

## 2 · What we accept

- Bug fixes — anything in [ISSUES.md](ISSUES.md) is fair game.
- New visualiser templates — see §6 below.
- Documentation improvements.
- Test coverage for the backend services.
- Accessibility / RTL polish on the Flutter app.

What we **don't** accept without a discussion first:
- New third-party services (analytics, ads, crash reporters) — they need a team vote.
- Renaming the project (it just got renamed; let's not do that again).
- Removing the dev-bypass path — it's load-bearing for local dev.

---

## 3 · Local setup

You'll need:

- **Flutter** 3.35 or newer, with Dart 3.9+
- **Python** 3.14 (3.11+ should also work; 3.14 is what the team uses)
- **A Firebase project** (free tier is fine) — see [quanta_app/FIREBASE_SETUP.md](quanta_app/FIREBASE_SETUP.md)
- An **iQOO phone** or any Android device / emulator with a camera

### 3.1 · Clone

```bash
git clone git@github.com:JustRK-07/quanta.git
cd quanta
```

### 3.2 · Backend

```bash
cd backend
python3.14 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt

cp .env.example .env
# Add your GOOGLE_API_KEY. Leave ALLOW_DEV_AUTH_BYPASS=true for now.

ALLOW_DEV_AUTH_BYPASS=true .venv/bin/uvicorn main:app --reload --port 8001
```

### 3.3 · Flutter app

```bash
cd ../quanta_app
flutter pub get
flutterfire configure --project=<your-firebase-project-id> --platforms=android
flutter run
```

If you're on an Android emulator, the app talks to `http://10.0.2.2:8001` (which is the host machine's `localhost`). For a physical device, change `_devUrl` in `lib/screens/main_screen.dart` to your laptop's LAN IP.

### 3.4 · One-liner

```bash
make dev
```

This uses the `Makefile` at the repo root to boot both sides with logs tailing.

---

## 4 · Branch model

- **`main`** is always deployable. Every commit on `main` has passed CI.
- **Feature branches** — `feat/<short-slug>` (e.g. `feat/atom-shells-zn`).
- **Bugfix branches** — `fix/<short-slug>` (e.g. `fix/history-detail-overflow`).
- **Docs branches** — `docs/<short-slug>` (e.g. `docs/architecture-diagram`).
- **Refactor branches** — `refactor/<short-slug>` (e.g. `refactor/visualiser-factory`).

We don't use long-running branches. Rebase on `main` before opening a PR.

---

## 5 · Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/) loosely. Format:

```
<type>(<scope>): <one-line summary>

<body — wrap at 72 chars>

<footer — refs, breaking changes>
```

Types we use: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`.

Examples from history:

- `feat(visualiser): add atom renderer for Z=6..Z=30`
- `fix(history-detail): drop demo placeholder image block`
- `chore: ignore firebase_options.dart from git`

---

## 6 · Adding a new visualiser template

This is the single most useful contribution. The flow:

1. Create a JSON template in `backend/templates/visualiser/`. See `projectile_motion.json` for the shape.
2. Add a `topic_keyword → template_id` rule in `backend/routers/visualiser.py`.
3. Write a Flutter widget in `quanta_app/lib/visualiser/your_template.dart`. The widget takes a `VisualiserTemplate` and renders a `CustomPainter`. See `atom_component.dart` for the smallest example.
4. Register the widget in `quanta_app/lib/visualiser/visualiser_factory.dart`.
5. Add a `topic` to the seed data in `quanta_app/lib/storage/history_store.dart` so the demo shows it.
6. Add a screenshot to `screenshots/`.
7. Open a PR with a 30-second screen recording.

---

## 7 · PR rules

- **One concern per PR.** Don't bundle a refactor with a new feature.
- **Write a real description.** What did you change, why, and what did you test? Screenshots for any UI change.
- **Run the tests** before pushing.

  ```bash
  # Backend
  cd backend && .venv/bin/pytest -q

  # Flutter
  cd quanta_app && flutter analyze && flutter test
  ```

- **Keep the diff small.** A PR over 600 lines probably needs splitting.
- **Link the issue.** PRs without an issue are reviewed last.

### 7.1 · Review SLA

We aim for first review within **48 hours** of opening a PR during the hackathon sprint, and within a **week** after. If you don't hear back, ping a maintainer on the WhatsApp group.

### 7.2 · Merge

- One approval from a maintainer.
- All CI checks green.
- Squash-merged with a conventional commit message that summarizes the diff.

---

## 8 · Reporting a vulnerability

**Don't open a public issue.** See [SECURITY.md](SECURITY.md) for the private disclosure path.

---

## 9 · Style

- **Dart** — `flutter analyze` must be clean. Format with `dart format .` before committing.
- **Python** — `ruff check` and `ruff format`. We don't run black/isort; ruff does both.
- **Markdown** — keep line length under 120, use ATX headings, one blank line between blocks.

---

## 10 · License

By contributing, you agree that your contributions are licensed under the project's [MIT license](LICENSE).
