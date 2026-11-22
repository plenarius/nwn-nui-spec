# The skin (`NUI-SKIN`)

`nui_skin.tml`, a TOML file, sets the look of every NUI window at once:
the textures and colours of each window part and widget, and the fonts to
bake. Patch 8193.35 added it. It does not style the classic GUI.

## Where it comes from

**NUI-SKIN-001** The skin is the resource `nui_skin` of type 2076 (`tml`),
read like any other resource: a module's hak or NWSync manifest, the
player's `override/` or `development/` folder, or the base game's
(`data/ovr.bif`). *Confirmed: T41.* A module MAY ship a skin in its haks
or NWSync; it reaches every player who joins. The nwn.wiki NUI page says
the `nui_*` files can be overridden only from a client's `override/` or
`development/` folder before a module loads; on 8193.37-17 that is not so
for the skin file (NUI-SKIN-010).

**NUI-SKIN-002** There is one skin for all NUI windows of a session,
Beamdog's own NUI panels included. There is no per-window skin.
*Confirmed: T41, T42.*

## When it is read

**NUI-SKIN-010** The client reads the skin and bakes its fonts at start,
on joining a server (after the module's haks and NWSync manifests are
added), on leaving, when a hak is re-attached, when the GUI scale
changes, and on a server resman message with bit 0x200. *Confirmed: T42.*
A renderer that previews a module's windows MUST use the skin the module
supplies, falling back to the base game's.

**NUI-SKIN-011** Every read empties the skin image cache first; skin
images are then loaded as NUI images (NUI-IMAGE-010). *Confirmed: T39,
T43.*

## Values

**NUI-SKIN-020** The client asks only for its own keys; unknown keys are
ignored. Each key has one of four value types, and a default when it is
missing ([tables/skin_keys.yaml](../tables/skin_keys.yaml)):

| type | value | default |
|---|---|---|
| nine-slice image | a texture resref, nine-sliced with fixed margins (NUI-SKIN-030) | `""`, which fails to load and draws the not-found placeholder |
| image or colour | `"#RRGGBBAA"` for a flat colour, anything else a texture stretched over the widget | `"#00000000"` (transparent) |
| colour | `"#RRGGBBAA"` | `"#00000000"` |
| integer | a whole number | 0 |

*Confirmed: T43.* Because the defaults are not the base game's values, a
partial skin is broken: an author SHOULD start from a complete file.

**NUI-SKIN-021** A TOML syntax error is logged ("failed to parse
nui_skin.tml") and the style is not updated, but the skin image cache has
already been emptied. A missing skin resource changes nothing. An author
MUST ship a skin that parses. *Confirmed: T43.*

**NUI-SKIN-022** The chart colours are read at the top level
(`background_color`, `color`, `border_color`, `selected_color`), not
under `[chart]`; `property.hover` and `scrollh.border_color` are never
read; `button.border` is divided by 100. *Confirmed: T45.* A checker
SHOULD warn about keys the client does not read.

**NUI-SKIN-023** `window.scrollbar_size_x` and `_y` are scaled by the
GUI scale. *Confirmed: T43.*

## Nine-slice margins

**NUI-SKIN-030** A nine-slice key's margins are fixed by the client, in
texture pixels: 3 on each side, except 7 for `button.hover`,
`selectable.hover`, `progress.hover`, `progress.active` and `combo.hover`,
and (5, 3, 3, 3) for `tab.background`. A skin cannot change them.
*Confirmed: T44.* Which side of `tab.background` has the 5 is open.

**NUI-SKIN-031** The scrollbar thumbs (`scrollv.cursor_*`,
`scrollh.cursor_*`) are not nine-sliced: they use only the texture's rect
(3, 0, 10, 16) for `scrollv` and (0, 3, 16, 10) for `scrollh`, repeated
along the bar and stretched across it. *Confirmed: T44.*

## Resource order and stock textures

**NUI-SKIN-040** Of files of the same name and type, the client takes the
player's `development/` folder first, then NWSync manifests, the module's
haks, Beamdog's patch haks, the player's `override/` folder, and the base
data. *Confirmed: T46.*

**NUI-SKIN-041** The base game's skin names TGAs `nui_*`. A module MAY
replace one by shipping a TGA or DDS of the same name in a hak; a PNG of
that name does not replace it (NUI-IMAGE-010). *Inferred: T47 (not tried
in game with a stock name).* A skin that names its own textures avoids
the question and is confirmed to work (NUI-SKIN-001).
