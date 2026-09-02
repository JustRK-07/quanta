"""Voice script for the long Quanta demo.

Each line is paired with the SHOTS tuple of the same index in
build_demo_long.py. Holds are sized so the narration finishes about
half a second before the crossfade, leaving a tiny tail of silence
between lines.

Style: written for an Indian English speaker narrating a hackathon
demo. Short sentences. The reader doesn't see the captions on screen,
so each line repeats enough context to stand on its own.

If you change a shot's hold, retime the matching line so it still
finishes inside the hold. Roughly: 2.5 words per second, leave 0.5 s
of tail.
"""

# Mapping is positional — index i corresponds to SHOTS[i] in
# build_demo_long.py. Empty string means "no narration for this shot"
# (used for visual cards where the on-screen text is enough).
VOICE_LINES: list[str] = [
    # 00  Title (6s)
    "Welcome to Quanta. Scan a textbook page — get the diagram, notes, and a quiz.",
    # 01  Act I — The setup (4s)
    "Act one. How a Quanta session begins.",
    # 02  Home (22s)
    "The home screen is built around one big teal tile. Tap it once to start a scan. Below it, your most recent scans are already queued up, ready to be reopened with a single tap.",
    # 03  History (20s)
    "Every scan is saved on the phone. The history tab works offline — no signal, no problem. Open one and the visualiser, the notes, and the quiz come back exactly as you left them.",
    # 04  Act II — The visualiser (4s)
    "Act two. The visualiser.",
    # 05  Projectile (28s)
    "Here is projectile motion at twenty metres per second, launch angle forty-five degrees. Drag the slider and the parabola redraws live, with the velocity vector at the apex. Every visualiser is a Flutter widget — no remote canvas, sixty frames a second.",
    # 06  SHM (24s)
    "Simple harmonic motion. A spring with a position-versus-time graph drawn underneath. Change the mass, the spring constant, or the amplitude, and the period updates in real time.",
    # 07  Bohr atom (22s)
    "The Bohr model for carbon. Two electrons in the first shell, four in the second. Tap a shell to highlight it. Quanta recognises the topic and picks the right diagram automatically.",
    # 08  Wave on a string (22s)
    "A transverse wave on a stretched string. Amplitude, frequency, wave speed — all are sliders. The standing-wave pattern updates as you change any of them.",
    # 09  Act III — Notes & quiz (4s)
    "Act three. Notes and quiz.",
    # 10  AI Notes (24s)
    "AI Notes turns the same problem into a study sheet. Concept, formulas, key points, and a worked example, all in expandable cards. Written by Gemini, edited to fit one screen.",
    # 11  AI Quiz (24s)
    "Pick a difficulty. Quanta generates five multiple-choice questions on the same topic, scores them as you answer, and explains why each wrong option is wrong.",
    # 12  History loop (20s)
    "Every scan, every quiz, every note lives in your history. Six scans in the demo set; yours will too — across physics, chemistry, and maths.",
    # 13  Act IV — The loop (4s)
    "Act four. The loop.",
    # 14  Account & coins (22s)
    "Account and Quanta coins. Ten coins per scan, five more for completing a quiz. Streaks keep you honest. The whole reward loop runs on the phone, no backend round trip.",
    # 15  Architecture card (18s)
    "How it fits together. The phone runs OCR on-device, then sends the text to a FastAPI backend. The backend calls Gemini, fills in the visualiser template, and returns JSON. Flutter renders the diagram.",
    # 16  Tech stack card (18s)
    "What it is built on. Flutter for the client, FastAPI and MongoDB for the backend, Firebase Auth with a dev-token bypass, and Gemini two-point-five Flash for the AI generation.",
    # 17  Roadmap card (18s)
    "What is next. On-device topic classification, more visualisers for optics and circuits, cross-device history sync, Hindi Marathi Tamil Telugu and Kannada translations, and an LMS hook for teachers.",
    # 18  Credits (8s)
    "Team Gryffindor. Built at Vishwakarma Institute of Technology, Pune. iQOO Hackathon twenty-twenty-six.",
]