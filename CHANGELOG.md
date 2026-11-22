# Changelog

The spec is tagged per engine build. Each entry says which build it was
read on and what changed in the engine's behaviour since the last one.

## Unreleased (build 89.8193.37-17)

First draft, desktop client only (2026-11-21), from the NUI research done
for a persistent-world module's layout checker and window previews
(2026-11-03 to 2026-11-18) and for nwn-nui-designer:
- spec text for the window JSON, the window, layout, lists, text and
  fonts, images, draw lists, binds and events, and the skin, with rule
  IDs; engine findings T1-T53;
- tables: default sizes, margins and strengths; measured geometry; image
  types and their lookup order; the skin's keys;
- placeholders for the mobile chapters and the conformance probes.

Function addresses were normalised to objdump addresses and checked
against `nm -C`. For this repository the default margin (T10), the default
sizes (T14) and the image lookup order (T36) were re-read from the
disassembly, their constants read back from the file.

Corrections to earlier community documentation, on this build:
- NUI images are picked DDS > JPG > TGA > PNG > GIF > WBM, not
  JPG > TGA > PNG > GIF > WBM > DDS (T36);
- `nui_skin.tml` is read from any resource layer, haks and NWSync
  included, on every join (T41, T42).
