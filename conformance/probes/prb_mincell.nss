// prb_mincell: a list 304 x 440 whose template is 2 (blue), 266 (green),
// 2 (red), each divided by the factor f = d / s (so 2/3, 266/3, 2/3 on an
// iPhone at GUI scale 1.0, meant to draw 2, 266, 2 px), rows 34 / f, no
// scrollbar; 2 rows and 11 rows. Measure the blue and red cells.
// NUI-MOBILE-024; T61. Run prb_clamp first.
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

void Open(object oPC, string sId, int nRows, float fX)
{
    float f = PrbFactor(oPC);
    json jT = JsonArray();
    jT = JsonArrayInsert(jT, NuiListTemplateCell(PrbFill(0, 0, 255), 2.0 / PrbDensity(oPC), FALSE));
    jT = JsonArrayInsert(jT, NuiListTemplateCell(PrbFill(0, 255, 0), 266.0 / PrbDensity(oPC), FALSE));
    jT = JsonArrayInsert(jT, NuiListTemplateCell(PrbFill(255, 0, 0), 2.0 / PrbDensity(oPC), FALSE));
    json jList = NuiMargin(NuiHeight(NuiWidth(NuiList(jT, JsonInt(nRows), 34.0 / PrbDensity(oPC), TRUE, NUI_SCROLLBARS_NONE), 304.0), 440.0), 0.0);
    json jRoot = NuiMargin(NuiCol(JsonArrayInsert(JsonArray(), jList)), 0.0);
    PrbClose(oPC, sId);
    NuiCreate(oPC, PrbWindow(jRoot, sId, fX / f, 10.0, 380.0, 560.0), sId);
}
void main()
{
    object oPC = PrbPlayer();
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_mincell: no player"); return; }
    Open(oPC, "rows 2", 2, 20.0);
    Open(oPC, "rows 11", 11, 440.0);
    WriteTimestampedLogEntry("prb_mincell sent; factor " + FloatToString(PrbFactor(oPC), 0, 3));
}
