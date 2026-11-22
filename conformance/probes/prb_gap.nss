// prb_gap: six 30 x 30 elements, margin 0, alternating green and red, in a
// row and in a column (both margin 0). Each element's drawing is 30 / d
// square (d the size factor, NUI-MOBILE-020), so it fills its element on any
// client. Look for gaps.
// NUI-MOBILE-028; T60. Run prb_clamp first.
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

json Block(object oPC, int bRed)
{
    float fD = 30.0 / PrbDensity(oPC);
    json jC = bRed ? NuiColor(255, 0, 0) : NuiColor(0, 255, 0);
    json jDraw = JsonArrayInsert(JsonArray(), NuiDrawListRect(JsonBool(TRUE), jC, JsonBool(TRUE), JsonFloat(0.0), NuiRect(0.0, 0.0, fD, fD)));
    return NuiMargin(NuiHeight(NuiWidth(NuiDrawList(NuiSpacer(), JsonBool(FALSE), jDraw), 30.0), 30.0), 0.0);
}
void main()
{
    object oPC = PrbPlayer();
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_gap: no player"); return; }
    PrbClose(oPC, "prb_grow"); PrbClose(oPC, "prb_gcol");
    json jRow = JsonArray(), jCol = JsonArray();
    int i;
    for (i = 0; i < 6; i++) { jRow = JsonArrayInsert(jRow, Block(oPC, i % 2)); jCol = JsonArrayInsert(jCol, Block(oPC, i % 2)); }
    json jR = NuiMargin(NuiCol(JsonArrayInsert(JsonArray(), NuiMargin(NuiRow(jRow), 0.0))), 0.0);
    json jC = NuiMargin(NuiCol(jCol), 0.0);
    NuiCreate(oPC, PrbWindow(jR, "row of 6", 10.0, 10.0, 260.0, 120.0), "prb_grow");
    NuiCreate(oPC, PrbWindow(jC, "col of 6", 300.0 / PrbFactor(oPC), 10.0, 100.0, 260.0), "prb_gcol");
    WriteTimestampedLogEntry("prb_gap sent");
}
