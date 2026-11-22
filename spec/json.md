# The window JSON (`NUI-JSON`)

What reaches the client and how it reads it. The element keys themselves
are those `nw_inc_nui.nss` writes; this chapter does not repeat its
documentation.

## Parsing

**NUI-JSON-001** The client parses a window as one strict JSON value:
nothing but whitespace after it, no comments. The text ends at its first
NUL byte. An author MUST send exactly one JSON object. *Confirmed: T1.*

**NUI-JSON-002** Where the client wants a float it reads an integer
alike. An author MAY write `36` or `36.0`. *Confirmed: T1.*

**NUI-JSON-003** A window built by `nw_inc_nui.nss` carries
`"version": 1`. An author SHOULD write it. *Confirmed: T1 (the builders);
what the client does with another version is in unknown.md.*

## `.jui` resources

**NUI-JSON-010** `NuiCreateFromResRef` sends the client only a resref. The
client loads it as resource type 2083 (`jui`) from its own resources and
parses it as NUI-JSON-001. A `.jui` MUST therefore reach the player (a
hak, NWSync, or their own folders), and MUST hold exactly the JSON a
script would pass to `NuiCreate`, as UTF-8 text. *Confirmed: T2.*

**NUI-JSON-011** Binds and ids come from the `.jui`; bind values do not.
The script sets them after the call returns the window's token.
*Confirmed: T2.*

## Strings

**NUI-JSON-020** A string the server sends is UTF-8; the client converts
bound and static display strings back to the game's code page before
drawing them, and the text drawing reads UTF-8. So a label, text, button,
tooltip, draw-list text or window title MUST hold only ASCII
(U+0020-U+007E) to show as written: each byte from 0x80 up draws as the
font's fallback glyph. Combo entries and text-field values are converted
back to UTF-8 and show their real letters. *Confirmed: T31.* A renderer
SHOULD draw such characters as the fallback glyph, not as themselves.

**NUI-JSON-021** Chat colour tokens (`<cRGB>`, `</c>`) are not
interpreted in NUI text: they draw as characters. *Confirmed: T31.*
