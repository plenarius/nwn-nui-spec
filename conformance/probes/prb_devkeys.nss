// prb_devkeys: asks GetPlayerDeviceProperty for guessed keys that might
// tell a touch or high-density client apart. NUI-MOBILE-002; T55. No window.
// The keys are guesses; nwscript.nss documents none of them. -1 means
// "no such property".
// CC0 1.0 (nwn-nui-spec conformance). Needs no include.

void main()
{
    string sKeys = "ui.unconstrain-scale,window.scaler,ui.font.pixel-height,ui.font.pixel-snap,"
                 + "graphics.window.highdpi,graphics.video.highdpi,graphics.highdpi,window.highdpi,window.high-dpi,"
                 + "graphics.video.high-dpi,window.retina,graphics.retina,window.display-scale,window.pixel-density,"
                 + "ui.dpi-scale,graphics.display.dpi,input.touch.enabled,input.touch,input.touch.mode,ui.touch,"
                 + "ui.touch.enabled,ui.mobile,device.platform,input.controller.enabled,input.gamepad.enabled,"
                 + "input.joystick.enabled,ui.virtual-joystick,input.virtual-joystick.enabled,ui.touch.radial,"
                 + "graphics.video.mode,graphics.window.width,window.width,window.height,graphics.video.width";
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        string sOut = GetPCPlayerName(oPC) + " platform " + IntToString(GetPlayerDevicePlatform(oPC));
        string s = sKeys + ",";
        int i = FindSubString(s, ",");
        while (i >= 0)
        {
            string k = GetStringLeft(s, i);
            sOut += " | " + k + "=" + IntToString(GetPlayerDeviceProperty(oPC, k));
            s = GetStringRight(s, GetStringLength(s) - i - 1);
            i = FindSubString(s, ",");
        }
        WriteTimestampedLogEntry("prb_devkeys " + sOut);
        oPC = GetNextPC();
    }
}
