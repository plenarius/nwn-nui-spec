# Contributing

This repository describes what the game client does with NUI windows.
Every statement about the client needs evidence, and the text keeps what
is known apart from what is guessed.

## Evidence

A claim about the client carries:

- **the build** it was read on (today 89.8193.37-17, Linux, commit
  26c6e573):
  - `nwmain-linux`, sha256 `6d19c39b…5925e700`, for everything the client
    does;
  - `nwserver-linux`, sha256 `d6d95282…8e051111d`, for what the server
    sends;
  - full checksums in [engine/README.md](engine/README.md);
  - for an in-game result or a measurement, the client's platform (Linux,
    Windows, macOS, iOS, Android) and its GUI scale;
- **its evidence**, one or more of:
  - a function and address, and the binary. Use objdump/nm addresses (file
    virtual addresses). Ghidra loads the binary at 0x100000, so its
    addresses are 0x100000 higher: `Nui__ReloadSkin` is 0x1205460 in
    objdump, 0x1305460 in Ghidra. Say which function, and what in it;
  - an in-game result: the window's JSON (or what in it mattered), how it
    was opened, and what the client did;
  - a measurement of an in-game screenshot: the window, the capture's
    scale and how it was fitted, and the precision;
  - published source (the `nuilayout.cpp` gist, Nuklear) or Beamdog's
    documentation (`nw_inc_nui.nss`, `nwscript.nss`, patch notes), named;
  - data in the game's own files, named by resref (never copied here);
- **a status**:
  - **confirmed**: read in the code and checked (against the disassembly,
    or by an in-game result), shown in game, or measured on an in-game
    screenshot;
  - **inferred**: follows from the code, the data, documentation or a
    renderer's agreement with screenshots, not shown directly. Say which;
    "renderer agreement" must be named as such;
  - **untested**: written down so it is not lost, not checked at all.

Confirmed behaviour is normative (MUST, SHOULD). An inferred rule may be
written in the spec only with its status in its evidence, and is
informative until confirmed; untested behaviour goes into
[spec/unknown.md](spec/unknown.md). Nothing is promoted without new
evidence. Where the client disagrees with documentation, the rule follows
the client and says so.

## Rule IDs

Each rule has an ID `NUI-<AREA>-<NNN>`:

| Area | File | What |
|---|---|---|
| `JSON` | [spec/json.md](spec/json.md) | How the client receives and parses a window; `.jui`; strings |
| `WINDOW` | [spec/window.md](spec/window.md) | Window keys, title bar, frame, placement, constraints, scrolling |
| `LAYOUT` | [spec/layout.md](spec/layout.md) | The solver: margins, padding, sizes, spans, options, groups, GUI scale |
| `LIST` | [spec/list.md](spec/list.md) | Lists: rows, insets, templates, scrollbars |
| `TEXT` | [spec/text.md](spec/text.md) | Fonts, glyphs, text elements, tooltips, combo lists |
| `IMAGE` | [spec/image.md](spec/image.md) | Image types, lookup order, decoding, caches |
| `DRAW` | [spec/draw.md](spec/draw.md) | Draw lists |
| `BIND` | [spec/bind.md](spec/bind.md) | Binds and events |
| `SKIN` | [spec/skin.md](spec/skin.md) | `nui_skin.tml` |
| `MOBILE` | [spec/mobile.md](spec/mobile.md) | The mobile clients (to be written) |

IDs are stable: never renumber or reuse one. Numbers leave gaps so a rule
can be added beside its neighbours. A rule that turns out wrong is marked
withdrawn, with the reason, and a new ID replaces it. A rule that differs
between clients keeps its ID and says per client what it does.
Implementations may cite IDs in comments and tests.

Engine findings are numbered `T1`, `T2`, … in
[engine/behaviour.md](engine/behaviour.md) (desktop) and
[engine/mobile.md](engine/mobile.md). The numbers are this repository's
own.

## Pull requests

- A change to normative text needs evidence: an in-game result, a
  measurement, or an engine citation with the build. Say which.
- A new behaviour should come with a probe window that shows it (see
  [conformance/README.md](conformance/README.md)) once the probe format
  is in place.
- Tables change with the text that justifies them. Implementations
  generate their tables from `tables/`, so a table error spreads; check it
  twice.
- Write plainly. Short sentences, one claim each, the address or test next
  to it.
- Keep it generic: no server names, hosts, player or person names. Say
  "a persistent-world module" where a real window was the evidence.

## Assets

- No Beamdog game assets: no skin textures, fonts, `nui_skin.tml`,
  scripts, screenshots of Beamdog art, or BIF/KEY content. Refer to them by
  resref; tools read them from the user's install.
- No third-party content, and nothing whose licence you cannot give as
  CC0 (tables, probes) or CC-BY 4.0 (text).
- Engine decompiles are not copied here; cite the function and address.

## Licences

By contributing you agree that text you add is licensed CC-BY 4.0 and
tables, probes, code and data CC0 1.0 (see the README).
