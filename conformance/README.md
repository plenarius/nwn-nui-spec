# Conformance probes

NWScript probe windows, each built to show one rule, with what each class
of client did with it. All CC0.

| Path | What |
|---|---|
| [probes/](probes/) | one `.nss` per probe; each needs only the game's `nw_inc_nui.nss` |
| [manifest.json](manifest.json) | each probe: what it isolates, the rules and findings it supports, and the expected result per client class |

This first set covers the mobile chapter ([spec/mobile.md](../spec/mobile.md))
and the desktop rules it is compared with. Expected results were measured
on build 89.8193.37-17: desktop on Linux and an Intel Mac, iOS on an
iPhone (density 3) at GUI scale 1.0 and 1.6, Android on an Android
tablet. Probes for the desktop chapters alone are still to be written.

## Client classes

| Class | What | How to tell |
|---|---|---|
| `desktop` | Windows, Linux, macOS | `prb_clamp` reports d / s = 1 |
| `ios_d3` | iOS at density 3 (an iPhone) | `prb_clamp` reports d = 3; platform 22 |
| `android` | Android | `prb_clamp` reports d / s = 1 with `gui_scale` 0; platform 40-42 |

Expected results for `ios_d3` are at GUI scale 1.0 unless they say
otherwise.

## Running the probes

1. Compile the probes with the module (they need only `nw_inc_nui.nss`;
   `nwn_script_comp` 2.3.1 or later wants the `void main();` they
   already declare) and put the `.ncs` files where the test server loads
   scripts (the module, a hak, or the server's `development/` folder).
2. Join the server with the client to test. On a server with other
   players see "Choosing the player" below.
3. Run `prb_device`, then `prb_clamp`, on the module. The stock server
   has no command for this: NWNX adds a `runscript <name>` server console
   command, and any DM tool or chat command that runs a script by name
   works too (the probes find the player themselves, so the script's
   caller does not matter). Read the server log: `prb_clamp report` gives
   the player's d and d / s within a few seconds. Run `prb_clamp` first
   after every join or GUI scale change: `prb_mincell`, `prb_gap`,
   `prb_listins`, `prb_image`, `prb_frame` and the window positions of the
   others divide by the f it stores (PRB_DENSITY on the player), and take
   f = 1 when it has not run.
4. Run each probe the same way and compare what the client
   shows with the manifest's `expected` for its class. Measure sizes on a
   screenshot from the device, scaled back to the device's resolution.
5. Close the probe windows (each has a close button; running a probe
   again replaces its windows).

The server logs each probe's `sent` line. It logs nothing when a client
refuses a window (NUI-LAYOUT-002), and still lists the refused window as
open: whether a window was built is seen only on the client.

### Choosing the player

The probes open their windows for the first PC. Another player can be
named by player name, either as the script parameter `player`
(`SetScriptParam("player", "<name>")` before `ExecuteScript`, as
`prb_frameh` does for `prb_frame`'s `axis`), or as the module's local
string `PRB_PLAYER`. `prb_device`, `prb_devkeys` and `prb_clamp` cover
every player.

### Two notes

- A server that runs scripts from a `development/` folder was seen to
  keep running the old version of a script it had already run since it
  started, after its `.ncs` there was replaced; a new script name ran at
  once. Give a changed probe a new name, or restart.
- Images: `prb_image` uses base-game resources only. To try the hak
  workaround of NUI-MOBILE-051, put a byte-identical copy of
  `po_hu_m_21_l.tga` from your own install in a hak; no game file is
  committed here.

## The probes

| Probe | Isolates | Rules | desktop | ios_d3 | android |
|---|---|---|---|---|---|
| `prb_device` | build, platform, GUI size and scale per player | NUI-MOBILE-001, -040 | platform by OS (1, 2, 10-13, 20-22) | platform 22 | platform 41, `gui_scale` 0 |
| `prb_devkeys` | guessed device-property keys | NUI-MOBILE-002 | all -1 | all -1 | not tried |
| `prb_clamp` (+ `prb_clampev`) | the density probe | NUI-MOBILE-010..012 | d = s | d = 3.0 (s 1.0 and 1.6) | d = s (s as 1.0) |
| `prb_margin` | margins against fixed rows | NUI-MOBILE-021, NUI-LAYOUT-001, -015 | all 10 build | only c3, c4, c6 build | as desktop |
| `prb_rowh` | `row_height` and row pitch | NUI-MOBILE-022, NUI-LIST-001, -003 | rows h px, pitch h + 4 | rows 3 h px, pitch about 3 h + 12 | as desktop |
| `prb_cells` | template cell widths | NUI-MOBILE-023, NUI-LIST-010 | 40, 100, 40 px, no gap | first cell about 128 px; the rest cut by the list | as desktop |
| `prb_mincell` | the narrowest cell | NUI-MOBILE-024 | 2, 266, 2 px (not measured) | blue and red about 11 px | as desktop (not measured) |
| `prb_draw` | draw-list coordinates in a list and a plain element | NUI-MOBILE-025 | green 10 px, red at 20 | green about 28 px, red at about 60, outline past the element | as desktop |
| `prb_place` | window position, -1 centring | NUI-MOBILE-026, -027, NUI-WINDOW-020 | left edge 100 s px; second centred | left edge about 304 px; second in the bottom-right corner | as desktop |
| `prb_gap` | gaps between span children | NUI-MOBILE-028 | none | none | none |
| `prb_button` | button frame and label | NUI-MOBILE-031 | every label centred in its frame | frame inset about 10 px; label low at 32; centred at 36 | as desktop |
| `prb_listins` | list inset | NUI-MOBILE-033, NUI-LIST-002 | rows 4 inside the border | about 14 (s 1.0), 8.7 (s 1.6) | as desktop |
| `prb_frame` (`prb_frameh`) | the window frame's extra | NUI-MOBILE-030, NUI-WINDOW-010 | every window fits (extra 0 fits) | width fits from +32 (s 1.0), +12 (s 1.6); height from +48, +16 | as desktop |
| `prb_image` | base-game images by type | NUI-MOBILE-050, NUI-IMAGE-010 | all draw | TGA-only names black; PNG, JPG, GIF, TGA+DDS draw | as iOS |

"As desktop" for Android means the windows of a persistent-world module
and the density probe behaved as on the desktop; the probe marked so was
not itself run on Android. The manifest says, per probe and class,
whether the expected result was measured with this probe, with an earlier
version of it, or follows from the rules.
