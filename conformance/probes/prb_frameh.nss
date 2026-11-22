// prb_frameh: prb_frame's height sweep (axis h, extras 8, 16, ... 64), for
// a server console that cannot pass script parameters. NUI-MOBILE-030; T65.
// CC0 1.0 (nwn-nui-spec conformance). Needs no include.

void main()
{
    SetScriptParam("axis", "h");
    ExecuteScript("prb_frame", OBJECT_SELF);
}
