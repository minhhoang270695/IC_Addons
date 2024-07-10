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

global g_GSF_col1w := 180
global g_GSF_col2w := 70
global g_GSF_col3w := 180
global g_GSF_col1x := 15
global g_GSF_col2x := 205
global g_GSF_col3x := 290
global g_GSF_ypos := 20

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h335, Settings
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, Setting
Gui, ICScriptHub:Add, Text, xs%g_GSF_col2x% ys%g_GSF_ypos% w%g_GSF_col2w%, Value
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% ys%g_GSF_ypos% w%g_GSF_col3w%, Recommended
Gui, ICScriptHub:Font, w400
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, TargetFramerate:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_GSF_TargetFramerate xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right, 600
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, 600 (Maybe more - maybe less)
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, PercentOfParticlesSpawned:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_GSF_PercentOfParticlesSpawned xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, 0
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, resolution_x:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_GSF_resolution_x xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, resolution_y:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_GSF_resolution_y xs%g_GSF_col2x% y+-17 w%g_GSF_col2w% +Right, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, resolution_fullscreen:
Gui, ICScriptHub:Add, Checkbox, vg_GSF_resolution_fullscreen xs%g_GSF_col2x% y+-13,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, ReduceFramerateWhenNotInFocus:
Gui, ICScriptHub:Add, Checkbox, vg_GSF_ReduceFramerateWhenNotInFocus xs%g_GSF_col2x% y+-13,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Unchecked
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, FormationSaveIncludeFeatsCheck:
Gui, ICScriptHub:Add, Checkbox, vg_GSF_FormationSaveIncludeFeatsCheck xs%g_GSF_col2x% y+-13,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Unchecked
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, LevelupAmountIndex:
Gui, ICScriptHub:Add, DDL, vg_GSF_LevelupAmountIndex xs%g_GSF_col2x% y+-17 w%g_GSF_col2w%, x1|x10|x25|x100|Next Upg||
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-17 w%g_GSF_col3w%, Next Upg or x100 w/ Level Up Addon
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, UseConsolePortraits:
Gui, ICScriptHub:Add, Checkbox, vg_GSF_UseConsolePortraits xs%g_GSF_col2x% y+-13,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, NarrowHeroBoxes:
Gui, ICScriptHub:Add, Checkbox, vg_GSF_NarrowHeroBoxes xs%g_GSF_col2x% y+-13,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference
g_GSF_ypos += 25
Gui, ICScriptHub:Add, Text, xs%g_GSF_col1x% ys%g_GSF_ypos% w%g_GSF_col1w% +Right, SoundMuted:
Gui, ICScriptHub:Add, Checkbox, Checked vg_GSF_SoundMuted xs%g_GSF_col2x% y+-13,
Gui, ICScriptHub:Add, Text, xs%g_GSF_col3x% y+-13 w%g_GSF_col3w%, Personal Preference

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+340 Section w500 h95, Info
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