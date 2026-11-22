# What the client does with NUI windows (desktop)

Build 89.8193.37-17. Addresses are objdump addresses in `nwmain-linux`
(Ghidra adds 0x100000) unless marked. See [README.md](README.md) for the
conventions and [method.md](method.md) for what (code), (asm), (strings),
measured and "renderer agreement" mean.

## Windows and their JSON (T1-T8)

**T1 Parsing a window.** `CNWCMessage::HandleServerToPlayerNuiEvent`
(0x7b09d0) receives a window's JSON as a string, measures it with `strlen`
(nothing after a NUL counts) and parses it with nlohmann::json, strict
(exactly one value, nothing after it but whitespace), comments off. The
client reads an integer where it wants a float alike. *Confirmed (code).*
A window whose JSON the builders of `nw_inc_nui.nss` make carries
`"version": 1`; what the client does with another version was not traced.

**T2 `NuiCreateFromResRef`.** The server
(`CNWSMessage::SendServerToPlayerNui_CreateClient`, `nwserver-linux`
0x5c29b0) sends only the resref. The client looks it up as resource type
2083 (`jui`) in its own resource manager, so the file must reach the
player (a hak, NWSync, or their own folders), and parses it as T1. Binds
and ids come from the file; bind values do not: the script sets them after
the call returns the token. *Confirmed (code).* What the client does when
the resource is missing was not traced.

**T3 The window's keys.** `Nui::JSON::JsonWindow::Initialize` (0x883c10)
reads the window's boolean keys as follows. "Bind" is a bind whose value
has not been set yet; for `closable`, `border`, `transparent` and
`accepts_input` the bind only registers a listener, so the starting state
holds until the bind is set.

| key | `true` | `false` | `null` | missing | bind |
|---|---|---|---|---|---|
| `collapsed` | collapse button; opens collapsed | no button | button; opens expanded | no button | button; collapsed while the value is true |
| `closable` | close button | none | close button | close button | close button |
| `border` | drawn | none | none | drawn | none |
| `transparent` | no background | background | background | background | background |
| `accepts_input` | input | none (clicks fall through) | input | input | input |

*Confirmed (code).* `resizable` was not traced (`nw_inc_nui.nss` says
`true` or `null` lets the player resize).

**T4 The title bar** is left out only when the title is empty **and**
there is no close button **and** no collapse button. *Confirmed (code).*
`nw_inc_nui.nss` documents a title of `false` for this; that `false` reads
as an empty title was not traced. A window that opens collapsed is drawn
as its title bar alone.

**T5 Window position.** For `geometry.x` (and `y` alike, with the screen
height and the mouse's y from the top), with GUI scale s:

| x | left edge |
|---|---|
| -1 | screenW / 2 − s·w / 2 (centred) |
| -2 | mouseX (the corner at the mouse) |
| -3 | mouseX − s·w / 2 (centred on the mouse) |

A result below 0 is clamped to 0. Any other value is the position itself.
*Confirmed (code).* That only exactly -1, -2 and -3 are special, and what
other negative values do beyond the clamp, was not traced.

**T6 Size and edge constraints.** `size_constraint` (x, y, w, h) goes to
`SetWindowSizeConstraints(x, y, w, h)`: minimum width, minimum height,
maximum width, maximum height. `edge_constraint` goes to
`SetWindowEdgeConstraints` reordered as (x, w, y, h): left, right, top,
bottom. *Confirmed (code).* A 0 means "no constraint" per
`nw_inc_nui.nss`; not traced.

**T7 The window's frame.** At GUI scale 1.0, a window with a title bar has a title bar 33 px high, the body's frame
directly under it (no gap), and its content inset 8 px from the left,
right and bottom edges and 8 px below the title bar. So the frame takes
8 + 8 = **16 px of the geometry's width** and 33 + 8 + 8 = **49 px of its
height**. *Confirmed (measured: the 106-element window; the crafting
window agrees by renderer agreement).* Both were measured with a skin
whose `window.padding_x` and `padding_y` are 0; whether a skin's window
padding adds to the 8 px was not tried.

Without a title bar the frame is taken to be 16 × 16 (the 33 px bar
removed): *inferred*, not measured.

**T8 Window scrolling.** When the laid-out content reaches past the body
(T16: along a row or column children overflow instead of being squeezed),
Nuklear scrolls the window's body. A module's options window, a 392 × 72
body holding options given 284 px whose two entries need 308 (T15), showed
both scrollbars: the horizontal bar covers the bottom of the body, so
content that fills the height then needs the vertical one too.
*Confirmed (in game).* How the client reserves room for the bars was not
traced.

## Layout (T9-T21)

**T9 An unsolvable layout refuses the window.** When a required constraint
contradicts the others, the client shows "Error constructing window from
json: The constraint can not be satisfied." and the window does not
open. The server logs nothing. *Confirmed (in game: two windows of a
module, a 32 px emblem in a 34 px row and a presets window; strings: both
messages are in the binary).* A layout checker written from T10-T16 fails
both windows at the element the client refused and passes their fixed
versions.

**T10 Default margin and padding.** `Nui::Layout::Layoutable::Layoutable()`
(0x84f0b0) calls `SetPadding(nk_rect(0,0,0,0))` (call at 0x84fb5c) and
then `SetMargin(nk_rect(2,2,2,2))` (call at 0x84fb7a, the 2.0f loaded from
0x12f1b94). `SetMargin` (0x84ef00) and `SetPadding` (0x84ed50) make each
side an equality constraint at Kiwi's default strength, **required**.
*Confirmed (asm; the decompile dropped the arguments, the disassembly has
them).*

**T11 Widgets with no margin.** `Widgets::spacer` (0x8ac000),
`Widgets::tabbar` (0x8b0630, JSON type `tabbar`, `NuiToggles`) and
`Widgets::options` (0x8b0900, `NuiOptions`) call `SetMargin` again after
construction, with 0. No other `SetMargin` or `SetPadding` call changes a
default. *Confirmed (code; the calls (asm)).* In game: a row `[group 260,
spacer 16, group 530]` put the right group 4.0 px left of where a 2 px
spacer margin would (measured, the 106-element window).

**T12 JSON margin and padding.** `Nui::JSON::from_json(…, LayoutableJ&)`
(0x8a0810) reads `margin` and `padding`, default -1;
`Nui::JSON::LayoutableJ::Construct` (0x877850) applies each after the
widget is constructed, only when it is 0 or more. So a JSON value of 0 or
more replaces the default for any widget, and -1 means "not set".
*Confirmed (code).* The value applies to all four sides.

**T13 JSON width and height are required.** `width` and `height` from the
JSON become equality constraints at required strength. *Confirmed (in
game: a 32 px element with its 2 + 2 margin in a 34 px row refused the
window, T9).*

**T14 Default sizes.** A widget's constructor asks for a size when the
JSON sets none, as a constraint the JSON's required size replaces:

| Constructor (address) | JSON types | width | height |
|---|---|---|---|
| `Widgets::button(DynamicString)` (0x8b0bd0) | `button` | 150·s strong | 50·s strong |
| `Widgets::button(image, region)` (0x8aef00) | `button_image` | 150·s strong | 50·s strong |
| `Widgets::check` (0x8b0f10) | `check` | 150·s **weak** | 35·s strong |
| `Widgets::slider` (float 0x8adff0, int 0x8af430) | `sliderf`, `slider` | 150·s strong | 35·s strong |
| `Widgets::progress(float)` (0x8adcf0) | `progress` | 150·s strong | 35·s strong |
| `Widgets::textedit` (0x8b1380) | `textedit` | none | 35·s strong |
| `Widgets::combo<int>` | `combo` | 150·s strong | 35·s strong |

s is the GUI scale (T21). Labels, text, images, lists, groups, charts and
spacers ask for nothing. *Confirmed: values (asm: 150.0f at 0x1319668,
50.0f at 0x12f3610, 35.0f at 0x1319650 loaded in the button, check,
slider, progress and textedit constructors); strengths (code); the
combo's values (code).* A `button_select` measured 150 wide in game with
no width set (the 106-element window's list; its height was set);
which constructor gives it that was not traced.

**T15 Options and toggles.** `Widgets::options` and `Widgets::tabbar` build
a `SelectList`: a row when `direction` is 0, a column when it is 1, of
margin 0 (T11). `SelectList::MakeButtons` (0x8aff90) makes one entry per
label with `Widgets::custom` (0x8ab260): an ordinary widget, margin 2,
asking for 35·s high and, in a row only, 150·s wide, both strong. The
label's text does not change the entry's size. So *n* horizontal entries
want *n* × 154 by 39, and *n* vertical ones *n* × 39 high. Options draw
each entry as `nk_option_label` (a radio and its text), toggles as
`nk_button_label`. *Confirmed (code; in game: the options window of T8,
whose two entries reached 308 past a 284 px element).* An entries list
bound to a bind rather than an array makes its entries when the bind is
set: not traced.

**T16 Rows and columns.** The published `Span::BuildConstraintDependants`
(the gist; the client's function is at 0x850560) builds, for a row (and a
column with the axes swapped), with *primary* the row's axis and *layout*
the room the row was given less its padding:

1. each child's own constraints first (T10-T15), depth first;
2. along the primary axis, the first child at the layout's start plus its
   front margin, each next child at the previous child's position plus the
   previous child's size and back margin plus its own front margin
   (required: children never overlap);
3. on the secondary axis, each child at the layout's start plus its front
   margin (required);
4. for each child, layout size ≥ child size + its margins along the
   primary axis, **medium**; then the sum of all children's sizes and
   margins == layout size, **medium**, and ≤ layout size, **medium**;
5. children that are "spaced equally" (T17) are suggested the same primary
   size, **weak**;
6. for each child on the secondary axis: its position again (required),
   layout size ≥ child size + its margins (**required**: "Widgets can
   never outgrow the parent. Not negotiable."), and layout size == child
   size + its margins, **medium**.

Widget sizes (T14, T15) are strong. So along a row, children whose sizes
add up to more than the row has run past its end (they overflow and the
window scrolls, T8); across it, a child that does not fit makes the layout
unsolvable (T9). *Confirmed: the published code; its two consequences in
game (T8, T9).* That the client's function matches the gist in every
step, and the order of the constraints, are *inferred* (renderer
agreement: a solver built from steps 1-6 reproduces the measured windows).

**T17 Spaced-equally widgets.** The gist suggests (weak) the same primary
size for every child with `m_spaced_equally`. Which widgets set it was not
traced; the renderers take it to be spacers. *Inferred.*

**T18 Groups and lists.** The published `LayoutGroup::SetChildren` (the
client's is at 0x853db0) lays a group's content out in a solver of its
own: the content's room is (0, 0, gw, gh), with gw and gh edit variables
at **medium** strength, suggested from the group's own size each time its
geometry changes, and the GUI scale pinned (required) to
`nk_get_gui_scale()`. So a group's content never makes the group or its
parent unsolvable; content larger than the group is clipped or scrolls.
*Confirmed: the published code.* That lists lay their rows out the same
way is *inferred* (renderer agreement).

**T19 Ties.** When several solutions satisfy the constraints equally well,
C++ Kiwi picks by iterating maps sorted by symbol id. A port whose maps
keep insertion order (as the JavaScript port `@lume/kiwi` does) can pick
another solution for the same constraints. *Inferred (from Kiwi's sources; the reference
implementation's port keeps its maps sorted for this reason).*

**T20 Sizes are static.** `width`, `height`, `aspect`, `margin` and
`padding` are read as numbers when the window is built; the API offers no
bind for them, and a window changes its geometry only by swapping a
group's layout (`NuiSetGroupLayout`). *Inferred (`nw_inc_nui.nss`; the
JSON readers were not traced for binds).*

**T21 GUI scale.** The default sizes of T14 and T15 are multiplied by the
GUI scale (`s_guiscale`, which `LayoutGroup::SetChildren` pins to
`nk_get_gui_scale()`). The scrollbar thickness is multiplied by it (T43).
Fonts are baked at `font_size` × the scale (T26). *Confirmed (code).*
Whether the window's own content (outside any group) is scaled the same
way is *inferred* (medium confidence); how the frame (T7), the list and
text insets (T22, T31) and the skin's slices scale was not measured.

## Lists (T22-T24)

**T22 List rows.** `NuiList(…, fRowHeight = NUI_STYLE_ROW_HEIGHT)` writes
`row_height`, 25.0 by default (`nw_inc_nui.nss`). With a border, the rows
start 4 px inside the list's frame on each side (top and left; and end 4 px
before the right edge, or before the scrollbar when there is one); rows
are `row_height` high and 4 px apart (Nuklear's row spacing); the
vertical scrollbar, when shown, is `window.scrollbar_size_x` wide (18 in
the skins measured) inside the right inset, and the rows lose its width.
*Inferred (renderer agreement: list rows within 1 to 3 px of the crafting
window).* The 4 px values were not measured separately and not read in
code; what the client uses when `row_height` is missing was not traced.

**T23 Row templates.** A row is laid out from `row_template`, a list of
cells `[element, width, variable]`. In the renderers a fixed cell takes its
width, the variable cells share what is left equally but never less than
their own width, and each cell's element is laid out in its cell as in a
solver of its own: it fills the row's height (a button in a list row is
`row_height` high) and the cell's width less its side margins, unless it
sets a size. *Inferred (renderer agreement; not read in code).* Whether
an element with its margins taller than `row_height` refuses the window,
or is cut, was not tried in game.

**T24 Scrollbar thumbs.** In a group's or list's vertical scrollbar (18 px,
T22), the thumb is 10 px wide at the bar's x + 4 and starts 2 px into the
track: Nuklear's `nk_do_scrollbarv` insets it by the skin's
`scrollv.padding_x` and `padding_y`. *Confirmed (measured).* The thumb is
drawn from a strip of its texture (T44). Its length in game was about
20 px shorter than Nuklear's formula with the solver's content height
(296 against 317 on one list): open (spec/unknown.md).

## Text, fonts and tooltips (T25-T35)

**T25 Fonts are TrueType resources.** `nk_sdl_refresh_config` (0xe066a0)
loads each `[[fonts]]` entry of the skin as resource type 2074 (`ttf`)
with `nk_font_atlas_add_from_memory` into one shared atlas. The first font
that loads is the default. It logs "NUI: Font %lu loaded successfully: %s,
from resref %s", "Font %lu failed to load … not found", and "NUI: Font
bake complete; texture is %dx%dpx". A font that fails to load is not
registered. *Confirmed (code).*

**T26 Font size.** The baked size is `font_size` × the GUI scale (16 if
`font_size` ≤ 0); `oversample_h` and `oversample_v` are truncated to
integers; `pixel_height` is read and not used. *Confirmed (code).* Nuklear
bakes with `stbtt_ScaleForPixelHeight`, so `font_size` is the height from
the font's hhea ascent to its descent, not the em: glyphs come out smaller
than a `font_size` em. Each glyph's advance is the font's own scaled by
the same factor plus `spacing_h`, rounded to a whole pixel when
`pixel_snap` is on. *Confirmed (measured: the default font at 17 has an
x-height of 6.11 px in game, 6.16 by this rule and 6.98 by the em; word
starts along lines up to 457 px long within 0.6 px of this rule).*

**T27 Font defaults.** `NkConfig::Font::Font()` (0x120a490): `name`
"(default)", `resref` "fnt_maintext", `pixel_height` 0, `pixel_snap`
true, `oversample_h`/`_v` 1, `font_size` 17, `spacing_h` 0.5, `spacing_v`
0. With no `[[fonts]]` at all one default font is added. *Confirmed
(code).* The base game's skin (8193.37-17, `nui_skin.tml` in
`data/ovr.bif`) lists a second font, `(monospace)`, which
`Nui::Debug::GUITree::Render` uses. *Confirmed (data; strings).*

**T28 Glyph ranges.** `nk_sdl_refresh_config` bakes, by
`Encoding::GetDefaultLocale()`: code page 1252 (Western) → U+0020-U+00FF
(Nuklear's default range); 1251 → Nuklear's Cyrillic ranges; otherwise
(1250) → U+0020-U+02FF and U+2000-U+21FF (the table at 0x136a600).
*Confirmed (code).*

**T29 Unknown font names.** `nk_get_font_by_name` (0xe064e0) logs
"Requested font was not found" and returns null; its four callers (the
window, draw-list text, an element's font, the text edit) check for null
and keep the current font. *Confirmed (code).* Which of two entries with
the same name wins was not traced.

**T30 The "large font" option** (`ui.large-font`, ini `Game
Options/UseLargeFont`) calls only `CTlkTable::SetUseLargeDialogFont` and
`CGuiInGame::RefreshDialogFont`: it does not change NUI. *Confirmed
(asm: the option's lambda).*

**T31 Strings reach Nuklear in the game's code page.** A string the server
sends is UTF-8 (`JsonString` converts from cp1252); the client turns a
bound string back into its code page (`Encoding::FromUTF8`, in
`Nui::JSON::DynamicBinding::ToString`, 0x86aa00) and hands those bytes to
Nuklear, which reads UTF-8. So in a label, text, button, tooltip,
draw-list text or window title, every byte from 0x80 up is an invalid
sequence and draws as the font's fallback glyph. Combo entries and text
fields are converted back to UTF-8 first, and show the real letters.
*Confirmed (code; in game: "×" (U+00D7, which the default font has)
showed as another glyph).* Chat colour tokens (`<cRGB>`) are not
interpreted: they draw as text. *Confirmed (in game).*

**T32 Text boxes.** A `text` element (`NuiText`) wraps its text at word
breaks (Nuklear's `nk_text_clamp` with separators). With the base skin
at GUI scale 1.0: the wrap width is the box's width less 18 px (room for a
scrollbar, also when none is shown; a 500 px box wrapped in [480, 488));
the first line starts 2 px below the inner top; lines are `font_size` + 4
apart (21 px for 17). With a border the text starts 4 px further in.
*Confirmed (measured: the 13-line paragraph breaks at the game's words
with these numbers).* The 2 px left inset and 4 px border inset are
*inferred (renderer agreement)*.

**T33 Draw-list text** is one `nk_draw_text` call: one line, no wrapping,
from the rect's top-left corner, cut after the glyph that crosses the
rect's width (that glyph is kept), clipped by the scissor only, not by
the rect's height. *Confirmed (code).*

**T34 Tooltips.** `Nui::Layout::Layoutable::Render` (0x84c6b0) shows an
element's `tooltip` when it is enabled and hovered, its `disabled_tooltip`
when it is disabled (never the other); an empty string shows nothing. The
tooltip (`nk_tooltip`, 0xe01b00, as Beamdog changed it) is one `nk_text`
line, left-aligned, in a popup as wide as the text + 16 px and one font
height + 8 px high, its left edge 21 px right of the mouse and 1 px below
it, drawn with no clip: nothing keeps it on the screen or in the window,
and there is no maximum width. The drawing loop skips only `\r`: a `\n`
draws as a glyph on the same line. The font is the element's own, else
the default. *Confirmed (code; in game: a long tooltip ran off the right
edge of the screen).*

**T35 Combo boxes.** The box is a widget of 150·s × 35·s, margin 2
(T14). Its open list (`nk_combo_callback`, 0xe02db0): left edge at the
combo's left, top at the combo's bottom less `style.window.combo_border`;
always opens downward; drawn with no clip (like a tooltip), so it reaches
past the window and off the screen; rows of the font's height + 2 (19 for
a 17 px font), `style.window.spacing.y` apart; width s × the widest entry
label + 50 + `window.scrollbar_size_x`; height min(300·s, s × ((spacing +
row) × entries + 2 × (padding + spacing))), with padding the `padding.y` of
the panel the combo is in. Past 300·s it scrolls. A combo with no entries
still opens, as an empty popup s × 2 × (padding + spacing) high.
*Confirmed (code; in game: clicking an empty combo seemed to do
nothing).* A tooltip
and an open list both use the window's one popup: while the mouse is over
a combo that has a `tooltip`, the tooltip takes the popup and the list
closes every frame, so the combo cannot be opened. *Confirmed (in game);
the shared slot is inferred from Nuklear.* A `disabled_tooltip` is
harmless: a disabled combo does not open.

## Images (T36-T40)

**T36 Image lookup.** `nk_loadimg(char const*, unsigned short)` (0xe1a820),
given type 0xffff ("any", which every NUI image and skin image uses),
probes the name with `CExoResMan::Exists` as each of six types, in the
order of the table built at 0xe1aa48: 2071 (`wbm`), 2079 (`gif`), 2080
(`png`), 3 (`tga`), 2081 (`jpg`), 2033 (`dds`), and keeps the **last** one
that exists (`cmovne` at 0xe1aaae). So **DDS > JPG > TGA > PNG > GIF >
WBM**, whichever resource layer holds each file; the chosen type is then
loaded from the best layer that has it. No other type is probed: PLT is
not an NUI image type. *Confirmed (asm; in game: a base-game DDS showed in
an `NuiImage` instead of a hak's TGA of the same name).* Beamdog's 8193.36
patch notes and the nwn.wiki NUI page (last updated 2026-02-02) say
JPG > TGA > PNG > GIF > WBM > DDS, DDS "loaded last"; the 8193.37-17
client does the reverse for DDS and for the order of the rest.

**T37 Decoding.** `NkImage::Load` (0xe19b50) sniffs `DDS ` and `GIF89a`;
anything else goes to stb_image (TGA, PNG, JPEG). A GIF keeps 1 to 255
frames and `NkImage::GetImage` (0xe1c800) advances them by each frame's
delay, looping. A WebM plays through `CExoMoviePlayer::UpdateMovie`, with
no sound. Images load asynchronously: a loading placeholder, then the
image, or a not-found or error placeholder. *Confirmed (code).*

**T38 Row order.** NUI reads a DDS **bottom row first**: a DDS stored
bottom row first shows upright in an `NuiImage`, one stored top row first
upside down. *Confirmed (in game: two portraits that exist only as DDS,
one of each storage).* That standard `DDS ` files and draw-list images
behave the same is *inferred*. Whether NUI honours a TGA's top-left-origin
flag is not known (spec/unknown.md).

**T39 Image caches.** Each window caches its images by resref and type
(`Nui::Window::GetImageByResRef`, 0x848a20). Skin images have their own
cache, which `clear_nk_styleimg_cache` (0x1204ab0) empties on every skin
reload (T42). *Confirmed (code).*

**T40 `SetTextureOverride`.** `CNWCMessage::HandleServerToPlayerResman`
(0x7aedc0), subtype 1, adds resource overrides for `tga`, `dds`, `ktx`,
`plt`, `bmp`, `mtr` and `txi` only (not `png`, `jpg`, `gif` or `wbm`) and
resets the 3D texture; it does not touch the NUI image caches (T39).
*Confirmed (code).*

## The skin (T41-T47)

**T41 The skin is an ordinary resource.** `Nui__ReloadSkin` (0x1205460)
reads resref `nui_skin`, type 2076 (`tml`), through `CExoResMan::Get`, and
parses it with cpptoml. Any resource layer can supply it: a hak, an
NWSync manifest, the player's `override/` or `development/` folder.
*Confirmed (code; in game: a module's skin shipped in its haks is drawn
for every player who joins).* The base game's copy is in `data/ovr.bif`.
The nwn.wiki NUI page says the `nui_*` files can be overridden only from a
client's `override/` or `development/` folder before a module loads, not
from a hak or NWSync; that is not so for the skin file in 8193.37-17 (T42;
patch 8193.37 also fixed fonts of a hak's `nui_skin.tml` not being
re-baked).

**T42 When the skin is read.** Every frame `nk_sdl_render` (0xe07bb0) calls
`nk_sdl_refresh_config`, which works only when a flag
(`g_pNuklearConfig`) is set: it clears the flag, calls `Nui__ReloadSkin`,
and bakes the fonts (T25). The flag is set at client start, by
`CNWCModule::ReloadAllResources` (0x7e0e90, unconditionally), which runs
from `CNWCModule::LoadModuleResources` (0x7e1700, after the NWSync
manifests and haks are added: on joining), from `~CNWCModule` (on leaving)
and from `CNWCModule::ReAttachHAKFile` (0x7e2570); by a change of GUI
scale (`CAurora::ComputeGUIScaleAndUpdate`, 0x436ae0, which also stores
the scale); and by a server resman message, subtype 4 with bit 0x200
(T40's function). *Confirmed (code).* No NWScript function was found
that sends that message.

**T43 Values.** `Nui__ReloadSkin` reads its keys through four helpers:

| Helper (unnamed; address) | Value | Default when missing |
|---|---|---|
| 0x1204d90 → `nk_styleimg9` (0x1205120) | a texture resref, drawn nine-sliced with margins fixed per key (T44) | `""`: fails to load, the not-found placeholder is drawn |
| 0x1204fa0 | `"#RRGGBBAA"` → a flat colour; anything else → a texture stretched over the widget (`nk_styleimg`, 0x1204e90) | `"#00000000"` (transparent) |
| 0x1204c30 | `"#RRGGBBAA"` colour | `"#00000000"` |
| 0x1204b30 | integer | 0 |

Unknown keys are ignored. A TOML syntax error is caught: the client logs
"Nui__ReloadSkin: failed to parse nui_skin.tml: %s" and skips every style
update after the parse, though `clear_nk_styleimg_cache` already ran. No
`nui_skin` resource logs "failed to load nui_skin.tml" and changes
nothing. A font entry without `pixel_snap` throws inside the parser; a
catch-all keeps the default entry. *Confirmed (code).* The skin textures
load through `nk_loadimg(name, 0xffff)` (T36). `window.scrollbar_size_x`
and `_y` are multiplied by the GUI scale. The full key list, in the
client's order, is [tables/skin_keys.yaml](../tables/skin_keys.yaml).

**T44 Nine-slice margins.** Each `nk_styleimg9` call passes its margins
(in texture pixels) as constants: 3 on every side for every nine-slice
key except `button.hover`, `selectable.hover`, `progress.hover`,
`progress.active` and `combo.hover` (7) and `tab.background` (5, 3, 3, 3);
the scrollbar thumbs (`scrollv.cursor_*`, `scrollh.cursor_*`) have 0
margins and use only the texture's rect (3, 0, 10, 16) for `scrollv` and
(0, 3, 16, 10) for `scrollh`, repeated along the bar at its own size and
stretched across it. A width or height of -1.0 (0x13f5ef0) means the whole
image. Drawing uses Beamdog's `nk_9slice_tiledata`. *Confirmed (code: the
calls' arguments).* Which tiling flag is which axis was read from a
screenshot (the thumb's ridges match); which side of `tab.background` has
the 5 is not known.

**T45 Key oddities.**
- The chart keys `background_color`, `color`, `border_color` and
  `selected_color` are read at the top level of the file, not under
  `[chart]`; the base game's file puts them under `[chart]`, so they come
  out transparent. *Confirmed (code; data).*
- `property.hover` is asked for as `"property.hover "`, with a trailing
  space, so it is never read. *Confirmed (code).*
- `scrollh.border_color` is not read (`scrollv.border_color` is).
  *Confirmed (code).*
- `button.border` is divided by 100. *Confirmed (code).*
- The border thickness of windows, popups, combos, menus, groups and
  tooltips is derived from `border.border_image`'s slice margin + 1 = 4 px.
  *Inferred (from the style struct's layout).*

**T46 Resource order.** For NUI's resources, highest first: the player's
`development/` folder, NWSync manifests, the module's haks, Beamdog's
patch haks, the player's `override/` folder, the base data. *Confirmed
(code).* In game, for the classic GUI's textures: a file in
`development/` beats a hak sent through NWSync, one in `override/` does
not.

**T47 Replacing a stock skin texture.** The base game's skin names TGAs
`nui_*` (in `bd_nui.bif`). Since they load through `nk_loadimg` (T36) and
the resource order of T46, a hak's TGA or DDS of the same name replaces
one, and a PNG of the same name does not (a TGA beats it whatever the
layer). *Inferred (code); not tried in game with a stock name.* A skin
that names its own textures, shipped in a hak, is drawn (T41).

## Draw lists (T48-T50)

**T48 Order.** A widget's draw-list items with `order` -1
(`NUI_DRAW_LIST_ITEM_ORDER_BEFORE`) are painted before the widget, under
it; the rest after it, over it; each group in the order listed. With
`draw_list_scissor` false the items are not clipped to the element.
*Inferred (`nw_inc_nui.nss`, Nuklear's command buffer; renderer
agreement on real windows).*

**T49 Bind arrays.** An item made with `nBindArrays` true is drawn once
for each entry of its bound arrays. *Inferred (`nw_inc_nui.nss`).* What
happens when the arrays differ in length was not traced.

**T50 Circles.** A circle item draws Nuklear's `nk_fill_circle` or
`nk_stroke_circle` in its rect: radius w / 2 around the rect's centre
(h only moves the centre), the stroke centred on the radius,
anti-aliased. *Inferred (Nuklear; renderer agreement).*

## Binds and events (T51-T53)

**T51 Event names.** The client's string table has the event names
`click`, `mousedown`, `mouseup`, `mousescroll`, `blur`, `open`, `watch`
and `unknown-bind`; the server's has `close` and `watch`. No hover event
is documented or found. *Inferred (strings; `nw_inc_nui.nss`).* Which
widget sends which event was not traced; `nw_inc_nui.nss` says only
elements with an `id` send events.

**T52 Watches.** `NuiSetBind` on a watched bind runs the window's event
script with type `watch` before it returns. *Inferred (`nwscript.nss`).*

**T53 Bind values are not converted.** The client and server do not
convert a bind's JSON type to the one a widget needs (`nwscript.nss`
"No auto-conversion happens"). *Inferred (docs).* What a widget draws for
a bind of the wrong type was not traced.
