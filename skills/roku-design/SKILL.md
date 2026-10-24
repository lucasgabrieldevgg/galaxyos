---
name: roku-design
description: "The visual-craft skill, adapted for television: 10-foot UI that reads as designed, not generated — and that works with a D-pad, not a mouse. Adapted from lucasgabrieldevgg/design v1.0.0 (MIT) for Roku SceneGraph interfaces. Four modes: DE-SLOP (audit a TV screen against banned web-tropes AND banned TV-tropes), CREATE (Design Read + three contrasting macrostructures from TV layout families — launcher home, content rails, catalog grid, detail page), RESTYLE (professional pass preserving navigation behavior as a hard contract), STUDY (extract DNA from launchers/TV UIs the user admires). Covers the TV-specific hard bans (text below 24px at 1080p, hover-dependent affordances, low-contrast-on-TV palettes, dense desktop grids, long animations), the focus system as the interaction spine (focus is the cursor), the 7-axis gates re-grounded for TV (D-pad reachability, focus visibility, room-lighting contrast, overscan safe area), and the sofa test as the final assertion. Use for ANY request about how a Roku app looks, reads, or feels on the TV — 'make my channel look professional', 'this UI feels wrong on the TV', 'design my launcher', 'audit my channel UI', 'make it feel like a real OS'."
version: 1.0.0
license: MIT — adaptation of lucasgabrieldevgg/design (MIT). Upstream licenses: see original ATTRIBUTION.md.
---

# roku-design — interfaces for a couch, not a desk

The test for everything this skill produces: a person on a sofa, 3 meters from the screen, holding a remote with five buttons, reads the screen in two seconds, never loses the focus, and never sees anything that looks generated from a prompt.

TV UI fails that test in two predictable ways. **Carried over from web slop**: the same purple gradients, emoji icons, three identical cards, Inter-on-everything. **Native to TV slop**: mouse-minded layouts (hover affordances, tiny click targets, corner buttons only a cursor reaches), desktop-density grids, text sized for a lap instead of a living room, and palettes tuned for a calibrated monitor instead of a mid-brightness TV panel in a bright room. This skill attacks both.

## The roku-design contract

1. **Focus is the cursor.** Every element the user can act on is reachable by arrow keys alone, in the order the eye expects (the focus path matches the visual reading path). If it can't be focused and OK'd with the D-pad, it doesn't exist.
2. **Legible at 3 meters.** Minimum body 24-28 px at 1080p (nothing under 24, ever), titles big, hierarchy visible on a squint from across the room. TV panels wash out contrast — design for the washed-out case.
3. **Structure follows content.** A launcher, a content hub, a games catalog and a detail page are different skeletons. Two Roku apps for different briefs must not share a shape.
4. **Restraint is a feature.** On a TV, every extra element is another thing to focus past. Audit for what can be removed before adding anything.
5. **Verify on the render.** Checks run against the real screen — on the TV when possible, on a 1920×1080 screenshot at 100% when not. "I meant to" does not count.
6. **Motion is functional, not decorative.** Focus transitions ≤150 ms, 60 fps or nothing, no parallax, no cinematic reveals blocking input. There is no `prefers-reduced-motion` on a TV — so motion must earn its keep by default.

## The Design Read (mandatory first line)

> **`Design Read: building [screen] for [device tier], in [visual world], dials [V/M/D], structure [TV macrofamily], input [D-pad only / D-pad + remote extras].`**

- `Design Read: building a launcher home for a 512MB FHD Roku TV, in a Minimal Daylight world, dials [V=3 / M=2 / D=4], structure: hero-band + rails, input: D-pad only.`
- `Design Read: building a games catalog for a 512MB FHD Roku TV, in an Arcade Cabinet world, dials [V=5 / M=3 / D=6], structure: coverflow grid, input: D-pad + media keys.`

The three dials, TV-calibrated: **VARIANCE** V1–10 (1–3 an OS-grade launcher with strict consistency → 7–10 a game catalog with personality) · **MOTION** M1–10 (1–3 near-static OS feel, focus steps only → 8–10 game-y transitions; default TV app lives at 1–3) · **DENSITY** D1–10 (1–3 a clock-and-four-tiles ambient screen → 9–10 an EPG-style grid; most TV screens belong at 3–5).

## TV macrostructure families (pick three different ones in CREATE, never one default)

| Family | Shape | Fits |
| --- | --- | --- |
| **Ambient hero-band** | large clock/greeting block + status card + one shortcut rail | launcher home, screensaver-with-info |
| **Content rails** | poster rows over a background hero, like the Store/Netflix | media hub, Web hub modules |
| **Catalog grid** | uniform tile grid with category chips above | games library, app picker |
| **Focus spotlight** | one giant focused item, siblings peeking at the edges | detail pages, game picker |
| **Panel split** | left nav rail + right content pane | settings, diagnostics |

A launcher and a catalog must not share a skeleton; a settings screen must not look like a landing page.

## Hard bans (binary; user override wins, note it and proceed)

**Web slop (inherited)**: gradient blobs and gradient text · emoji as icons · three identical icon-heading-text cards as the structure · screaming uppercase eyebrows · vanity stats · dead placeholders · unmodified Inter/Roboto/Poppins as the entire type system · `transition: all .3s ease` everywhere.

**TV-native slop (this adaptation)**:

- Any text under 24 px at 1080p. No exceptions, not even "just a caption".
- Hover-only affordances. Hover does not exist; a design that needs it is a mockup, not a UI.
- Mouse-corner patterns: buttons pinned to top-right corners reachable in 3+ focus steps from the natural path.
- Contrast tuned on a monitor: body text below ~4.5:1 against its surface **after** simulating TV panel washout (check at mid backlight; dark-gray-on-light-gray dies on TVs).
- Ignoring overscan: critical content within the outer ~5% of the screen edges (38 px h / 21 px v at 1080p is the floor; use 96 px/54 px margins when the device allows) risks being cut on some panels.
- Desktop-density grids (6+ columns of small tiles at 1080p).
- Animations that delay input: any transition that blocks OK/arrow handling, cinematic reveals, auto-carousels the user didn't trigger.
- Long lists rendered as a wall: no virtualized RowList/MarkupGrid on 512 MB devices is a crash waiting to happen, not a design choice.

## The focus system (the interaction spine)

- **Focus is always visible**: a 3–4 px ring or a scale step (1.03–1.08) plus elevation — visible on both light and dark surfaces, in the user's peripheral vision.
- **The focus path is the layout**: design the focus order as deliberately as the visual hierarchy. Arrows behave geometrically (left/right within a rail, up/down across rails); never "nearest-element roulette".
- **Every screen has a natural resting focus** — where OK does the most likely thing (play, open, continue).
- **Focus states are the states**: focused, focused-pressed, disabled, loading-with-focus — design them before the pretty idle state. The idle state is what screenshots show; the focus state is what users live in.
- Back is sacred: a modal closes, a screen pops — Back never traps the user (cert checks this, so does the sofa test).

## The 7-axis gate (every axis ≥ 4, score 1–5, TV edition)

| Axis | Checks |
| --- | --- |
| **1. Anti-slop purity** | zero banned tropes (web + TV lists); icons one library one weight; one committed visual world |
| **2. D-pad UX & 1-to-3** | every actionable element reachable by arrows; one primary action per screen; the 85% case is ≤2 OK presses; focus never lost (including after async loads) |
| **3. Typographic discipline** | ≤2 families; ≥24 px body @1080p; tabular numerals on clock/stats; scale steps obvious from the couch; three-layer hierarchy on squint |
| **4. Spacing & safe area** | 8 px ladder; overscan margins respected; ≥16 px tile padding; rails breathe more than web rows (TV rhythm is horizontal) |
| **5. Focus & states** | focus ring/scale visible on every surface; transitions ≤150 ms; pressed/disabled/loading designed; no input-blocking animation |
| **6. Accessibility** | contrast ≥4.5:1 body (washout-adjusted); audio-guide friendly labels on focus (roAudioGuide); captions for media; color never the only signal |
| **7. Structural variety** | not the same rail-skeleton as every other screen in the app; structure fits the content type; deliberate asymmetry documented |

Any axis < 4 loops back to structure, not to detail polish.

## The deterministic sweep (objective before judgment)

Before the scored gates, yes/no facts: no text under 24 px at 1080p · no hover-dependent affordance · focus order matches visual order when walked with arrows only · every screen's Back path exits cleanly · no content inside overscan margins that would break certification · color count ≤ tokens · numbers tabular · one accent used once-per-view as the focal cue. Run it against a real render (TV screenshot or 1080p browser capture), one pass, fix one batch.

## The sofa test (the final assertion)

> *Sitting 3 m away, on a mid-brightness TV, with only arrows, OK and Back: can a first-time user do the screen's main job within 5 seconds, without reading anything twice, and without ever wondering where the focus went?*

If any part fails: fix it, don't soften it. Then stop — over-polished TV UIs acquire their own uniformity tells. Craft ends at *decided and verified*.
