# How the evidence was gathered

So anyone with the game can repeat it.

## Reading the code

- `nwmain-linux` is unstripped, so functions have their C++ names
  (`Nui::Layout::Layoutable::SetMargin`, `Nui__ReloadSkin`). Build and
  checksums are in [README.md](README.md).
- `nm -C` and `objdump -d --no-show-raw-insn -C` give addresses and
  disassembly. Addresses in this repository are objdump's.
- Ghidra 12.1, headless and read-only, decompiled the layout constructors
  (2026-11-05) and the skin, font and image loaders (2026-11-15), with the
  "Non-Returning Functions - Discovered" analyser off (the default marks
  `memcpy`, `free` and `operator new[]` as non-returning and truncates the
  functions that call them). Where a decompile dropped arguments or
  mislabelled locals, the finding was re-derived from the disassembly; the
  findings say which.
- Constants were read back from the binary at their address (program
  headers to file offset): for example the margin's `2.0f` at 0x12f1b94
  and the default sizes' `150.0f` at 0x1319668, `50.0f` at 0x12f3610 and
  `35.0f` at 0x1319650.
- A finding marked **(code)** was read in the decompile (and, where a
  decompile was doubtful, its disassembly) when it was first found. One
  marked **(asm)** was also checked against the disassembly for this
  repository, constants read back from the file. **(strings)** means only
  the binary's string table was read.
- The decompiles are not copied here. Each finding names its function and
  address, which is enough to repeat the reading.

### The published layout code

The nwn.wiki NUI page links a gist, `nuilayout.cpp`
(<https://gist.github.com/9bf60ca649fdf6709c17886a1a467755>, revision
`8504d435`, 2024-12-29), with the source of `Layoutable::BuildConstraints`,
`LayoutGroup::SetChildren` and `Span::BuildConstraintDependants`. Findings
that rest on it say so. The client's own functions (0x84e500, 0x853db0,
0x850560) were not compared with it line by line; what the gist implies
was checked in game where a finding says so, and a renderer that builds
the gist's constraints agrees with the client's windows (below).

## Trying windows in game

Windows were built with `NuiCreate` on a test server and opened on desktop
clients of build 8193.37-17. The tests are named in each finding: the
window, what was changed, and what the client did (the window opened or
was refused with "Error constructing window from json: The constraint can
not be satisfied", a drop-down opened or not, a picture showed upright or
upside down). Several of them are windows of a persistent-world module
that failed for players before their cause was found; their JSON is not
published here, but each finding says what in it mattered.

Two things help:

- The server logs nothing when a client refuses a window. Watch the
  client's log or screen.
- The client caches images per window and skin images per skin load
  (T33). Open a new window, or rejoin, after changing a file.

## Measuring screenshots

Two in-game screenshots of real windows (8193.37-17, GUI scale 1.0) were
measured:

- a crafting window, 1440 × 900, scaled by about 0.897 by the capture
  (2026-11-15);
- a 106-element window with a list, a header and a 13-line paragraph, a
  macOS Retina capture at a fitted scale of 1.800 (2026-11-16).

For the second, the render of the same JSON by the reference
implementation was scaled onto the screenshot and compared by sub-pixel
cross-correlation of edge profiles and patches; the scale was fitted from
several independent distances, so single edges are good to about ±0.3 px.
A finding marked **measured** was read off a screenshot this way. A finding
whose only support is that a renderer using the number agrees with the
screenshot (within 1 to 3 px on the first, scaled one) says so: the number
fits, but other numbers might fit as well.

The screenshots are not published: they show Beamdog's skin and a
module's art.

## The renderers

Two renderers were built from these findings: a Python one inside a
module's tooling (not public) and its TypeScript port,
[nwn-nui-designer](https://github.com/plenarius/nwn-nui-designer), the
reference implementation. Both build the gist's constraints in the gist's
order and solve them with Kiwi (kiwisolver, the binding of C++ Kiwi; and a
port of `@lume/kiwi` whose maps are kept sorted as C++ Kiwi's
`AssocVector` is, so ties break the same way). A module's test suite also
checks every one of its windows with a layout checker written from the
same rules; it fails the windows the client refused, at the element the
client refused, and passes their fixed versions (T9).
