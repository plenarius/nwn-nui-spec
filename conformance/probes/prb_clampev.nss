// prb_clampev: prb_clamp's event script. On the watch event with the
// clamped geometry: d = (GUI_WIDTH - w * s) / x. Stores d on the player as
// PRB_DENSITY (the other probes read it), logs it, closes the window.
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
    object oPC = NuiGetEventPlayer();
    int nToken = NuiGetEventWindow();
    if (NuiGetEventType() != "watch") return;
    json g = NuiGetBind(oPC, nToken, "geometry");
    float x = JsonGetFloat(JsonObjectGet(g, "x"));
    float w = JsonGetFloat(JsonObjectGet(g, "w"));
    if (x <= 0.0 || x >= 20000.0) return;                 // not the clamped report
    float s = PrbScale(oPC);
    float fGuiW = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH));
    float d = (fGuiW - w * s) / x;
    SetLocalFloat(oPC, "PRB_DENSITY", d);
    WriteTimestampedLogEntry("prb_clamp report " + GetPCPlayerName(oPC) + " geometry " + JsonDump(g)
        + " s " + FloatToString(s, 0, 2) + " d " + FloatToString(d, 0, 3) + " d/s " + FloatToString(d / s, 0, 3));
    NuiDestroy(oPC, nToken);
}
