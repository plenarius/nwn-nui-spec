# Mobile clients (`NUI-MOBILE`)

How the iOS and Android clients differ from the desktop client in
building and drawing NUI windows, and how to write windows that work on
all of them. Measured on build 89.8193.37-17: iOS on an iPhone (screen
density 3) at GUI scales 1.0 and 1.6, Android on an Android tablet. The
evidence is in [engine/mobile.md](../engine/mobile.md) (T54-T73); the
numbers are in [tables/mobile.yaml](../tables/mobile.yaml); the probes
that show each rule are in [conformance/](../conformance/).

Everything here was measured on the clients, not read in their code. A
rule whose number is a fit through the measured points says so and is
informative.

## Words

- **s**: the GUI scale, `gui_scale` / 100. A `gui_scale` of 0 or missing
  counts as 1.0 (NUI-MOBILE-040).
- **GUI unit**: the unit of the desktop rules; one GUI unit is s screen
  pixels.
- **d**: the density NUI-MOBILE-011 measures. d = s on a desktop client
  and on Android; on iOS, the screen's pixels per point (3 on the iPhone).
- **f**: d / s, the position factor. 1 on a desktop-like client; on the
  iPhone 3 at s = 1.0 and 1.875 at s = 1.6. The window position is
  multiplied by f relative to the desktop; margins, list row heights,
  cell widths and draw-list coordinates by d (NUI-MOBILE-020).
- **point-based client**: a client with f > 1 (iOS); **desktop-like**:
  f = 1 (desktop, Android).

## Telling the clients apart

**NUI-MOBILE-001** `GetPlayerDevicePlatform` does not identify iOS: an
iPhone reports 22 (`PLAYER_DEVICE_PLATFORM_MAC_ARM64`), the value an
Apple-silicon Mac would report, not 30 (`_IOS`). A script MUST NOT
use the platform to decide whether a client is point-based. *Confirmed:
T54.*

**NUI-MOBILE-002** No device property tells a touch or high-density
client apart: the guessed keys tried all return -1 on desktop and iOS.
*Confirmed: T55.*

**NUI-MOBILE-010** A script that needs to know SHOULD measure the client
with the clamped-window probe: create a window whose `geometry` is a bind,
set it to x = y = 20000 (any size, say 300 × 150), and watch the bind.
The client clamps the window into the screen's bottom-right corner and
reports the clamped geometry back in a `watch` event within about 3 s,
without input from the player. *Confirmed: T56.*

**NUI-MOBILE-011** From the reported x, the window's width w, the device
property `gui_width` and s:

    d = (gui_width − w · s) / x_reported

*Confirmed: T56.* d = s on Linux, macOS (Intel) and Android; d = 3.0 on
the iPhone at s = 1.0 and 1.6.

**NUI-MOBILE-012** Two factors follow from d and s: the position factor
f = d / s, and the size factor d itself (NUI-MOBILE-020). A client with
f = d / s > 1 is point-based and the
rules NUI-MOBILE-020 to -033 apply to it; a client with f = 1 is
desktop-like and the desktop chapters apply. A script SHOULD allow for
rounding (treat f within a few per cent of 1 as 1). Until the probe has
reported, a script MAY assume f = 1. *Confirmed: T56, T69.*

## What iOS multiplies

**NUI-MOBILE-020** On a point-based client these quantities are
multiplied relative to the desktop, in GUI units: the window position by
f = d / s, and margins, list row heights, template cell widths and
draw-list coordinates by d, whatever the GUI scale. The list row spacing
is a fixed 4 · d screen pixels (4 · d / s units). The others are in GUI
units as on the desktop. At s = 1.0 both factors are d. A checker or
renderer that models iOS MUST apply this table. *Confirmed at s = 1.0
for every row (T57-T63) and at s = 1.6 for the position, row height,
row spacing, cell widths and draw-list coordinates (T63, T74); the
margin at s ≠ 1.0 is inferred from the other sizes.*

| Quantity | iOS | Evidence |
|---|---|---|
| element margin (the default 2 and any explicit margin) | × d | T57 |
| list `row_height` | × d | T59, T74 |
| list row spacing (4 on the desktop) | 4 · d px (4 · d / s units) | T59, T74 |
| list template cell width | × d | T60, T74 |
| draw-list coordinates (rects, lines, points, text and image rects) | × d | T62, T74 |
| window position (`geometry.x`, `y`) | × f = d / s | T63 |
| window size (`geometry.w`, `h`) | not multiplied | T63 |
| element `width`, `height` | not multiplied | T63 |
| font glyph size, draw-list text size | not multiplied | T62 |
| padding | not measured | — |

**NUI-MOBILE-021** So on the iPhone at s = 1.0 the default margin is 6 on
each side, and an element's footprint (NUI-LAYOUT-015) is its size + 12.
A window whose fixed sizes leave room only for desktop margins is
unsolvable on iOS and is refused (NUI-LAYOUT-001): "Error constructing
window from json: The constraint can not be satisfied" on the device, no
window, nothing on the server, which still lists the window as open. A
window without fixed sizes is built but its content overflows and the
window scrolls. A margin of 0 is the only margin the same on every
client. *Confirmed: T57, T58.*

**NUI-MOBILE-022** A list's rows are row_height × d units tall and
4 · d screen pixels apart (about 3 h + 12 px on the iPhone at s = 1.0;
12 px, about 7.5 units, at s = 1.6). *Confirmed: T59, T74.*

**NUI-MOBILE-023** A row template's fixed cell widths are multiplied by d.
Cells, and the children of a span with margin 0, are laid out with no gap
between them on iOS as on the desktop. *Confirmed: T60.*

**NUI-MOBILE-024** On iOS a list cell is never drawn narrower than about
11 px, whatever its width. *Confirmed at s = 1.0: T61; untested at
other scales.* A checker SHOULD flag
template cells that would draw narrower than 11 px on a point-based
client.

**NUI-MOBILE-025** Draw-list coordinates are in points everywhere, in
lists and in plain elements: a renderer MUST multiply every coordinate
and size of a draw-list item by d (not d / s), and MUST NOT multiply the
glyph size of draw-list text. *Confirmed: T62, T74.*

**NUI-MOBILE-026** `geometry.x` and `y` are in points: a window at x on
the iPhone has its left edge at d · x pixels, whatever the GUI scale.
*Confirmed: T63.* The width and height are in GUI units.

**NUI-MOBILE-027** On iOS a window at -1 (centred, NUI-WINDOW-020) lands
clamped in the bottom-right corner of the screen, often mostly
off-screen. An author SHOULD NOT use -1 for a window iOS players open, and
SHOULD place it explicitly in points (NUI-MOBILE-060). *Confirmed: T64;
the cause (the centre computed in pixels, then read as points) inferred.*

**NUI-MOBILE-028** Nothing else in the layout was seen to change: spans
have no gaps, sizes are not multiplied, the solver refuses what is
unsolvable. *Confirmed: T57, T60, T63.*

## The frame and controls on iOS

**NUI-MOBILE-030** On iOS a window's frame takes more than the desktop's
16 × 49 (NUI-WINDOW-010). Measured on a two-row window with 360 × 72 of
content and margin 0, the extra over the desktop frame was:

| s | width (no horizontal scrollbar) | height (first fit) | height (even gaps) |
|---|---|---|---|
| 1.0 | 32 | 48 | about 66 |
| 1.6 | 12 | 16 | about 28 |

*Confirmed: T65.* An implementation MAY take the extra as K / s² GUI units
with K = 32 for the width and 66 for the height at d = 3, and SHOULD add
6 units of slack. *Inferred: T65 (a fit through two scales).* A large
window may need more (unknown.md).

**NUI-MOBILE-031** On iOS a button draws its frame about 10 px inside its
box vertically while its label is centred on the whole box, so a button
of the desktop's height shows its label low, past the frame. Padding does
not fix it. A button 36 high (desktop 32) centres its label at s = 1.0.
*Confirmed: T66.* An implementation MAY grow controls by 2 (d − 1) / s
units on a point-based client. *Inferred: T66 (fit).*

**NUI-MOBILE-032** Right-aligned text inside a button lands on the inset
frame; pulling it in by 2.5 (d − 1) / s units clears it. *Inferred: T67
(fit).*

**NUI-MOBILE-033** On iOS a bordered list's rows start about 14 screen
pixels inside its border on each side (14 units at s = 1.0, about 8.7 at
s = 1.6), not 4 (NUI-LIST-002). A renderer modelling iOS SHOULD use
14 / s units. *Confirmed: T68.*

## Android

**NUI-MOBILE-040** The Android client lays out NUI windows as the desktop
client does: none of NUI-MOBILE-020 to -033 apply. Its `gui_scale`
device property is 0; a script MUST treat 0 or a missing value as a scale
of 1.0 (100). *Confirmed: T69.*

## Images

**NUI-MOBILE-050** On iOS and Android, a base-game image that exists only
as a TGA draws as a black box of the right size, in an `NuiImage` and in a
draw-list image: the `po_*` portraits, the `is_`, `ife_`, `ir_`, `ief_`
spell and feat icons, many item icons. Base-game PNG, JPG and GIF draw; a
base-game name that also exists as DDS draws (from the DDS, NUI-IMAGE-010);
TGA and DDS files from haks or NWSync draw. The classic GUI draws the
same TGAs. *Confirmed: T70.* Why (the mobile clients keep base-game TGAs
in a converted form NUI cannot read) is *inferred: T71*.

**NUI-MOBILE-051** A module that shows base-game TGA images in NUI to
mobile players SHOULD ship byte-identical copies of them in a hak; a hak's
TGA overrides the base-game one and draws on every client. *Confirmed:
T72.* A checker SHOULD warn about a base-game image name that exists
only as TGA in a window meant for mobile players.

**NUI-MOBILE-052** On iOS an image element (`NuiImage`) in a list's row
template does not draw, and the row's other cells are laid out wrongly
(cells of consecutive rows run together). This holds whether the image
is bound or fixed, and whether or not the window was scaled per
NUI-MOBILE-060. An author MUST NOT put an image element in a list row for
iOS players: draw the icon with a draw-list image on a spacer instead,
which draws correctly. A checker SHOULD flag it. *Confirmed: T75.
Images nested deeper in a cell, and Android, untested.*

## Portable windows

**NUI-MOBILE-060** A window meant to work on desktop, Android and iOS
SHOULD be written so (*confirmed* where the cited rules are; the margin's
scaling at s ≠ 1.0 is *inferred*, NUI-MOBILE-020):

1. **Margin 0 everywhere.** Give every element an explicit margin of 0
   and make room with spacers or sizes. A default or explicit margin above
   0 is multiplied on iOS and breaks fixed rows (NUI-MOBILE-021).
2. **No thin spacer cells in list templates.** A cell narrower than about
   11 px draws wider on iOS and pushes the others (NUI-MOBILE-024); use the
   list's own inset or the cell's content for spacing.
3. **Explicit placement.** Do not use -1 (NUI-MOBILE-027). Place the
   window at a position divided by f = d / s, so it lands at the same
   pixels on every client (NUI-MOBILE-026).
4. **Per-player scaling of what iOS multiplies.** After the probe of
   NUI-MOBILE-010 has reported, divide by d every row_height, template cell
   width and draw-list coordinate, so the client's multiplication gives
   back the desktop size (NUI-MOBILE-022, -023, -025). Keep the probe's
   result per player; it does not change while they stay connected at the
   same GUI scale.
5. **Slack.** Size the window for the iOS frame (NUI-MOBILE-030) plus 6,
   or let the content flex: a window sized to the desktop frame exactly
   scrolls on iOS. Make buttons 36 high, or grow them by
   NUI-MOBILE-031, so labels stay inside the frame.
6. **Images.** Ship hak copies of base-game TGAs a window shows
   (NUI-MOBILE-051), and draw icons in list rows with a draw-list image,
   never an image element (NUI-MOBILE-052).

A checker SHOULD offer to check a window as a point-based client would
build it (sizes × d, the position × d / s; d = 3 on the iPhone), with
margins, row heights and cell widths multiplied, besides the desktop
check.
