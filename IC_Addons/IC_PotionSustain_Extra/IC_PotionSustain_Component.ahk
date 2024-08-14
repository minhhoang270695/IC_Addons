#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk
#include %A_LineFile%\..\IC_PotionSustain_Functions.ahk

global g_PS_SettingsPath := A_LineFile . "\..\PotionSustain_Settings.json"

GUIFunctions.AddTab("Potion Sustain")
global g_PotionSustain := new IC_PotionSustain_Component
global g_PS_Running := false
global g_PS_StatusText
global g_PS_ChestSmallThreshMin
global g_PS_ChestSmallThreshMax
global g_PS_AutomateThreshMin
global g_PS_AutomateThreshMax
global g_PS_Brackets := ["Anything Available","Smalls + Others","Mediums + Others","Larges + Others"]

Gui, ICScriptHub:Tab, Potion Sustain
GUIFunctions.UseThemeTextColor("HeaderTextColor")
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, Text, x15 y+15, Potion Sustain:
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Button, x145 y+-15 w100 vg_PotionSustainSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_PotionSustain, "SaveSettings")
GuiControl,ICScriptHub: +g, g_PotionSustainSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x5 y+10 w130 +Right, Status:
Gui, ICScriptHub:Add, Text, vg_PS_StatusText x145 y+-13 w400, Waiting for Gem Farm to start
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h115, Sustain Smalls
Gui, ICScriptHub:Add, Text, xs165 ys15 w50, Minimum
Gui, ICScriptHub:Add, Text, xs235 y+-13 w50, Maximum
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Small Potion Thresholds:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_PS_ChestSmallThreshMin xs160 y+-17 w60 +Right, 
Gui, ICScriptHub:Add, Edit, vg_PS_ChestSmallThreshMax xs230 y+-21 w60 +Right, 
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs300 y+-17, (For deciding to buy Silvers or Golds)
Gui, ICScriptHub:Add, Text, xs20 y+15 w130 +Right, Can Sustain Smalls:
Gui, ICScriptHub:Add, Text, vg_PS_AbleSustainSmallStatus xs160 y+-13 w300, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Currently Buying Silvers:
Gui, ICScriptHub:Add, Text, vg_PS_BuyingSilversStatus xs160 y+-13 w200, Unknown
Gui, ICScriptHub:Add, GroupBox, x15 ys120 Section w500 h270, Automate Modron Potions
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_EnableAlternating xs15 ys25, Enable automating potions in the modron?
Gui, ICScriptHub:Add, Text, xs165 y+10 w50, Minimum
Gui, ICScriptHub:Add, Text, xs235 y+-13 w50, Maximum
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Modron Potion Thresholds:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_PS_AutomateThreshMin xs160 y+-17 w60 +Right, 
Gui, ICScriptHub:Add, Edit, vg_PS_AutomateThreshMax xs230 y+-21 w60 +Right, 
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs15 y+10 w135 +Right vg_PS_SustainBracketHeader, Sustain Bracket:
Gui, ICScriptHub:Add, Text, vg_PS_SustainBracketStatus xs160 y+-13 w130, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Automation Status:
Gui, ICScriptHub:Add, Text, vg_PS_AutomationStatus xs160 y+-13 w330, Unknown
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_IncreaseSustainBracket xs15 y+15, Allow Increasing Sustain Bracket?
Gui, ICScriptHub:Add, Text, xs200 y+-13 w180 +Right, Increase Sustain Bracket Threshold:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_PS_IncreaseBracketThresh xs390 y+-17 w60 +Right, 
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_ForceSustainBracket xs15 y+10, Force Specific Sustain Bracket?
Gui, ICScriptHub:Add, Text, xs200 y+-13 w100 +Right, Sustain Bracket:
Gui, ICScriptHub:Add, DDL, xs310 y+-17 w140 vg_PS_SpecificSustainBracket, % g_PS_Brackets[1] "||" g_PS_Brackets[2] "|" g_PS_Brackets[3] "|" g_PS_Brackets[4] "|"
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_DisableSmalls xs15 y+20, Disable the use of Small potions?
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_DisableMediums xs245 y+-13, Disable the use of Medium potions?
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_DisableLarges xs15 y+15, Disable the use of Large potions?
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_DisableHuges xs245 y+-13, Disable the use of Huge potions?
GUIFunctions.UseThemeTextColor("TableTextColor")
Gui, ICScriptHub:Add, ListView, xs300 ys15 w190 h100 vg_PS_AutomateList, Priority|Alternating|Status
GUIFunctions.UseThemeListViewBackgroundColor("g_PS_AutomateList")
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, GroupBox, x15 ys275 Section w500 h140, Current Potion Amounts
Gui, ICScriptHub:Add, Text, xs20 ys+20 w130 +Right, Smalls:
Gui, ICScriptHub:Add, Text, vg_PS_SmallPotCountStatus xs160 y+-13 w60 +Right, Unknown
Gui, ICScriptHub:Add, Text, vg_PS_SmallPotWaxingStatus xs240 y+-13 w240, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Mediums:
Gui, ICScriptHub:Add, Text, vg_PS_MediumPotCountStatus xs160 y+-13 w60 +Right, Unknown
Gui, ICScriptHub:Add, Text, vg_PS_MediumPotWaxingStatus xs240 y+-13 w240, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Larges:
Gui, ICScriptHub:Add, Text, vg_PS_LargePotCountStatus xs160 y+-13 w60 +Right, Unknown
Gui, ICScriptHub:Add, Text, vg_PS_LargePotWaxingStatus xs240 y+-13 w240, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Huges:
Gui, ICScriptHub:Add, Text, vg_PS_HugePotCountStatus xs160 y+-13 w60 +Right, Unknown
Gui, ICScriptHub:Add, Text, vg_PS_HugePotWaxingStatus xs240 y+-13 w240, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Gem Hunters:
Gui, ICScriptHub:Add, Text, vg_PS_GemHunterPotCountStatus xs160 y+-13 w60 +Right, Unknown
Gui, ICScriptHub:Add, Text, vg_PS_GemHunterStatus xs240 y+-13 w240, Unknown

;Gui, ICScriptHub:Add, Button, x145 y+25 w100 vg_Test_Clicked, `Test
;buttonFunc := ObjBindMethod(g_PotionSustain, "Test")
;GuiControl,ICScriptHub: +g, g_Test_Clicked, % buttonFunc

if(IsObject(IC_BrivGemFarm_Component))
{
	g_PotionSustain.InjectAddon()
}
else
{
	GuiControl, ICScriptHub:Text, g_PS_StatusText, WARNING: This addon needs IC_BrivGemFarm enabled.
	Gui, Submit, NoHide
	return
}

g_PotionSustain.Init()