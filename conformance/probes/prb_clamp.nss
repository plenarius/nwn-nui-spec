// prb_clamp: the density probe. Opens, for every player, a 300 x 150 window
// whose geometry is a watched bind set to x = y = 20000. The client clamps
// it into the screen's bottom-right corner and reports the clamped
// geometry back (a watch event, no input needed); prb_clampev computes the
// density from it. NUI-MOBILE-010..012; T56.
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
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        PrbClose(oPC, "prb_clamp");
        json jRoot = NuiCol(JsonArrayInsert(JsonArray(), NuiSpacer()));
        json jWin = NuiWindow(jRoot, JsonString("density probe"), NuiBind("geometry"), JsonBool(FALSE), JsonNull(),
                              JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
        int n = NuiCreate(oPC, jWin, "prb_clamp", "prb_clampev");
        NuiSetBind(oPC, n, "geometry", NuiRect(20000.0, 20000.0, 300.0, 150.0));
        NuiSetBindWatch(oPC, n, "geometry", TRUE);
        WriteTimestampedLogEntry("prb_clamp sent " + GetPCPlayerName(oPC)
            + " platform " + IntToString(GetPlayerDevicePlatform(oPC))
            + " gui " + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH))
            + "x" + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT))
            + " gui_scale " + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)));
        oPC = GetNextPC();
    }
}
