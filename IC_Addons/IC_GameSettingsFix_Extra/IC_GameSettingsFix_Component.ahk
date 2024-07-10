#include %A_LineFile%\..\IC_GameSettingsFix_Functions.ahk

global g_GSF_SettingsPath := A_LineFile . "\..\GameSettingsFix_Settings.json"

GUIFunctions.AddTab("Game Settings Fix")
global g_GameSettingsFix := new IC_GameSettingsFix_Component
global g_GSF_Running := false
global g_GSF_StatusText

Gui, ICScriptHub:Tab, Game Settings Fix
GUIFunctions.UseThemeTextColor("HeaderTextColor")
Gui, ICScriptHub:Add, Text, x15 y+15, Game Settings Fix:
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Button, x145 y+-15 w100 vg_GameSettingsFixSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_GameSettingsFix, "SaveSettings")
GuiControl,ICScriptHub: +g, g_GameSettingsFixSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x5 y+10 w130 +Right, Status:
Gui, ICScriptHub:Add, Text, vg_GSF_StatusText x145 y+-13 w400, Waiting for Gem Farm to start

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h240, Settings
Gui, ICScriptHub:Add, Text, xs15 ys20 w200 +Right, Setting
Gui, ICScriptHub:Add, Text, xs225 ys20 w200, Value
Gui, ICScriptHub:Add, Text, xs305 ys20 w150, Recommended
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, xs15 ys45 w200 +Right, TargetFramerate:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_GSF_TargetFramerate xs225 y+-17 w60 +Right, 600
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs305 y+-17 w150, 600 (Maybe more - maybe less)
Gui, ICScriptHub:Add, Text, xs15 y+15 w200 +Right, PercentOfParticlesSpawned:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_GSF_PercentOfParticlesSpawned xs225 y+-17 w60 +Right, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs305 y+-17 w150, 0
Gui, ICScriptHub:Add, Text, xs15 y+15 w200 +Right, ReduceFramerateWhenNotInFocus:
Gui, ICScriptHub:Add, Checkbox, vg_GSF_ReduceFramerateWhenNotInFocus xs225 y+-13,
Gui, ICScriptHub:Add, Text, xs305 y+-13 w150, Unchecked
Gui, ICScriptHub:Add, Text, xs15 y+15 w200 +Right, FormationSaveIncludeFeatsCheck:
Gui, ICScriptHub:Add, Checkbox, vg_GSF_FormationSaveIncludeFeatsCheck xs225 y+-13,
Gui, ICScriptHub:Add, Text, xs305 y+-13 w150, Unchecked
Gui, ICScriptHub:Add, Text, xs15 y+15 w200 +Right, UseConsolePortraits:
Gui, ICScriptHub:Add, Checkbox, vg_GSF_UseConsolePortraits xs225 y+-13,
Gui, ICScriptHub:Add, Text, xs305 y+-13 w150, Personal Preference
Gui, ICScriptHub:Add, Text, xs15 y+15 w200 +Right, NarrowHeroBoxes:
Gui, ICScriptHub:Add, Checkbox, vg_GSF_NarrowHeroBoxes xs225 y+-13,
Gui, ICScriptHub:Add, Text, xs305 y+-13 w150, Personal Preference
Gui, ICScriptHub:Add, Text, xs15 y+15 w200 +Right, SoundMuted:
Gui, ICScriptHub:Add, Checkbox, Checked vg_GSF_SoundMuted xs225 y+-13,
Gui, ICScriptHub:Add, Text, xs305 y+-13 w150, Personal Preference

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+245 Section w500 h95, Info
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, xs15 ys+20 w125, Settings File Location:
Gui, ICScriptHub:Add, Text, xs35 y+5 w450 vg_GSF_GameSettingsFileLocation, Unknown
Gui, ICScriptHub:Add, Text, xs15 y+15 w125, Num Times Fixed Settings:
Gui, ICScriptHub:Add, Text, xs150 y+-13 w200 vg_GSF_NumTimesFixed, 0

if(IsObject(IC_BrivGemFarm_Component))
{
	g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_GameSettingsFix, "CreateTimedFunctions"))
	g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_GameSettingsFix, "StartTimedFunctions"))
	g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(g_GameSettingsFix, "StopTimedFunctions"))
}
else
{
	GuiControl, ICScriptHub:Text, g_GSF_StatusText, WARNING: This addon needs IC_BrivGemFarm enabled.
	Gui, Submit, NoHide
	return
}

g_GameSettingsFix.Init()