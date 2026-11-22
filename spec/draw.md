# Draw lists (`NUI-DRAW`)

A `draw_list` on any element paints lines, curves, circles, arcs,
rectangles, text and images in the element's rectangle, with coordinates
relative to its top-left corner. Most of this chapter rests on the API's
documentation and on Nuklear, not on the client's code: those rules are
*inferred*.

**NUI-DRAW-001** Items whose `order` is -1
(`NUI_DRAW_LIST_ITEM_ORDER_BEFORE`) are painted before the element, under
it; the others after it, over it. Within each group items are painted in
the order listed. *Inferred: T48 (renderer agreement).*

**NUI-DRAW-002** With `draw_list_scissor` true, items are clipped to the
element's rectangle; with it false they may paint outside it, clipped
only by the enclosing group, list or window. *Inferred: T48.*

**NUI-DRAW-003** An item's `render` condition (always, mouse off, hover,
left, right or middle button held) decides whether it is painted in a
frame. *Inferred (`nw_inc_nui.nss`).*

**NUI-DRAW-004** An item whose `arrayBinds` is true (`nBindArrays`) is painted once for
each entry of its bound arrays. *Inferred: T49.* What happens when the
arrays differ in length is open (unknown.md).

**NUI-DRAW-010** Draw-list text follows NUI-TEXT-022: one line, cut at
the rect's width, not wrapped. *Confirmed: T33.*

**NUI-DRAW-011** A circle item is a circle of radius w / 2 around its
rect's centre (h moves only the centre), filled or stroked with its line
thickness centred on the radius, anti-aliased. *Inferred: T50.*

**NUI-DRAW-012** A draw-list image is looked up as NUI-IMAGE-010.
*Inferred: T36 (the same loader is taken to serve draw lists; that it
also reads DDS bottom row first is open).*
