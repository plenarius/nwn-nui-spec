# Text and fonts (`NUI-TEXT`)

NUI draws text with Nuklear's font atlas, baked from TrueType resources
the skin lists. Pre-NUI fonts (`PostString`, the classic GUI) are another
system and not covered here.

## Fonts

**NUI-TEXT-001** A NUI font is a `[[fonts]]` entry of the skin: a
`.ttf` resource (type 2074) at one size. All entries are baked into one
atlas when the skin is read (NUI-SKIN-010). The first entry that loads is
the default font. One face at three sizes is three entries. *Confirmed:
T25.*

**NUI-TEXT-002** A font entry's keys and defaults are: `name`
"(default)", `resref` "fnt_maintext", `font_size` 17, `pixel_snap`
true, `oversample_h` and `oversample_v` 1 (truncated to integers),
`spacing_h` 0.5, `spacing_v` 0; `pixel_height` is read and ignored. With
no `[[fonts]]` the client adds one default entry. *Confirmed: T26, T27.*

**NUI-TEXT-003** A font is baked at `font_size` × the GUI scale, where
`font_size` is the height from the font's hhea ascent to its descent
(stb_truetype's `ScaleForPixelHeight`), **not** the em: glyphs are
smaller than a `font_size` em by the ratio em / (ascent − descent). A
renderer MUST scale glyphs this way to match the client. *Confirmed: T26
(measured).*

**NUI-TEXT-004** Each glyph's advance is the font's advance scaled as in
NUI-TEXT-003, plus `spacing_h`, rounded to a whole pixel when
`pixel_snap` is on. *Confirmed: T26 (measured).*

**NUI-TEXT-005** A font name no skin entry registered (or whose `.ttf`
failed to load) logs "Requested font was not found" and keeps the font
in effect. *Confirmed: T25, T29.* A checker SHOULD report font names the
skin does not define.

**NUI-TEXT-006** The game's "large font" option does not change NUI text.
*Confirmed: T30.*

## Glyphs

**NUI-TEXT-010** The atlas holds only the glyph ranges of the player's
code page: U+0020-U+00FF for 1252 (Western), Nuklear's Cyrillic ranges
for 1251, U+0020-U+02FF and U+2000-U+21FF otherwise (1250). *Confirmed:
T28.* Together with NUI-JSON-020, display text SHOULD be plain ASCII:
typographic quotes, dashes and "…" do not draw as themselves.

## Text elements

**NUI-TEXT-020** A `label` draws one line; a button draws one centred
line; neither wraps, and the client adds no ellipsis to text that does not
fit: it is cut. *Inferred (renderer agreement).*

**NUI-TEXT-021** A `text` element wraps at word breaks. At GUI scale 1.0
its wrap width is its width less 18 px (also when no scrollbar shows),
its first line starts 2 px below its inner top, and its lines are
`font_size` + 4 apart. *Confirmed: T32 (measured).* Its left inset (2 px,
4 more with a border) is *inferred* (T32, renderer agreement).

**NUI-TEXT-022** Draw-list text is one line from its rect's top-left
corner: no wrapping, cut after the glyph that crosses the rect's width
(that glyph is drawn), not clipped by the rect's height. *Confirmed:
T33.*

## Tooltips

**NUI-TEXT-030** An enabled element shows its `tooltip` on hover, a
disabled one its `disabled_tooltip`, never the other; an empty string
shows nothing. *Confirmed: T34.*

**NUI-TEXT-031** A tooltip is one line, never wrapped: a popup as wide as
the text + 16 px and one line + 8 px high, its left edge 21 px right of
the mouse and 1 px below it. Nothing keeps it on the screen or in the
window. `\n` is not a line break (it draws as a glyph). It is drawn in
the element's font. *Confirmed: T34.* An author SHOULD keep tooltips to
one short line; a checker SHOULD report a tooltip that would run off the
screen.

## Combo lists

**NUI-TEXT-040** A combo's open list opens below the combo, its left at
the combo's left and its top at the combo's bottom less the combo border,
always downward, unclipped by the window or the screen. Its rows are the
font's height + 2 high, the window style's `spacing.y` apart; its width is
the widest entry label + 50 + the scrollbar size (not the combo's width);
its height at most 300·s, past which it scrolls. *Confirmed: T35.*

**NUI-TEXT-041** A combo with no entries opens as an empty popup a few
pixels high. An author SHOULD NOT leave a combo's entries empty.
*Confirmed: T35.*

**NUI-TEXT-042** A combo that has a `tooltip` cannot be opened: the
tooltip takes the window's one popup while the mouse is over the combo.
An author MUST NOT put a `tooltip` on a combo (put it on its label); a
`disabled_tooltip` is harmless. *Confirmed: T35 (in game).*
