// prb_cells: a list 300 wide with a row template of three fixed cells,
// 40 (green), 100 (red) and 40 (blue), row_height 10, no scrollbar.
// Measure each cell's width and any gap between cells.
// NUI-MOBILE-023, NUI-LIST-010; T60.
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
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_cells: no player"); return; }
    json jT = JsonArray();
    jT = JsonArrayInsert(jT, NuiListTemplateCell(PrbFill(0, 255, 0), 40.0, FALSE));
    jT = JsonArrayInsert(jT, NuiListTemplateCell(PrbFill(255, 0, 0), 100.0, FALSE));
    jT = JsonArrayInsert(jT, NuiListTemplateCell(PrbFill(0, 0, 255), 40.0, FALSE));
    json jList = NuiMargin(NuiHeight(NuiWidth(NuiList(jT, JsonInt(2), 10.0, TRUE, NUI_SCROLLBARS_NONE), 300.0), 120.0), 0.0);
    json jRoot = NuiMargin(NuiCol(JsonArrayInsert(JsonArray(), jList)), 0.0);
    PrbClose(oPC, "prb_cells");
    NuiCreate(oPC, PrbWindow(jRoot, "cells 40/100/40", 20.0, 20.0, 400.0, 260.0), "prb_cells");
    WriteTimestampedLogEntry("prb_cells sent");
}
