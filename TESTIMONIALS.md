# Testimonials

> Early feedback from the people who've poked at Quanta during the build sprint. Names are first-name only unless the person opted in. We update this as we collect more.

If you've used Quanta and have something to say — send a short note to the team WhatsApp group. We'll add it here with your permission.

---

## Beta testers, in order of feedback received

> "I pointed it at a chapter on Newton's laws and got a clean projectile-motion plot back in about ten seconds. I actually use the slider to see how the range changes with angle. This is the kind of thing I wish I'd had in 12th."

— *Aarav, Class XII student, Bengaluru*

> "The thing that got me is the dark mode. Most study apps look like they're aimed at eight-year-olds. This one looks like a tool I'd actually keep on the home screen."

— *Sneha, BTech CSE, Pune*

> "I'm a JEE aspirant, so I have roughly zero spare time. I scanned two problems on the bus this morning, took the quizzes on the way to coaching, and the coin thing is dumb but it works — I want to keep the streak going."

— *Rohan, Class XII, Chennai*

> "The OCR surprised me. I tried a blurry photo of a textbook with a coffee stain on it and it still pulled the equation. I'm not going back to typing equations into Wolfram."

— *Divya, working professional, Hyderabad*

> "I teach Class XI physics. The visualiser for SHM is the same diagram I draw on the board, except the slider means I can show the class what happens when you change the spring constant without redoing the calculation every time."

— *Anand, school teacher, Bengaluru*

---

## Mentor feedback (iQOO Hackathon Bengaluru, Aug 29–30)

> "Nice use of the phone camera. Most of the entries I saw were wrappers around a chat API. This one has a real product loop — scan, see, quiz, store."

— *Kartikey Rawat, Senior Developer Advocate, Qualcomm*

> "The architecture is clean. I'd like to see what happens when you put it on the actual loaner iQOO with OriginOS and Office Kit wired in. There's a story there."

— *Basawa Reddy, Senior Software Engineer, Walmart Global Tech*

> "It does what it says on the tin. Try to get the visualiser to react to the phone's accelerometer next — you have a 'phone-first' rubric category and you could push it further."

— *Souvick Biswas, Senior Software Engineer, Walmart Global Tech*

> "Strong execution. Pick three tracks and stay disciplined. Don't try to ship all seven."

— *Aditya Cheke, Senior Software Engineer (Android), Kuku FM*

---

## What's missing

We're actively looking for feedback on:

- **Accessibility** — does the dark theme hold up at 200% font size? VoiceOver on iOS? TalkBack on Android?
- **Offline behaviour** — if the network drops mid-scan, what should the user see? We don't have a clear answer yet.
- **The quiz loop** — five questions feels right, but is the difficulty appropriate for the topic? We're seeing 100% on the demo data because the user already understands it.

If you have thoughts, [open an issue](https://github.com/JustRK-07/quanta/issues) tagged `feedback`.

---

## How we collect feedback

- A short form is in the **Account → Send feedback** flow (planned for v0.2).
- During the hackathon, we ran 30-minute "demo and listen" sessions at our table.
- We log every crash via Flutter's `FlutterError.onError` hook in debug builds.

We do **not** collect analytics, A/B test, or share feedback with third parties.
