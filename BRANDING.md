# Branding

> How Quanta presents itself — name, voice, and visual identity. Use this as the single source of truth when you write copy, design a screen, or talk to a user.

---

## 1 · The name

**Quanta** — plural of *quantum*. The smallest discrete unit of a physical property. The name is short, distinctive, and carries the right connotation for a STEM learning product: small, precise, and additive. Scan one quanta of knowledge, then another.

- **Pronounced** — *kwon-tah*
- **Capitalisation** — Quanta, never QUANTA, never quanta (except in URLs / `snake_case` identifiers).
- **Plural** — there is no plural form we use. "Quanta" is itself plural.

### 1.1 · Why we changed it

The project was originally prototyped as **Stemly**. We renamed to Quanta in late August 2026 during the iQOO Hackathon 2026 build sprint for a sharper, more distinctive identity. The old name still appears in a few Vercel deploys and Android package paths (`com.example.quanta_app`, `quanta_app/`) — those will move in a future migration.

---

## 2 · Tagline

> **Scan → Visualize → Learn**

The three steps describe the user journey exactly. They map to the three tabs inside a Scan Result: **AI Visualiser** / **AI Quiz** / **AI Notes**.

A longer pitch we use in deck slides:

> Point your phone at a textbook equation. Quanta reads the page, draws the diagram, and turns the worked example into revision notes and a five-question quiz — all in under thirty seconds.

---

## 3 · Voice and tone

- **Direct, never condescending.** "Quanta recognised projectile motion" — not "Wow, look at that cool thing we made for you!"
- **Curious, not lecturing.** "Here is the parabola at 20 m/s. Drag the slider to see how the range changes with launch angle." — not "Range is computed by R = v² sin(2θ)/g."
- **First-person plural when speaking for the team**, second person for the user. "We built this for the thirty minutes before the bus." not "You, the user, are expected to..."
- **Indian English** is fine. The team writes in India; users are mostly Indian students and working professionals. We do not Americanise spellings or word order to sound polished.

### 3.1 · Banned phrases

- "AI-powered" without saying what model, what latency, what the user does with it.
- "Revolutionary" / "game-changing" / "next-gen" / "disruptive".
- "We leverage cutting-edge technology" — show, don't tell.
- Marketing superlatives ("the best", "the only") without a citation.

### 3.2 · Phrases we like

- "Thirty seconds."
- "Your phone, your notes, your coin."
- "Scan → Visualise → Learn."
- "Built for the bus, the metro, and the boring lecture."

---

## 4 · Visual identity

### 4.1 · Palette

| Token | Value | Used for |
|---|---|---|
| `--quanta-ink` | `#0B1220` | Background, dark mode primary surface |
| `--quanta-ink-soft` | `#111A2C` | Cards, bottom nav |
| `--quanta-teal` | `#0F766E` | Primary brand colour, the "Scan to Learn" tile, accents |
| `--quanta-teal-soft` | `#1FA8A0` | Highlights, active states |
| `--quanta-mint` | `#9FF6E0` | Success states, completed scans |
| `--quanta-amber` | `#F5C26B` | Star, streak, coin |
| `--quanta-coral` | `#FF7A6B` | Quiz errors, destructive |
| `--quanta-cream` | `#F5F1E8` | Light-mode text on dark, paper-card background |

The teal/mint/amber combo came from looking at the textbooks the team grew up with — page corners that had been thumbed a hundred times. We want the app to feel like the back cover of a well-loved NCERT book, not a SaaS dashboard.

### 4.2 · Typography

- **Headings & body** — `Inter` (variable, semi-bold for headings).
- **Code, formulas, parameters** — `JetBrains Mono`.
- Both are bundled in `quanta_app/assets/fonts/`.

### 4.3 · Logo

The Quanta logo is a single "Q" with a tangent line dropping from the bowl, suggesting a projectile path. We render it in three sizes:

- `q-logo-mark-512.png` — 512×512, used as the app icon source.
- `q-logo-mark-128.png` — 128×128, used for the lock screen / splash.
- `q-logo-wordmark.png` — horizontal lockup with the wordmark.

All three live in `quanta_app/assets/` (not yet — the lockup is a v0.2 deliverable).

### 4.4 · Iconography

- Rounded corners (16 px radius on cards, 28 px on primary CTAs).
- No drop shadows. Use a 1 px hairline in `quanta-ink-soft` to separate layers.
- Iconography is `Material Symbols Outlined` with rounded weights.

---

## 5 · Screens, named the way we name them

- **Home** — the launching surface. "Scan to Learn" tile, recent scans.
- **Scan** — camera capture.
- **Scan Result** — the three-tab view of a single scan.
- **AI Visualiser** — the diagram/plot tab.
- **AI Quiz** — five multiple-choice questions, scored live.
- **AI Notes** — Concept / Formulas / Key points / Worked example.
- **History** — list of every scan the user has done.
- **Account** — profile, stats, Quanta coin balance.
- **Settings** — theme, sign-out, privacy.

When we name a new feature, we name it for the user, not for the system. "AI Notes" not `notes_screen.dart`.

---

## 6 · Subject taxonomy

The `subject` enum in `quanta_app/lib/models/scan_subject.dart`:

| Subject | Colour | Topics |
|---|---|---|
| `physics` | Teal | Mechanics, optics, electromagnetism, modern physics |
| `chemistry` | Mint | Atoms, molecules, reactions, organic, periodic table |
| `math` | Amber | Algebra, calculus, trigonometry, probability |
| `other` | Cream | Anything that doesn't fit the above three |

The colour is used for the subject badge in the scan card and the history list.

---

## 7 · Quanta coin

The in-app currency. Awarded 10 coins per scan, 5 more for completing a quiz. Displayed in the top-right of the home screen via `quanta_coin_badge.dart`. Streaks are tracked in `coin_store.dart`.

- **Coin icon** — a single circle with a "Q" etched into it, in `quanta-amber`.
- **Streak icon** — a flame in `quanta-coral`, used for streaks ≥ 3 days.

---

## 8 · Screenshot etiquette

When we capture screenshots for the deck or the README:

- Use the dark theme.
- Hide the bottom nav when the focus is a single screen.
- Show a real scan, not a placeholder. Placeholders are for development only.
- Always include the topic, the variables, and the timestamp.
- Crop to the content; the phone frame is implied.

---

## 9 · Open questions (v0.2)

- Are we sticking with `quanta_app` as the Flutter package name, or do we rename to `Quanta` (PascalCase) to match the brand?
- Do we publish the wordmark under a permissive license, or keep it internal?
- Should the coin be on-chain? (Answer: no, not for v1. We have enough on our plate.)

---

## 10 · References

- Internal: `quanta_app/lib/theme/quanta_theme.dart` — the implementation of the palette.
- Internal: `quanta_app/assets/team/` — the team's profile photos used in the "About" card.
- External: Material Symbols (https://fonts.google.com/icons) for iconography.
