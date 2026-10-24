---
name: roku-projects
description: "Project creation as a discipline, adapted for the Roku platform: turning 'build me a Roku channel' into a repo that compiles, sideloads, launches on the TV, and remembers — with the thinking done before the BrightScript. Adapted from lucasgabrieldevgg/projects v1.0.0 (MIT) for Roku channel + web hub + Linux companion projects. TRACK 1 - INTAKE: one batched round with Roku-specific questions (personal sideload vs Streaming Store certification, target device tier and RAM, distribution strategy, content/assets ownership, UI language vs dev language). TRACK 2 - DECISIONS: boring-by-default Roku stack (BrightScript + SceneGraph + BrighterScript tooling; RSG 2.0/TypeScript only after beta evaluation), ADR-lites for every deviation, device-info in the brain folder. TRACK 3 - SCAFFOLD: a Roku channel skeleton is done only when it compiles, sideloads to the TV via Developer Mode, launches, and shows clean logs on telnet :8060/:8085 (green smoke test — a folder tree is a mock). TRACK 4 - MEMORY & HANDOFF: the brain folder survives sessions; the TV (IP, dev password, model) is part of the project state. Use for ANY Roku project-creation request: 'build my channel', 'start GalaxyOS', 'set up my Roku dev environment', 'what stack for a Roku app'."
version: 1.0.0
license: MIT — adaptation of lucasgabrieldevgg/projects (MIT). Upstream licenses: see original ATTRIBUTION.md.
---

# roku-projects — Roku project creation as a discipline

Same spine as `projects` — intent before artifacts, boring stack, self-proving skeleton, durable memory — re-grounded for the realities of the Roku platform: a TV device you sideload to over the LAN, a certification gate between you and the Store, 512 MB of RAM on the low end, and a package that ships closed.

## The roku-projects contract

1. **Intent before artifacts.** Same rule, plus the Roku question that changes everything: **personal sideload or Streaming Store public?** A personal channel can iterate daily and ignore cert; a public channel must budget for certification from day one (deprecated APIs, launch time, multi-device testing). This is decided in the intent doc, never improvised mid-build.
2. **Size the ceremony to the work.** Trivial screensaver → build now, assumptions stated. A channel with a web hub → intake round + decisions + tasks. The dial is stated out loud.
3. **Decisions are written down or they didn't happen.** Stack, feed format, pairing design, hosting, cert posture — every durable choice lands in an ADR-lite the moment it is made. Chat history is not memory; the repo is.
4. **The skeleton must prove itself on the TV.** A Roku scaffold is done when it **compiles, sideloads, launches on the real device, and shows clean logs on the debug console** — verified by reading real output, not by assuming. A channel that only compiled on the machine is a mock.
5. **Vertical slice before horizontal layers.** One path (open app → fetch feed JSON → render one row → play one stream) beats ten empty components. No abstraction layer for "the modules we'll have later" — the package is closed anyway; modules that ship are modules in the package.
6. **Boring by default, deviations explicit.** BrightScript + SceneGraph + the community Node tooling is the proven default. RSG 2.0/TypeScript is a **written-reason deviation** until its beta is evaluated and it can be submitted to the Store.

## Routing table

| When | Read / do |
| --- | --- |
| Any Roku greenfield request | intake below → decisions → scaffold → handoff |
| Choosing stack or evaluating RSG 2.0 | the stack matrix below + `docs/research-roku.md` in the project |
| Materializing the channel repo | scaffold steps below (the TV smoke test) |
| New session on an existing Roku repo | brain folder startup (incl. `device-info.md`) |
| Going public / cert prep | cert gate below + sibling `roku-security` pre-deploy gate |

## TRACK 1 — Intake (Roku edition)

One batched round, past-behavior-not-future-intent, zero dangling — plus the Roku-specific block:

1. **Distribution** — personal sideload (dev mode, no review) / beta channel (≤20 users, 120-day expiry) / Streaming Store (certification, assets, multi-device)? Who is it for?
2. **Target device tier** — which TV/box actually runs it (model, Roku OS version, RAM)? A 512 MB FHD set is a different budget than a 4K stick with 2 GB. Write it into `device-info.md`.
3. **Content** — where does media/art come from, who owns the rights (cert checks app name/trademark), is there a feed or API already?
4. **Languages** — UI language(s) ≠ dev language. Roku supports app localization; bilingual PT/EN is a legitimate launch choice in BR.
5. **Network reality** — how does the TV reach your services (static host? functions? LAN only?)? The 4 MB package budget pushes all real assets to a CDN/Hub.
6. **Reality check** — has the user published or sideloaded anything on Roku before? Is Developer Mode already enabled on the TV?

## TRACK 2 — Decisions: the boring Roku stack

| Layer | Boring default | Deviation requires an ADR-lite because |
| --- | --- | --- |
| Channel language | BrightScript + SceneGraph | RSG 2.0 (TypeScript) is in beta — verify Store submission opens before betting on it |
| Build tooling | Node + BrighterScript + `roku-deploy` + `bslint` | hand-rolled zip/upload is error-prone and unpinnable |
| Package deps | `ropm` with pinned versions | unpinned deps can break certification builds |
| Feed/Hub | static JSON on GitHub Pages → real API on Vercel when needed | a server from day one buys nothing |
| Companion (PC) | systemd user service, Node or Go, Chromium headless for web rendering | anything heavier is ops burden |
| Debug | telnet `<tv-ip>`:8085 console | — |

Every deviation gets the 10-line ADR-lite: context, options, choice, consequence, revert condition.

## TRACK 3 — Scaffold (the green smoke test on the TV)

Creation order that ends in proof, not a folder tree:

1. `mkdir` repo; `git init`; brain folder (`brain/context.md`, `brain/decisions/`, `brain/tasks.md`, `brain/device-info.md`); `.gitignore` (`.env`, keys, `out/`, `build/`).
2. Channel skeleton: manifest with `bs_const`s, one scene, one row, one `roUrlTransfer` fetch of a **known-good** feed URL, graceful "offline" state.
3. Feed skeleton: one JSON file served over plain HTTP from the dev machine or a static host.
4. **The smoke test (all four, or it is not done):**
   - [ ] compiles with zero errors via the toolchain
   - [ ] sideloads to the target TV via Developer Mode (web upload or `roku-deploy`)
   - [ ] launches on the TV and renders the row
   - [ ] debug console (`telnet <ip>:8085`) shows the expected lifecycle logs, no errors
5. First commit **after** the smoke test, including the brain folder.
6. Wire day-one foundations: error states in every screen, logging helper, `bslint` in a pre-commit/CI-lite, and the **feed contract test** (schema validation the channel runs on its own data).

## TRACK 4 — Memory & handoff

- `brain/device-info.md` carries: TV model, Roku OS version, TV IP, dev mode password location (never the password itself in git), network topology (Ethernet vs Wi-Fi), known device quirks.
- Session startup order: `context.md` → latest ADR-lites → `tasks.md` → the open "verify" queue from `research-roku.md`.
- Task discipline unchanged: never mark done without verifying the criterion — on Roku, "done" includes "ran on the TV".

## The cert gate (only when distribution = public)

- [ ] No deprecated APIs (cert blocker) — run the official Static Analysis tool first.
- [ ] Launch fast on a low-RAM device; no infinite spinners; remote focus never lost.
- [ ] Tested on multiple device models (required — mix of RAM/CPU tiers).
- [ ] Store assets ready: poster 540×405, ≤6 screenshots 1920×1080, short/long descriptions, name without "Roku" in it.
- [ ] Content rights and naming cleared; monetization model decided (ads 70/30, subs 80/20).

## Hard rules (carried over + Roku-specific)

- Never scaffold on a vague idea — batch the round first.
- Never invent a requirement; zero dangling assumptions.
- The publish button — the cert submission, the Store listing — is the **user's**. The agent prepares everything up to it.
- Dev-mode passwords and Hub secrets never land in committed files; the package is extractable — **no secrets inside the channel, ever** (see `roku-security`).
