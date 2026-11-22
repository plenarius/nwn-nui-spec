// prb_margin: a 48 x lblH label in a row of fixed height rowH, the row and
// its column margin 0, the window sized to the content (desktop frame
// 16 x 49). Ten windows: the label's margin default, 0, 2, 3 or 4.
// NUI-MOBILE-021, NUI-LAYOUT-001, -010, -015; T57.
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

void Open(object oPC, string sId, float fRowH, float fLblH, float fMargin, int i)
{
    float f = PrbFactor(oPC);
    json jLbl = NuiHeight(NuiWidth(NuiLabel(JsonString("Theme"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 48.0), fLblH);
    if (fMargin >= 0.0) jLbl = NuiMargin(jLbl, fMargin);
    json jRow = NuiMargin(NuiHeight(NuiWidth(NuiRow(JsonArrayInsert(JsonArray(), jLbl)), 360.0), fRowH), 0.0);
    json jCol = NuiMargin(NuiHeight(NuiWidth(NuiCol(JsonArrayInsert(JsonArray(), jRow)), 360.0), fRowH), 0.0);
    float fX = (20.0 + 400.0 * IntToFloat(i % 4)) / f;
    float fY = (20.0 + 120.0 * IntToFloat(i / 4)) / f;
    PrbClose(oPC, sId);
    NuiCreate(oPC, PrbWindow(jCol, sId, fX, fY, 376.0, fRowH + 49.0), sId);
}
void main()
{
    object oPC = PrbPlayer();
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_margin: no player"); return; }
    Open(oPC, "c1 row36 lbl32",     36.0, 32.0, -1.0, 0);
    Open(oPC, "c2 row40 lbl32",     40.0, 32.0, -1.0, 1);
    Open(oPC, "c3 row44 lbl32",     44.0, 32.0, -1.0, 2);
    Open(oPC, "c4 row48 lbl32",     48.0, 32.0, -1.0, 3);
    Open(oPC, "c5 row36 lbl28",     36.0, 28.0, -1.0, 4);
    Open(oPC, "c6 row36 lbl32 m0",  36.0, 32.0,  0.0, 5);
    Open(oPC, "d1 row36 lbl32 m2",  36.0, 32.0,  2.0, 6);
    Open(oPC, "d2 row40 lbl32 m4",  40.0, 32.0,  4.0, 7);
    Open(oPC, "d3 row38 lbl32 m3",  38.0, 32.0,  3.0, 8);
    Open(oPC, "d4 row42 lbl32 def", 42.0, 32.0, -1.0, 9);
    WriteTimestampedLogEntry("prb_margin sent; factor " + FloatToString(PrbFactor(oPC), 0, 3));
}
