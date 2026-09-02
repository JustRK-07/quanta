#!/usr/bin/env python3
"""
build_demo_long_narrated.py — same long demo, with a voice-over track.

Adds a single AAC audio stream to the long demo: one narration line per
shot, generated with espeak, padded with silence to fit each shot's hold,
concatenated in shot order, and muxed into the video via ffmpeg.

Output:  video/quanta-demo-long-narrated.mp4  (same 1080x1920 video,
          plus an AAC stereo narration track)

The voice script lives in voice_script.py — edit that to change what is
spoken, then re-run. Video re-renders are not required unless you also
change a screenshot.

Voice engine: espeak (local, free, default). For a more natural voice,
install the `mmx` CLI from https://github.com/anthropics/mmx-cli (already
configured in this environment) and swap the `synth_line` function for
`mmx speech synthesize --voice <name>`. The rest of the pipeline is
identical.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

# Reuse the same visual layout + filter as build_demo_long.py by
# importing it. The `encode` function below produces just the video
# stream; the audio is built and muxed in afterwards.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_demo_long import OUTPUT as LONG_VIDEO   # noqa: E402
from build_demo_long import SHOTS, encode, render_shots  # noqa: E402
from voice_script import VOICE_LINES  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parents[2]
OUTPUT = REPO_ROOT / "video" / "quanta-demo-long-narrated.mp4"
AUDIO_TMP = Path("/tmp/quanta-narration.wav")

# How fast to speak. espeak defaults to about 175 wpm. -s sets words
# per minute; 200 is a comfortable hackathon-pace (lines fill ~75% of
# each shot's hold, leaving room for the line to breathe).
ESPEAK_WPM = 200
ESPEAK_VOICE = "en+m3"   # male English voice 3 — pick another if you like
ESPEAK_AMP = 110         # 0..200, default 100. A touch louder for clarity
ESPEAK_PITCH = 50        # 0..99, default 50
ESPEAK_SR = 22050        # 22.05 kHz mono — small file, fine for narration


def run(cmd: list[str]) -> None:
    result = subprocess.run(cmd, check=False, capture_output=True, text=True)
    if result.returncode != 0:
        print("FAILED:", " ".join(cmd), file=sys.stderr)
        print(result.stdout, file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        raise SystemExit(result.returncode)


def synth_line(text: str, out: Path) -> None:
    """Render one narration line to a WAV file via espeak."""
    if shutil.which("espeak") is None:
        raise SystemExit("espeak not found. Install with: sudo pacman -S espeak")
    cmd = [
        "espeak",
        "-v", ESPEAK_VOICE,
        "-s", str(ESPEAK_WPM),
        "-a", str(ESPEAK_AMP),
        "-p", str(ESPEAK_PITCH),
        "-w", out.as_posix(),
        text,
    ]
    run(cmd)


def probe_duration(path: Path) -> float:
    """Return the duration of an audio file in seconds, via ffprobe."""
    cmd = [
        "ffprobe", "-v", "error",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        path.as_posix(),
    ]
    result = subprocess.run(cmd, check=True, capture_output=True, text=True)
    return float(result.stdout.strip())


def pad_to_duration(src: Path, target_seconds: float, dst: Path) -> None:
    """Stretch src with trailing silence so the output is exactly target_seconds long."""
    cmd = [
        "ffmpeg", "-y",
        "-i", src.as_posix(),
        "-af", f"apad=whole_dur={target_seconds}",
        "-ar", str(ESPEAK_SR),
        "-ac", "1",
        dst.as_posix(),
    ]
    run(cmd)


def build_audio_track(tmp: Path) -> Path:
    """Synthesise one narration line per shot and concatenate them.

    Returns the path to a single WAV file whose total length equals the
    video length. Empty voice lines produce a silent WAV of the right
    length.
    """
    line_paths: list[Path] = []
    for i, ((_, _, _, hold), text) in enumerate(zip(SHOTS, VOICE_LINES)):
        if not text.strip():
            # Silent shot — produce the right length of silence directly.
            silent = tmp / f"silent_{i:02d}.wav"
            cmd = [
                "ffmpeg", "-y",
                "-f", "lavfi", "-i", f"anullsrc=r={ESPEAK_SR}:cl=mono",
                "-t", str(hold),
                silent.as_posix(),
            ]
            run(cmd)
            line_paths.append(silent)
            continue

        raw = tmp / f"raw_{i:02d}.wav"
        padded = tmp / f"padded_{i:02d}.wav"
        synth_line(text, raw)
        spoken = probe_duration(raw)
        if spoken > hold:
            print(
                f"warning: shot {i:02d} narration is {spoken:.1f}s, "
                f"longer than its {hold:.1f}s hold — will overrun the crossfade",
                file=sys.stderr,
            )
            target = hold
        else:
            target = hold
        pad_to_duration(raw, target, padded)
        line_paths.append(padded)
        print(f"  shot {i:02d}: spoken {spoken:.1f}s / hold {hold:.1f}s")

    # Concatenate all padded clips into one WAV.
    concat_list = tmp / "concat.txt"
    concat_list.write_text(
        "\n".join(f"file '{p.as_posix()}'" for p in line_paths)
    )
    out_wav = tmp / "narration.wav"
    cmd = [
        "ffmpeg", "-y",
        "-f", "concat", "-safe", "0",
        "-i", concat_list.as_posix(),
        "-c", "copy",
        out_wav.as_posix(),
    ]
    run(cmd)
    return out_wav


def mux_audio_into_video(video_in: Path, audio_in: Path, video_out: Path) -> None:
    """Mux the audio track into a copy of the video, keeping the video stream intact."""
    cmd = [
        "ffmpeg", "-y",
        "-i", video_in.as_posix(),
        "-i", audio_in.as_posix(),
        "-map", "0:v:0",
        "-map", "1:a:0",
        "-c:v", "copy",
        "-c:a", "aac", "-b:a", "128k",
        "-ar", "44100",
        "-ac", "2",
        "-shortest",
        "-movflags", "+faststart",
        video_out.as_posix(),
    ]
    run(cmd)


def main() -> None:
    if not shutil.which("ffmpeg") or not shutil.which("magick"):
        print("ffmpeg and ImageMagick (magick) are required.", file=sys.stderr)
        raise SystemExit(1)
    if len(VOICE_LINES) != len(SHOTS):
        raise SystemExit(
            f"VOICE_LINES has {len(VOICE_LINES)} entries, SHOTS has {len(SHOTS)}. "
            "Edit voice_script.py until the counts match."
        )

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)

        # Re-render the video first (don't reuse the prebuilt long cut
        # — if the user edited SHOTS we want the narration to stay in
        # sync). Build directly to a temp file, then mux.
        print("Rendering video frames...")
        shots = render_shots(tmp_path)
        video_tmp = tmp_path / "video.mp4"
        encode(shots, video_tmp)

        print("Synthesising narration...")
        audio = build_audio_track(tmp_path)

        print(f"Muxing audio into {OUTPUT.name} ...")
        mux_audio_into_video(video_tmp, audio, OUTPUT)

    size_mb = OUTPUT.stat().st_size / (1024 * 1024)
    total_hold = sum(d for _, _, _, d in SHOTS)
    minutes, seconds = divmod(int(total_hold), 60)
    print(f"OK  {OUTPUT}  ({size_mb:.1f} MB, video {minutes}:{seconds:02d})")


if __name__ == "__main__":
    main()