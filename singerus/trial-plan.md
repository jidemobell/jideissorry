# Singerus — Remote Choir Practice Trial Plan

**Status:** Concept / pre-trial
**Date:** May 2026
**Context:** Choir with members spread between Navan and Dublin (~50 km). Currently limited to Sunday morning practice. Goal: explore "practice from your room" sessions where singers, guitarist (me), keyboardist, and bass can rehearse together mid-week with near-live feel.

---

## 1. Why this is realistic for our setup

Network Music Performance (NMP) requires round-trip audio latency under ~30 ms to feel "in sync." Two facts make our case favourable:

- **Geography**: Navan ↔ Dublin is ~50 km. On wired fibre this is typically 5–10 ms network latency — well within budget.
- **Jamulus's effective range**: Jamulus is reliable up to roughly **300 km** between participants and a server (a comfortable rule of thumb in the Jamulus community). We are nowhere near that limit, so the network is not the bottleneck — *our local setup* will be.

The bottleneck for us will be: WiFi vs Ethernet, audio interface quality, and Bluetooth headphones (which must not be used).

---

## 2. Tools to evaluate (in order)

| Tool | Cost | Why try it |
|---|---|---|
| **Jamulus** | Free, open source | Most popular for amateur bands. Low-latency, mature, runs a server everyone connects to. Best first try. |
| **SonoBus** | Free, open source | Friendlier UI, peer-to-peer. Good fallback if Jamulus server hosting is awkward. |
| **JackTrip** | Free, open source | Highest fidelity (uncompressed). More technical to set up. Use only if Jamulus quality isn't enough. |
| FarPlay / JamKazam | Commercial | Skip for now. |

**Decision:** Start with **Jamulus**. If it works for 2 people, expand to the full choir.

---

## 3. The trial — Phase 1 (2 people)

**Goal:** Prove that me (Navan) + one Dublin singer can rehearse one song with acceptable timing.

**Participants:**
- Me (guitar) — Navan
- One singer (or the bass player if available) — Dublin

**Hardware checklist per person:**

- [ ] USB audio interface (Focusrite Scarlett Solo ~€120, or Behringer UMC22 ~€60)
- [ ] **Wired Ethernet** to router (no WiFi)
- [ ] **Wired headphones** (no Bluetooth — adds 100–300 ms)
- [ ] Laptop with Jamulus installed
- [ ] Instrument/mic cable

**Test session protocol:**
1. Both connect to a public Jamulus server in Dublin or London (test 2–3, pick lowest ping).
2. Each person reports their "ping" and "overall delay" numbers from Jamulus.
3. Play one chord together. If it feels tight, move to a familiar song.
4. Record the session locally. Listen back. Note timing slips, dropouts, tone quality.
5. Document: round-trip ms, dropouts/min, subjective feel (1–5).

**Pass criteria:** overall delay < 40 ms, no dropouts in a 3-minute song, both players say "felt like jamming."

---

## 4. My current gear (Navan side)

- Guitar
- Powered monitor speaker with its own preamp
- **Zoom G2 Four** multi-effects pedal — has USB-C, AUX, headphone out. **This is likely sufficient as my audio interface** for the trial. The G2 Four exposes itself as a USB audio device, so I can:
  - Guitar → G2 Four → USB-C → Laptop (input)
  - Laptop → G2 Four headphone out → wired headphones (monitor)
  - This avoids needing to buy a Scarlett yet.
- **Action:** confirm G2 Four's USB driver latency on macOS. If round-trip through it is < 10 ms at 64-sample buffer, we're good. If not, fall back to a Scarlett Solo.

## 5. Bass player (Dublin side) — unknown

- Need to ask what he has. Likely scenarios:
  - Bass amp with USB out → works as interface (best case)
  - Just a bass + laptop → needs a cheap interface (€60 UMC22 with a 1/4" input is enough)
  - DI box + interface → ideal
- **Action:** send him a short message: "Do you have anything that connects your bass to your computer over USB? If not, I'll point you at a €60 box."

## 6. Singers

- Any condenser or dynamic mic into a USB interface works.
- Cheapest path: Behringer UMC22 (€60) + an SM58-clone (€30) + wired headphones (€20). ~€110 total.
- Built-in laptop mics will **not** work — too much latency, feedback risk, awful tone.

---

## 7. Phase 2 — full choir (if Phase 1 passes)

- Spin up our **own Jamulus server** (cheap VPS in Dublin, ~€5/month, or run on a spare machine at home with port forwarding).
- Add members one at a time. Watch for the first person on WiFi — they'll be the weak link.
- Realistic ceiling: 6–10 people if everyone is wired. Beyond that, a server topology helps but we'll re-evaluate.

---

## 8. What's worth building on top (the actual product idea)

If the trial works, the existing tools (Jamulus etc.) are powerful but **built for engineers, not musicians**. A wrapper/fork aimed at choirs and worship teams could be valuable.

### Build vs fork

- **Don't build from scratch.** Latency engineering, jitter buffers, codec choices — already solved.
- **Fork Jamulus** (GPL — fork is allowed; derivative work must also be GPL). Use its audio engine and protocol; replace the UI and add choir-specific features.

### Candidate features for a "Singerus" layer over Jamulus

1. **Onboarding wizard** — detects audio interface, sets buffer size, warns about WiFi/Bluetooth before the user joins. ("Plug this here, set buffer to X.")
2. **Pre-session check** — 30-second test that measures each participant's round-trip latency, dropouts, and clock drift, then shows a green/amber/red score per person. Names and shames the WiFi user before practice starts, not during.
3. **Setlist + chord chart sync** — leader picks the next song, everyone's screen scrolls together. ChordPro / OnSong format. Auto-transpose for capo'd guitarists.
4. **Session recording** — multi-track per participant, stored locally, optionally uploaded. Useful for "listen back to last Wednesday."
5. **Choir mode topology** — Jamulus today is one mix per server. Add:
   - Section grouping (sopranos / altos / tenors / basses / band) with per-section sub-mixes.
   - "Director view" that can solo/mute sections.
6. **Roles**: director, section lead, member. Director controls song changes, count-ins, click track.
7. **Friendly identity**: choir login, not IP/port. Single shared link to join.
8. **Click track / count-in** that's tight (sample-accurate, sent on the audio bus, not as a chat message).
9. **Mobile-friendly observer mode** (listen only, no perform) for members who can't get hardware that week.

### What's deliberately out of scope

- Video. Adds latency, distraction. Maybe a small webcam thumbnail row, no large video.
- Effects/mixing DAW features. Use what your interface/pedal already does.
- General-purpose jamming. Stay focused on choirs/worship/structured rehearsals.

---

## 9. Immediate next actions

- [ ] Confirm Zoom G2 Four works as low-latency USB interface on my Mac (test buffer 64 / 128 / 256 samples, measure round-trip with Jamulus's own meter).
- [ ] Message the bass player: ask what he can connect his bass to a computer with.
- [ ] Pick one Dublin singer who is willing to buy a €60 interface for the trial.
- [ ] Schedule a 30-minute Wednesday evening test slot.
- [ ] Write down the numbers and feel-score after the test.
- [ ] Decide: stop, continue with Jamulus as-is, or start prototyping the Singerus wrapper/fork.

---

## 10. Honest risks

- One person on WiFi sinks the whole session.
- Rural broadband (parts of Meath) may have higher jitter than expected — needs measuring, not assuming.
- Singers tend to be the least technical members; onboarding friction is the real product problem, not audio.
- GPL on a Jamulus fork means a commercial closed-source product is not straightforward — plan licensing early if monetisation matters.
