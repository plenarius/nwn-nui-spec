# Tables

Machine-readable data for implementations. All CC0 1.0. Generate your
tables from these rather than copying them by hand; each file names its
build, binary and the addresses it was read at, and each value says how
it is known.

| File | What | Rules |
|---|---|---|
| [defaults.yaml](defaults.yaml) | Margins, padding, default element sizes and their strengths, options and toggle entries, a skin font entry's defaults, what the `nw_inc_nui.nss` builders write by default. | NUI-LAYOUT-010..031, NUI-TEXT-002 |
| [geometry.yaml](geometry.yaml) | The measured window frame; list, text box and scrollbar insets; tooltip and combo-list geometry. Values marked `renderer_agreement` are informative. | NUI-WINDOW-010..012, NUI-LIST-*, NUI-TEXT-021..040 |
| [image_types.yaml](image_types.yaml) | The six NUI image types, their resource type numbers and the order the client picks them in; the other NUI resource types. | NUI-IMAGE-001..011 |
| [skin_keys.yaml](skin_keys.yaml) | Every key the client reads from `nui_skin.tml`, in its order, with type, default and nine-slice margins. | NUI-SKIN-020..031 |

## Conventions

- YAML 1.2, one document per file, a `schema` key naming the file's
  format and version (`nwn-nui-spec/<name>/<n>`). A change that breaks a
  reader bumps `<n>`.
- Sizes are pixels at GUI scale 1.0.
- Addresses are objdump/nm addresses in `nwmain-linux` (Ghidra adds
  0x100000).
- `status` or `how` on a value: `confirmed`, `measured` and `code` are
  normative; `inferred` and `renderer_agreement` are not (see
  [spec/README.md](../spec/README.md)).

The skin-key list was written out from the reference implementation's key
model (nwn-nui-designer `src/core/skin/keys.ts`), itself written from the
client's `Nui__ReloadSkin`; it holds key names and numbers, no content of
the game's own `nui_skin.tml`.
