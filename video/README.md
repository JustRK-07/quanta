# video/

> Demo recordings of Quanta. The folder is tracked but the binary files (`.mp4`, `.mov`, `.webm`) are gitignored — drop recordings in via a PR or by emailing them to the team, and we'll re-host them on the team's Vercel or a dedicated Loom playlist.

## What to put here

- **City-battle demo recordings** — 3 to 5 minutes, captured on the loaner iQOO.
- **Walkthroughs of new visualiser templates** — short (60–90 s) clips showing the parameter sliders in action.
- **Pitch-deck screen captures** — for the WhatsApp announcement after each battle.

## Filename convention

`YYYY-MM-DD_<track-or-feature>_<speaker-or-teammate>.<ext>`

Examples:

- `2026-08-29_bengaluru-battle_team.mp4`
- `2026-09-05_visualiser-shm-slider_nihith.mp4`
- `2026-09-12_pitch_chennai-battle.mp4`

## How to record on the iQOO

1. Pull down the quick-settings shade → tap **Screen Recorder**.
2. Pick the **1080p / 30 fps** preset.
3. Capture the full demo from a clean app launch.
4. Rename the file to the convention above.
5. AirDrop / `scp` it onto the laptop.
6. Open a PR adding the file with a one-line description.

## Hosting

For v0.1 the recordings live in the team's shared drive. For v0.2 we'll add a `videos.json` manifest at the repo root that points at the hosted URLs (Loom, Vercel Blob, or a self-hosted Bunny stream).
