// prb_draw: the same drawing in a list cell (A: row_height 60, cell 100)
// and in a plain 100 x 60 element (B): a green rect 0..10 and a red rect
// 20..30 tall, 100 wide, and a blue 1-px outline 100 x 60, unclipped.
// Measure the rects' heights in pixels. NUI-MOBILE-025; T62.
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

json Rects()
{
    json j = JsonArray();
    j = JsonArrayInsert(j, NuiDrawListRect(JsonBool(TRUE), NuiColor(0, 255, 0), JsonBool(TRUE), JsonFloat(0.0), NuiRect(0.0, 0.0, 100.0, 10.0)));
    j = JsonArrayInsert(j, NuiDrawListRect(JsonBool(TRUE), NuiColor(255, 0, 0), JsonBool(TRUE), JsonFloat(0.0), NuiRect(0.0, 20.0, 100.0, 10.0)));
    j = JsonArrayInsert(j, NuiDrawListRect(JsonBool(TRUE), NuiColor(0, 0, 255), JsonBool(FALSE), JsonFloat(1.0), NuiRect(0.0, 0.0, 100.0, 60.0)));
    return j;
}
void main()
{
    object oPC = PrbPlayer();
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_draw: no player"); return; }
    PrbClose(oPC, "prb_drawa"); PrbClose(oPC, "prb_drawb");
    json jCell = NuiMargin(NuiDrawList(NuiSpacer(), JsonBool(FALSE), Rects()), 0.0);
    json jList = NuiMargin(NuiList(JsonArrayInsert(JsonArray(), NuiListTemplateCell(jCell, 100.0, FALSE)), JsonInt(2), 60.0), 0.0);
    NuiCreate(oPC, PrbWindow(NuiMargin(NuiCol(JsonArrayInsert(JsonArray(), jList)), 0.0), "A list", 10.0, 10.0, 160.0, 330.0), "prb_drawa");
    json jSp = NuiMargin(NuiHeight(NuiWidth(NuiDrawList(NuiSpacer(), JsonBool(FALSE), Rects()), 100.0), 60.0), 0.0);
    NuiCreate(oPC, PrbWindow(NuiMargin(NuiCol(JsonArrayInsert(JsonArray(), jSp)), 0.0), "B plain", 200.0 / PrbFactor(oPC), 10.0, 160.0, 200.0), "prb_drawb");
    WriteTimestampedLogEntry("prb_draw sent");
}
