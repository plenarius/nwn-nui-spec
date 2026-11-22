// prb_listimg: three lists of six rows side by side, rows 32 high, each row
// an icon cell (32 wide), a flexible name and a fixed 50 count, with the row
// height and cell widths divided by d (NUI-MOBILE-020) so the rows are 32 on
// any client. A: the icon as an image element (NuiImage) in the cell. B: no
// icon cell. C: the icon as a draw-list image on a spacer cell. On iOS, A
// draws no icons and its labels run together; B and C draw correctly.
// NUI-MOBILE-029; T75. Run prb_clamp first.
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

// nIcon: 0 an image element, 1 none, 2 a draw-list image on a spacer.
json PrbTemplate(int nIcon, float fD)
{
    json jT = JsonArray();
    json jIcon;
    if (nIcon == 0)
        jIcon = NuiImage(NuiBind("icon"), JsonInt(NUI_ASPECT_FIT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
    else if (nIcon == 2)
        jIcon = NuiDrawList(NuiSpacer(), JsonBool(TRUE), JsonArrayInsert(JsonArray(),
                NuiDrawListImage(JsonBool(TRUE), NuiBind("icon"), NuiRect(0.0, 0.0, 32.0 / fD, 32.0 / fD),
                                 JsonInt(NUI_ASPECT_FIT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE))));
    if (nIcon != 1)
        jT = JsonArrayInsert(jT, NuiListTemplateCell(NuiMargin(jIcon, 0.0), 32.0 / fD, FALSE));
    jT = JsonArrayInsert(jT, NuiListTemplateCell(NuiMargin(NuiLabel(NuiBind("name"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 0.0), 0.0, TRUE));
    jT = JsonArrayInsert(jT, NuiListTemplateCell(NuiMargin(NuiLabel(NuiBind("count"), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 0.0), 50.0 / fD, FALSE));
    return jT;
}

void PrbOpen(object oPC, int nIcon, string sId, string sTitle, float fX)
{
    float fD = PrbDensity(oPC);
    json jList = NuiMargin(NuiHeight(NuiList(PrbTemplate(nIcon, fD), NuiBind("rows"), 32.0 / fD), 240.0), 0.0);
    json jRoot = NuiMargin(NuiCol(JsonArrayInsert(JsonArray(), jList)), 0.0);
    PrbClose(oPC, sId);
    int n = NuiCreate(oPC, PrbWindow(jRoot, sTitle, fX / PrbFactor(oPC), 10.0, 320.0, 340.0), sId);
    // Base-game icons that exist as more than a TGA, so they draw on every client (NUI-MOBILE-050).
    NuiSetBind(oPC, n, "icon", JsonParse("[\"gui_mp_defaultu\",\"gui_mp_defaultu\",\"gui_mp_defaultu\",\"gui_mp_defaultu\",\"gui_mp_defaultu\",\"gui_mp_defaultu\"]"));
    NuiSetBind(oPC, n, "name", JsonParse("[\"One\",\"Two\",\"Three\",\"Four\",\"Five\",\"Six\"]"));
    NuiSetBind(oPC, n, "count", JsonParse("[\"1/6\",\"2/6\",\"3/6\",\"4/6\",\"5/6\",\"6/6\"]"));
    NuiSetBind(oPC, n, "rows", JsonInt(6));
}

void main()
{
    object oPC = PrbPlayer();
    PrbOpen(oPC, 0, "prb_limga", "A image element", 10.0);
    PrbOpen(oPC, 1, "prb_limgb", "B no icon", 350.0);
    PrbOpen(oPC, 2, "prb_limgc", "C draw-list icon", 690.0);
    WriteTimestampedLogEntry("prb_listimg sent; density " + FloatToString(PrbDensity(oPC), 0, 3));
}
