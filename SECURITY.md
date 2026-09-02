# Security policy

> Quanta is a hackathon project but it touches user data, authentication, and a generative model. This document explains what we protect, how to report a vulnerability, and what we promise to do about it.

---

## 1 · What we protect

- **User authentication** — Firebase ID tokens issued to the iQOO app.
- **User content** — captured textbook photos, scan metadata, quiz answers.
- **AI prompts** — the text we send to Gemini (and any future model) for visualiser / notes / quiz generation. Prompts may contain fragments of the user's textbook; we do not log full prompt text to disk.
- **API keys** — Gemini key on the backend; Firebase service account credentials.
- **The dev-bypass path** — the `Bearer test-token` shortcut used for local development. It is gated by an env flag and is not exposed in production.

---

## 2 · Reporting a vulnerability

**Do not open a public GitHub issue.** We can't always react in time, and the issue will be visible to anyone watching the repo.

Send a private report to **quanta-security@proton.me** with:

- A short title.
- A reproduction: which app version, which endpoint, which input, what you observed.
- If you have a fix, the patch.
- Your handle / email if you'd like to be credited in the fix.

### 2.1 · What we'll do

- Acknowledge within **48 hours** during the hackathon sprint, **5 business days** otherwise.
- Triage within a week.
- Ship a fix before disclosing.
- Credit you in the fix commit and the changelog (unless you ask to stay anonymous).

---

## 3 · Out of scope

The following are not vulnerabilities in Quanta and should not be reported as such:

- **The dev bypass token.** `test-token` is intentional. If you set `ALLOW_DEV_AUTH_BYPASS=true` in `backend/.env`, you have explicitly opted in. Production deployments must leave the flag unset.
- **Self-XSS.** We don't expect users to paste arbitrary code into the app.
- **The lack of rate limiting in local dev.** The backend does not rate-limit requests in development mode. Production deploys add a per-user limit.
- **The Gemini API key in `backend/.env`.** If the key leaks, rotate it in the Google Cloud console.

---

## 4 · Threat model

We assume:

- The user is on a personal iQOO / Android device they control.
- The network is untrusted (public Wi-Fi, college LAN).
- The backend is deployed on a public host (Vercel).
- The generative model is a third-party (Google) and not under our control.

We **do not** assume:

- The user's device is rooted or jailbroken.
- The Firebase project is private to the user (it isn't — it's shared across the team).
- The Gemini API has perfect safety filters.

---

## 5 · Concrete protections

| Layer | Protection |
|---|---|
| Transport | HTTPS only. The phone rejects plain-HTTP responses in release builds (`usesCleartextTraffic=false` on Android). |
| Auth | Firebase ID tokens, verified on every backend call. Dev bypass is opt-in and env-gated. |
| Storage | The phone stores scans in `SharedPreferences`. The local file is not encrypted; we treat it as a convenience cache. Cloud sync (Firestore) is per-user with rules that allow only `request.auth.uid == uid`. |
| Prompts | We do not log the raw prompt text to a third-party sink. Logs are best-effort and live on the backend host. |
| AI output | We display AI output as Markdown. We do not execute it. Quiz answers are validated server-side before scoring. |
| Dependencies | `dependabot.yml` opens weekly PRs against pinned dependencies. CI runs on every PR. |

---

## 6 · Hardening checklist for a public deploy

Before you point a real Firebase project at a deployed Quanta backend:

- [ ] `ALLOW_DEV_AUTH_BYPASS` is **unset** in the deployed environment.
- [ ] Firestore rules are locked to the per-user pattern in `quanta_app/FIREBASE_SETUP.md`.
- [ ] Firebase App Check is enabled on the phone.
- [ ] The Gemini API key is restricted to the deployed backend's IP range in the Google Cloud console.
- [ ] The service account key is rotated after the hackathon.
- [ ] The backend logs are shipped to a sink with a 30-day retention, not the local disk.

---

## 7 · Past incidents

None publicly reported. (We'd document any here after they're resolved.)

---

## 8 · Credits

Thanks to the people who have reported issues responsibly. We're a small team; every report is read and acted on.
