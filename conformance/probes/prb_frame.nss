// prb_frame: the window frame's extra size. A two-row settings window,
// content 360 x 72, margin 0 everywhere (a "Theme" label 52, a gap 8 and
// a combo 300 in a row 36; a gap 240 and a "Close" button 120 in a row
// 36), opened 8 times with geometry = content + the desktop frame
// (16 x 49) + an extra on one axis:
//   axis "w" (default): extra width start, start + step, ... (default 8, 4),
//                       height + 80;
//   axis "h":           extra height start, ... (default 8, 8), width + 60.
// Script parameters "axis", "start", "step" (ExecuteScript + SetScriptParam).
// The first window with no horizontal (axis w) or vertical (axis h)
// scrollbar is the fit. NUI-MOBILE-030, NUI-WINDOW-010; T65.
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

json Content()
{
    json jEntries = JsonArrayInsert(JsonArray(), NuiComboEntry("First", 0));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry("Second", 1));
    json jRow1 = JsonArray();
    jRow1 = JsonArrayInsert(jRow1, NuiMargin(NuiHeight(NuiWidth(NuiLabel(JsonString("Theme"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 52.0), 36.0), 0.0));
    jRow1 = JsonArrayInsert(jRow1, NuiMargin(NuiHeight(NuiWidth(NuiSpacer(), 8.0), 36.0), 0.0));
    jRow1 = JsonArrayInsert(jRow1, NuiMargin(NuiHeight(NuiWidth(NuiCombo(jEntries, NuiBind("sel")), 300.0), 36.0), 0.0));
    json jRow2 = JsonArray();
    jRow2 = JsonArrayInsert(jRow2, NuiMargin(NuiHeight(NuiWidth(NuiSpacer(), 240.0), 36.0), 0.0));
    jRow2 = JsonArrayInsert(jRow2, NuiMargin(NuiHeight(NuiWidth(NuiButton(JsonString("Close")), 120.0), 36.0), 0.0));
    json jCol = JsonArray();
    jCol = JsonArrayInsert(jCol, NuiMargin(NuiHeight(NuiWidth(NuiRow(jRow1), 360.0), 36.0), 0.0));
    jCol = JsonArrayInsert(jCol, NuiMargin(NuiHeight(NuiWidth(NuiRow(jRow2), 360.0), 36.0), 0.0));
    return NuiMargin(NuiHeight(NuiWidth(NuiCol(jCol), 360.0), 72.0), 0.0);
}
void main()
{
    object oPC = PrbPlayer();
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_frame: no player"); return; }
    string sAxis = GetScriptParam("axis");
    if (sAxis != "h") sAxis = "w";
    float fStart = StringToFloat(GetScriptParam("start"));
    float fStep = StringToFloat(GetScriptParam("step"));
    if (GetScriptParam("start") == "") fStart = 8.0;
    if (fStep <= 0.0) fStep = sAxis == "w" ? 4.0 : 8.0;
    float f = PrbFactor(oPC);
    int i;
    for (i = 0; i < 8; i++)
    {
        float fExtra = fStart + fStep * IntToFloat(i);
        float fW = 376.0 + (sAxis == "w" ? fExtra : 60.0);
        float fH = 121.0 + (sAxis == "h" ? fExtra : 80.0);
        string sId = "prb_frame" + IntToString(i);
        PrbClose(oPC, sId);
        float fX = (10.0 + 470.0 * IntToFloat(i % 4)) / f;
        float fY = (10.0 + 260.0 * IntToFloat(i / 4)) / f;
        int n = NuiCreate(oPC, PrbWindow(Content(), sAxis + "+" + IntToString(FloatToInt(fExtra)), fX, fY, fW, fH), sId);
        NuiSetBind(oPC, n, "sel", JsonInt(0));
    }
    WriteTimestampedLogEntry("prb_frame sent axis " + sAxis + " start " + FloatToString(fStart, 0, 1) + " step " + FloatToString(fStep, 0, 1)
        + " gui_scale " + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)));
}
