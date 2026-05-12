# Nigerian Government Delivery Tracker

**Status:** Idea / Early Concept
**Date:** April 2026 (reframed May 2026)

---

## Editorial Position

This is **advocacy media**, not neutral aggregation. The product exists to counter-program against a dominant negativity bias in Nigerian public discourse — a bias driven partly by opposition actors, partly by engagement incentives that reward outrage over competence, and partly by a younger generation that has no historical baseline for what "normal" Nigerian governance used to look like.

The stance is explicit: **surface concrete, verifiable government delivery — federal, state, and LGA — and place it in historical context.**

This is not "balance." Balance is already over-supplied by the negativity industry. What is under-supplied is rigorous, evidence-backed signal about things that actually got built, disbursed, enacted, or completed.

---

## The Problem Being Addressed

1. **Negativity dominance.** Nigerian civic discourse, especially online, treats outrage as the default. Failures are amplified, deliveries are ignored.
2. **Lost historical baseline.** Younger Nigerians have no reference point. A road completed in 2026 is judged against an imagined ideal, not against the actual completion rate of comparable projects in 1995, 2005, or 2015.
3. **Fragmented governance.** Delivery in Nigeria spans federal ministries, state governments, and LGAs. No one stitches the chain together. A federal programme announced in Abuja, implemented by a state agency, and delivered at the LGA level is currently three disconnected stories. It should be one.
4. **Government PR is not trusted, and rightly so** — it is undisciplined, unsourced, and self-congratulatory. A third-party tracker with stricter sourcing standards than government itself is a credibility gap worth filling.

---

## The Idea

A **delivery tracker** — webapp + Telegram channel — that records concrete government delivery events across federal, state, and LGA strata, with evidence per item and historical context where available.

The unit of content is a **delivery**, not an announcement. Distinguishing the two is the single most important editorial discipline.

---

## What "Delivery" Means Here

Each tracked item is one of:

- **Announced** — a programme, grant, or project has been formally declared, with a named owner and timeline. Tagged clearly as announcement.
- **In progress** — work has visibly started, with evidence (contractor named, site active, disbursements made).
- **Completed / commissioned** — the thing exists and functions. Photo, video, GPS, or official gazette required.
- **Reversed / abandoned** — previously celebrated items that later stalled or failed. Tracked with the same rigour as wins. This is non-negotiable; without it the product is propaganda.

---

## The Historical Context Layer

This is the differentiator, not the aggregation.

For a meaningful subset of items, attach a context note:

> *Ogun–Ondo coastal road, Section 4 commissioned. Last federal upgrade on this corridor: 1987. Average federal road project completion rate 2010–2015: ~38%. 2020–2025: ~61%.*

Nobody in Nigerian media is doing this systematically. Negative-takes media won't (it undermines them). Government PR won't (they lack the discipline). Foreign press doesn't care.

The historical baseline is the moat.

---

## Why Not an X Bot

Original framing was an X bot. Dropped:

- X API is heavily monetised; the free tier is unusable for read/write at scale.
- Automated bots face suspension risk under current X policies.
- Discoverability is poor — users have to find and follow.

X remains useful as a **distribution channel** — manual or lightly scheduled posts linking back to the platform. The platform is the product; X is a megaphone.

---

## Sources

Filtered for **delivery events**, not all announcements. Most input is noise; that's expected.

**Telegram channels (primary — free Bot API, well-documented):**
- Ministry and agency channels (NITDA, CBN, FMARD, etc.)
- State government channels where available

**RSS / stable HTML scraping (secondary):**
- A small set of ministry sites with reliable structure
- Official gazette feeds where available

**Hand-curated additions:**
- Press conference recordings (YouTube)
- Photo/video evidence sourced from official social channels
- Field reports from trusted contributors (later)

**Explicitly out of scope for MVP:**
- WhatsApp Channels (no usable API)
- PDF OCR pipeline (link to the PDF, don't index it)
- Multilingual support (English only for v1)
- Twenty-plus ministry site scrapers (maintenance trap)

---

## Editorial Discipline (Non-Negotiable)

Even openly advocacy-positioned media dies if it's sloppy. The audience this targets — Nigerians tired of the doom feed — will fact-check ruthlessly.

1. **No unverified claims.** If a project is "commissioned" but not functioning, do not publish until verified.
2. **Distinguish announcement from delivery.** Tag clearly. Never let a promise read as a result.
3. **Evidence per item.** Photo, video, gazette, named contractor, GPS — something concrete. "Trust me" does not ship.
4. **Track our own backlog.** Items previously celebrated that later stall must be re-tagged as reversed/abandoned, publicly. This is what separates advocacy from propaganda.
5. **No per-item editorialising.** The aggregate of 200 verified deliveries is the argument. Prose commentary is unnecessary and weakens credibility.

---

## What Makes This Useful

- A single feed of verified government delivery across all three strata.
- Cross-strata stitching: federal programme → state implementation → LGA delivery, traced as one chain.
- Historical context that gives current performance a baseline.
- Sector and state filters: Digital Economy, Agriculture, Education, Health, Infrastructure, Finance.
- Map view (state pins) and timeline view.
- Optional weekly digest (email + Telegram).

---

## Technical Approach (Preliminary)

Standalone product. Not tied to any existing project codebase.

**Data layer:**
- Scheduled poller (Python) — Telegram Bot API, RSS, a handful of stable HTML sources.
- SQLite for MVP. Postgres later if needed.
- Schema (per item): `title`, `summary`, `level` (federal/state/LGA), `state`, `sector`, `status` (announced/in-progress/completed/reversed), `evidence_urls[]`, `source`, `published_at`, `historical_context` (nullable), `chain_id` (nullable, links related items).

**Backend:**
- Python REST API (FastAPI).
- Endpoints: feed, search, filter by sector/state/level/status, chain view, deadline-approaching.

**Frontend:**
- Mobile-first PWA (connectivity in Nigeria is patchy; offline matters).
- Search + filters + map + chain view.

**Distribution:**
- Auto-mirrored Telegram channel (every published item posts there).
- X presence: manual or lightly scheduled, links back to the platform.
- Weekly digest: email + Telegram.

**Curation workflow:**
- Semi-manual at first. Items enter a review queue; a human verifies evidence before publish.
- Trust over volume. Better 30 verified items per week than 300 unverified.

---

## Risks & Mitigations

- **"Looks partisan" criticism** — accepted. Editorial position is explicit. Mitigation is rigorous sourcing, not false balance.
- **Maintenance burden of scrapers** — limit to a small set of stable sources; lean on Telegram Bot API.
- **Verification load doesn't scale** — accepted for first 6 months. Curation discipline is the product.
- **Government PR co-option attempts** — refuse direct feeds. Independence is the only asset that matters.
- **Backlog discipline drift** — if reversed/abandoned items stop appearing, the project has failed. This metric must be watched internally.

---

## Open Questions

- Hosting: low-cost options sized to a Nigerian audience.
- Contributor model: when (if ever) to open submissions to the public, and how to verify them.
- Funding model: irrelevant for now (this is not a revenue project), but hosting cost needs an answer.
- Historical context sourcing: what's the cheapest reliable source for baseline data (NBS reports, World Bank, archived news)?

---

## Next Steps

- [ ] Identify 5–8 Telegram channels worth polling on day one.
- [ ] Identify 2–3 RSS feeds and 2–3 stable HTML sources.
- [ ] Define the delivery schema in detail (status transitions, chain linking).
- [ ] Build the poller + review queue + minimal feed UI as the MVP.
- [ ] Pick one sector (suggest: Infrastructure or Digital Economy) to seed the first 50 verified items.
- [ ] Name and position the product.
