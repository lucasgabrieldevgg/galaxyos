---
name: roku-craft
description: "Craftsmanship for the Roku platform: process, code quality and verification discipline adapted from lucasgabrieldevgg/theskill (craftsmanship v2.0.0, MIT) to BrightScript/SceneGraph and its Node toolchain. The process track without the parts that don't survive contact with a TV (pure TDD becomes: compile clean, feed contract tests, smoke on the device, telnet-driven verification); the slop taxonomy re-grounded for BrightScript naming conventions and SceneGraph lifecycle bugs; code review with the Roku checklist (node leaks, dangling observers, task-thread misuse, memory budget on 512MB devices); git communications unchanged (commit-craft applies verbatim). Use whenever building or reviewing channel code: 'plan and build this screen right', 'review my BrightScript', 'why does my scene leak', 'polish my channel code', 'make the code not look AI-generated'."
version: 1.0.0
license: MIT — adaptation of lucasgabrieldevgg/theskill · craftsmanship (MIT). Upstream licenses: see original ATTRIBUTION.md.
---

# roku-craft — BrightScript with the discipline kept, the ritual cut

The craftsmanship spine — think before writing, verify before claiming, one change at a time, prose and commits without chatbot cadence — ports cleanly. What changes is the **verification substrate**: a Roku channel runs on a TV you telnet into, not in a REPL, and the classic TDD loop doesn't survive that intact. This skill replaces the parts that don't survive, keeps everything that does, and adds the failure modes SceneGraph apps actually die from.

## The roku-craft contract

1. **Plan the screen before the markup.** A scene is a tree with fields and observers — write the component list, field contracts and focus path as three lines of text before any XML. Most SceneGraph rework is markup written before the data shape existed.
2. **Compile clean is the floor, not the proof.** `bslint` zero warnings is the entry bar. Proof is: the feature running on the TV, exercised with the remote, logs read on `telnet <ip>:8085`.
3. **The feed contract is the test you actually have.** Pure functions (parsing, validation, state machines, formatting) get real unit tests via the Node toolchain; everything else gets (a) feed contract fixtures — including hostile ones — and (b) on-device smoke. Name which one a change has before calling it verified.
4. **One change at a time.** A restyle never bundles a behavior change; a bug found mid-polish is flagged for a separate change. (Carried over unchanged.)
5. **Memory is a budget, not an afterthought.** The target device tier (512 MB low-end Roku TV) is written in the brain folder; every list, image and task is chosen against it. Virtualized lists (RowList/MarkupGrid) are the default; unbounded child creation is a crash, not a style.
6. **Prose and commits don't sound like a chatbot.** Same anti-slop rules, same conventional commits — applied to BrightScript comments, ADR-lites, and PR text.

## Verification ladder (what "done" means, per rung)

| Rung | Proof | Tool |
| --- | --- | --- |
| 1. Compiles | zero errors, zero lints | BrighterScript/`bslint` |
| 2. Unit logic | pure functions pass fixtures | Node test runner over shared logic |
| 3. Feed contract | hostile/valid JSON fixtures accepted/rejected | fixture tests run in CI-lite |
| 4. On-device smoke | sideload → launch → navigate → back out, logs clean | Developer Mode + telnet :8085 |
| 5. Adversarial remote session | arrow-mash, Back-spam, network flap mid-load, empty feed | you, on the sofa, with the remote |

A change is called "verified" with the rung named — "verified to rung 4" — or it isn't called verified.

## BrightScript slop taxonomy (the S-list, Roku edition)

- **S1 · Ghost components**: files in `components/` nothing instantiates, screens kept "for later". Delete or wire.
- **S2 · God scene**: one 2000-line scene doing data, layout, navigation and analytics. Split by responsibility before the second feature lands in it.
- **S3 · Observer rot**: `observeField` without a matching lifecycle cleanup; callbacks firing on nodes that left the scene. Every observer has an owner and a death plan.
- **S4 · Thread abuse**: UI work on the render thread, blocking waits on `roUrlTransfer`, Task threads touching UI nodes directly. Data tasks report through fields.
- **S5 · Naming drift**: components PascalCase, functions camelCase, members `m.`-prefixed with intent (`m.feedUrl` not `m.a`); a function named `doStuff2` is a confession.
- **S6 · Comment theater**: comments narrating the next line ("increment i"), or worse, stale ones contradicting it. Comments explain *why*, code says *what*.
- **S7 · Silent catch**: `try/catch` (or error-return paths) that swallow the failure and march on. Errors surface: log, state, or crash loud in dev builds.
- **S8 · Magic consts**: `if type = "3"` strings and bare numbers deep in logic. Named constants, one manifest, one place.
- **S9 · Dead print**: `print` statements shipped in release paths. Log levels from day one; debug prints have a build reason and an expiry.
- **S10 · Copy-paste siblings**: three near-identical row components that differ by one field. One parameterized component.
- **S11 · Unhandled empty/offline**: screens with no empty state, no error state, no retry path. On a TV, "the Wi-Fi blipped" is a *first-class user flow*.
- **S12 · Focus after async**: a load finishes and focus jumped, vanished, or double-fired the focused item's handler. Focus is restored deliberately after every async transition.

## The Roku review checklist (beyond generic code review)

- [ ] Node leaks: children added to scene rails never removed as rows recycle; the node count is stable over a soak (ECP `query/app-object-counts` in dev mode makes this measurable).
- [ ] Every observer accounted for; no callbacks into destroyed nodes.
- [ ] Tasks: `roUrlTransfer` async (never synchronous on the render thread), timeouts set, failure paths render an error state.
- [ ] Images: correct sizes for their slots, compressed, served from the Hub/CDN — not compiled into the 4 MB package.
- [ ] Lists virtualized; no unbounded `for` creating children.
- [ ] Deep-link params and feed fields validated before use (see `roku-security` rule 3).
- [ ] Launch path: no blocking work before first paint; cert cares about launch time, so do users.
- [ ] Back button exits every screen cleanly; no dead ends (also a cert criterion).
- [ ] No ECP-emitting code anywhere in channel sources (cert blocker; grep for it in CI).
- [ ] Strings localized or centralized if the app is bilingual — no hardcoded copy scattered in markup.

## Debug workflow (the tools that exist)

- `telnet <tv-ip>:8085` — the live console; `?` lists commands; learn `break`/`cont` and the thread list before you need them under pressure.
- Log lines carry a consistent prefix per component (`[Feed]`, `[Home]`, `[Focus]`) — greppable on a scrolling console beats pretty-printing.
- Reproduce bugs on the device, not in assumptions: "works on my machine" has no meaning when the machine is a TV.

## Prose & git (unchanged from commit-craft / stop-slop)

Conventional commits, subject ≤ 50 chars, body answers *why*. PR descriptions state the rung reached on the verification ladder. No "vibes", no "done!!", no narrating the diff line by line — the diff is right there.
