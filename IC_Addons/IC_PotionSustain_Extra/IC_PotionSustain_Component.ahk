#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk
#include %A_LineFile%\..\IC_PotionSustain_Functions.ahk
#include %A_LineFile%\..\IC_PotionSustain_Overrides.ahk

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
Gui, ICScriptHub:Add, Text, x145 y+-13 w400 vg_PS_StatusText, Waiting for Gem Farm to start
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h90, Sustain Smalls
Gui, ICScriptHub:Add, Text, xs165 ys15 w50, Minimum
Gui, ICScriptHub:Add, Text, xs235 y+-13 w50, Maximum
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Small Potion Thresholds:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs160 y+-17 w60 +Right vg_PS_ChestSmallThreshMin, 
Gui, ICScriptHub:Add, Edit, xs230 y+-21 w60 +Right vg_PS_ChestSmallThreshMax, 
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs300 y+-17, (For deciding to buy Silvers or Golds)
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Currently Buying Silvers:
Gui, ICScriptHub:Add, Text, xs160 y+-13 w200 vg_PS_BuyingSilversStatus, Unknown
Gui, ICScriptHub:Add, GroupBox, x15 ys95 Section w500 h270, Automate Modron Potions
Gui, ICScriptHub:Add, Checkbox, xs15 ys25 vg_PS_Checkbox_EnableAlternating, Enable automating potions in the modron?
Gui, ICScriptHub:Add, Text, xs165 y+10 w50, Minimum
Gui, ICScriptHub:Add, Text, xs235 y+-13 w50, Maximum
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Modron Potion Thresholds:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs160 y+-17 w60 +Right vg_PS_AutomateThreshMin, 
Gui, ICScriptHub:Add, Edit, xs230 y+-21 w60 +Right vg_PS_AutomateThreshMax, 
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs15 y+10 w135 +Right vg_PS_SustainBracketHeader, Sustain Bracket:
Gui, ICScriptHub:Add, Text, xs160 y+-13 w130 vg_PS_SustainBracketStatus, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Automation Status:
Gui, ICScriptHub:Add, Text, xs160 y+-13 w330 vg_PS_AutomationStatus, Unknown
Gui, ICScriptHub:Add, Checkbox, xs15 y+15 vg_PS_Checkbox_IncreaseSustainBracket, Allow Increasing Sustain Bracket?
Gui, ICScriptHub:Add, Text, xs210 y+-13 w100 +Right, ISB Thresholds:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, xs320 y+-17 w60 +Right vg_PS_IncreaseBracketThreshMin, 
Gui, ICScriptHub:Add, Edit, xs390 y+-21 w60 +Right vg_PS_IncreaseBracketThreshMax, 
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Checkbox, xs15 y+10 vg_PS_Checkbox_ForceSustainBracket, Force Specific Sustain Bracket?
Gui, ICScriptHub:Add, Text, xs210 y+-13 w100 +Right, Sustain Bracket:
Gui, ICScriptHub:Add, DDL, xs320 y+-17 w130 vg_PS_SpecificSustainBracket, % g_PS_Brackets[1] "||" g_PS_Brackets[2] "|" g_PS_Brackets[3] "|" g_PS_Brackets[4] "|"
Gui, ICScriptHub:Add, Checkbox, xs15 y+20 vg_PS_Checkbox_DisableSmalls, Disable the use of Small potions?
Gui, ICScriptHub:Add, Checkbox, xs245 y+-13 vg_PS_Checkbox_DisableMediums, Disable the use of Medium potions?
Gui, ICScriptHub:Add, Checkbox, xs15 y+15 vg_PS_Checkbox_DisableLarges, Disable the use of Large potions?
Gui, ICScriptHub:Add, Checkbox, xs245 y+-13 vg_PS_Checkbox_DisableHuges, Disable the use of Huge potions?
GUIFunctions.UseThemeTextColor("TableTextColor")
Gui, ICScriptHub:Add, ListView, xs300 ys15 w190 h100 vg_PS_AutomateList, Priority|Alternating|Status
GUIFunctions.UseThemeListViewBackgroundColor("g_PS_AutomateList")
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, GroupBox, x15 ys275 Section w500 h140, Current Potion Amounts
Gui, ICScriptHub:Add, Text, xs20 ys+20 w130 +Right, Smalls:
Gui, ICScriptHub:Add, Text, xs160 y+-13 w60 +Right vg_PS_SmallPotCountStatus, Unknown
Gui, ICScriptHub:Add, Text, xs240 y+-13 w240 vg_PS_SmallPotWaxingStatus, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Mediums:
Gui, ICScriptHub:Add, Text, xs160 y+-13 w60 +Right vg_PS_MediumPotCountStatus, Unknown
Gui, ICScriptHub:Add, Text, xs240 y+-13 w240 vg_PS_MediumPotWaxingStatus, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Larges:
Gui, ICScriptHub:Add, Text, xs160 y+-13 w60 +Right vg_PS_LargePotCountStatus, Unknown
Gui, ICScriptHub:Add, Text, xs240 y+-13 w240 vg_PS_LargePotWaxingStatus, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Huges:
Gui, ICScriptHub:Add, Text, xs160 y+-13 w60 +Right vg_PS_HugePotCountStatus, Unknown
Gui, ICScriptHub:Add, Text, xs240 y+-13 w240 vg_PS_HugePotWaxingStatus, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Gem Hunters:
Gui, ICScriptHub:Add, Text, xs160 y+-13 w60 +Right vg_PS_GemHunterPotCountStatus, Unknown
Gui, ICScriptHub:Add, Text, xs240 y+-13 w240 vg_PS_GemHunterStatus, Unknown

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