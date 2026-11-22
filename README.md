# NWN:EE NUI: specification

A shared, evidenced description of how Neverwinter Nights: Enhanced Edition
builds and draws NUI windows: the JSON a script sends, the layout solver
that turns it into rectangles, element sizes, margins and padding, rows,
columns, groups and lists, the window's frame and placement, text and
fonts, images, draw lists, binds and events, and the skin.

**Status:** draft, read on engine build 89.8193.37-17 (Linux
`nwmain-linux`, commit 26c6e573). Nothing here is official: it is what the
game was seen to do, with the evidence for each claim. This draft covers
the **desktop** client; the mobile chapters are placeholders
([spec/mobile.md](spec/mobile.md)).

## Why

NUI windows are built on the server and laid out only on the client. The
server never sees the layout, so a window the client cannot build fails on
the player's screen and nowhere else. Tools that design, check or preview
windows (editors, linters, renderers, test suites) need to know what the
client does with the JSON. Beamdog's script headers describe the API;
the rest is folklore. Three examples, each of which cost a broken window
before it was understood:

- every element has a 2 px margin on each side, so a 32 px button does not
  fit a 32 px row: the client refuses the whole window with "The constraint
  can not be satisfied" and nothing is logged on the server
  (NUI-LAYOUT-015, NUI-LAYOUT-001);
- the window's frame takes 16 px of the geometry's width and 49 of its
  height, so a window sized to its content plus a guessed margin shows an
  empty band or scrolls (NUI-WINDOW-010);
- an image name is looked up as every type and the **last** type that
  exists wins, DDS first, whatever layer each file is in: a base-game DDS
  beats a hak's TGA of the same name (NUI-IMAGE-010). Community pages say
  the opposite.

## What is here

| Folder | What it is |
|---|---|
| [spec/](spec/) | The normative text: the window JSON, layout, lists, the window frame, text and fonts, images, draw lists, binds and events, the skin. Every rule has a stable ID (`NUI-LAYOUT-012`) and cites its evidence. |
| [engine/](engine/) | What the client does, finding by finding (T1, T2, …), with function addresses, build and status (confirmed, inferred, untested). The spec's evidence. |
| [tables/](tables/) | Machine-readable data (CC0): default element sizes and margins, the measured frame and insets, image types and their lookup order, the skin's keys with their types, defaults and slice margins. Generate your tables from these. |
| [conformance/](conformance/) | To hold NWScript probe windows with the expected result on each client. Empty in this draft. |

## How it relates to the sibling specs

This is a sibling of [nwn-mdl-spec](../nwn-mdl-spec/), which describes the
model files, and [nwn-tileset-spec](../nwn-tileset-spec/), which describes
tilesets and area pathfinding. It follows the same conventions: the same
evidence rules, statuses and licences, rule IDs of the same shape
(`NUI-<AREA>-<NNN>` here, `MDL-…` and `SET-…` there) and objdump addresses
throughout. The three were read on the same client binary.

## The reference implementation

[nwn-nui-designer](https://github.com/plenarius/nwn-nui-designer) (MIT) is
the reference implementation of the layout and drawing rules. Its layout
engine (`src/core/layout/layout.ts`) builds the client's Kiwi constraints
in the client's order and solves them with a Kiwi port whose maps are
sorted as C++ Kiwi's are, so it picks the solution the client picks; its
renderer (`src/core/render/`) draws with the measured frame, insets and
text model. Its renders were compared with in-game screenshots of real
windows (8193.37-17): frames, buttons, list rows and text lines fall within
1 to 3 px, and the 13 lines of a measured paragraph break at the game's
words. Where a rule's only evidence is that agreement, the rule says so.

Its `docs/CLIENT-BEHAVIOUR.md` is where many of these findings were first
written down; this repository restates them per rule, with the addresses
checked against the binary, and without reference to any one tool.

## Evidence

Every claim about the engine names the build it was read on, its evidence (a
function and address, an in-game test, or a measurement of an in-game
screenshot) and a status: **confirmed**, **inferred** or **untested**.
Confirmed rules are normative; a rule that is only inferred says so in its
evidence and is informative until it is confirmed. Open questions are in
[spec/unknown.md](spec/unknown.md). [engine/behaviour.md](engine/behaviour.md)
has the findings themselves. [CONTRIBUTING.md](CONTRIBUTING.md) has the
rules.

### Not done yet

- **Mobile clients** (iOS, Android): findings measured on 2026-11-21 are
  being verified ([spec/mobile.md](spec/mobile.md)).
- **GUI scale above 1.0**: the default sizes, the scrollbar width and the
  font sizes scale (code); how the frame, the insets and skin slices scale
  was not measured.
- **The Windows and macOS builds**: the code was read on the Linux
  client; the in-game tests and screenshots came from desktop clients of
  the same build (one screenshot a macOS capture).
- **Conformance probes**: the probe windows and their expected results per
  client are still to be written ([conformance/](conformance/)).

### Versioning and governance

The spec is tagged per engine build, with a changelog of behaviour that
changed between builds ([CHANGELOG.md](CHANGELOG.md)). A change to
normative text needs evidence: an in-game result, a measurement, or an
engine citation with the build. The repository is meant to belong to no
single tool.

## Licences

- Text (`spec/`, `engine/`, the Markdown files): [CC-BY 4.0](LICENSE-TEXT).
- Tables and future conformance probes: [CC0 1.0](LICENSE-DATA).
- **No Beamdog game assets are in this repository.** Stock skin textures,
  fonts, `nui_skin.tml` and scripts are named, never copied. The tables are
  numbers: sizes, offsets, type IDs, key names and their defaults as the
  client reads them.

## Related

- [nwn-mdl-spec](../nwn-mdl-spec/) and [nwn-tileset-spec](../nwn-tileset-spec/).
- [nwn.wiki's NUI page](https://nwn.wiki/spaces/NWN1/pages/48988184/NUI): the
  community page; it links the layout gist this spec cites. Where it and the
  8193.37-17 client disagree, the spec says so (NUI-IMAGE-010,
  NUI-SKIN-001).
- `nw_inc_nui.nss` and `nwscript.nss`, shipped with the game: the API.
  This repository does not repeat their documentation.
