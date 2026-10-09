# Handoff: Épreuve — Photo & Video Editor (iOS)

## Overview
Épreuve is a mobile photo and video editor with an editorial, darkroom-inspired identity. Presets are presented as film emulsions, text can be written along a hand-drawn path (Text Brush), and a Pro subscription unlocks the full preset catalogue, watermark-free exports and the type library.

This package covers 22 screens: onboarding (4), Home, the photo editor (Presets, Adjust, Text Brush), the video editor, Archive (preset catalogue), Export, Pro paywall, a light version of the 5 editor screens, and 5 system states.

## About the design files
`Epreuve.dc.html` is a **design reference built in HTML**. It shows the intended look and behavior; it is not production code. Rebuild these screens in the target stack (SwiftUI recommended for an iOS-first editor; React Native / Flutter are fine) using that stack's own patterns. Open the file in a browser to inspect it: every screen is a 390 × 844 pt artboard (iPhone 14/15), and all styles are inline, so the exact values can be read straight from the markup.

## Fidelity
**High fidelity.** Colors, type, spacing, hairlines and copy are final, except where marked *placeholder* below. Rebuild pixel-close.

---

## Design principles (non-negotiable)
1. **One accent, used sparingly.** Safelight red marks only *the live thing*: the active value, the playhead, the active tool dot, the Pro badge and error causes. Never use it for fills or decoration, and never use gold/champagne.
2. **Theme follows the task, not a setting.** Browsing screens (Home, Archive, Onboarding, Pro) are paper. The editor is dark by default; the light editor is used when the system appearance is Light.
3. **Hairlines, not boxes.** 1 px rules at low opacity; corner radius 0 everywhere except the device, toggles and round play/progress marks.
4. **Type does the hierarchy.** A serif for names and values; tracked uppercase sans for every functional label. No bold weights.
5. **Icons:** a single 1 px stroke, round caps, 24 × 24 grid, geometric. Never filled.
6. **Anything drawn on the photo** (Text Brush path, handles) keeps its light treatment in both themes.

---

## Design tokens

### Color
| Token | Hex | Use |
|---|---|---|
| `paper` | `#F3EEE5` | Light backgrounds |
| `paper-frame` | `#EAE5DC` | Device frame (mock only) |
| `ink` | `#1A1714` | Text and filled CTAs on paper |
| `ink-2` | `#3D3832` | Secondary text on paper |
| `ink-3` | `#4D463E` | Body copy / ghost buttons on paper |
| `muted-light` | `#6F665C` | Labels and metadata on paper (≥ 4.5:1) |
| `darkroom` | `#161412` | Editor background (dark) |
| `bone` | `#EFE8DC` | Text and filled CTAs on dark |
| `bone-2` | `#C9C0B3` | Secondary text on dark |
| `muted-dark` | `#8C8378` | Labels and metadata on dark |
| `muted-dark-2` | `#A39A8E` | Close / Cancel on dark |
| `safelight` | `#E0573C` | Accent on dark |
| `safelight-deep` | `#B23A26` | Accent on paper |
| `black` | `#0B0A09` | Deepest shadow / notch |

Hairlines: on paper `rgba(26,23,20, .10–.18)`; on dark `rgba(239,232,220, .10–.22)`. Veils over trimmed footage: `rgba(22,20,18,.72)` dark / `rgba(243,238,229,.72)` light.

Preset tone strips (highlight / mid / shadow):
- Ektar 02 `#e9c9a0 / #b4674a / #3b2a22`
- Portra 04 `#efe0cc / #c49a80 / #3d3530`
- Cendre 11 `#d6d2ca / #8c8a86 / #2c2d2f`
- Nocturne 19 `#b9a98a / #3d4f66 / #121a26`
- Vitrine `#d7e1dc / #6f8c90 / #1f2a2e`
- Portra Fade `#efe0cc / #c49a80 / #4a3f38`

### Typography
| Role | Font | Size / line-height | Notes |
|---|---|---|---|
| Wordmark | Newsreader 400 | 13–15 pt, tracking 0.30–0.32 em | "ÉPREUVE", uppercase |
| Display | Newsreader 400 | 34–44 pt / 1.05–1.12, tracking −0.015 em | The key word is italic |
| Cover title | Newsreader 400 | 64 pt / 0.95 | |
| Parameter name | Newsreader italic 400 | 30 pt / 1 | e.g. *Exposure* |
| Value | Newsreader 400 | 22–28 pt | Accent color when it is live |
| Item name | Newsreader 400 / italic | 14–22 pt | Presets, recents, list rows |
| Label (caps) | Jost 500 | 10–11 pt, tracking 0.08–0.18 em, UPPERCASE | All functional UI |
| Small tag | Jost 500 | 8.5–9.5 pt, tracking 0.12–0.16 em | ATELIER, durations |
| Body | Geist 400 | 13–14 pt / 1.55 | Explanations only |
| Specimens | IBM Plex Mono 400, Caveat 500 | — | Type picker only |

Minimum size in UI: 10 pt (8.5 pt only for tags sitting on images).

### Spacing and shape
- Screen side margin: **24 pt**. Status bar 54 pt; home indicator area 26 pt.
- Vertical rhythm: 6 / 8 / 10 / 12 / 14 / 18 / 22 / 28 / 34 pt.
- Hit targets: ≥ 44 × 44 pt (text links are padded to reach this).
- Corner radius: **0**. Exceptions: round play button (40 pt), toggle (13 pt), slider knob (circle).
- Primary button: height 54 pt, full width, filled (`ink` on paper / `bone` on dark), label Jost 500 11 pt, tracking 0.18 em.
- Ghost button: height 46 pt, no border, same label style, color `ink-3` / `bone-2`.
- Header secondary action (Export / Done): 1 px border, padding 10 × 12 pt.
- Shadows: none in the UI.

---

## Screens

All screens are 390 × 844 pt. Unless stated otherwise, the header sits 54 pt from the top with a height of 48 pt.

### Onboarding
- **O1 Cover** (dark). Full-bleed photo with a gradient from transparent to `rgba(22,20,18,.92)` at the bottom. Top line: "Nº 01" / "PHOTO · FILM · TYPE". "Épreuve" at 64 pt, then the italic sentence "A darkroom for the photographs and films on your phone." Buttons: **BEGIN** (primary), *I ALREADY HAVE PRO* (ghost → restore purchases).
- **O2 Film** (paper). Wordmark + SKIP. Three-column grid (gap 6, height 300) showing the same photo as Original / Ektar / Cendre, with captions underneath. Eyebrow "I — FILM", headline "Develop with *real emulsions,* not filters.", one line of body. Footer: progress marks (active 18 × 2, inactive 6 × 2 at 30% opacity) and NEXT →.
- **O3 Type & Film.** Photo (height 332) with a Text Brush demonstration. "II — TYPE & FILM", "Write *along a line* you draw."
- **O4 Access.** Eight-photo grid (the first 3 at 100%, the rest at 25%, suggesting "selected photos"). "Épreuve only sees *what you choose.*" Three numbered promises (i / ii / iii) in rows with hairline separators. **CONTINUE** triggers the iOS photo-library permission; **NOT NOW** opens the single-photo picker (PHPicker).

### Home (paper)
Header: wordmark, PRO badge (1 px `safelight-deep` border, 5 × 8 padding; opens Pro), SETTINGS. Headline "What are we *developing* today?" (38 pt). Two tiles, 150 pt tall with a 10 pt gap: **Photo** (filled `ink`, icon `photo`) and **Video** (1 px `ink` border, icon `video`). RECENT section: a 3-column grid of 118 pt-tall thumbnails, each with an italic name and a caps metadata line; videos show a duration tag. Footer row: collection thumbnail (44 pt), "NEW COLLECTION" eyebrow, name, DISCOVER → Archive. **There is no tab bar anywhere in the app.**

### Photo editor (dark by default, light when the system is Light)
Shared layout:
- Header: CLOSE / "Roll 014 · *07*" (Newsreader 15) / EXPORT (bordered).
- Photo fills the remaining height.
- State caption under the photo (italic Newsreader 15, e.g. "Ektar, at 72%"), plus undo/redo. Hold the photo to compare with the original.
- Tool bar: 5 equal columns (FILM / ADJUST / TYPE / BRUSH / ADD), each a 22 pt icon over a caps label. The active tool is in full color with a 3 pt accent dot.

Screens:
- **Presets.** Category row (FILM, VINTAGE, MOODY, CLEAN, NIGHT, SAVED). Horizontal scroll of 72 pt-wide cards: a 90 pt preview of the user's own photo with the preset applied, a 2 pt tone strip, the name, then "stock · ISO". The selected card has a 1 px outline offset by 3 pt. Pro presets carry an ATELIER tag but still preview live; the paywall appears only at export. Below: "Intensity" with its value, on a slider (1 px track, 12 pt knob).
- **Adjust.** One parameter on screen at a time. Parameter name (italic, 30 pt), five position dots, value in the accent color. Lens-style ruler: minor ticks every 10%, major ticks at −1 / 0 / +1; an accent bar shows the distance from zero. Double-tap resets. Swipe the name to change parameter. Below: 5 families (LIGHT, COLOR, CURVE, GRAIN, CROP) as 28 pt icons.
- **Text Brush.** Segmented toggle SET TYPE / TEXT BRUSH. The finger-drawn path becomes the text baseline (dashed 1 px guide, end ring of 11 pt radius). Floating action bar when something is selected: duplicate / delete / EDIT. Typeface specimens (88 × 66): Didone, Grotesk, Typewriter, Hand. SIZE slider; INK swatches (22 pt swatch inside a 40 pt hit area).

### Video editor
Photo-editor shell; the tools are TRIM / FILM / ADJUST / TYPE / BRUSH. Under the frame: a 40 pt round play button, the timecode "00:04.12 OF 00:10", and SOUND.

Timeline, laid out on a grid with a 40 pt label column on the left:
- **FILM:** 7 frames, 46 pt tall. Trimmed-out ends (9% each side) are veiled; the trim brackets are 7 pt wide with 1 px borders.
- **TYPE:** solid clip. The selected clip is filled with the foreground color, with 5 pt grab handles on both ends.
- **BRUSH:** hatched clip, 135° lines every 5 pt.
- **SOUND:** waveform at 55% opacity on a 7% tint.
- **Ruler:** 0 / 3 / 6 / 9 / 12 / 14 S.
- **Playhead:** 1 px accent line with a 7 pt dot on top, spanning every lane.

Lanes are told apart by **texture, never by color**.

### Archive (paper)
"← HOME" with a count on the right; eyebrow "EDITION Nº 12 · AUTUMN · AVAILABLE OFFLINE"; title "The Archive" (42 pt); a featured collection (176 pt tall, bottom gradient, italic name). Then a list of rows: tone strip (34 × 42), name (18 pt), "AUTHOR · DESCRIPTION", and OWNED / TRY.

### Export (dark)
Back "EDIT", title "Export". Summary: thumbnail (92 × 116), italic name, edit state, dimensions. **FORMAT** (JPEG Smallest / HEIF Sharper / PNG Lossless) and **SIZE** (Original 20 MP / Large 12 MP / Web 2 MP): segmented controls 46 pt tall with a filled selection. "Keep location & camera data" toggle, **off** by default. If a Pro preset is used: a single notice row (1 px accent border, dot, "*Nocturne* is part of Pro…", SEE PRO). Buttons: **SAVE TO PHOTOS**, SHARE….

### Pro (paper)
Eyebrow "ÉPREUVE PRO" with a close button (always visible). Headline "The whole *darkroom,* unlocked." Before/after image, 112 pt tall. Three benefits numbered i / ii / iii. Plans: Yearly (preselected, SAVE 44% tag) and Monthly, as radio rows with a 1 px border (the selected row's border is `ink`). **START FREE TRIAL**, then the full terms written as a sentence, then RESTORE · TERMS · PRIVACY.

### States
- **S1 Home, first use:** recents become dashed placeholders plus the italic line "Edits you start will be kept here…"; the footer offers a collection to start from.
- **S2 No photo access:** explains the iOS path (Settings → Épreuve → Photos). Buttons: OPEN SETTINGS (deep-link) and PICK ONE PHOTO INSTEAD.
- **S3 Exporting:** the frame "develops" top to bottom (dark veil + 1 px accent line moving with progress); percentage at 44 pt, status line in italics, format and ETA, 1 px progress bar, CANCEL.
- **S4 Export done:** the image mounted with a 10 pt `bone` border; "SAVED TO PHOTOS", "Printed. *Beautifully.*", then SHARE / STORY / COPY, BACK TO EDIT, NEW PHOTO.
- **S5 Export error:** a paper bottom sheet over the dimmed editor. Cause in the accent color ("NOT SAVED · STORAGE FULL"), reassurance that the edit is safe, the primary fix (export a smaller size), TRY AGAIN.

---

## Interactions and behavior
- Navigation is a stack from Home; Archive and Pro are pushed or presented modally. There are no tabs.
- Editor transitions: switching tools cross-fades the bottom panel (180 ms, ease-out); the photo never moves.
- Sliders and rulers: light haptic at 0 and at every major tick; double-tap to reset.
- Hold the photo to see the original; release to go back to the edit.
- Pro gating happens **only at export**. Pro presets and fonts preview freely.
- Export progress replaces the screen; cancelling returns to Export with the settings kept.
- Errors never discard the edit; edits autosave continuously as non-destructive copies.

## State (suggested)
- `project { id, kind: photo|video, sourceAssetId, preset { id, intensity }, adjustments { [param]: value }, textLayers[], brushStrokes[], timeline?, updatedAt }`
- `editor { activeTool, activeFamily, activeParam, selection }`
- `export { format, size, keepMetadata, progress, status: idle|running|done|error, error? }`
- `entitlement { isPro, plan, trialEndsAt }`
- `photoAccess: notDetermined|limited|authorized|denied`

## Assets
- `icons/*.svg`: every UI icon, on a 24 grid with a 1 px stroke and `currentColor` (the adjustment families are on a 28 grid).
- Photos are **Unsplash placeholders**; replace them with your own or licensed imagery.
- Fonts (Google Fonts, OFL): Newsreader (opsz 6–72, 400/500, italic), Jost 400/500, Geist 400/500, IBM Plex Mono 400, Caveat 500.

## Placeholders to confirm
Prices ($39.99 / yr, $5.99 / mo, "Save 44%"), preset names and stock numbers, counts (60+ presets, 12 typefaces), file sizes and ETAs, and every copy string marked as an example.

## Files
- `Epreuve.dc.html`: all 22 screens (open in a browser; `support.js` and `image-slot.js` must sit next to it).
- `icons/`: SVG icons.
- `screens/`: a PNG of every screen (the Unsplash credit tags are an artifact of the preview, not part of the UI):
  - `01-library.png`
  - `02-presets.png`
  - `03-adjust.png`
  - `04-text-brush.png`
  - `05-video.png`
  - `06-archive.png`
  - `07-export.png`
  - `08-pro.png`
  - `09-presets-light.png`
  - `10-adjust-light.png`
  - `11-text-brush-light.png`
  - `12-video-light.png`
  - `13-export-light.png`
  - `14-cover.png`
  - `15-onboarding-1.png`
  - `16-onboarding-2.png`
  - `17-onboarding-3-access.png`
  - `18-home-empty.png`
  - `19-no-access.png`
  - `20-exporting.png`
  - `21-export-done.png`
  - `22-export-error.png`
