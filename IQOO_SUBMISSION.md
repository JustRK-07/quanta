# iQOO Hackathon 2026 — Submission brief

> This is the one-pager the team uses to pitch Quanta at the city battle. It maps the screenshots in `screenshots/` to the rubric the iQOO Hackathon publishes, and tells the jury exactly which screens to look at for which criteria.

---

## 1 · The product in one sentence

Quanta turns a photographed textbook equation into an interactive visualiser, a set of revision notes, and a five-question quiz — in under thirty seconds, on the iQOO phone.

---

## 2 · Track

**Smart Education.** AI-powered learning, study workflows, assessment, and the daily operations of a classroom. The local / on-device bias earns brownie points: the OCR runs on the iQOO's NPU, and the visualiser widgets are pure Flutter `CustomPainter` — no remote canvas.

---

## 3 · The five-minute demo script

1. **Open the app on the loaner iQOO.** *0:00–0:30* — "This is Quanta. Scan → Visualise → Learn. Three steps. No login wall in dev."
2. **Snap a projectile-motion problem** from the book we brought. *0:30–1:30* — show the camera, the OCR overlay, the tap-to-submit.
3. **AI Visualiser tab.** *1:30–2:30* — "It picked projectile motion. Here's the parabola. Here's the velocity vector at the apex. Drag the slider for launch angle."
4. **AI Notes tab.** *2:30–3:30* — "The same problem, expanded: concept, three formulas, three key points, the worked example. Scroll through."
5. **AI Quiz tab.** *3:30–4:00* — five questions, score, ten Quanta coins awarded.
6. **Wrap.** *4:00–5:00* — "It's local-first, so the History tab works offline. The Quanta coin loop is the retention hook. We're shipping under MIT, and the demo is a fresh clone + `make dev`."

Total: 5 minutes, no slides.

---

## 4 · Rubric mapping

### 4.1 · End product quality (30%, jury)

**Score: strong.** The full flow works on the loaner iQOO with no manual setup beyond the dev-bypass env flag. The screenshots in `screenshots/` are from a Pixel 6 emulator at the same resolution and theme as the loaner.

- `screenshots/Screenshot_20260902_144300.png` — Home / "Scan to Learn" tile.
- `screenshots/Screenshot_20260902_144349.png` — AI Visualiser, projectile motion with velocity vector at the apex.
- `screenshots/Screenshot_20260902_144428.png` — AI Visualiser, Bohr atom (Z = 6 carbon), two shells, six electrons.
- `screenshots/Screenshot_20260902_144452.png` — AI Visualiser, sine wave from the wave-on-string template.
- `screenshots/Screenshot_20260902_144415.png` — AI Notes, projectile motion (concept + formulas + key points).
- `screenshots/Screenshot_20260902_144527.png` — AI Notes, SHM (concept + formulas + worked example).

### 4.2 · Novelty and impact (20%, jury)

**Score: strong.** Most "AI education" apps in this category are chat wrappers. Quanta has a real product loop — capture, see, learn, earn, repeat — and the visualiser is something the user can poke at, not just read.

The loop survives offline: scans live in `SharedPreferences`; the History tab works on a flight.

### 4.3 · HackTracker — creative phone use (15%, device data)

**Score: solid.** Camera, on-device ML Kit OCR, parameter sliders driving the `CustomPainter` at the device's refresh rate, persistent local storage, accelerometer hooks for v0.2.

We will demonstrate the camera + OCR + touch interaction on the iQOO. The `HackTracker` data will show: camera-open duration, OCR invocations, slider interactions, scan completions.

### 4.4 · Technical depth (15%, jury)

**Score: strong.**

- **Custom `CustomPainter` widgets** for every visualisation. No third-party chart library, no remote canvas. The projectile widget computes the parabola point-by-point in `Path` and re-renders on slider changes.
- **Templated backend** with deterministic keyword dispatch (`routers/visualiser.py`) plus an AI fallback. New topics are JSON + a Flutter widget.
- **Local-first persistence** with a custom coin ledger.
- **Dev-bypass auth** with a real Firebase path side-by-side.

### 4.5 · HackTracker — Office Kit usage (10%, device data)

**Score: solid.** Office Kit is our primary build / demo tool. During Red Light we mirror the laptop to the phone, drop the freshly-built APK over the bridge, and demo on the loaner without picking the laptop up. During Green Light we run the IDE on the laptop and the phone stays in the loop through Office Kit.

Counts and durations will be visible to HackTracker: screen-mirror sessions, file transfers, clipboard events.

### 4.6 · Demo and presentation (10%, jury)

**Score: strong.** Five minutes, no slides, all live. The product is the slide deck. Two dry-runs scheduled before the city battle.

---

## 5 · Why we chose this track

- We tried three tracks during the pre-Bengaluru spike. The Smart Education brief was the one where the demo made a mentor's eyes light up the most.
- The phone's camera is the only sensor we really need. We're not pretending the accelerometer or GPS are central.
- The user is on a bus, a metro, or a boring lecture. They have thirty minutes. Quanta fits in their pocket and their time budget.

---

## 6 · What's intentionally out of scope

- **A full LMS.** Quanta scans, visualises, and quizzes. It does not assign, track, or grade a class.
- **A content marketplace.** Templates are in the repo. The team writes them.
- **Cross-device sync.** v1 is local-first. Firestore sync is a v0.2 deliverable.
- **iPad / tablet layouts.** Mobile-first by design.

---

## 7 · The team

| Name | Role | From |
|---|---|---|
| Dakshin | Full-stack + backend lead | Vishwakarma Institute of Technology Pune |
| Nihith | Flutter + visualisation | Vishwakarma Institute of Technology Pune |
| Shreram | AI services + quiz generation | Vishwakarma Institute of Technology Pune |
| Vibin | Design + product | Vishwakarma Institute of Technology Pune |

Reach the team through the WhatsApp group or open an issue on the repo.

---

## 8 · How to evaluate

```bash
git clone https://github.com/JustRK-07/quanta.git
cd quanta
make dev
```

Two terminals. The phone connects to the laptop on `10.0.2.2:8001`. The full loop runs in under a minute on a clean checkout.

---

## 9 · Appendix — the screenshots in order

| File | What it shows | Rubric hit |
|---|---|---|
| `screenshots/Screenshot_20260902_144300.png` | Home — "Scan to Learn" tile, bottom nav | End product quality (30%) |
| `screenshots/Screenshot_20260902_144329.png` | Scan capture, OCR overlay | Phone use, technical depth |
| `screenshots/Screenshot_20260902_144349.png` | AI Visualiser — projectile motion with velocity vector | Novelty, end product |
| `screenshots/Screenshot_20260902_144403.png` | Scan Result, AI Notes tab | End product, technical depth |
| `screenshots/Screenshot_20260902_144415.png` | AI Notes — projectile (concept + formulas + key points) | End product quality |
| `screenshots/Screenshot_20260902_144428.png` | AI Visualiser — Bohr atom, Z = 6 | Novelty, technical depth |
| `screenshots/Screenshot_20260902_144437.png` | AI Quiz tab | End product, retention loop |
| `screenshots/Screenshot_20260902_144452.png` | AI Visualiser — sine wave | Novelty, end product |
| `screenshots/Screenshot_20260902_144458.png` | History list | Local-first architecture |
| `screenshots/Screenshot_20260902_144507.png` | History detail, scan metadata | End product, retention |
| `screenshots/Screenshot_20260902_144527.png` | AI Notes — SHM | End product, technical depth |
| `screenshots/probe.png` | Test capture from the in-app image picker | Engineering setup |

Twelve captures. The deck uses six; the rest are in the appendix.
