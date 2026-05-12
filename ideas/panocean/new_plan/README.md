# Newcross and Pan Ocean Group — Digital Transformation Document Set

**Version 2.0 · May 2026**

This folder contains a perspective paper and supporting materials prepared for
a discussion with the Newcross and Pan Ocean Group of Companies about digital
transformation.

The materials are deliberately framed as **discussion papers, not delivery
plans**. They offer an external industry view and do not assume full visibility
of initiatives already in motion inside the group (RADA-AMS, infrastructure
modernisation, and others).

---

## What's in this folder

| File | What it is | Audience |
|---|---|---|
| [`Strategic_Vision.tex`](./Strategic_Vision.tex) | The main paper. Frames digital transformation around the **eight capability themes** that define the conversation in oil and gas in 2026, adapted to the group's Nigerian context. Capability-led, not phase-led. | Leadership, strategy |
| [`Nigeria_AI_Roadmap.tex`](./Nigeria_AI_Roadmap.tex) | Companion document. Ten concrete AI and data initiatives, organised by **data and infrastructure readiness** (Tiers 1–3), not by calendar dates. Each initiative grounded in actual group assets. | Technical leadership, planning |
| [`Expression_of_Interest.tex`](./Expression_of_Interest.tex) | Cover letter from Olajide Olaniyan to the colleague who initiated the conversation. Positions the materials as discussion, not application. | Specific recipient |
| [`Digital_Transformation_in_Oil_and_Gas_2026.md`](./Digital_Transformation_in_Oil_and_Gas_2026.md) | A short standalone reference: what "digital transformation" actually means across the global oil and gas industry today. The eight themes explained without group-specific framing. | Anyone wanting context |
| [`README.md`](./README.md) | This file. | — |

---

## What changed from Version 1.0 (April 2026)

The earlier version was structured around a **two-track, phased roadmap**
(Phase 1 quick wins, Phase 2 AI-driven operations, Phase 3 foundation for
scale). That framing has been retired. Three reasons:

1. **Phases overstate visibility.** A phased delivery plan reads like it was
   written by someone with full inside knowledge of the group's plans. From an
   external position that is dishonest.
2. **Transformation isn't a project.** Global majors and serious indigenous
   operators don't run digital transformation as a 24-month plan. They run it
   as concurrent capability programmes that mature over years.
3. **It crowded out internal initiatives.** A phased external plan implicitly
   competes with internal momentum. A capability frame complements it.

**What replaced it:**

- **Eight capability themes** (connected operations, industrial AI, data
  fabric, ESG digitisation, workforce digitisation, OT security, generative
  AI / institutional memory, hybrid cloud and edge) are concurrent, not
  sequential.
- **Tier 1 / 2 / 3** in the AI roadmap are now explicitly **data readiness
  tiers**, not time tiers. No calendar dates.
- A **capability maturity self-assessment matrix** the group can use to
  position itself across the eight themes.
- A **dependency diagram** in the AI roadmap replacing the old Year-1 /
  Year-2 / Year-3 timeline. The arrows show what enables what.
- Explicit **acknowledgement of internal work in motion** throughout.
- **Communications infrastructure** is now positioned as a transformation
  prerequisite (LAN, WAN, VSAT, rig data links) rather than treated as a
  background IT concern.

---

## Building the PDFs

All `.tex` files are self-contained and compile with a standard TeX Live
distribution. From this folder:

```bash
pdflatex Strategic_Vision.tex
pdflatex Nigeria_AI_Roadmap.tex
pdflatex Expression_of_Interest.tex
```

Run twice if cross-references or TikZ positioning need a second pass.

The documents share a common visual identity:

- **Font:** TeX Gyre Heros (Helvetica-compatible sans-serif)
- **Primary colour:** Deep petroleum navy `RGB(15, 52, 96)`
- **Accent colour:** Oil amber `RGB(198, 124, 0)`
- **Page:** A4, 0.75-inch margins
- **Tables:** booktabs + tabularx for consistent appearance
- **Diagrams:** TikZ (capability map, dependency diagram, etc.)

---

## How to read the document set

If you have **15 minutes**, read:

- The "About This Paper" box on the first page of `Strategic_Vision.tex`
- The "Eight Themes" diagram and the section that follows
- The "Where External Perspective Adds Value" section

If you have **45 minutes**, read all of `Strategic_Vision.tex` end-to-end.

If you want **specific initiatives**, the `Nigeria_AI_Roadmap.tex` lists ten
concrete initiatives with data, tech stack, ROI, and commercial-product
framing for each.

If you want **industry context without group-specific framing**, read
`Digital_Transformation_in_Oil_and_Gas_2026.md`.

---

## Contact

Olajide Olaniyan · CEng Software Engineer, IBM
[jidemobell@gmail.com](mailto:jidemobell@gmail.com) ·
[linkedin.com/in/olajide-olaniyan](https://linkedin.com/in/olajide-olaniyan)
