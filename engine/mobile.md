# What the mobile clients do with NUI windows

Build 89.8193.37-17 on every client. These findings were **measured**, not
read in code: the iOS and Android binaries were not disassembled. Each
finding says which client it was measured on, at which GUI scale, and how.
Numbering continues the desktop findings ([behaviour.md](behaviour.md),
T1-T53).

## Clients and method

| Client | Platform reported | GUI size (px) | GUI scale reported | Used for |
|---|---|---|---|---|
| iOS, an iPhone | 22 | 2532 × 1170 | 100 and 160 | everything below; screen density 3 (px per point) |
| Android, an Android tablet | 41 | 1340 × 800 | 0 | T56, T69, T70 |
| Linux desktop | 11 | — | 100 | comparison |
| macOS desktop (Intel) | 21 | — | 100 | comparison (T54, T56) |

Method (2026-11-21 and -22): NWScript probe windows built with
`nw_inc_nui.nss`, opened on a test server from its console, screenshots
taken on the device and measured after scaling them back to the device's
resolution. The probes are in [conformance/probes/](../conformance/probes/),
rewritten to depend on `nw_inc_nui.nss` only; each finding names its
probe. A number written "about" or "~" was read off a screenshot to the
nearest pixel or so; the rest were exact or the result was yes or no
(the window built or not, an image drew or not).

Words used here, as in [spec/mobile.md](../spec/mobile.md):

- **s**: the GUI scale (gui_scale / 100);
- **GUI unit**: what a desktop client lays out in; one unit is s screen
  pixels;
- **point**: one unit of the screen's native coordinate space on iOS; one
  point is d screen pixels;
- **d**: the screen density, pixels per point (3 on the iPhone). On a
  desktop client the probe of T56 gives d = s.

## Telling the clients apart (T54-T56)

**T54 The platform id does not identify iOS.** `GetPlayerDevicePlatform`
returned 22 (`PLAYER_DEVICE_PLATFORM_MAC_ARM64`) on the iPhone, not 30
(`PLAYER_DEVICE_PLATFORM_IOS`); 41 (`ANDROID_ARM64`) on the Android
tablet, 21 (`MAC_X64`) on the Intel Mac and 11 (`LINUX_X64`) on Linux.
*Confirmed (measured; probe `prb_device`).* So an iPhone cannot be told
from an Apple-silicon Mac by its platform. An Apple-silicon Mac was not
tried.

**T55 No device property identifies a touch or high-density client.**
About thirty guessed `GetPlayerDeviceProperty` keys (touch, dpi, retina,
mobile, controller, window size and the like; 33 in the measurement's
notes, the list in `prb_devkeys` has 34) all returned -1 on both a desktop
client and the iPhone. The documented display keys (`gui_width`,
`gui_height`, `gui_scale`, `ui.scale`, `ui.large-font`) return the same
kind of values on both. *Confirmed (measured; `prb_devkeys`).*

**T56 The clamped-window probe measures the density.** A 300 × 150 window
whose `geometry` is a watched bind set to x = y = 20000 is clamped by the
client into the screen's bottom-right corner, and the client reports the
clamped geometry back as a `watch` event within about 3 s, with no input
from the player. With `GUI_WIDTH` the device property, w the window's
width and s the GUI scale,

    d = (GUI_WIDTH − w · s) / x_reported

- Linux and the Intel Mac: d = s (positions are in GUI units);
- the iPhone: d = 3.0 exactly, at s = 1.0 and at s = 1.6 (positions are in
  points);
- the Android tablet: d = s, with s taken as 1.0 since it reports a GUI
  scale of 0 (T69): it behaves as a desktop client.

*Confirmed (measured; `prb_clamp`, `prb_clampev`).*

## What iOS multiplies by the density (T57-T64)

Measured on the iPhone (d = 3) at GUI scale 1.0 unless a finding gives
another scale.

**T57 Margins are multiplied.** The default margin of 2 (T10) and any
explicit margin are multiplied by d: the default margin on the iPhone is
6. A 32-high label in a fixed-height row (row and column margin 0):

| row height | label margin | desktop | iPhone |
|---|---|---|---|
| 36 | default | builds | refused |
| 40 | default | builds | refused |
| 44 | default | builds | builds |
| 48 | default | builds | builds |
| 36 | 0 | builds | builds |
| 36 | 2 | builds | refused |
| 38 | 3 | builds | refused |
| 40 | 4 | builds | refused |

So 32 + 2 · 6 = 44 is the smallest row the label fits with the default
margin, and only a margin of 0 is the same on both. A refused window
shows "Error constructing window from json: The constraint can not be
satisfied" on the device and never appears; the server is not told and
still lists the window as open (`NuiFindWindow` returns its token).
*Confirmed (measured; `prb_margin`).* A row of 36 with a 28-high label and
the default margin (28 + 12 = 40) and a row of 42 with the default margin
are in the probe; their results above follow from the rule and were not
recorded separately.

**T58 Windows without fixed heights build but overflow.** The same kind of
window with no fixed row or column heights is built on the iPhone, but
the multiplied margins make its content larger than the window, which
shows scrollbars. *Confirmed (in game).*

**T59 `row_height` is multiplied.** A list's rows are d times as tall:
row_height 20 drew rows 59.5 px tall, 40 drew 119 px. The pitch from one
row to the next is about 3 h + 12 px, the desktop's 4 px row spacing
(NUI-LIST-003) times 3. *Confirmed (measured; `prb_rowh`).*

**T60 Template cell widths are multiplied; spans have no gaps.** A row
template of cells 40, 100 and 40 drew its first cell about 128 px wide
(3 · 40 = 120; the extra was not explained). Between cells, and between
the children of a row or a column with margin 0, there is no gap.
*Confirmed (measured; `prb_cells`, `prb_gap`).*

**T61 A list cell is never drawn narrower than about 11 px.** A template
cell of 2/3 unit (2 px after the multiplication) drew 11.4 px wide.
*Confirmed (measured; `prb_mincell`).* Whether the desktop client has a
minimum cell width was not measured.

**T62 Draw-list coordinates are in points.** In a list cell and in a plain
column alike, a rect at y 0, height 10 drew 27.9 px tall; positions and
sizes of rects, lines, points, text and image rects are multiplied by d.
The glyph size of draw-list text is not: only its position moves.
*Confirmed (measured; `prb_draw`).*

**T63 Window position is in points; window and element sizes are not.**
`geometry.x` of 100 put the window's left edge at about 304 px, at GUI
scale 1.0 and at 1.6 alike. `geometry.w` and `h` and element `width` and
`height` are in GUI units, as on the desktop: not multiplied by d.
*Confirmed (measured; `prb_place`, `prb_gap`).* Font glyph sizes are not
multiplied either (T62).

**T64 Centring (-1) misplaces the window.** A window at x = y = -1 lands
clamped in the screen's bottom-right corner, often mostly off-screen.
*Confirmed (measured; `prb_place`).* That the client computes the centred
position in pixels (NUI-WINDOW-020) and then treats it as points, which
puts it past the screen's edge before the clamp, is *inferred*: it
explains the landing, the code was not read.

## Frame and controls on iOS (T65-T68)

These extras are fixed in screen pixels, so in GUI units they shrink as
the GUI scale grows.

**T65 The window frame is larger.** The two-row settings window of
`prb_frame` (content 360 × 72, margin 0 everywhere) needs this much more
than the desktop frame (16 wide, 49 high, NUI-WINDOW-010):

| GUI scale | width, first without a horizontal scrollbar | height, first fit | height, even gaps above and below |
|---|---|---|---|
| 1.0 | +32 | +48 | about +66 |
| 1.6 | +12 | +16 | about +28 |

*Confirmed (measured; `prb_frame` and earlier sweeps of the same layout).*
The points fit extra = K / s² with K = 32 for the width and K = 66 for
the height (even gaps) at d = 3. *Inferred (a fit through two scales).*
In use, 6 more units of slack were needed for windows to fit reliably.
*Confirmed (in game).* A larger window holding two lists needed about 10
more height than this at s = 1.6, not at 1.0; see T73.

**T66 Buttons draw their frame inset.** A button's frame is drawn about
10 px inside its box vertically (top and bottom), while its label is
centred on the whole box, so at s = 1.0 a 32-high button's label sits low
and runs out of the frame. Explicit padding 0 does not change it; padding
2 squeezes the frame further. A 36-high button centres the label at
s = 1.0. *Confirmed (measured; `prb_button`).* The growth a control needs
fits about 2 (d − 1) / s units (4 at d = 3, s = 1.0). *Inferred (fit).*

**T67 Right-aligned text in a button sits on the inset frame.** Text
aligned right inside a button lands on the inset frame of T66; pulling it
in by about 2.5 (d − 1) / s units clears it. *Inferred (fit, from windows
of a persistent-world module).*

**T68 The list inset is larger.** Rows start this far inside a bordered
list's border, on each side: desktop 4 (NUI-LIST-002); iPhone about 14
at s = 1.0 and about 8.7 at s = 1.6, that is about 14 screen pixels at
both. *Confirmed (measured; `prb_listins`).*

## Android (T69)

**T69 Android lays out as the desktop does.** On the Android tablet none
of the multipliers of T57-T68 applied: windows laid out as on Linux, and
the probe of T56 gave d = s. Its `gui_scale` device property was 0; with
0 taken as 1.0 every desktop rule held. *Confirmed (measured; `prb_clamp`,
`prb_device`, the windows of a persistent-world module).*

## Images (T70-T72)

**T70 Base-game TGAs draw black on iOS and Android.** A base-game image
that exists only as a TGA draws as a black box of the right size, in an
`NuiImage` and in a draw-list image, on the iPhone and on the Android
tablet: every `po_*` portrait, the `is_`, `ife_`, `ir_` and `ief_` icons,
many item icons, `gui_pal_hair01`. On the same clients these draw:
base-game PNG, JPG and GIF (a GIF animates); a base-game name that exists
as TGA and DDS (`gui_mp_defaultu`, drawn from its DDS, T36); TGAs and
DDSs from haks or NWSync. The classic GUI draws the same base-game TGAs
(the character portrait). On the desktop all of them draw.
*Confirmed (measured; `prb_image`).*

**T71 Why.** The mobile clients ship the base game's TGAs in a converted
form that the classic GUI reads and NUI's loader (T36) does not.
*Inferred*: it fits T70 (only base-game TGAs fail; the same bytes in a
hak draw), but the mobile data and code were not read.

**T72 A hak copy draws.** A byte-identical copy of a base-game TGA,
shipped in a hak under the same name, draws on iOS and Android: a hak's
TGA overrides the base-game TGA (T46). *Confirmed (in game).*

**T74 Sizes follow d, the position d / s, at GUI scale 1.6.** On the
iPhone at s = 1.6 a list whose row heights, cell widths and draw-list
rect were divided by d / s = 1.875 drew them 1.6 times too large: a
draw-list rect sent 32 / 1.875 = 17.07 high drew 82 px (17.07 × 3 × 1.6),
not the 51 px (32 × 1.6) meant. Divided by d = 3 instead, the rows,
cells and rect drew at their desktop sizes. The rows of that list were
about 39.6 units apart, row height 32 plus about 7.6, that is 12 px:
the row spacing is 4 · d screen pixels at both scales. *Confirmed
(measured, the device screenshot)*; consistent with a module whose
per-player scaling divides by d and was checked at s = 1.0 and 1.6.

**T75 An image element in a list row breaks the row on iOS.** On the
iPhone (s = 1.6) a list whose row template was an image cell, a flexible
label and a fixed label drew no image, and the labels of consecutive
rows ran together (each line showed a row's two labels and the next
row's first). The same with the image bound or fixed, and with the
window sent as is or scaled per NUI-MOBILE-060. The list without the
image cell drew correctly, and so did the icon drawn as a draw-list image
on a spacer cell. *Confirmed (measured, the device screenshots; probe
`prb_listimg`).* Images nested deeper in a cell, and Android, untested.

## Open (T73)

**T73 A larger window needs more height at GUI scale 1.6.** A window of
two lists side by side needed about 10 more units of height than T65
predicts at s = 1.6, and none at s = 1.0. *Confirmed (measured)*; the
cause is not known ([spec/unknown.md](../spec/unknown.md)).

## Not NUI

The classic GUI's resolution and UI scaling dialog (its arrows, close
button and slider) showed stock art on the iPhone where a module's hak
replaced the desktop textures of those names, and showed the replacements
on the desktop. The mobile client probably uses other texture names for
those controls. *Inferred*; not investigated.
