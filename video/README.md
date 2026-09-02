# video/

> Demo recordings of Quanta. The actual `.mp4` / `.mov` / `.webm` files
> are gitignored — drop them in via a PR, or generate one from the
> screenshots with the included script.

## What's here

| File | What it is | Tracked? |
|---|---|---|
| `quanta-demo.mp4` | The 3-minute demo video stitched from the screenshots | **No** (gitignored) — re-generate locally or attach to a release |
| `quanta-demo-long.mp4` | The 5-minute extended cut with architecture, tech stack, and roadmap cards | **No** (gitignored) — generate with `build_demo_long.py` |
| `quanta-demo-long-narrated.mp4` | The 5-minute extended cut with an espeak narration track | **No** (gitignored) — generate with `build_demo_long_narrated.py` |
| `scripts/build_demo.py` | The 3-min generator. Read this if you want to change the short cut. | **Yes** |
| `scripts/build_demo_long.py` | The 5-min generator. Adds three context cards (architecture, tech stack, roadmap) and longer holds. | **Yes** |
| `scripts/build_demo_long_narrated.py` | Adds an espeak narration track to the 5-min cut. Reads the lines from `voice_script.py`. | **Yes** |
| `scripts/voice_script.py` | One narration line per shot. Lengths are tuned to the hold times — edit this to change what is spoken. | **Yes** |
| `.gitkeep` | Keeps the folder in git so the scripts path is stable | **Yes** |
| `README.md` | This file | **Yes** |

## The script

`scripts/build_demo.py` reads the 12 screenshots in `../screenshots/`, draws
captioned labels and four act cards, and encodes everything to
`quanta-demo.mp4` at 1080×1920, ~3 minutes, H.264.

It does not touch the network, does not require a Firebase project, and
leaves no transient files in the working tree.

### What you need

- **Python 3.10+** (no third-party packages; the script uses only stdlib).
- **ffmpeg** with the `libx264` encoder.
- **ImageMagick** (`magick` command — the `convert` legacy command is not enough).

```bash
# Arch / Manjaro
sudo pacman -S ffmpeg imagemagick

# Debian / Ubuntu
sudo apt install ffmpeg imagemagick

# macOS
brew install ffmpeg imagemagick
```

### Run it

```bash
python3 video/scripts/build_demo.py
```

Output: `video/quanta-demo.mp4`. The console prints the total duration
and file size. Re-run any time you change a screenshot — the script
re-renders everything from scratch.

### The 5-minute cut

For reviewers who want more than a quick tour, there's also a longer
generator that adds three context cards (architecture, tech stack,
roadmap) on top of the four-act narrative, and lengthens the hold on
every hero shot.

```bash
python3 video/scripts/build_demo_long.py
```

Output: `video/quanta-demo-long.mp4` (~5:03, ~5 MB at 1080×1920).
Everything in the table below is in addition to the 3-min cut:

| # | Shot | Caption | Hold |
|--:|---|---|---:|
| 15 | Architecture | "How it fits together — phone, backend, AI, visualiser." | 18 s |
| 16 | Tech stack | "Flutter · FastAPI · MongoDB · Gemini 2.5 · ML Kit." | 18 s |
| 17 | Roadmap | "On-device topic classification, more visualisers, i18n, LMS hook." | 18 s |
| 18 | Credits | "Team Gryffindor · iQOO Hackathon 2026" | 8 s |

The script reuses every visual constant from `build_demo.py` (palette,
fonts, resolution, crossfade duration), so the two cuts look like the
same film at different runtimes.

### The narrated 5-minute cut

For reviewers who would rather listen than read, there's a third cut
that adds an espeak narration track on top of the long version.

```bash
python3 video/scripts/build_demo_long_narrated.py
```

Output: `video/quanta-demo-long-narrated.mp4` (~5:03, ~7 MB). One AAC
stereo track at 44.1 kHz, muxed with the same H.264 video.

What it needs:

- **Python 3.10+** and **ffmpeg** (already required for the other
  scripts).
- **espeak** — the local TTS engine. Install with:
  ```bash
  sudo pacman -S espeak          # Arch / Manjaro
  sudo apt install espeak        # Debian / Ubuntu
  brew install espeak            # macOS
  ```

How the pipeline works:

1. Re-renders the video frames from `build_demo_long.py` so the
   narration stays in sync if you tweaked `SHOTS`.
2. Reads `voice_script.py` — one line per shot, in the same order as
   `SHOTS`.
3. Runs `espeak` on each line, measures the spoken duration with
   `ffprobe`, and pads each clip with silence to the shot's hold.
4. Concatenates the padded clips and muxes the result into the video.

#### Editing what is spoken

Open `scripts/voice_script.py` and rewrite any line. Re-run the script
— no need to touch the video generator. Keep each line under its hold
time (a warning will print if a line overruns).

Pacing is controlled near the top of
`scripts/build_demo_long_narrated.py`:

- `ESPEAK_WPM` — words per minute (default 200).
- `ESPEAK_VOICE` — the espeak voice id (default `en+m3`, male English).
- `ESPEAK_AMP` / `ESPEAK_PITCH` — volume and pitch.

#### Upgrading to a more natural voice

`espeak` sounds like a navigation system — fine for a hackathon, rough
for a polished demo. For a real submission, swap the `synth_line`
function (top of `build_demo_long_narrated.py`) for a call to a
neural TTS API such as MiniMax's `mmx speech synthesize`:

```python
def synth_line(text: str, out: Path) -> None:
    run(["mmx", "speech", "synthesize",
         "--voice", "en-female-1",
         "--text", text,
         "--out", out.with_suffix(".mp3").as_posix()])
    # then convert the mp3 to wav with the same sample rate
```

The rest of the pipeline (duration probe, padding, muxing) is identical.

### The structure

The video has four acts. Each act is introduced by a title card and
followed by 2–4 captioned screenshots with a slow Ken-Burns zoom
and 0.4 s crossfades between shots.

| # | Shot | Caption | Hold |
|--:|---|---|---:|
| 0 | Title card | "Quanta · Scan a textbook. Get the diagram, notes, and quiz." | 4 s |
| 1 | Act I — "The setup" |  | 3 s |
| 2 | Home (144300) | "One tap to start a scan." | 12 s |
| 3 | History (144329) | "Every scan you do is saved on the phone." | 12 s |
| 4 | Act II — "The visualiser" |  | 3 s |
| 5 | Projectile (144349) | "v0 = 20 m/s, angle 45°…" | 15 s |
| 6 | SHM (144437) | "m = 0.5 kg, k = 200 N/m…" | 15 s |
| 7 | Bohr atom (144428) | "Carbon: 2 electrons in the first shell…" | 13 s |
| 8 | Wave on a string (144452) | "y = A sin(ωt + kx)…" | 13 s |
| 9 | Act III — "Notes and quiz" |  | 3 s |
| 10 | AI Notes (144527) | "Concept, formulas, key points…" | 14 s |
| 11 | AI Quiz Generator (144403) | "Pick a difficulty, generate five questions…" | 14 s |
| 12 | History grows (144458) | "Six scans in the demo set; yours will too." | 12 s |
| 13 | Act IV — "The loop" |  | 3 s |
| 14 | Account & coins (144507) | "Earn 10 coins per scan…" | 14 s |
| 15 | Credits | "Team Gryffindor · iQOO Hackathon 2026" | 6 s |

Total ≈ 156 s of held footage + crossfades ≈ 178 s (2:58).

### Changing the timing

The `SHOTS` list near the top of the script is the source of truth.
Edit the fourth element of any tuple to change how long that frame
holds. Re-run the script.

### Changing the screenshots

Drop a new PNG in `../screenshots/` and update the matching tuple in
`SHOTS`. The script reads each image fresh on every run.

### Changing the look

The visual constants are at the top of the script:

- `W, H = 1080, 1920` — final resolution
- `FPS = 30`
- `CROSSFADE_S = 0.4`

The brand colours are hard-coded as the hex values from
[`../BRANDING.md`](../BRANDING.md):

- `#0B1220` — quanta-ink (background)
- `#111A2C` — quanta-ink-soft (caption strip)
- `#0F766E` — quanta-teal (accent)
- `#9FF6E0` — quanta-mint (titles)
- `#F5F1E8` — quanta-cream (subtitles)

## Hosting

The video isn't checked in. To make it visible to the public:

- **GitHub release** — attach `quanta-demo.mp4` to a release tag.
  Releases survive in git history without bloating the repo.
- **Loom** — record a Loom walkthrough and embed the link in the
  README. Best for live narration, worst for offline review.
- **Vercel Blob / S3** — host the file, embed in the README with the
  `<video>` tag.

For the iQOO Hackathon submission deck, the team attaches the file
directly to the submission form and shares it on the WhatsApp group.
