# Observed, inferred and unknown

Nothing on this page is normative. Each item says what is known, how, and
what would settle it. Addresses are objdump addresses in `nwmain-linux`.

## The window

- **Frame without a title bar** (NUI-WINDOW-012): taken as 16 × 16, not
  measured. *Settle:* a screenshot of a window with no title bar.
- **Frame and window padding** (T7): measured with a skin whose
  `window.padding_x/y` are 0. Whether the skin's window padding adds to
  the 8 px inset is not known. *Settle:* the same window with the base
  game's skin and with a padding of 8.
- **`resizable`**, a title of `false`, `version` other than 1, and a
  missing `.jui` resource were not traced in `JsonWindow::Initialize`
  (0x883c10) and the message handler (0x7b09d0).
- **Geometry values other than -1, -2, -3** below 0: clamped, but whether
  -0.5 or -4 mean anything was not traced.
- **How window scrollbars take room** (T8): seen, not traced.

## Layout

- **The client's `Span::BuildConstraintDependants` (0x850560) against the
  gist.** The gist is dated 2024-12; the client is 2025-10. Steps and
  strengths agree with everything seen in game; the order of the
  constraints, which decides ties, was not compared. *Settle:* read the
  function's calls in order.
- **Spaced-equally children** (NUI-LAYOUT-044): which widgets set
  `m_spaced_equally`. *Settle:* find its writers.
- **Default sizes not listed**: `button_select`'s height, `color_picker`,
  `chart`, `image` (none, presumably), the int progress bar (35 high, not
  made by `nw_inc_nui.nss`), `movieplayer` (an undocumented widget type
  the client parses). *Settle:* read each constructor's constraint
  lambdas.
- **GUI scale above 1.0**: whether the window's own content (outside a
  group) scales its default sizes as a group's does; how the frame,
  insets and slices scale. *Settle:* screenshots at 1.0 and 2.0.
- **Sizes and binds** (T20): whether the JSON readers reject a bind for
  `width` and the like, or ignore it.

## Lists

- **Insets and spacing** (NUI-LIST-002, -003): 4 px each, fitted by a
  renderer (renderer agreement), not measured on their own or read.
  *Settle:* a screenshot of a bordered list with known rows, or Nuklear's
  `nk_list_view` call in the client.
- **Missing `row_height`**: the builder always writes one.
- **A cell taller than `row_height`**: refused, cut or overflowing? Not
  tried. *Settle:* a probe window.
- **Row templates of rows, columns or groups**: not tried.
- **Variable cells** (NUI-LIST-010): the share rule is the renderers'.
  *Settle:* a row of two variable cells of unequal minimum widths,
  measured.
- **Scrollbar thumb length**: about 20 px shorter in game than
  `visible / content × track − 2 × padding_y` with the solver's extent
  (296 against 317 on one list); the content height the client gives
  Nuklear is about 45 px larger. *Settle:* a second screenshot with
  another content height, or the group's render code.

## Text

- **Label and button text** (NUI-TEXT-020): one line, cut, no ellipsis;
  renderer agreement. Where a label's text sits vertically was fitted.
- **Text box insets** (2 px, 4 with a border): renderer agreement.
- **Two font entries with one name**: which wins.
- **Inherited fonts**: whether a group's or window's `font` reaches its
  children (patch 8193.36 says `NuiStyleFont` works on both).
- **Code pages other than 1252**: the ranges are read; nothing was tried
  in game.

## Images

- **TGA origin flag in NUI.** The engine ignores a TGA's top-left-origin
  flag for model textures; whether NUI's stb_image path honours it is not
  known. *Settle:* a flagged TGA whose name exists in no other type, in an
  `NuiImage`.
- **Draw-list images and DDS row order** (NUI-DRAW-012): taken to follow
  `NuiImage`. *Settle:* a DDS-only resref in `NuiDrawListImage`.
- **Image fitting** (NUI-IMAGE-040): the arithmetic of each aspect mode
  was not read.
- **A stock `nui_*` texture replaced from a hak** (NUI-SKIN-041): follows
  from the loader; not tried.

## Draw lists, binds and events

- **Bind arrays of unequal length** (NUI-DRAW-004).
- **What each widget sends**: which events, and their payloads, were not
  traced in the client; the names come from its string table.
- **An unset bind** on a label, image or list: what draws.

## The skin

- **Border thickness** of 4 px derived from `border.border_image`'s
  slice margin: from the style struct's layout, not traced.
- **cpptoml conversions**: an integer key written as a float, or the
  reverse; not tried.
- **Which side of `tab.background` has the 5 px margin.**

## Mobile clients

- **A larger window needs about 10 more height on iOS at GUI scale 1.6**
  (T73). A window of two lists side by side needed about +10 height over
  NUI-MOBILE-030's extra at s = 1.6 and nothing more at s = 1.0. Not
  explained: the list insets (T68), the row spacing (T59) or the scrollbar
  may be counted differently. *Settle:* the same window with one list,
  then two, at s = 1.0, 1.3 and 1.6.
- **Frame extra against GUI scale** (T65): a constant number of screen
  pixels would shrink as 1 / s in GUI units, as the list inset does (T68);
  the frame's two points fit 1 / s² instead. Two scales cannot tell the
  forms apart well. *Settle:* `prb_frame` at a third scale.
- **Margins at s ≠ 1.0** (NUI-MOBILE-020): row heights, cells, row
  spacing and draw-list coordinates were measured at s = 1.6 (T74) and
  follow d; the margin was measured at s = 1.0 only and is taken to follow
  d too. *Settle:* `prb_margin` at s = 1.6.
- **The 11 px minimum cell at s ≠ 1.0** (NUI-MOBILE-024). *Settle:*
  `prb_mincell` at s = 1.6.
- **Images in list rows deeper than the cell, and on Android**
  (NUI-MOBILE-052). *Settle:* `prb_listimg` with the image inside a row,
  and on an Android client.
- **Padding on iOS**: whether an explicit padding is multiplied was not
  measured (only a button's, T66, which did not move its label).
- **The first cell of `prb_cells`** drew about 128 px wide on the iPhone,
  not 3 × 40 = 120 (T60).
- **Desktop minimum cell width**: whether the desktop client draws a 2 px
  cell 2 px wide (T61 is iOS only).
- **Other iOS devices** (an iPad, a density-2 screen) and **Apple-silicon
  Macs** (which report the iPhone's platform id): not tried. NUI-MOBILE-011
  should measure them; that a Mac is desktop-like is untested.
- **Android at other GUI scales**: only the default was tried; the client
  reports 0 for its scale.
- **Why base-game TGAs draw black** (T71): the converted form the mobile
  clients keep them in was not read.
- **Classic GUI textures on iOS**: some of the resolution dialog's
  controls ignore a hak's replacement of the desktop texture names
  (engine/mobile.md, "Not NUI").
