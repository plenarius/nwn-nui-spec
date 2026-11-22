// prb_image: base-game images by type, each 64 x 100 (NUI_ASPECT_EXACT)
// over its label. Top row: NuiImage of three names that exist only as TGA
// and one that exists as TGA and DDS. Bottom row: a PNG, a JPG, a GIF, and
// a draw-list image of the first TGA-only name. No image is shipped with
// the probe; all are base-game resources.
// NUI-MOBILE-050, NUI-IMAGE-010; T70.
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

json Cell(string sLabel, json jImg)
{
    json jC = JsonArray();
    jC = JsonArrayInsert(jC, NuiMargin(NuiHeight(NuiWidth(jImg, 64.0), 100.0), 0.0));
    jC = JsonArrayInsert(jC, NuiMargin(NuiHeight(NuiWidth(NuiLabel(JsonString(sLabel), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_TOP)), 90.0), 40.0), 0.0));
    return NuiMargin(NuiWidth(NuiCol(jC), 90.0), 0.0);
}
json Img(string sRes) { return NuiImage(JsonString(sRes), JsonInt(NUI_ASPECT_EXACT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)); }
json Drawn(object oPC, string sRes)
{
    float f = PrbFactor(oPC);
    json jD = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), JsonString(sRes), NuiRect(0.0, 0.0, 64.0 / f, 100.0 / f),
                                                            JsonInt(NUI_ASPECT_EXACT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    return NuiDrawList(NuiSpacer(), JsonBool(TRUE), jD);
}
void main()
{
    object oPC = PrbPlayer();
    if (!GetIsObjectValid(oPC)) { WriteTimestampedLogEntry("prb_image: no player"); return; }
    json jTop = JsonArray();
    jTop = JsonArrayInsert(jTop, Cell("TGA portrait", Img("po_hu_m_21_l")));
    jTop = JsonArrayInsert(jTop, Cell("TGA icon", Img("is_bless")));
    jTop = JsonArrayInsert(jTop, Cell("TGA gui", Img("gui_pal_hair01")));
    jTop = JsonArrayInsert(jTop, Cell("TGA+DDS", Img("gui_mp_defaultu")));
    json jBot = JsonArray();
    jBot = JsonArrayInsert(jBot, Cell("PNG", Img("nwnlogo_blue")));
    jBot = JsonArrayInsert(jBot, Cell("JPG", Img("nwn_header_ari")));
    jBot = JsonArrayInsert(jBot, Cell("GIF", Img("gui_loading")));
    jBot = JsonArrayInsert(jBot, Cell("TGA drawn", Drawn(oPC, "po_hu_m_21_l")));
    json jCol = JsonArray();
    jCol = JsonArrayInsert(jCol, NuiMargin(NuiRow(jTop), 0.0));
    jCol = JsonArrayInsert(jCol, NuiMargin(NuiRow(jBot), 0.0));
    PrbClose(oPC, "prb_image");
    NuiCreate(oPC, PrbWindow(NuiMargin(NuiCol(jCol), 0.0), "images", 20.0, 20.0, 400.0, 340.0), "prb_image");
    WriteTimestampedLogEntry("prb_image sent");
}
