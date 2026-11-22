// prb_device: logs each player's build, platform and display properties.
// NUI-MOBILE-001, -012, -040; T54, T69. No window.
// CC0 1.0 (nwn-nui-spec conformance). Needs no include.

void main()
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        string s = "prb_device " + GetPCPlayerName(oPC)
                 + " build " + IntToString(GetPlayerBuildVersionMajor(oPC)) + "." + IntToString(GetPlayerBuildVersionMinor(oPC))
                 + "-" + IntToString(GetPlayerBuildVersionPostfix(oPC))
                 + " platform " + IntToString(GetPlayerDevicePlatform(oPC))
                 + " gui " + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH))
                 + "x" + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT))
                 + " gui_scale " + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE))
                 + " ui.scale " + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_UI_SCALE))
                 + " ui.large-font " + IntToString(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_UI_LARGE_FONT));
        WriteTimestampedLogEntry(s);
        oPC = GetNextPC();
    }
}
