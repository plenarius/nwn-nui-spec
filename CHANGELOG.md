# Changelog

Releases follow semantic versioning. Each entry says which engine build it
was read on and what changed in the engine's behaviour since the last one.

## 1.0.0 (build 89.8193.37-17)

First draft, desktop client only (2026-11-21), from the NUI research done
for a persistent-world module's layout checker and window previews
(2026-11-03 to 2026-11-18) and for nwn-nui-designer:
- spec text for the window JSON, the window, layout, lists, text and
  fonts, images, draw lists, binds and events, and the skin, with rule
  IDs; engine findings T1-T53;
- tables: default sizes, margins and strengths; measured geometry; image
  types and their lookup order; the skin's keys;
- placeholders for the mobile chapters and the conformance probes.

Mobile chapter and first conformance probes (2026-11-22), measured on iOS
8193.37-17 on an iPhone (density 3, GUI scale 1.0 and 1.6) and on Android
8193.37-17 on an Android tablet, compared with Linux and Intel-Mac
desktop clients:
- spec/mobile.md, rules NUI-MOBILE-001..060; engine findings T54-T73;
  tables/mobile.yaml;
- conformance/: 16 probe scripts (14 probes, an event script and a
  wrapper) needing only `nw_inc_nui.nss`, a manifest with the expected
  result per client class (desktop, iOS at density 3, Android), and how
  to run them from a server console;
- open questions for the mobile clients in spec/unknown.md.

What the mobile clients do differently, on this build:
- an iPhone reports platform 22 (`MAC_ARM64`), not 30 (`IOS`); a clamped
  window's reported position measures the density instead (T54, T56);
- iOS multiplies margins, row heights, row spacing, template cell widths,
  draw-list coordinates and window positions by its density, not window
  or element sizes or glyphs (T57-T63); its frame, buttons and list
  insets take more room (T65-T68);
- Android lays out as the desktop does and reports a GUI scale of 0 (T69);
- on iOS and Android, base-game images that exist only as TGA draw black
  in NUI; a hak copy draws (T70-T72).

Corrections from GUI scale 1.6 on iOS (2026-11-22):
- NUI-MOBILE-020 had all multiplied quantities follow f = d / s, which was
  measured for the window position only. At s = 1.6, row heights, cell
  widths and draw-list coordinates follow d, and the row spacing is a
  fixed 4 · d screen pixels (T74); the position still follows d / s.
  NUI-MOBILE-012, -022, -023, -025, -060 and tables/mobile.yaml now use
  both factors; the probes divide sizes by d.
- New NUI-MOBILE-052: an image element in a list row does not draw on iOS
  and breaks the row; a draw-list image works (T75, probe `prb_listimg`).

Function addresses were normalised to objdump addresses and checked
against `nm -C`. For this repository the default margin (T10), the default
sizes (T14) and the image lookup order (T36) were re-read from the
disassembly, their constants read back from the file.

Corrections to earlier community documentation, on this build:
- NUI images are picked DDS > JPG > TGA > PNG > GIF > WBM, not
  JPG > TGA > PNG > GIF > WBM > DDS (T36);
- `nui_skin.tml` is read from any resource layer, haks and NWSync
  included, on every join (T41, T42).
