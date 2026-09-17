# Quanta backend

> FastAPI service that turns a photographed textbook problem into a visualiser, a notes payload, and a quiz. This file is the backend-specific companion to the top-level [README](../README.md).

---

## Status

This checkout does **not** contain the FastAPI source tree, dependency
manifests, Dockerfile, or tests described below. The document is a deployment
contract for the missing backend, not proof that the backend can currently be
built. Restore the backend from its authoritative source before running any
commands in this file.

## TL;DR

```bash
cd backend
python3.14 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # add provider keys locally; never commit .env
ALLOW_DEV_AUTH_BYPASS=true .venv/bin/uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

Open <http://localhost:8001/docs> for the OpenAPI explorer.

---

## 1 · What's in here

```
backend/
├── main.py                 # app entry, CORS, router mount
├── config.py               # env-driven config
├── api/index.py            # Vercel serverless handler
├── auth/                   # Firebase middleware + dev bypass
├── database/               # Mongo (motor) client + per-collection models
├── models/                 # Pydantic request/response shapes
├── routers/                # scan · visualiser · history · notes · quiz · chat · users
├── services/               # ai_visualiser · ai_notes · ai_quiz · ai_chat · ai_detector
├── templates/visualiser/   # JSON templates for static topics
├── static/uploads/         # runtime artefacts (gitignored)
├── tests/                  # pytest
├── Dockerfile
├── vercel.json
├── requirements.txt
├── requirements-dev.txt
└── .env.example
```

A full architectural overview is in [ARCHITECTURE.md](../ARCHITECTURE.md).

---

## 2 · Endpoints

All endpoints are mounted under `/`. Most require a Firebase ID token in the `Authorization` header — see [§ 4](#4--auth--dev-bypass).

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/health` | Liveness check, returns `{"status":"ok"}`. |
| `POST` | `/auth/verify` | Verify an ID token, return the user. |
| `POST` | `/auth/dev-token` | Issue a dev token (only when the bypass is enabled). |
| `POST` | `/scan` | Upload an image + OCR text, kick off the AI pipeline, return the full scan payload. |
| `GET` | `/visualiser/{topic}` | Resolve a topic to a visualiser template. |
| `POST` | `/visualiser/generate` | Same, but with a free-form topic string. |
| `GET` | `/history` | List the current user's scans. |
| `GET` | `/history/{id}` | Fetch one scan. |
| `DELETE` | `/history/{id}` | Delete one scan. |
| `POST` | `/notes/generate` | Generate notes for a topic. |
| `POST` | `/quiz/generate` | Generate a five-question quiz for a topic. |
| `POST` | `/quiz/grade` | Grade a quiz submission. |
| `POST` | `/chat` | Stream a tutor chat reply. |
| `GET` | `/users/me` | Current user profile. |
| `GET` | `/users/leaderboard` | Top users by Quanta coins. |
| `GET` | `/static/uploads/{filename}` | Serve an uploaded image. |

The OpenAPI doc at `/docs` is the canonical reference.

---

## 3 · Environment

`backend/.env` is read by `config.py` at startup once that source file is
restored. The minimum viable set:

```ini
# Required for AI features
GOOGLE_API_KEY=...

# Auth
ALLOW_DEV_AUTH_BYPASS=true   # for local dev only
FIREBASE_CREDENTIALS_FILE=firebase_service_account.json
# or
FIREBASE_CREDENTIALS_JSON={...escaped JSON...}

# Storage
MONGO_URI=                   # leave blank to disable the Mongo mirror (uses local file storage)
```

See [`.env.example`](.env.example) for the full template.

---

## 4 · Auth & dev bypass

`auth/auth_middleware.py` is a FastAPI dependency that runs on every protected route. The flow:

1. Read `Authorization: Bearer <token>`.
2. If `ALLOW_DEV_AUTH_BYPASS=true` and the token equals `test-token`, attach a synthetic `dev-user` and continue.
3. Otherwise, verify the token with `firebase-admin` and attach the real `uid`.

The phone's `firebase_auth_service.dart` returns the same `test-token` constant when no Firebase user is signed in. **Do not enable the bypass in production.**

Setup of a real Firebase project: [quanta_app/FIREBASE_SETUP.md](../quanta_app/FIREBASE_SETUP.md).

---

## 5 · Running

### 5.1 · Local (uvicorn)

```bash
.venv/bin/uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### 5.2 · Docker

```bash
docker build -t quanta-backend .
docker run --rm -p 8001:8001 --env-file .env quanta-backend
```

### 5.3 · Vercel

The repo includes a `vercel.json` that mounts `api/index.py` as the serverless function. The runtime artefact `api/index.py` re-exports the FastAPI app from `main.py`. Set the env vars in the Vercel project settings; do not commit `.env`.

---

## 6 · Tests

```bash
.venv/bin/pytest -q
```

The tests cover:

- `test_aiml_llm.py` — Gemini prompt/response shape.
- `test_db_connection.py` — Mongo connection (skipped if `MONGO_URI` is empty).
- `test_notes.py` — notes generation.
- `test_quiz.py` — quiz generation + grading.
- `test_visualiser.py` — template lookup and dispatch.
- `test_openrouter.py` — the OpenRouter fallback path (planned).

CI runs the suite on every PR: `.github/workflows/backend-ci.yml`.

---

## 7 · The visualiser dispatch

`routers/visualiser.py` keeps a list of `topic_keyword → template_id` rules. The AI detector (`services/ai_detector.py`) runs first and suggests a topic; the dispatcher then resolves it to a template.

| Keywords | Template |
|---|---|
| `projectile`, `parabola`, `launch` | `projectile_motion.json` |
| `simple harmonic`, `shm`, `spring` | `shm.json` |
| `atom`, `bohr`, `electron`, `proton` | `kinematics.json` (atom) |
| `water`, `h2o`, `molecule`, `bond` | `kinematics.json` (molecule) |
| `wave`, `string`, `sinusoid` | `kinematics.json` (wave) |
| `free fall`, `gravity drop` | `free_fall.json` |
| `equation`, `quadratic`, `roots` | `graphs.json` |
| `circuit`, `resistor`, `ohm` | `circuits.json` |
| `lens`, `mirror`, `refraction` | `optics.json` |

Adding a new topic: see [CONTRIBUTING.md § 6](../CONTRIBUTING.md).

---

## 8 · Storage

- **Uploads** — `static/uploads/{uuid}.jpg`. Served at `/static/uploads/{filename}`. Gitignored.
- **Mongo** — when `MONGO_URI` is set, scans and user data are mirrored to Mongo. Otherwise the service is best-effort and the local disk is the source of truth.
- **Templates** — `templates/visualiser/*.json` are checked in. The dispatcher and the AI services read them at request time; edits to the JSON are picked up on the next uvicorn reload.

---

## 9 · Linting

```bash
.venv/bin/ruff check .
.venv/bin/ruff format .
```

`pre-commit` (configured at the repo root) runs these on every commit.

---

## 10 · Troubleshooting

### 10.1 · "Address already in use" on port 8001

We use **8001** by default during the hackathon because port 8000 is occupied by another service on the dev laptop. Change the port in the run command and the Flutter app's `_devUrl`.

### 10.2 · "GEMINI_API_KEY not set"

Add `GOOGLE_API_KEY=...` to `backend/.env`. The AI services will refuse to start without it.

### 10.3 · "Cannot connect to Mongo"

Either start Mongo locally or set `MONGO_URI=` (empty) in `.env` to disable the Mongo mirror. The service falls back to the local disk.

### 10.4 · Visualiser returns "no template matched"

The keyword rules in `routers/visualiser.py` didn't catch the topic. Either add a rule, or fall back to `kinematics.json` (generic) which renders a labelled diagram with the extracted text.

---

## 11 · What we deliberately don't do

- **No user-facing analytics.** We don't track requests, latencies, or token spend. The Google Cloud console's billing dashboard is the source of truth.
- **No persistent prompt logging.** Gemini prompts live in memory for the duration of the request and are not written to disk.
- **No queue.** The AI services run in-process. For the hackathon, this is fine. For production, we'd add a worker queue (RQ or Arq) to decouple the upload from the AI calls.

---

## 12 · License

MIT — see [LICENSE](../LICENSE).
