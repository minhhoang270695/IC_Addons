#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk

global g_PS_SettingsPath := A_LineFile . "\..\PotionSustain_Settings.json"

GUIFunctions.AddTab("Potion Sustain")
global g_PotionSustain := new IC_PotionSustain_Component
global g_PS_SmallThresh
global g_PS_StatusText
global g_PS_SmallPotCountStatus := -1

Gui, ICScriptHub:Tab, Potion Sustain
GUIFunctions.UseThemeTextColor()
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, Text, x15 y+15, Potion Sustain:
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Button, x128 y+-15 w100 vg_PotionSustainSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_PotionSustain, "SaveSettings")
GuiControl,ICScriptHub: +g, g_PotionSustainSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x90 y+10, Status:
Gui, ICScriptHub:Add, Text, vg_PS_StatusText x130 y+-13 w250, Waiting for Gem Farm to start
Gui, ICScriptHub:Add, Text, x15 y+20, Small Potion Theshold:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_PS_SmallThresh x130 y+-17 w60, 
GUIFunctions.UseThemeTextColor()
Gui, ICScriptHub:Add, Text, x30 y+10, Small Potion Count:
Gui, ICScriptHub:Add, Text, vg_PS_SmallPotCountStatus x130 y+-13, Unknown

if(IsObject(IC_BrivGemFarm_Component) AND IsObject(IC_InventoryView_Component))
    g_PotionSustain.InjectAddon()
else
{
    GuiControl, ICScriptHub:Text, g_PS_StatusText, WARNING: This addon needs IC_BrivGemFarm enabled.
    Gui, Submit, NoHide
    return
}

g_PotionSustain.Init()

/*  IC_PotionSustain_Component
    Class that manages the GUI for IC_PotionSustain.

*/
Class IC_PotionSustain_Component
{
    Settings := ""
    TempSettings := new IC_PotionSustain_Component._IC_PotionSustain_TempSettings
    TimerFunctions := ""
	SanitySize := 5000
	smallPotCount := -1

    InjectAddon()
    {
        splitStr := StrSplit(A_LineFile, "\")
        addonDirLoc := splitStr[(splitStr.Count()-1)]
        addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_PotionSustain_Addon.ahk`n"
        FileAppend, %addonLoc%, %g_BrivFarmModLoc%
        OutputDebug, % addonLoc . " to " . g_BrivFarmModLoc
    }
	
    ; GUI startup
    Init()
    {
        Global
        Gui, Submit, NoHide
		this.LoadSettings()
        GuiControl, ICScriptHub:, g_PS_StatusText, Waiting for Gem Farm to start.
        GuiControl, ICScriptHub:, g_PS_SmallThresh, % this.Settings.SmallThresh
		GuiControl, ICScriptHub:, g_PS_SmallPotCountStatus, Unknown
        this.CreateTimedFunctions()
        this.Start()
    }
	
    ; Loads settings from the addon's setting.json file.
    LoadSettings()
    {
		Global
        Gui, Submit, NoHide
        writeSettings := False
        this.Settings := g_SF.LoadObjectFromJSON(g_PS_SettingsPath)
        if(!IsObject(this.Settings))
        {
            this.DefaultSettings()
            writeSettings := True
        }
        if(writeSettings)
        {
            g_SF.WriteObjectToJSON(g_PS_SettingsPath, this.Settings)
        }
        GuiControl,ICScriptHub:, g_PS_SmallThresh, % this.Settings["SmallThresh"]
        Gui, Submit, NoHide
    }
    
    ; Saves settings to addon's setting.json file.
    SaveSettings()
    {
		Global
        Gui, Submit, NoHide
        this.Settings["SmallThresh"] := g_PS_SmallThresh
        g_SF.WriteObjectToJSON(g_PS_SettingsPath, this.Settings )
        Gui, Submit, NoHide
    }
	
	DefaultSettings()
	{
		Global
		this.Settings := {}
		this.Settings["SmallThresh"] := 50
	}

    ; Adds timed functions to be run when briv gem farm is started
    CreateTimedFunctions()
    {
        this.TimerFunctions := {}
        fncToCallOnTimer := ObjBindMethod(this, "UpdateTick")
        this.TimerFunctions[fncToCallOnTimer] := 500
        g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(this, "Start"))
        g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(this, "Stop"))
    }

    ; Updates status on a timer
    UpdateTick()
    {
        try ; avoid thrown errors when comobject is not available.
        {
            SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
            if (SharedRunData.PSBGF_Running == "") ; Addon running check
            {
                GuiControl, ICScriptHub:Text, g_PS_StatusText, Loaded after Gem Farm script. Stop and Start.
            }
			else if (SharedRunData.PSBGF_Running)
			{
                GuiControl, ICScriptHub:Text, g_PS_StatusText, Running.
				size := g_SF.Memory.ReadInventoryItemsCount()
				if (size >= 1 AND size <= this.SanitySize)
				{
					loop, %size%
					{
						buffID := g_SF.Memory.ReadInventoryBuffIDBySlot(A_Index)
						if (buffID!=74)
							continue
						currPotCount := g_SF.Memory.ReadInventoryBuffCountBySlot(A_Index)
						if (currPotCount != "" AND currPotCount > 0 AND (SharedRunData.PSBGF_GetSmallPotCount() != currPotCount OR SharedRunData.PSBGF_GetSmallPotThresh() != g_PS_SmallThresh)) {
							smallPotCount := currPotCount
							SharedRunData.PSBGF_SetData(g_PS_SmallThresh,smallPotCount)
							GuiControl, ICScriptHub:, g_PS_SmallPotCountStatus, %smallPotCount%
						}
						break
					}
				}
				Gui, Submit, NoHide
			}
        }
        catch
        {
            GuiControl, ICScriptHub:Text, g_PS_StatusText, Waiting for Gem Farm to start.
            GuiControl, ICScriptHub:Text, g_PS_SmallPotCountStatus, Unknown
        }
    }

    Start()
    {
        for k,v in this.TimerFunctions
            SetTimer, %k%, %v%, 0
        GuiControl, ICScriptHub:Text, g_PS_StatusText, Running.
    }

    Stop()
    {
        for k,v in this.TimerFunctions
        {
            SetTimer, %k%, Off
            SetTimer, %k%, Delete
        }
        GuiControl, ICScriptHub:Text, g_PS_StatusText, Waiting for Gem Farm to start
        GuiControl, ICScriptHub:Text, g_PS_SmallPotCountStatus, Unknown
    }
	
}