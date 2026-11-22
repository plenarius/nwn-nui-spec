// prb_rowh: four lists of 12 rows, row_height 20, 40, 60 and 90, each row
// filled green or red. Measure a row's height and the pitch from one row's
// top to the next. NUI-MOBILE-022, NUI-LIST-001..003; T59.
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

void Open(object oPC, string sId, float fRowH, int i)
{
    json jDraw = JsonArrayInsert(JsonArray(), NuiDrawListRect(JsonBool(TRUE), NuiBind("c"), JsonBool(TRUE), JsonFloat(0.0),
                                                              NuiRect(0.0, 0.0, 2000.0, 2000.0)));
    json jCell = NuiMargin(NuiDrawList(NuiSpacer(), JsonBool(TRUE), jDraw), 0.0);
    json jT = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jCell, 120.0, FALSE));
    json jList = NuiMargin(NuiList(jT, NuiBind("n"), fRowH), 0.0);
    json jCol = NuiMargin(NuiCol(JsonArrayInsert(JsonArray(), jList)), 0.0);
    PrbClose(oPC, sId);
    int n = NuiCreate(oPC, PrbWindow(jCol, sId, (10.0 + 200.0 * IntToFloat(i)) / PrbFactor(oPC), 10.0, 180.0, 330.0), sId);
    json a = JsonArray();
    int k;
    for (k = 0; k < 12; k++) a = JsonArrayInsert(a, k % 2 ? NuiColor(255, 0, 0) : NuiColor(0, 255, 0));
    NuiSetBind(oPC, n, "c", a);
    NuiSetBind(oPC, n, "n", JsonInt(12));
}
void main()
{
    object oPC = PrbPlayer();
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_rowh: no player"); return; }
    Open(oPC, "r20", 20.0, 0);
    Open(oPC, "r40", 40.0, 1);
    Open(oPC, "r60", 60.0, 2);
    Open(oPC, "r90", 90.0, 3);
    WriteTimestampedLogEntry("prb_rowh sent");
}
