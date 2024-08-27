#include %A_LineFile%\..\IC_EGSOverlaySwatter_Functions.ahk

global g_EGSOS_SettingsPath := A_LineFile . "\..\EGSOverlaySwatter_Settings.json"

GUIFunctions.AddTab("EGS Overlay Swatter")
global g_EGSOverlaySwatter := new IC_EGSOverlaySwatter_Component
global g_EGSOS_Running := false
global g_EGSOS_StatusText

Gui, ICScriptHub:Tab, EGS Overlay Swatter
GUIFunctions.UseThemeTextColor("HeaderTextColor")
Gui, ICScriptHub:Add, Text, x15 y+15, EGS Overlay Swatter:
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Button, x145 y+-15 w100 vg_EGSOverlaySwatterSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_EGSOverlaySwatter, "SaveSettings")
GuiControl,ICScriptHub: +g, g_EGSOverlaySwatterSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x5 y+10 w130 +Right, Status:
Gui, ICScriptHub:Add, Text, x145 y+-13 w400 vg_EGSOS_StatusText, Waiting for Gem Farm to start

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h180 vg_EGSOS_SettingsGroupBox, Settings
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, xs15 ys+30 vg_EGSOS_DisableOverlay, Disable EGS Overlay?
Gui, ICScriptHub:Add, Text, xs15 y+15 w200 vg_EGSOS_EGSFolderLocationH, EGS Install Folder:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs25 y+10 w450 r3 vg_EGSOS_EGSFolderLocation, 0
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Checkbox, xs15 y+15 vg_EGSOS_CheckDefaultFolder, Also Check Default Folder?  (C:\Program Files (x86)\Epic Games)

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+185 Section w500 h190 vg_EGSOS_InfoGroupBox, Info
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, xs15 ys+30 w110 +Right vg_EGSOS_OverlayStatusH, Current Overlay Status:
Gui, ICScriptHub:Add, Text, xs130 y+-13 w350 vg_EGSOS_OverlayStatus, Unknown
GUIFunctions.UseThemeTextColor("TableTextColor")
Gui, ICScriptHub:Add, ListView, xs15 y+15 w470 r5 vg_EGSOS_OverlayFilesList, Overlay Files
GUIFunctions.UseThemeListViewBackgroundColor("g_EGSOS_OverlayFilesList")
GUIFunctions.UseThemeTextColor("DefaultTextColor")

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+195 Section w500 h65, On Demand
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Button, xs15 ys25 w150 vg_EGSOverlaySwatterEnableNow_Clicked, `Enable Overlay Now
buttonFunc := ObjBindMethod(g_EGSOverlaySwatter, "RestoreOverlayFilesNow")
GuiControl,ICScriptHub: +g, g_EGSOverlaySwatterEnableNow_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Button, x+10 ys25 w150 vg_EGSOverlaySwatterDisableNow_Clicked, `Disable Overlay Now
buttonFunc := ObjBindMethod(g_EGSOverlaySwatter, "SwatOverlayFilesNow")
GuiControl,ICScriptHub: +g, g_EGSOverlaySwatterDisableNow_Clicked, % buttonFunc

if(IsObject(IC_BrivGemFarm_Component))
{
	g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_EGSOverlaySwatter, "CreateTimedFunctions"))
	g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_EGSOverlaySwatter, "StartTimedFunctions"))
	g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_EGSOverlaySwatter, "GetPlatformID"))
	g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(g_EGSOverlaySwatter, "StopTimedFunctions"))
}
else
{
	GuiControl, ICScriptHub:Text, g_EGSOS_StatusText, WARNING: This addon needs IC_BrivGemFarm enabled.
	Gui, Submit, NoHide
	return
}

g_EGSOverlaySwatter.Init()