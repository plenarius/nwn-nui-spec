// prb_button: 200-wide buttons, margin 0, each alone in a row 8 taller
// than it: height 32 with the default padding, padding 0 and padding 2,
// then heights 36, 38, 40 and 44. See where the frame is drawn and where
// the label sits. NUI-MOBILE-031; T66.
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

json Btn(string sLabel, float fH, float fPad)
{
    json j = NuiMargin(NuiHeight(NuiWidth(NuiButton(JsonString(sLabel)), 200.0), fH), 0.0);
    if (fPad >= 0.0) j = JsonObjectSet(j, "padding", JsonFloat(fPad));
    return j;
}
json Row(json jE, float fH) { return NuiMargin(NuiHeight(NuiRow(JsonArrayInsert(JsonArray(), jE)), fH), 0.0); }
void main()
{
    object oPC = PrbPlayer();
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_button: no player"); return; }
    json jCol = JsonArray();
    jCol = JsonArrayInsert(jCol, Row(Btn("Close h 32", 32.0, -1.0), 40.0));
    jCol = JsonArrayInsert(jCol, Row(Btn("Close pad 0", 32.0, 0.0), 40.0));
    jCol = JsonArrayInsert(jCol, Row(Btn("Close pad 2", 32.0, 2.0), 40.0));
    jCol = JsonArrayInsert(jCol, Row(Btn("Close h 36", 36.0, -1.0), 44.0));
    jCol = JsonArrayInsert(jCol, Row(Btn("Close h 38", 38.0, -1.0), 46.0));
    jCol = JsonArrayInsert(jCol, Row(Btn("Close h 40", 40.0, -1.0), 48.0));
    jCol = JsonArrayInsert(jCol, Row(Btn("Close h 44", 44.0, -1.0), 52.0));
    json jRoot = NuiMargin(NuiCol(jCol), 0.0);
    PrbClose(oPC, "prb_button");
    NuiCreate(oPC, PrbWindow(jRoot, "buttons", 10.0, 10.0, 300.0, 420.0), "prb_button");
    WriteTimestampedLogEntry("prb_button sent");
}
