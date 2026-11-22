# Lists (`NUI-LIST`)

A `list` draws `row_count` rows, each laid out from its `row_template`.
Most numbers here were fitted to in-game screenshots by a renderer and
not read in code: they are *inferred* (renderer agreement) and
informative until measured on their own or read.

## Rows

**NUI-LIST-001** `row_height` is the height of every row. `NuiList`
writes 25 unless given another. *Confirmed: T22 (the builder);* what the
client uses when the key is missing is not known (unknown.md).

**NUI-LIST-002** With a border, rows start 4 px inside the list's frame
at the top and left, and end 4 px before its right edge (or before the
scrollbar when one shows). *Inferred: T22 (renderer agreement).*

**NUI-LIST-003** Rows are 4 px apart: row *i* starts at the inner top +
*i* × (`row_height` + 4). So *n* rows need *n* × `row_height` +
(*n* − 1) × 4 px. *Inferred: T22 (renderer agreement).*

**NUI-LIST-004** A vertical scrollbar, when it shows, is
`window.scrollbar_size_x` × s wide (18 in the skins measured), inside the
right inset, and the rows lose its width. With `NUI_SCROLLBARS_AUTO` it
shows only when the rows need more height than the list has. *Inferred:
T22 (renderer agreement); the scrollbar's size (code, T43).* An author
SHOULD size a list's cells for the width that remains when the scrollbar
shows, so a row is not squeezed when the list fills.

**NUI-LIST-005** The thumb of a vertical scrollbar is 10 px wide at the
bar's x + 4 and starts 2 px into the track (Nuklear insets it by the
skin's `scrollv.padding_x` and `padding_y`). *Confirmed: T24 (measured).*
Its length is open (unknown.md).

## Row templates

**NUI-LIST-010** A row template is a list of cells `[element, width,
variable]`, laid out side by side from the row's left. A fixed cell
(`variable` false) is `width` wide. Variable cells share what the fixed
cells leave, equally, each at least its own `width`. *Inferred: T23
(renderer agreement).*

**NUI-LIST-011** A cell's element fills the row's height and the cell's
width less its side margins, unless it sets a size of its own; a button
in a list row is `row_height` high. *Inferred: T23 (renderer
agreement).*

**NUI-LIST-012** Each template cell is solved on its own (NUI-LAYOUT-051):
a cell can only make its own row wrong, not the window unsolvable.
*Inferred: T18, T23.* An author SHOULD keep a cell's element, margins
included, within `row_height`; what the client does when it is not is
open (unknown.md).

**NUI-LIST-013** Every bind a template cell names is read per row from an
array with one entry per row; `NuiGetEventArrayIndex` gives the row of an
event. *Inferred (`nw_inc_nui.nss`, `nwscript.nss`; T51).*
