# The specification

What a Neverwinter Nights: Enhanced Edition NUI window is, and what the
game client does with it, written so a window designer, a layout checker
or a renderer can be built from it.

**Build:** 89.8193.37-17 (Linux `nwmain-linux`, commit 26c6e573). Every
rule was read on this build. A later patch may change behaviour; the
changelog records what changed and when. The chapters describe the
**desktop** client; [mobile.md](mobile.md) says how the iOS and Android
clients differ, measured on an iPhone and an Android tablet.

| File | Rules | What |
|---|---|---|
| [json.md](json.md) | `NUI-JSON-*` | The window's JSON: how the client receives and parses it, `.jui` resources, element keys |
| [window.md](window.md) | `NUI-WINDOW-*` | The window: its keys, title bar, frame, placement, constraints, scrolling |
| [layout.md](layout.md) | `NUI-LAYOUT-*` | The solver: margins, padding, set and default sizes, rows and columns, options and toggles, groups, unsolvable windows, GUI scale |
| [list.md](list.md) | `NUI-LIST-*` | Lists: row height, insets, spacing, row templates, scrollbars |
| [text.md](text.md) | `NUI-TEXT-*` | Fonts, their size, glyph ranges, code pages, wrapping, draw-list text, tooltips, combo lists |
| [image.md](image.md) | `NUI-IMAGE-*` | Image types, their lookup order, decoding, row order, caches |
| [draw.md](draw.md) | `NUI-DRAW-*` | Draw lists: order, clipping, bind arrays, shapes |
| [bind.md](bind.md) | `NUI-BIND-*` | Binds and events |
| [skin.md](skin.md) | `NUI-SKIN-*` | `nui_skin.tml`: where it comes from, when it is read, its values, nine-slice margins |
| [mobile.md](mobile.md) | `NUI-MOBILE-*` | The mobile clients: telling them apart, what iOS multiplies by its density, its frame and controls, Android, base-game TGAs, portable windows |
| [unknown.md](unknown.md) | — | Observed, inferred or unknown behaviour, and open questions. Not normative. |

## Reading the rules

Each rule has an ID, a statement, and its evidence:

> `NUI-LAYOUT-010` Every element has a margin of 2 px on each side unless
> its type or its JSON says otherwise. *Confirmed: T10.*

- **MUST** / **MUST NOT**: what the client does, and what an
  implementation has to do to match it (a layout checker, a renderer), or
  what a window has to do for the client to build it.
- **SHOULD**: what a window author does to get windows the client shows
  well, where the evidence is a recorded failure and its fix; or client
  behaviour that is a defect an implementation may avoid where it says so.
- **MAY**: explicitly allowed variation.

"Author" means anything that writes window JSON (a script, a designer, a
`.jui`); "checker" anything that predicts whether the client can build a
window; "renderer" anything that predicts what it draws. Rules about what
the client does are statements of fact with their evidence; rules for
implementations follow from them.

Evidence names an engine finding (`T12`, in
[engine/behaviour.md](../engine/behaviour.md)). Every rule carries one of:

- *Confirmed*: normative.
- *Inferred*: what the evidence supports, written down because an
  implementation needs a number; **informative** until confirmed. An
  implementation MAY follow it and SHOULD say that it does. "Renderer
  agreement" means the only support is that a renderer using the rule
  matches in-game screenshots.

Untested behaviour is not stated as a rule: it is in
[unknown.md](unknown.md).

## Words

- **element**: an object in the window's JSON with a `type` (`row`, `col`,
  `group`, `button`, …); the client's `Layoutable`.
- **row**, **column**: elements of type `row` and `col`, the client's
  `Span`. "Span" means either.
- **primary axis**: the axis a span lays its children along (x for a row,
  y for a column); the other is the **secondary axis**.
- **margin**: room an element keeps around itself, inside its parent's
  room. **padding**: room a span keeps inside itself, around its children.
- **footprint**: an element's size plus its two margins along an axis.
- **strength**: a Cassowary strength: required, strong, medium or weak.
  A required constraint cannot be broken; the others give way to stronger
  ones.
- **unsolvable**: a window whose required constraints contradict each
  other; the client refuses it (NUI-LAYOUT-001).
- **s**: the GUI scale, 1.0 by default.
- **body**: the window below its title bar, inside its frame.
- **content**: what the window's root element lays out, inside the body.
- **skin**: the resource `nui_skin.tml` and the textures and fonts it
  names.

Sizes are in pixels at GUI scale 1.0 unless a rule says otherwise.
