#include %A_LineFile%\..\IC_GameSettingsFix_Functions.ahk

global g_GSF_SettingsPath := A_LineFile . "\..\GameSettingsFix_Settings.json"
global g_GSF_ProfilesPath := A_LineFile . "\..\profiles\"

GUIFunctions.AddTab("Game Settings Fix")
global g_GameSettingsFix := new IC_GameSettingsFix_Component
global g_GSF_Running := false
global g_GSF_StatusText

Gui, ICScriptHub:Tab, Game Settings Fix
GUIFunctions.UseThemeTextColor("HeaderTextColor")
Gui, ICScriptHub:Add, Text, x15 y+15 vg_GSF_Header, Game Settings Fix:
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Button, x145 y+-18 w100 vg_GameSettingsFixSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_GameSettingsFix, "SaveSettings")
GuiControl,ICScriptHub: +g, g_GameSettingsFixSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x5 y+10 w130 +Right, Status:
Gui, ICScriptHub:Add, Text, x145 y+-13 w400 vg_GSF_StatusText, Waiting for Gem Farm to start

global g_GSF_col1w := 180
global g_GSF_col2w := 70
global g_GSF_col3w := 180
global g_GSF_col1x := 15
global g_GSF_col2x := 205
global g_GSF_col3x := 290
global g_GSF_ypos := 20
global g_GSF_xpos := 15

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h55, Profiles
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, xs%g_GSF_xpos% ys+24 w38 +Right, Profiles:
g_GSF_xpos += 48
Gui, ICScriptHub:Add, DDL, xs%g_GSF_xpos% y+-17 w150 vg_GSF_Profiles, 
g_GSF_xpos += 160
Gui, ICScriptHub:Add, Button, xs%g_GSF_xpos% y+-23 w80 vg_GameSettingsFixSaveProfile_Clicked, `Save Profile
buttonFunc := ObjBindMethod(g_GameSettingsFix, "SaveProfile")
GuiControl,ICScriptHub: +g, g_GameSettingsFixSaveProfile_Clicked, % buttonFunc
g_GSF_xpos += 90
Gui, ICScriptHub:Add, Button, xs%g_GSF_xpos% y+-24 w80 vg_GameSettingsFixLoadProfile_Clicked, `Load Profile
buttonFunc := ObjBindMethod(g_GameSettingsFix, "LoadProfile")
GuiControl,ICScriptHub: +g, g_GameSettingsFixLoadProfile_Clicked, % buttonFunc
g_GSF_xpos += 90
Gui, ICScriptHub:Add, Button, xs%g_GSF_xpos% y+-24 w80 vg_GameSettingsFixDeleteProfile_Clicked, `Delete Profile
buttonFunc := ObjBindMethod(g_GameSettingsFix, "DeleteProfile")
GuiControl,ICScriptHub: +g, g_GameSettingsFixDeleteProfile_Clicked, % buttonFunc

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+60 Section w500 h300, Settings
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, Setting
Gui, ICScriptHub:Add, Text, xs%g_GSF_col2x% ys%g_GSF_ypos% w%g_GSF_col2w%, Value
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% ys%g_GSF_ypos% w%g_GSF_col3w%, Recommended
Gui, ICScriptHub:Font, w400
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_TargetFramerateH, TargetFramerate:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right vg_GSF_TargetFramerate, 600
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, 600 (Maybe more - maybe less)
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_PercentOfParticlesSpawnedH, PercentOfParticlesSpawned:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right vg_GSF_PercentOfParticlesSpawned, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, 0
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_resolution_xH, resolution_x:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right vg_GSF_resolution_x, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_resolution_yH, resolution_y:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right vg_GSF_resolution_y, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_resolution_fullscreenH, resolution_fullscreen:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_resolution_fullscreen,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_ReduceFramerateWhenNotInFocusH, ReduceFramerateWhenNotInFocus:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_ReduceFramerateWhenNotInFocus,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Unchecked
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_FormationSaveIncludeFeatsCheckH, FormationSaveIncludeFeatsCheck:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_FormationSaveIncludeFeatsCheck,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Unchecked
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_LevelupAmountIndexH, LevelupAmountIndex:
Gui, ICScriptHub:Add, DDL, xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% vg_GSF_LevelupAmountIndex, x1|x10|x25|x100|Next Upg||
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, Next Upg or x100 w/ Level Up Addon
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_UseConsolePortraitsH, UseConsolePortraits:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_UseConsolePortraits,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right vg_GSF_NarrowHeroBoxesH, NarrowHeroBoxes:
Gui, ICScriptHub:Add, Checkbox, xs%g_GSF_col2x% y+-13 vg_GSF_NarrowHeroBoxes,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+305 Section w500 h105 vg_GSF_InfoGroupBox, Info
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, xs15 ys+30 w125, Num Times Fixed Settings:
Gui, ICScriptHub:Add, Text, xs150 y+-13 w200 vg_GSF_NumTimesFixed, 0
Gui, ICScriptHub:Add, Text, xs15 y+15 w125, Settings File Location:
Gui, ICScriptHub:Add, Text, xs35 y+5 w450 vg_GSF_GameSettingsFileLocation, Unknown

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+110 Section w500 h65 vg_GSF_OnDemandGroupBox, On Demand
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Button, xs15 ys25 w100 vg_GameSettingsFixForceFix_Clicked, `Fix Settings Now
buttonFunc := ObjBindMethod(g_GameSettingsFix, "FixSettingsNow")
GuiControl,ICScriptHub: +g, g_GameSettingsFixForceFix_Clicked, % buttonFunc

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