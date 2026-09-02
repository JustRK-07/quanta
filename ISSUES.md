# Issues

> How we triage bug reports, feature requests, and questions. Read this before opening an issue — it might save you a round trip.

---

## 1 · Before you open anything

- **Search first.** Use GitHub's search bar. The issue you're about to file probably exists.
- **Check the troubleshooting section** in the relevant doc:
  - [quanta_app/FIREBASE_SETUP.md](quanta_app/FIREBASE_SETUP.md) for auth, Firestore, and storage questions.
  - [backend/readme.md](backend/readme.md) for backend setup, ports, and env vars.
  - [ARCHITECTURE.md](ARCHITECTURE.md) for the data flow and the visualiser dispatch rules.
- **Try the latest commit.** Your bug might already be fixed on `main` and not yet tagged.

If the issue is a **security vulnerability**, do not open a public issue. See [SECURITY.md](SECURITY.md).

---

## 2 · Templates

We have three issue templates:

- **Bug report** — something that worked and now doesn't, or never worked.
- **Feature request** — a capability we should add.
- **Question** — usage, setup, or "how do I…".

Pick the closest match. If none fits, the issue is probably a discussion; reach us on the WhatsApp group.

---

## 3 · What a great bug report looks like

```markdown
## What I did
1. Opened the app on iQOO 13, Android 16, build `0.1.0+7`.
2. Tapped "Scan to Learn" → captured a photo of a projectile-motion problem.
3. The app returned "Topic: Unknown" and an empty visualiser.

## What I expected
The visualiser should have shown the projectile_motion template with v₀ and θ populated from the photo.

## What happened
- "AI Visualiser" tab shows the placeholder grey box.
- "AI Notes" tab is empty.
- Logcat: `Error: no template matched` from `VisualiserFactory`.

## Environment
- Phone: iQOO 13 (OriginOS 6, Android 16)
- Backend: uvicorn on http://10.0.2.2:8001, .env with `ALLOW_DEV_AUTH_BYPASS=true`
- App build: `flutter build apk --debug`, install via adb

## Photos
[attach or link]
```

The more we know, the faster we can fix it. **No bug report is too detailed.**

---

## 4 · Triage labels

We use these labels on every issue:

| Label | Meaning |
|---|---|
| `bug` | Something is broken. |
| `enhancement` | A small improvement. |
| `feature` | A larger capability, may need a design discussion. |
| `question` | Needs an answer, not a code change. |
| `docs` | Documentation only. |
| `good first issue` | A small, well-scoped change for a new contributor. |
| `help wanted` | The team is busy; we'd love a PR. |
| `wontfix` | We considered it and decided not to address it. |
| `duplicate` | Already tracked elsewhere. |
| `priority: high` | Blocking the hackathon demo. |
| `priority: low` | Will get to it eventually. |
| `area: app` | Flutter client. |
| `area: backend` | FastAPI service. |
| `area: ai` | Gemini prompt engineering, model integration. |
| `area: visualizer` | CustomPainter widgets. |
| `area: docs` | Markdown docs in this repo. |

Issues without a label are pre-triage and usually get one within a week.

---

## 5 · Severity vs priority

- **Severity** — how bad is the bug? (data loss, crash, cosmetic, etc.)
- **Priority** — when will we fix it? (high, medium, low)

A cosmetic typo is low severity. A typo on the demo day pitch slide is high priority. We use both axes when triaging.

---

## 6 · The issue lifecycle

```
opened → triaged (labelled) → accepted / wontfix / duplicate
                              ↓
                              accepted
                              ↓
                        assigned → in-progress → in-review → closed (via PR)
```

If your issue is `wontfix`, we explain why in a comment. If you disagree, the door is open to make a case with a PR.

---

## 7 · SLAs (best-effort)

- **First response** — within 48 hours during the hackathon sprint, one week otherwise.
- **Triage label** — within a week.
- **Fix for `priority: high`** — before the next city battle.
- **Fix for `priority: low`** — when someone has time.

We are a four-person team doing this around university / work. We are not an on-call rotation. Please be patient with us, and please be specific in your reports so the time we do spend is well spent.

---

## 8 · Currently open themes

These are the categories of work we're actively thinking about. Open an issue if you want to take one.

- **Visualiser library** — adding templates for optics, circuits, organic chemistry molecules, vector geometry.
- **On-device AI** — running a quantised topic classifier on the phone so the backend round-trip is optional.
- **Cross-device sync** — Firestore rules + conflict-free history merge.
- **Accessibility** — TalkBack labels, dynamic type, high-contrast palette.
- **i18n** — Hindi, Tamil, Telugu, Kannada, Marathi translations of the notes.

---

## 9 · Past issues

The full history lives on the GitHub Issues tab. We don't curate a public archive in this repo.
