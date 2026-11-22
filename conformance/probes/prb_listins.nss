// prb_listins: a bordered list 300 x 160 of 3 rows, one cell 300 wide
// filled green, rows 40 / f tall (f = d / s); beside it a plain 300 x 40
// green element. Measure how far inside the list's border the rows start.
// NUI-MOBILE-033, NUI-LIST-002; T68. Run prb_clamp first.
// CC0 1.0 (nwn-nui-spec conformance). Needs only nw_inc_nui.nss.

void main();
#include "nw_inc_nui"

// Who the probe opens its windows for: the script parameter "player" (a
// player name, from ExecuteScript with SetScriptParam), else the module's
// local string PRB_PLAYER, else the first PC.
object PrbPlayer()
{
    string sName = GetScriptParam("player");
    if (sName == "") sName = GetLocalString(GetModule(), "PRB_PLAYER");
    object oPC = GetFirstPC();
    if (sName == "") return oPC;
    while (GetIsObjectValid(oPC) && GetPCPlayerName(oPC) != sName)
        oPC = GetNextPC();
    return oPC;
}

// The GUI scale as a factor; a missing or 0 value (Android) counts as 1.0.
float PrbScale(object oPC)
{
    int n = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE);
    return n > 0 ? IntToFloat(n) / 100.0 : 1.0;
}

// The factor f = d / s that prb_clamp measured for this player (1.0 on a
// desktop-like client, or before prb_clamp has run).
float PrbFactor(object oPC)
{
    float d = GetLocalFloat(oPC, "PRB_DENSITY");
    return d > 0.0 ? d / PrbScale(oPC) : 1.0;
}

// The size factor d (margins, row heights, cell widths, draw-list coordinates;
// NUI-MOBILE-020): 1.0 on a desktop-like client or before prb_clamp has run.
float PrbDensity(object oPC)
{
    return PrbFactor(oPC) > 1.05 ? GetLocalFloat(oPC, "PRB_DENSITY") : 1.0;
}

json PrbWindow(json jRoot, string sTitle, float fX, float fY, float fW, float fH)
{
    return NuiWindow(jRoot, JsonString(sTitle), NuiRect(fX, fY, fW, fH), JsonBool(FALSE), JsonNull(),
                     JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void PrbClose(object oPC, string sId)
{
    NuiDestroy(oPC, NuiFindWindow(oPC, sId));
}

// A drawing that fills its element with one colour, whatever the client's
// draw-list unit (the rect is larger than any element here; clipped).
json PrbFill(int nR, int nG, int nB)
{
    json jDraw = JsonArrayInsert(JsonArray(), NuiDrawListRect(JsonBool(TRUE), NuiColor(nR, nG, nB), JsonBool(TRUE),
                                                              JsonFloat(0.0), NuiRect(0.0, 0.0, 2000.0, 2000.0)));
    return NuiMargin(NuiDrawList(NuiSpacer(), JsonBool(TRUE), jDraw), 0.0);
}

void main()
{
    object oPC = PrbPlayer();
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_listins: no player"); return; }
    float f = PrbFactor(oPC);
    PrbClose(oPC, "prb_listins"); PrbClose(oPC, "prb_lplain");
    json jT = JsonArrayInsert(JsonArray(), NuiListTemplateCell(PrbFill(0, 255, 0), 300.0, FALSE));
    json jList = NuiMargin(NuiHeight(NuiWidth(NuiList(jT, JsonInt(3), 40.0 / PrbDensity(oPC), TRUE, NUI_SCROLLBARS_NONE), 300.0), 160.0), 0.0);
    NuiCreate(oPC, PrbWindow(NuiMargin(NuiCol(JsonArrayInsert(JsonArray(), jList)), 0.0), "list 300", 20.0, 20.0, 400.0, 260.0), "prb_listins");
    json jB = NuiMargin(NuiHeight(NuiWidth(PrbFill(0, 255, 0), 300.0), 40.0), 0.0);
    NuiCreate(oPC, PrbWindow(NuiMargin(NuiCol(JsonArrayInsert(JsonArray(), jB)), 0.0), "plain 300", 440.0 / f, 20.0, 400.0, 200.0), "prb_lplain");
    WriteTimestampedLogEntry("prb_listins sent; gui_scale " + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)));
}
