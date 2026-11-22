# Images (`NUI-IMAGE`)

What an image resref in an `image`, a `button_image`, a draw-list image or
the skin turns into.

## Types and their order

**NUI-IMAGE-001** NUI images are of six types: `dds` (2033), `jpg`
(2081), `tga` (3), `png` (2080), `gif` (2079) and `wbm` (2071, WebM).
PLT is not an NUI image type. *Confirmed: T36.* GIFs animate; WebM plays
as video without sound (NUI-IMAGE-020).

**NUI-IMAGE-010** An image name is looked up as all six types, and the
type that wins is the **last** of wbm, gif, png, tga, jpg, dds that
exists anywhere in the player's resources: **DDS > JPG > TGA > PNG > GIF >
WBM**. The type decides first, whatever layer each file is in; the
resource order (NUI-SKIN-040) then decides only between files of the
winning type. A renderer MUST pick images this way. *Confirmed: T36 (in
game, desktop 8193.37-17: a DDS of a name is drawn whenever any layer has
one, whether the game's own copy of that name is a DDS or a TGA; asm).*

**Conflicting source, contradicted by test.** Beamdog's 8193.36 patch
notes and the nwn.wiki NUI page (updated 2026-02-02) give the order
JPG > TGA > PNG > GIF > WBM > DDS, with DDS "loaded last". On desktop
8193.37-17 that order is contradicted by the in-game test and by the code
(T36). An implementation MUST NOT use it for this build.

**NUI-IMAGE-011** So a base-game DDS beats a hak's TGA of the same name,
and a hak's PNG loses to a base-game TGA of the same name. An author who
replaces an image MUST ship it in the winning type (a DDS where the game
has a DDS of that name), and two files of one name SHOULD be the same
picture. *Confirmed: T36.*

## Decoding

**NUI-IMAGE-020** A file starting `DDS ` is read as DDS, one starting
`GIF89a` as GIF; anything else goes to stb_image (TGA, PNG, JPEG). A GIF
keeps up to 255 frames and plays them by each frame's delay, looping. A
WebM plays through the game's movie player. *Confirmed: T37.*

**NUI-IMAGE-021** Images load asynchronously: a placeholder shows while
one loads, and a not-found or error placeholder when it fails.
*Confirmed: T37.*

**NUI-IMAGE-022** NUI reads a DDS bottom row first: one stored bottom row
first shows upright, one stored top row first shows upside down. An
author SHOULD store NUI DDS files bottom row first. *Confirmed: T38 (in
game, `image`).* That draw-list images and standard `DDS ` files behave
the same is *inferred*; whether NUI honours a TGA's origin flag is open
(unknown.md).

## Caches and overrides

**NUI-IMAGE-030** Each window caches its images by resref and type; skin
images are cached until the next skin reload. A changed file shows in a
new window (or after a reload), not in one already open. *Confirmed:
T39.*

**NUI-IMAGE-031** `SetTextureOverride` overrides only `tga`, `dds`,
`ktx`, `plt`, `bmp`, `mtr` and `txi` resources and does not clear NUI's
caches. An author SHOULD NOT rely on it to change an NUI image; bind the
image's resref instead. *Confirmed: T40.*

## Placement

**NUI-IMAGE-040** How an image is fitted in its rectangle is set by its
`image_aspect` (`NUI_ASPECT_FIT`, `FILL`, `FIT100`, `EXACT`,
`EXACTSCALED`, `STRETCH`) and its alignment; `NuiImageRegion` draws a
sub-rectangle. Transparency is the image's own alpha. *Inferred
(`nw_inc_nui.nss`); the fitting arithmetic was not read
(unknown.md).*
