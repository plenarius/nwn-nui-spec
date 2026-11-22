# The window (`NUI-WINDOW`)

The keys of `NuiWindow`, the frame the client draws round the content,
and where the window goes.

## Keys

**NUI-WINDOW-001** The client reads the window's boolean keys as this
table says. "Bind" is a bind with no value yet; for `closable`, `border`,
`transparent` and `accepts_input` the starting state holds until the bind
is set, then the bind's value counts. A renderer MUST draw the window's
decorations this way. *Confirmed: T3.*

| key | `true` | `false` | `null` | missing | bind |
|---|---|---|---|---|---|
| `collapsed` | collapse button; opens collapsed | no button | button; opens expanded | no button | button; collapsed while the value is true |
| `closable` | close button | none | close button | close button | close button |
| `border` | drawn | none | none | drawn | none |
| `transparent` | no background | background | background | background | background |
| `accepts_input` | input | none (clicks fall through) | input | input | input |

**NUI-WINDOW-002** The title bar is drawn unless the title is empty
**and** there is no close button **and** no collapse button. A window
that opens collapsed is drawn as its title bar alone. *Confirmed: T4.*
An author who turns off the close button SHOULD give the window another
way to close (the player otherwise cannot).

## Frame

**NUI-WINDOW-010** At GUI scale 1.0 a window with a title bar draws a
33 px title bar, its body's frame directly below it, and its content
inset 8 px from the left, right and bottom edges and 8 px below the title
bar. The frame therefore takes **16 px of the geometry's width and 49 px
of its height**. *Confirmed: T7 (measured, with a skin whose window
padding is 0).*

**NUI-WINDOW-011** An author who wants a window exactly the size of its
content SHOULD set its geometry to the content's footprint + 16 wide and
+ 49 tall, also when the geometry is a bind or set at run time. A larger
geometry leaves an empty band at the right and bottom; a smaller one
makes the body scroll (NUI-WINDOW-030). *Confirmed: T7, T8.*

**NUI-WINDOW-012** Without a title bar the frame takes 16 × 16.
*Inferred: T7 (the title bar's 33 px removed; not measured).*

## Placement

**NUI-WINDOW-020** `geometry.x` of -1 centres the window on the screen
(left edge screenW / 2 − s·w / 2), -2 puts its left edge at the mouse,
and -3 centres it on the mouse (mouseX − s·w / 2); `y` likewise, measured
from the top. A resulting position below 0 is clamped to 0. Other values
are the position. *Confirmed: T5.* A renderer with no mouse MAY take the
screen's centre for it, and SHOULD say so.

**NUI-WINDOW-021** `size_constraint` (x, y, w, h) is minimum width,
minimum height, maximum width, maximum height. `edge_constraint`
(x, y, w, h) is the left, top, right and bottom margins the window keeps
from the screen's edges (the client passes them on as left, right, top,
bottom). *Confirmed: T6.* That 0 turns a constraint off is
*inferred* (`nw_inc_nui.nss`).

## Scrolling

**NUI-WINDOW-030** When the content reaches past the body (children that
run past a span's end, NUI-LAYOUT-041, or entries past their options
element, NUI-LAYOUT-031), the body scrolls; a horizontal scrollbar covers
the bottom of the body, so content that filled its height then needs the
vertical one too. A checker SHOULD report content that reaches past the
body. *Confirmed: T8.*
