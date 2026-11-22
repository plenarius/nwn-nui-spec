# Layout (`NUI-LAYOUT`)

The server never lays a window out. The client turns the JSON into Kiwi
(Cassowary) constraints and solves them; each element gets a rectangle,
or the window is refused. The constraints for rows, columns and groups are
published (the `nuilayout.cpp` gist linked from the nwn.wiki NUI page,
engine/method.md); the rest was read from the client.

## Unsolvable windows

**NUI-LAYOUT-001** When the window's required constraints contradict each
other, the client does not open the window and shows "Error constructing
window from json: The constraint can not be satisfied." *Confirmed: T9.*

**NUI-LAYOUT-002** The server is not told: nothing is logged and
`NuiCreate` has already returned a token. A checker MUST report a window
the client cannot solve, naming the element whose constraint fails; an
author SHOULD check every window before it ships. *Confirmed: T9.*

## Margins and padding

**NUI-LAYOUT-010** Every element has a margin of 2 px on each side unless
its type or its JSON says otherwise. *Confirmed: T10.*

**NUI-LAYOUT-011** A `spacer`, a `tabbar` (`NuiToggles`) and `options`
(`NuiOptions`) have a margin of 0. *Confirmed: T11.*

**NUI-LAYOUT-012** Every element has a padding of 0 unless its JSON says
otherwise. *Confirmed: T10.*

**NUI-LAYOUT-013** A JSON `margin` or `padding` of 0 or more replaces the
default for any element, on all four sides; a negative value (the JSON
default, -1) means "not set" and keeps the default. *Confirmed: T12.*

**NUI-LAYOUT-014** Each side's margin and padding is a required
constraint. *Confirmed: T10.*

**NUI-LAYOUT-015** So an element's footprint along an axis is its size
plus twice its margin: a 32 px button (margin 2) needs 36 px of room, and
does not fit a 32 px row unless its margin is set to 0. *Confirmed: T9,
T10, T13.*

## Sizes

**NUI-LAYOUT-020** A JSON `width` or `height` is a required constraint.
*Confirmed: T13.*

**NUI-LAYOUT-021** An element that sets no `width` (or `height`) asks for
the client's default size on that axis, at the strength given:

| JSON type | width | height |
|---|---|---|
| `button`, `button_image` | 150 strong | 50 strong |
| `check` | 150 **weak** | 35 strong |
| `slider`, `sliderf` | 150 strong | 35 strong |
| `progress` | 150 strong | 35 strong |
| `combo` | 150 strong | 35 strong |
| `textedit` | — | 35 strong |

The sizes are multiplied by the GUI scale (NUI-LAYOUT-070). A JSON size
replaces the default on its axis. *Confirmed: T14.*

**NUI-LAYOUT-022** `label`, `text`, `image`, `list`, `group`, `chart`,
`spacer`, `row` and `col` ask for no size of their own: they take what
their parent's constraints give them. *Confirmed: T14.*

**NUI-LAYOUT-023** A `button_select` with no width takes 150.
*Confirmed: T14 (in game).* Its default height, and the defaults of
`color_picker` and the other types not listed, are not known
(unknown.md).

**NUI-LAYOUT-024** Because the defaults are strong, they beat a span's
medium fit (NUI-LAYOUT-041) but lose to any required constraint: an
unsized button in a row 36 px high is squeezed to 32, while two unsized
buttons in a row 200 px wide run past its end (2 × 154 = 308). A checker
MUST count default sizes. *Confirmed: T14, T16.*

## Options and toggles

**NUI-LAYOUT-030** `options` and `tabbar` lay out one entry per label: a
row of entries when `direction` is 0, a column when it is 1. Each entry
is an ordinary element with a margin of 2, asking (strong) for 35 high
and, in a row, 150 wide, whatever its label. *n* horizontal entries want
*n* × 154 by 39; *n* vertical ones *n* × 39 high. *Confirmed: T15.*

**NUI-LAYOUT-031** An options or tabbar element given a smaller size than
its entries want cuts the last entries off, and the cut-off entries still
reach the window's scroll extent (NUI-WINDOW-030). An author SHOULD size
options for their entries (or leave them unsized in a span with room).
*Confirmed: T8, T15.*

## Rows and columns

**NUI-LAYOUT-040** A span MUST be laid out with these constraints, where
*room* is the rectangle the span was given less its padding on each side
(T16):

1. each child's own constraints (NUI-LAYOUT-010 to -031), children before
   the span's own;
2. primary axis, required: the first child starts at the room's start plus
   its front margin; each next child starts at the previous child's start
   plus the previous child's size and back margin plus its own front
   margin;
3. secondary axis, required: each child starts at the room's start plus
   its front margin;
4. primary axis, medium: the room's size ≥ each child's footprint; the sum
   of the children's footprints == the room's size; that sum ≤ the room's
   size;
5. primary axis, weak: children that are spaced equally (NUI-LAYOUT-044)
   have the same size;
6. secondary axis: the room's size ≥ each child's footprint, **required**;
   the room's size == each child's footprint, medium.

*Confirmed: T16 (the published code and its consequences in game).* That
the client adds them in exactly this order is *inferred* (renderer
agreement; the order matters only for ties, NUI-LAYOUT-052).

**NUI-LAYOUT-041** Along a span, the fit is medium: children whose sizes
(set, or default and strong) add up to more than the span's room run past
its end, are drawn clipped by the window, and make the window scroll. It
is not an error to the client. A checker SHOULD report it. *Confirmed:
T8, T16.*

**NUI-LAYOUT-042** Across a span, the fit is required: a child whose
required size plus margins exceeds the span's room makes the window
unsolvable. A child with only a strong default size there is squeezed to
fit. *Confirmed: T9, T16.*

**NUI-LAYOUT-043** A span with no size of its own takes the size its
parent gives it; a set size on a span is required like any other
(NUI-LAYOUT-020), so a span set smaller across than a child's required
footprint is unsolvable. A checker MUST therefore follow required sizes
down through spans without sizes of their own. *Confirmed: T13, T16.*

**NUI-LAYOUT-044** Children that are "spaced equally" are suggested, at
weak strength, the same size along the span; spacers are such children.
*Inferred: T17.*

## Groups

**NUI-LAYOUT-050** A `group` lays its child out in a solver of its own,
in a room (0, 0, gw, gh) whose size is suggested from the group's size at
medium strength. Its content can never make the group or its parent
unsolvable; content larger than the group is clipped, or scrolls as the
group's `scrollbars` allow. *Confirmed: T18.*

**NUI-LAYOUT-051** A `list` lays out each row the same way, one row
template in a row of `row_height` (list.md). *Inferred: T18, T23.*

**NUI-LAYOUT-052** Where several solutions are equally good, the client's
choice follows C++ Kiwi's maps, sorted by symbol id. A solver MUST break
ties the same way to place elements as the client does: a port of Kiwi
SHOULD keep its maps sorted, as C++ Kiwi's `AssocVector` is. *Inferred:
T19.*

## Static geometry

**NUI-LAYOUT-060** `width`, `height`, `aspect`, `margin` and `padding`
are read once, when the window is built; to change geometry, an author
swaps a group's layout with `NuiSetGroupLayout`. *Inferred: T20.*

## GUI scale

**NUI-LAYOUT-070** The default sizes of NUI-LAYOUT-021 and -030 are
multiplied by the GUI scale; inside a group the scale is pinned to the
client's current GUI scale. *Confirmed: T21.* That the window's own
content is scaled the same way, and how the frame, insets and skin slices
scale, are open (unknown.md).
