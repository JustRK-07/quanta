#!/usr/bin/env python3
"""
build_demo.py — turn the 12 captioned screenshots into a ~3 minute
Quanta demo video.

Output:  video/quanta-demo.mp4  (1080x1920, ~180s, H.264, no audio)

Structure (4 acts, 12 frames + 4 title cards + credits):

  00  Title card                 4s
  01  Act I — "The setup"        3s
  02  Home                        12s
  03  History                     12s
  04  Act II — "The visualiser"   3s
  05  Projectile (money shot)     15s
  06  SHM (spring + graph)        15s
  07  Bohr atom (Carbon)          13s
  08  Wave on a string            13s
  09  Act III — "Notes & quiz"    3s
  10  AI Notes (concept)          14s
  11  AI Quiz Generator           14s
  12  History (loop)              12s
  13  Act IV — "The loop"         3s
  14  Account & coins             14s
  15  Credits                     6s

                                  ----
                                  ~167s   (~2:47 — pad to 3:00 with
                                          a slower last hold)

Each frame gets a slow Ken-Burns zoom (1.00 -> 1.06) and a 0.4s
crossfade into the next frame so the cuts don't feel hard.

Re-run after updating any screenshot. No transient files are left in
the working tree; everything is generated in a temp dir under /tmp.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SCREENSHOT_DIR = REPO_ROOT / "screenshots"
OUTPUT = REPO_ROOT / "video" / "quanta-demo.mp4"

W, H = 1080, 1920  # final video resolution
FPS = 30

# A "shot" is one continuous visual element: either a labeled screenshot
# or a section/title card. (filename, caption, sub-caption, duration_s)
# Order = narrative order. Section cards are encoded with a special
# filename prefix and rendered by the script rather than read from disk.
Shot = tuple[str, str, str, float]

TITLE: Shot = ("__title__", "Quanta", "Scan a textbook. Get the diagram, notes, and quiz.", 4.0)
CREDITS: Shot = ("__credits__", "Team Gryffindor", "iQOO Hackathon 2026  ·  github.com/JustRK-07/quanta", 6.0)

ACT_I:   Shot = ("__act__",   "Act I",   "The setup",          3.0)
ACT_II:  Shot = ("__act__",   "Act II",  "The visualiser",     3.0)
ACT_III: Shot = ("__act__",   "Act III", "Notes and quiz",     3.0)
ACT_IV:  Shot = ("__act__",   "Act IV",  "The loop",           3.0)

# The 12 screenshots, in story order, with caption + sub-caption + hold.
SHOTS: list[Shot] = [
    TITLE,
    ACT_I,
    ("Screenshot_20260902_144300.png", "Home", "One tap to start a scan.", 12.0),
    ("Screenshot_20260902_144329.png", "History", "Every scan you do is saved on the phone.", 12.0),
    ACT_II,
    ("Screenshot_20260902_144349.png", "Projectile motion", "v0 = 20 m/s, angle 45 deg, g = 9.8 m/s^2.  Drag the slider to watch the trajectory change.", 15.0),
    ("Screenshot_20260902_144437.png", "Simple harmonic motion", "m = 0.5 kg, k = 200 N/m, A = 0.1 m.  Spring + position-vs-time graph.", 15.0),
    ("Screenshot_20260902_144428.png", "Bohr atom, Z = 6", "Carbon: 2 electrons in the first shell, 4 in the second.", 13.0),
    ("Screenshot_20260902_144452.png", "Wave on a string", "y = A sin(omega t + kx),  A = 0.05 m,  f = 2 Hz,  v = 4 m/s.", 13.0),
    ACT_III,
    ("Screenshot_20260902_144527.png", "AI Notes", "Concept, formulas, key points, worked example — all in expandable cards.", 14.0),
    ("Screenshot_20260902_144403.png", "AI Quiz Generator", "Pick a difficulty, generate five multiple-choice questions, score them live.", 14.0),
    ("Screenshot_20260902_144458.png", "History grows with you", "Six scans in the demo set; yours will too.", 12.0),
    ACT_IV,
    ("Screenshot_20260902_144507.png", "Account & Quanta coins", "Earn 10 coins per scan, 5 more for a completed quiz.  Streaks keep you honest.", 14.0),
    CREDITS,
]

CROSSFADE_S = 0.4  # 12-frame crossfade between consecutive shots


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
        # kicker (small, mint)
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
    # We accumulate the durations (post-crossfade trimming) to compute it.
    # Each transition trims CROSSFADE_S seconds from the total because
    # the new shot is "blended in" during the last CROSSFADE_S of the
    # previous shot's hold.
    current_label = "v0"
    xfade_filter_parts: list[str] = []
    elapsed = 0.0
    for i in range(1, n):
        # The fade starts CROSSFADE_S seconds before this shot ends.
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
    print(f"OK  {OUTPUT}  ({size_mb:.1f} MB, ~{int(actual_seconds)}s)")


if __name__ == "__main__":
    main()
