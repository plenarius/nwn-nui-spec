# Binds and events (`NUI-BIND`)

A bind (`{"bind": "name"}`) puts a value the server sets with
`NuiSetBind` where a static JSON value would go; an element with an `id`
sends events to the window's event script. The API is documented in
`nwscript.nss` and `nw_inc_nui.nss`; little of the client's side was read,
so most rules here are *inferred*.

**NUI-BIND-001** A bind with no value yet leaves a window key at its
starting state (NUI-WINDOW-001). *Confirmed: T3.* For other elements,
what an unset bind draws is open (unknown.md).

**NUI-BIND-002** A bound string is converted to the game's code page
before it is drawn (NUI-JSON-020). *Confirmed: T31.*

**NUI-BIND-003** Bind values are not converted between JSON types: an
author MUST set the type a widget expects (a bool for `enabled`, a string
for a label, a number for a slider). *Inferred: T53.*

**NUI-BIND-004** Sizes, margins, padding, aspect and `row_height` cannot
be bound (NUI-LAYOUT-060). *Inferred: T20.*

**NUI-BIND-010** Only elements with an `id` send events. The client's
event names are `click`, `mousedown`, `mouseup`, `mousescroll`, `blur`,
`open` and `unknown-bind`; the server adds `watch` (a watched bind
changed) and `close`. There is no hover event. *Inferred: T51.*

**NUI-BIND-011** `NuiSetBind` on a watched bind runs the event script
with `watch` before it returns; an author SHOULD NOT set a watched bind
from its own watch handler. *Inferred: T52.*

**NUI-BIND-012** In a list, an event's `NuiGetEventArrayIndex` is the
row; outside an array it is -1. *Inferred (`nwscript.nss`).*
