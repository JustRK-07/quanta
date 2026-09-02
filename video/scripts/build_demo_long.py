#!/usr/bin/env python3
"""
build_demo_long.py — extended demo for reviewers who want more than a
3-minute tour. Adds three extra context cards (architecture, tech stack,
roadmap) on top of the four-act narrative used by build_demo.py, and
lengthens the hold on every hero shot.

Output:  video/quanta-demo-long.mp4  (1080x1920, ~5 min, H.264, no audio)

Structure (4 acts + 3 extra cards, 12 frames + 4 act intros + 3 cards
           + title + credits):

  00  Title card                       6 s
  01  Act I — "The setup"              4 s
  02  Home                             22 s
  03  History                          20 s
  04  Act II — "The visualiser"        4 s
  05  Projectile (money shot)          28 s
  06  SHM (spring + graph)             24 s
  07  Bohr atom (Carbon)               22 s
  08  Wave on a string                 22 s
  09  Act III — "Notes & quiz"         4 s
  10  AI Notes (concept)               24 s
  11  AI Quiz Generator                24 s
  12  History (loop)                   20 s
  13  Act IV — "The loop"              4 s
  14  Account & coins                  22 s
  15  Architecture card                18 s
  16  Tech stack card                  18 s
  17  Roadmap card                     18 s
  18  Credits                          8 s

                                       ----
                                       ~312 s   (~5:12 — minus ~9 s of
                                                 crossfade trim = ~5:03)

The visual treatment is identical to build_demo.py: a slow Ken-Burns
zoom (1.00 -> 1.06), 0.5 s crossfades between shots, and the same brand
palette. The only difference is more shots and longer holds.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SCREENSHOT_DIR = REPO_ROOT / "screenshots"
OUTPUT = REPO_ROOT / "video" / "quanta-demo-long.mp4"

W, H = 1080, 1920  # final video resolution
FPS = 30

# A "shot" is one continuous visual element: either a labeled screenshot
# or a section/title card. (filename, caption, sub-caption, duration_s)
# Order = narrative order. Card-like shots use a special filename prefix
# and are rendered by this script rather than read from disk.
Shot = tuple[str, str, str, float]

TITLE: Shot = ("__title__", "Quanta", "Scan a textbook. Get the diagram, notes, and quiz.", 6.0)
CREDITS: Shot = ("__credits__", "Team Gryffindor", "iQOO Hackathon 2026  ·  github.com/JustRK-07/quanta", 8.0)

ACT_I:   Shot = ("__act__",   "Act I",   "The setup",          4.0)
ACT_II:  Shot = ("__act__",   "Act II",  "The visualiser",     4.0)
ACT_III: Shot = ("__act__",   "Act III", "Notes and quiz",     4.0)
ACT_IV:  Shot = ("__act__",   "Act IV",  "The loop",           4.0)

# Three extra context cards that only appear in the long version.
ARCHITECTURE: Shot = (
    "__arch__",
    "How it fits together",
    "Phone (camera + on-device OCR)  ->  FastAPI backend  ->  Gemini 2.5 Flash  ->  JSON visualiser template  ->  Flutter CustomPainter.  Each visualiser is a widget, not a remote canvas.",
    18.0,
)
TECH_STACK: Shot = (
    "__stack__",
    "What it's built on",
    "Flutter 3.x  ·  Dart 3.9  ·  google_mlkit_text_recognition  ·  FastAPI + Motor (MongoDB)  ·  Firebase Auth (with a dev-token bypass)  ·  Gemini 2.5 Flash.",
    18.0,
)
ROADMAP: Shot = (
    "__roadmap__",
    "What's next",
    "On-device topic classification.  More visualisers (optics, circuits, organic chemistry).  Cross-device history sync.  Hindi, Marathi, Tamil, Telugu, Kannada translations.  An LMS hook for teachers.",
    18.0,
)

# The 12 screenshots, in story order, with caption + sub-caption + hold.
# Holds are roughly 1.5x the short version so the longer tour can breathe.
SHOTS: list[Shot] = [
    TITLE,
    ACT_I,
    ("Screenshot_20260902_144300.png", "Home", "One tap to start a scan.", 22.0),
    ("Screenshot_20260902_144329.png", "History", "Every scan you do is saved on the phone.", 20.0),
    ACT_II,
    ("Screenshot_20260902_144349.png", "Projectile motion", "v0 = 20 m/s, angle 45 deg, g = 9.8 m/s^2.  Drag the slider to watch the trajectory change.", 28.0),
    ("Screenshot_20260902_144437.png", "Simple harmonic motion", "m = 0.5 kg, k = 200 N/m, A = 0.1 m.  Spring + position-vs-time graph.", 24.0),
    ("Screenshot_20260902_144428.png", "Bohr atom, Z = 6", "Carbon: 2 electrons in the first shell, 4 in the second.", 22.0),
    ("Screenshot_20260902_144452.png", "Wave on a string", "y = A sin(omega t + kx),  A = 0.05 m,  f = 2 Hz,  v = 4 m/s.", 22.0),
    ACT_III,
    ("Screenshot_20260902_144527.png", "AI Notes", "Concept, formulas, key points, worked example — all in expandable cards.", 24.0),
    ("Screenshot_20260902_144403.png", "AI Quiz Generator", "Pick a difficulty, generate five multiple-choice questions, score them live.", 24.0),
    ("Screenshot_20260902_144458.png", "History grows with you", "Six scans in the demo set; yours will too.", 20.0),
    ACT_IV,
    ("Screenshot_20260902_144507.png", "Account & Quanta coins", "Earn 10 coins per scan, 5 more for a completed quiz.  Streaks keep you honest.", 22.0),
    ARCHITECTURE,
    TECH_STACK,
    ROADMAP,
    CREDITS,
]

CROSSFADE_S = 0.5  # a hair longer than the short version


def run(cmd: list[str]) -> None:
    result = subprocess.run(cmd, check=False, capture_output=True, text=True)
    if result.returncode != 0:
        print("FAILED:", " ".join(cmd), file=sys.stderr)
        print(result.stdout, file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        raise SystemExit(result.returncode)


def make_title_card(out: Path, *, kicker: str, title: str, sub: str) -> None:
    cmd = [
        "magick", "-size", f"{W}x{H}", "xc:#0B1220",
        # accent bar near the bottom
        "-fill", "#0F766E", "-draw", f"rectangle 0,1600 {W},1640",
        # kicker (small, teal)
        "-fill", "#0F766E", "-font", "Adwaita-Sans-Bold", "-pointsize", "44",
        "-gravity", "center", "-annotate", "+0-340", kicker,
        # title (big, mint)
        "-fill", "#9FF6E0", "-font", "Adwaita-Sans-Bold", "-pointsize", "150",
        "-annotate", "+0-80", title,
        # subtitle (small, cream)
        "-fill", "#F5F1E8", "-font", "Adwaita-Sans", "-pointsize", "44",
        "-annotate", "+0+140", sub,
        out.as_posix(),
    ]
    run(cmd)


def make_act_card(out: Path, *, label: str, title: str) -> None:
    cmd = [
        "magick", "-size", f"{W}x{H}", "xc:#0B1220",
        # vertical accent line on the left
        "-fill", "#0F766E", "-draw", f"rectangle 80,720 96,1200",
        # label
        "-fill", "#0F766E", "-font", "Adwaita-Sans-Bold", "-pointsize", "48",
        "-gravity", "west", "-annotate", "+150+0", label,
        # title
        "-fill", "#9FF6E0", "-font", "Adwaita-Sans-Bold", "-pointsize", "120",
        "-annotate", "+150+100", title,
        out.as_posix(),
    ]
    run(cmd)


def make_credits_card(out: Path, *, title: str, sub: str) -> None:
    cmd = [
        "magick", "-size", f"{W}x{H}", "xc:#0B1220",
        # top accent
        "-fill", "#0F766E", "-draw", f"rectangle 0,280 {W},320",
        # main
        "-fill", "#9FF6E0", "-font", "Adwaita-Sans-Bold", "-pointsize", "120",
        "-gravity", "center", "-annotate", "+0-60", title,
        # sub
        "-fill", "#F5F1E8", "-font", "Adwaita-Sans", "-pointsize", "44",
        "-annotate", "+0+120", sub,
        out.as_posix(),
    ]
    run(cmd)


def make_bullet_card(out: Path, *, label: str, title: str, body: str, accent_y: int) -> None:
    """Render a context card with a small label, a big title, and a body.

    body is rendered as a small cream-coloured paragraph. Multi-line text
    is approximated by splitting on the "  " separator passed in by the
    caller, since the magick -annotate call doesn't word-wrap on its own.
    """
    # Split body on the "  ·  " separator (we use a wider dot so it looks
    # like a single visual line) but the script may pass in a newline.
    # We just trust the caller to wrap at <=70 chars and split on "\\n".
    lines = body.split("\n")
    line_step = 48
    base_y = accent_y + 80

    cmd = [
        "magick", "-size", f"{W}x{H}", "xc:#0B1220",
        # accent bar near the top
        "-fill", "#0F766E", "-draw", f"rectangle 0,{accent_y - 60} {W},{accent_y - 20}",
        # label (small, teal)
        "-fill", "#0F766E", "-font", "Adwaita-Sans-Bold", "-pointsize", "40",
        "-gravity", "northwest", "-annotate", "+80+0", label,
        # title (big, mint)
        "-fill", "#9FF6E0", "-font", "Adwaita-Sans-Bold", "-pointsize", "88",
        "-annotate", "+80+40", title,
    ]
    # Body lines.
    for idx, line in enumerate(lines):
        cmd.extend([
            "-fill", "#F5F1E8", "-font", "Adwaita-Sans", "-pointsize", "30",
            "-annotate", f"+80+{base_y + idx * line_step}", line,
        ])
    # Bottom accent stripe.
    cmd.extend([
        "-fill", "#0F766E", "-draw", f"rectangle 0,{H - 80} {W},{H - 40}",
        out.as_posix(),
    ])
    run(cmd)


def make_labeled_frame(screenshot: Path, caption: str, sub: str, out: Path) -> None:
    target_w = 920
    cmd = [
        "magick",
        "-size", f"{W}x{H}", "xc:#0B1220",
        # screenshot, scaled, centered horizontally near the top
        "(", screenshot.as_posix(), "-resize", f"{target_w}x", ")",
        "-gravity", "north", "-geometry", "+0+220", "-composite",
        # caption strip background
        "-fill", "#111A2C",
        "-draw", f"rectangle 0,{H-340} {W},{H}",
        # accent line above the strip
        "-fill", "#0F766E", "-draw", f"rectangle 0,{H-340} {W},{H-336}",
        # caption
        "-fill", "#9FF6E0", "-font", "Adwaita-Sans-Bold", "-pointsize", "56",
        "-gravity", "southwest", "-annotate", "+60+200", caption,
        # sub-caption
        "-fill", "#F5F1E8", "-font", "Adwaita-Sans", "-pointsize", "32",
        "-annotate", "+60+110", sub,
        out.as_posix(),
    ]
    run(cmd)


def render_shots(tmp: Path) -> list[tuple[Path, float]]:
    """Render each Shot to a PNG in tmp. Returns [(path, duration_s), ...]."""
    rendered: list[tuple[Path, float]] = []
    for i, (fname, caption, sub, duration) in enumerate(SHOTS):
        out = tmp / f"shot_{i:02d}.png"
        if fname == "__title__":
            make_title_card(out, kicker="Quanta", title=caption, sub=sub)
        elif fname == "__credits__":
            make_credits_card(out, title=caption, sub=sub)
        elif fname == "__act__":
            make_act_card(out, label=caption, title=sub)
        elif fname == "__arch__":
            # Wrap the body manually so it fits the card.
            body = sub
            make_bullet_card(
                out,
                label="ARCHITECTURE",
                title=caption,
                body=body,
                accent_y=300,
            )
        elif fname == "__stack__":
            make_bullet_card(
                out,
                label="TECH STACK",
                title=caption,
                body=sub,
                accent_y=300,
            )
        elif fname == "__roadmap__":
            make_bullet_card(
                out,
                label="WHAT'S NEXT",
                title=caption,
                body=sub,
                accent_y=300,
            )
        else:
            src = SCREENSHOT_DIR / fname
            if not src.exists():
                print(f"missing screenshot: {src}", file=sys.stderr)
                raise SystemExit(1)
            make_labeled_frame(src, caption, sub, out)
        rendered.append((out, duration))
    return rendered


def encode(shots: list[tuple[Path, float]], output: Path) -> None:
    """Concatenate rendered shots into one MP4 with crossfades and a slow zoom."""
    n = len(shots)
    # Loop each input image indefinitely at FPS; per-shot duration is
    # enforced later by `trim` inside the filter graph (not by `-t`,
    # which interacts badly with `-loop 1` and `zoompan`).
    inputs: list[str] = []
    for path, _ in shots:
        inputs.extend(["-loop", "1", "-framerate", str(FPS), "-i", path.as_posix()])

    # Per-input: trim to shot length, scale, pad, then a slow zoompan.
    # zoompan's `d` is per-input-frame, so we pair it with `trim` to
    # give it exactly `dur*FPS` input frames and set `d=1` so each input
    # frame produces one output frame.
    per_input: list[str] = []
    for i, (_, dur) in enumerate(shots):
        z_expr = "min(zoom+0.0006,1.06)"
        per_input.append(
            f"[{i}:v]trim=0:{dur},setpts=PTS-STARTPTS,"
            f"scale={W}:{H}:force_original_aspect_ratio=decrease,"
            f"pad={W}:{H}:(ow-iw)/2:(oh-ih)/2:color=#0B1220,"
            f"zoompan=z='{z_expr}':d=1:"
            f"x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':"
            f"s={W}x{H}:fps={FPS},"
            f"setpts=PTS-STARTPTS+{i*0.01}/TB[v{i}]"
        )

    # Crossfade each pair of consecutive shots. With xfade, the offset
    # is the time in the OUTPUT timeline at which the transition starts.
    current_label = "v0"
    xfade_filter_parts: list[str] = []
    elapsed = 0.0
    for i in range(1, n):
        offset = max(0.0, elapsed + shots[i - 1][1] - CROSSFADE_S)
        out_label = f"xf{i}" if i < n - 1 else "outv"
        xfade_filter_parts.append(
            f"[{current_label}][v{i}]xfade=transition=fade:duration={CROSSFADE_S}:offset={offset}[{out_label}]"
        )
        current_label = out_label
        elapsed += shots[i - 1][1] - (CROSSFADE_S if i > 0 else 0.0)

    filter_complex = ";".join(per_input + xfade_filter_parts)

    cmd = [
        "ffmpeg", "-y",
        *inputs,
        "-filter_complex", filter_complex,
        "-map", "[outv]",
        "-c:v", "libx264",
        "-preset", "medium",
        "-crf", "20",
        "-pix_fmt", "yuv420p",
        "-movflags", "+faststart",
        output.as_posix(),
    ]
    run(cmd)


def main() -> None:
    if not shutil.which("ffmpeg") or not shutil.which("magick"):
        print("ffmpeg and ImageMagick (magick) are required.", file=sys.stderr)
        raise SystemExit(1)

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        shots = render_shots(tmp_path)
        total = sum(d for _, d in shots)
        print(f"Encoding {len(shots)} shots ({total:.1f}s total) to {OUTPUT} ...")
        encode(shots, OUTPUT)

    size_mb = OUTPUT.stat().st_size / (1024 * 1024)
    actual_seconds = sum(d for _, d in shots)
    minutes, seconds = divmod(int(actual_seconds), 60)
    print(f"OK  {OUTPUT}  ({size_mb:.1f} MB, {minutes}:{seconds:02d})")


if __name__ == "__main__":
    main()