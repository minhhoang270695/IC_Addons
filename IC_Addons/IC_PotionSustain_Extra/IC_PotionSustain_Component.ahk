#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk

global g_PS_SettingsPath := A_LineFile . "\..\PotionSustain_Settings.json"

GUIFunctions.AddTab("Potion Sustain")
global g_PotionSustain := new IC_PotionSustain_Component
global g_PS_Running := false
global g_PS_StatusText
global g_PS_ChestSmallThreshMin
global g_PS_ChestSmallThreshMax
global g_PS_AutomateThreshMin
global g_PS_AutomateThreshMax

Gui, ICScriptHub:Tab, Potion Sustain
GUIFunctions.UseThemeTextColor()
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, Text, x15 y+15, Potion Sustain:
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Button, x145 y+-15 w100 vg_PotionSustainSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_PotionSustain, "SaveSettings")
GuiControl,ICScriptHub: +g, g_PotionSustainSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x5 y+10 w130 +Right, Status:
Gui, ICScriptHub:Add, Text, vg_PS_StatusText x145 y+-13 w400, Waiting for Gem Farm to start
GUIFunctions.UseThemeTextColor("DefaultTextColor")
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
Gui, ICScriptHub:Add, Text, vg_PS_AbleSustainSmallStatus xs160 y+-13 w200, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Currently Buying Silvers:
Gui, ICScriptHub:Add, Text, vg_PS_BuyingSilversStatus xs160 y+-13 w200, Unknown
Gui, ICScriptHub:Add, GroupBox, x15 ys120 Section w500 h180, Automate Modron Potions
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_EnableAlternating xs15 ys25, Enable automating potions in the modron?
Gui, ICScriptHub:Add, Text, xs165 y+10 w50, Minimum
Gui, ICScriptHub:Add, Text, xs235 y+-13 w50, Maximum
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Modron Potion Thresholds:
GUIFunctions.UseThemeTextColor("InputBoxTextColor")
Gui, ICScriptHub:Add, Edit, vg_PS_AutomateThreshMin xs160 y+-17 w60 +Right, 
Gui, ICScriptHub:Add, Edit, vg_PS_AutomateThreshMax xs230 y+-21 w60 +Right, 
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Sustain Bracket:
Gui, ICScriptHub:Add, Text, vg_PS_SustainBracketStatus xs160 y+-13 w130, Unknown
Gui, ICScriptHub:Add, Text, xs20 y+10 w130 +Right, Automation Status:
Gui, ICScriptHub:Add, Text, vg_PS_AutomationStatus xs160 y+-13 w330, Unknown
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_DisableLarges xs15 y+15, Disable the use of Large potions?
Gui, ICScriptHub:Add, Checkbox, vg_PS_Checkbox_DisableHuges xs245 y+-13, Disable the use of Huge potions?
GUIFunctions.UseThemeTextColor("TableTextColor")
Gui, ICScriptHub:Add, ListView, xs300 ys15 w190 h100 vg_PS_AutomateList, Priority|Alternating|Status
GUIFunctions.UseThemeListViewBackgroundColor("g_PS_AutomateList")
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, GroupBox, x15 ys185 Section w500 h115, Current Potion Amounts
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
;Gui, ICScriptHub:Add, Button, x145 y+15 w100 vg_Test_Clicked, `Test
;buttonFunc := ObjBindMethod(g_PotionSustain, "Test")
;GuiControl,ICScriptHub: +g, g_Test_Clicked, % buttonFunc

if(IsObject(IC_BrivGemFarm_Component))
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
	Testing := false
	TestIndex := 0
	TestResetZone := 1300
	
	RunsCount := -1
	ModronResetZone := -1
	PotIDs := {"s":74,"m":75,"l":76,"h":77}
	PotAmounts := {"s":-1,"m":-1,"l":-1,"h":-1}
	ChestSmallPotMinThresh := 50
	ChestSmallPotMaxThresh := 100
	AutomatePotMinThresh := 50
	AutomatePotMaxThresh := 500
	ChestSmallPotBuying := false
	SustainSmallAbility := false
	EnableAlternating := false
	WaxingPots := {"s":false,"m":false,"l":false,"h":false}
	Using := "Using"
	NotEnough := "Not Enough"
	Blocked := "Blocked"
	ListSize := 0
	ModronCallParams := ""
	InstanceId := ""
	ForceChange := false
	FoundHighAreaPot := false
	DisableLarge := false
	DisableHuge := false

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
		GuiControl, ICScriptHub:, g_PS_SmallPotCountStatus, Unknown
        this.CreateTimedFunctions()
		this.RunsCount := g_SF.Memory.ReadResetsCount()
		g_ServerCall.UpdatePlayServer()
        g_SF.ResetServerCall()
		this.CalculateSmallPotionSustain()
        this.Start()
		this.ForceChange := true
    }
	
    ; Loads settings from the addon's setting.json file.
    LoadSettings()
    {
		Global
        Gui, Submit, NoHide
        writeSettings := False
        this.Settings := g_SF.LoadObjectFromJSON(g_PS_SettingsPath)
        if(!IsObject(this.Settings) OR this.Settings["SmallThresh"] != "")
        {
            this.DefaultSettings()
            writeSettings := True
        }
        if(writeSettings)
        {
            g_SF.WriteObjectToJSON(g_PS_SettingsPath, this.Settings)
        }
        GuiControl, ICScriptHub:, g_PS_ChestSmallThreshMin, % this.Settings["SmallThreshMin"]
        GuiControl, ICScriptHub:, g_PS_ChestSmallThreshMax, % this.Settings["SmallThreshMax"]
		GuiControl, ICScriptHub:, g_PS_AutomateThreshMin, % this.Settings["AutomateThreshMin"]
		GuiControl, ICScriptHub:, g_PS_AutomateThreshMax, % this.Settings["AutomateThreshMax"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_EnableAlternating, % this.Settings["Alternate"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_DisableLarges, % this.Settings["DisableLarges"]
		GuiControl, ICScriptHub:, g_PS_Checkbox_DisableHuges, % this.Settings["DisableHuges"]
		this.ChestSmallPotMinThresh := this.Settings["SmallThreshMin"]
		this.ChestSmallPotMaxThresh := this.Settings["SmallThreshMax"]
		this.AutomatePotMinThresh := this.Settings["AutomateThreshMin"]
		this.AutomatePotMaxThresh := this.Settings["AutomateThreshMax"]
		this.EnableAlternating := this.Settings["Alternate"]
		this.DisableLarge := this.Settings["DisableLarges"]
		this.DisableHuge := this.Settings["DisableHuges"]
        this.UpdateGUI()
    }
    
    ; Saves settings to addon's setting.json file.
    SaveSettings()
    {
		Global
        Gui, Submit, NoHide
        this.Settings["SmallThreshMin"] := g_PS_ChestSmallThreshMin
        this.Settings["SmallThreshMax"] := g_PS_ChestSmallThreshMax
        this.Settings["AutomateThreshMin"] := g_PS_AutomateThreshMin
        this.Settings["AutomateThreshMax"] := g_PS_AutomateThreshMax
		this.Settings["Alternate"] := g_PS_Checkbox_EnableAlternating
		this.Settings["DisableLarges"] := g_PS_Checkbox_DisableLarges
		this.Settings["DisableHuges"] := g_PS_Checkbox_DisableHuges
		this.ChestSmallPotMinThresh := g_PS_ChestSmallThreshMin
		this.ChestSmallPotMaxThresh := g_PS_ChestSmallThreshMax
		this.AutomatePotMinThresh := g_PS_AutomateThreshMin
		this.AutomatePotMaxThresh := g_PS_AutomateThreshMax
		this.EnableAlternating := g_PS_Checkbox_EnableAlternating
		this.DisableLarge := g_PS_Checkbox_DisableLarges
		this.DisableHuge := g_PS_Checkbox_DisableHuges
		if (!this.EnableAlternating)
		{
			this.ModronCallParams := ""
			try ; avoid thrown errors when comobject is not available.
			{
				SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
				SharedRunData.PSBGF_SetModronCallParams("")
			}
		}
        g_SF.WriteObjectToJSON(g_PS_SettingsPath, this.Settings )
		this.ForceChange := true
        this.UpdateGUI()
    }
	
	DefaultSettings()
	{
		Global
		this.Settings := {}
		this.Settings["SmallThreshMin"] := 150
		this.Settings["SmallThreshMax"] := 200
		this.Settings["AutomateThreshMin"] := 100
		this.Settings["AutomateThreshMax"] := 150
		this.Settings["Alternate"] := false
		this.Settings["DisableLarges"] := false
		this.Settings["DisableHuges"] := false
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
	
	Test()
	{
		if (this.TestIndex == 0)
		{
			;this.PotAmounts["s"] := 105
			;this.PotAmounts["m"] := 105
			;this.PotAmounts["l"] := 105
			;this.PotAmounts["h"] := 100
			;this.WaxingPots["l"] := true
		}
		;this.TestResetZone := 1500
		;this.ModronResetZone := this.TestResetZone
		;this.Testing := true
		;g_PS_Running := true
		;this.TestIndex += 1
	}

    ; Updates status on a timer
    UpdateTick()
    {
		this.UpdateAutomationStatus("Idle")
		currRuns := this.Testing ? this.TestIndex : g_SF.Memory.ReadResetsCount()
		saveModronParams := ""
		if (currRuns > 0 AND (this.PotAmounts["s"] < 0 OR (this.ListSize == 0 AND this.EnableAlternating) OR this.RunsCount != currRuns))
		{
			this.RunsCount := currRuns
			oldPotAmounts := this.ObjFullyClone(this.PotAmounts)
			size := g_SF.Memory.ReadInventoryItemsCount()
			if (this.PotAmounts["s"] < 0 OR (size >= 1 AND size <= this.SanitySize AND !this.Testing))
			{
				this.UpdateAutomationStatus("Updating Potion Amounts")
				loop, %size%
				{
					buffID := g_SF.Memory.ReadInventoryBuffIDBySlot(A_Index)
					amount := g_SF.Memory.ReadInventoryBuffCountBySlot(A_Index)
					for k,v in this.PotIDs
					{
						if (buffID==v)
							this.PotAmounts[k] := amount
					}
				}
				smalls := this.PotAmounts["s"]
				if (smalls >= 0 AND this.ChestSmallPotMinThresh >= 0 AND smalls <= this.ChestSmallPotMinThresh)
					this.ChestSmallPotBuying := true
				else
					this.ChestSmallPotBuying := false
			}
			needAChange := false
			for k,v in this.PotAmounts
			{
				if (((oldPotAmounts[k] > this.AutomatePotMinThresh AND v <= this.AutomatePotMinThresh) OR (oldPotAmounts[k] < this.AutomatePotMaxThresh AND v >= this.AutomatePotMaxThresh)) AND !this.AreObjectsEqual(oldPotAmounts, this.PotAmounts))
				{
					needAChange := true
					break
				}
			}
			Random,randChance,1,100
			if ((this.ListSize == 0 OR needAChange OR this.ForceChange OR randChance <= 20) AND g_PS_Running AND this.EnableAlternating)
			{
				this.UpdateAutomationStatus("Recalculating...")
				needAChange := false
				this.ForceChange := false
				gemHunter := false
				userData := g_ServerCall.CallUserDetails()
				if(IsObject(userData) AND userData.success)
					gemHunter := this.CheckUserDataForGemHunter(userData.details.buffs)
				calcAuto := this.CalculateAutomationBuffs(gemHunter)
				if(IsObject(userData) AND userData.success)
					saveModronParams := this.GetSaveModronParams(userData.details.modron_saves,calcAuto)
			}
		}
        try ; avoid thrown errors when comobject is not available.
        {
			this.ModronResetZone := this.Testing ? this.TestResetZone : g_SF.Memory.GetModronResetArea()
			this.CalculateSmallPotionSustain()
            SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
            if (SharedRunData.PSBGF_Running == "") ; Addon running check
            {
                GuiControl, ICScriptHub:Text, g_PS_StatusText, Not running. Loaded after Gem Farm script. Stop and Start.
            }
			else if (SharedRunData.PSBGF_Running)
			{
                GuiControl, ICScriptHub:Text, g_PS_StatusText, Running.
				g_PS_Running := true
				instanceId := g_SF.Memory.ReadInstanceID()
				if (instanceId != this.InstanceId AND instanceId != "" AND instanceId > 0)
				{
					this.InstanceId := instanceId
					SharedRunData.PSBGF_SetInstanceId(instanceId)
				}
				if (this.ChestSmallPotBuying != SharedRunData.PSBGF_GetBuySilvers())
					SharedRunData.PSBGF_SetBuySilvers(this.ChestSmallPotBuying)
				if (this.EnableAlternating AND saveModronParams != "" AND saveModronParams != this.ModronCallParams)
				{
					this.ModronCallParams := saveModronParams
					SharedRunData.PSBGF_SetModronCallParams(saveModronParams)
				}
			}
        }
        catch
        {
			this.UpdateAutomationStatus("Not Running")
            GuiControl, ICScriptHub:Text, g_PS_StatusText, Waiting for Gem Farm to start.
			GuiControl, ICScriptHub:Text, g_PS_AbleSustainSmallStatus, Unknown
            GuiControl, ICScriptHub:Text, g_PS_SmallPotCountStatus, Unknown
        }
		this.UpdateGUI()
    }
	
	UpdateAutomationStatus(status)
	{
		if (!this.EnableAlternating)
			GuiControl, ICScriptHub:Text, g_PS_AutomationStatus, Off
		if (status == "Idle" AND this.FoundHighAreaPot)
			status := "Warning: A potion in the Modron has a zone greater than 1."
		GuiControl, ICScriptHub:Text, g_PS_AutomationStatus, % status
		Gui, Submit, NoHide
	}

    Start()
    {
		this.UpdateTick()
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
		GuiControl, ICScriptHub:Text, g_PS_AbleSustainSmallStatus, Unknown
        GuiControl, ICScriptHub:Text, g_PS_SmallPotCountStatus, Unknown
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketStatus, Unknown
		GuiControl, ICScriptHub:Text, g_PS_AutomationStatus, Unknown
		Gui, Submit, NoHide
    }
	
	UpdateGUI()
	{
		waxing := "Unavailable. Restocking."
		waning := "Available."
		blocked := "Blocked by user."
		GuiControl, ICScriptHub:Text, g_PS_SmallPotCountStatus, % this.PotAmounts["s"]
		GuiControl, ICScriptHub:Text, g_PS_MediumPotCountStatus, % this.PotAmounts["m"]
		GuiControl, ICScriptHub:Text, g_PS_LargePotCountStatus, % this.PotAmounts["l"]
		GuiControl, ICScriptHub:Text, g_PS_HugePotCountStatus, % this.PotAmounts["h"]
		GuiControl, ICScriptHub:Text, g_PS_SmallPotWaxingStatus, % this.WaxingPots["s"] ? waxing : waning
		GuiControl, ICScriptHub:Text, g_PS_MediumPotWaxingStatus, % this.WaxingPots["m"] ? waxing : waning
		GuiControl, ICScriptHub:Text, g_PS_LargePotWaxingStatus, % this.Settings["DisableLarges"] ? blocked : this.WaxingPots["l"] ? waxing : waning
		GuiControl, ICScriptHub:Text, g_PS_HugePotWaxingStatus, % this.Settings["DisableHuges"] ? blocked : this.WaxingPots["h"] ? waxing : waning
		GuiControl, ICScriptHub:Text, g_PS_AbleSustainSmallStatus, % this.SustainSmallAbility
		potBuy := % "No."
		if (this.ChestSmallPotBuying)
			potBuy := % "Yes."
		GuiControl, ICScriptHub:Text, g_PS_BuyingSilversStatus, % potBuy
		Gui, Submit, NoHide
	}
	
	CalculateSmallPotionSustain()
	{
		smallSustain := 655
		status := ""
		if (this.ModronResetZone < 1 OR this.ModronResetZone == "")
			status := Unknown
		else if (this.ModronResetZone < smallSustain)
			status := "Modron reset of z" . (this.ModronResetZone) . " is too low to sustain. 655+ needed."
		else
			status := "Modron reset of z" . (this.ModronResetZone) . " allows sustaining."
		this.SustainSmallAbility := status
	}
	
	CalculateAutomationBuffs(gemHunter)
	{
        restore_gui_on_return := GUIFunctions.LV_Scope("ICScriptHub", "g_PS_AutomateList")
        LV_Delete()
		this.ListSize := 0
		; Bad modron read - flee.
		if (this.ModronResetZone < 1)
			return
		; Bad threshold read - flee.
		if (this.AutomatePotMinThresh < 0 OR this.AutomatePotMaxThresh < 0)
			return
		; Bad pot reads - flee.
		for k,v in this.PotAmounts
		{
			if (v < 0)
				return
		}
		; Deal with waxing.
		for k,v in this.PotAmounts
		{
			if (v <= this.AutomatePotMinThresh)
				this.WaxingPots[k] := true
			if (v >= this.AutomatePotMaxThresh)
				this.WaxingPots[k] := false
		}
		; Sustaining mediums.
		; Only use if modron reset is 1175+ (or 885+GH) and medium pots are above the minimum threshold.
		mZone := 1175
		sZone := 655
		if (gemHunter)
		{
			mZone := 885
			sZone := 475
		}
		calcAuto := {}
		if (this.ModronResetZone >= mZone AND this.PotAmounts["m"] > this.AutomatePotMinThresh)
			calcAuto := this.CalculateSustainMediums()
		; Sustaining smalls.
		; Only use if modron reset is 655+ (or 475+GH) and small pots are above the minimum threshold.
		else if (this.ModronResetZone >= sZone AND this.PotAmounts["s"] > this.AutomatePotMinThresh)
			calcAuto := this.CalculateSustainSmalls()
		; Sustaining nothing.
		; Only use as a last resort.
		else
			calcAuto := this.CalculateSustainNone()
		LV_ModifyCol(1, 45)
		LV_ModifyCol(2, 65)
		LV_ModifyCol(3, 75)
		Gui, Submit, NoHide
		return calcAuto
	}
	
	CalculateSustainMediums()
	{
		; Set can use mediums.
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketStatus, Mediums + Others.
		calcAuto := {this.PotIDs["m"]:1}
		status := ["---","---","---","---"]
		if (!this.DisableLarge AND this.PotAmounts["l"] >= this.AutomatePotMinThresh AND !this.WaxingPots["l"])
		{
			calcAuto[this.PotIDs["l"]] := 1
			status[1] := this.Using
		}
		else if (!this.DisableHuge AND this.PotAmounts["h"] >= this.AutomatePotMinThresh AND !this.WaxingPots["h"])
		{
			calcAuto[this.PotIDs["h"]] := 1
			status[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			status[2] := this.Using
		}
		else if (this.PotAmounts["s"] >= this.AutomatePotMinThresh AND !this.WaxingPots["s"])
		{
			calcAuto[this.PotIDs["s"]] := 1
			status[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			status[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			status[3] := this.Using
		}
		else
		{
			status[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			status[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			status[3] := this.NotEnough
			status[4] := this.Using
		}
		LV_Add(,1,"m + l",status[1])
		LV_Add(,2,"m + h",status[2])
		LV_Add(,3,"m + s",status[3])
		LV_Add(,4,"m",status[4])
		this.ListSize := 4
		return calcAuto
	}
	
	CalculateSustainSmalls()
	{
		; Set can use smalls.
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketStatus, Smalls + Others.
		calcAuto := {this.PotIDs["s"]:1}
		status := ["---","---","---","---"]
		if (!this.DisableLarge AND this.PotAmounts["l"] >= this.AutomatePotMinThresh AND !this.WaxingPots["l"])
		{
			calcAuto[this.PotIDs["l"]] := 1
			status[1] := this.Using
		}
		else if (!this.DisableHuge AND this.PotAmounts["h"] >= this.AutomatePotMinThresh AND !this.WaxingPots["h"])
		{
			calcAuto[this.PotIDs["h"]] := 1
			status[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			status[2] := this.Using
		}
		else if (this.PotAmounts["m"] >= this.AutomatePotMinThresh AND !this.WaxingPots["m"])
		{
			calcAuto[this.PotIDs["m"]] := 1
			status[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			status[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			status[3] := this.Using
		}
		else
		{
			status[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			status[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			status[3] := this.NotEnough
			status[4] := this.Using
		}
		LV_Add(,1,"s + l",status[1])
		LV_Add(,2,"s + h",status[2])
		LV_Add(,3,"s + m",status[3])
		LV_Add(,4,"s",status[4])
		this.ListSize := 4
		return calcAuto
	}
	
	CalculateSustainNone()
	{
		; Set can use smalls.
		GuiControl, ICScriptHub:Text, g_PS_SustainBracketStatus, Anything available.
		calcAuto := {}
		status := ["---","---","---","---"]
		if (!this.DisableLarge AND this.PotAmounts["l"] >= this.AutomatePotMinThresh AND !this.WaxingPots["l"])
		{
			calcAuto[this.PotIDs["l"]] := 1
			status[1] := this.Using
		}
		else if (!this.DisableHuge AND this.PotAmounts["h"] >= this.AutomatePotMinThresh AND !this.WaxingPots["h"])
		{
			calcAuto[this.PotIDs["h"]] := 1
			status[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			status[2] := this.Using
		}
		else if (this.PotAmounts["m"] >= this.AutomatePotMinThresh AND !this.WaxingPots["m"])
		{
			calcAuto[this.PotIDs["m"]] := 1
			status[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			status[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			status[3] := this.Using
		}
		else
		{
			calcAuto[this.PotIDs["s"]] := 1
			status[1] := this.DisableLarge ? this.Blocked : this.NotEnough
			status[2] := this.DisableHuge ? this.Blocked : this.NotEnough
			status[3] := this.NotEnough
			status[4] := this.Using
		}
		LV_Add(,1,"l",status[1])
		LV_Add(,2,"h",status[2])
		LV_Add(,3,"m",status[3])
		LV_Add(,4,"s",status[4])
		this.ListSize := 4
		return calcAuto
	}
	
	CheckUserDataForGemHunter(buffs)
	{
		for k,v in buffs
		{
			if (v.buff_id == 1723)
			{
				if (v.remaining_time > 0)
					return true
				return false
			}
		}
		return false
	}
	
	GetSaveModronParams(saves,calcAuto)
	{
		userId := g_SF.Memory.ReadUserID()
		userHash := g_SF.Memory.ReadUserHash()
		networkId := g_SF.Memory.ReadPlatform()
		version := g_SF.Memory.ReadBaseGameVersion()
		gameInstanceId := g_SF.Memory.ReadActiveGameInstance()
		params := ""
		for k,v in saves
		{
			if (v.instance_id != gameInstanceId)
				continue
			if (!this.AreObjectsEqual(calcAuto,v.buffs))
			{
				; Add non speed pots that might be included.
				this.FoundHighAreaPot := false
				for j,w in v.buffs
				{
					if (w > 1 AND !this.FoundHighAreaPot)
						this.FoundHighAreaPot := true
					if (!this.HasValue(this.PotIDs,j))
						calcAuto[j] := w
				}
			}
			if (!this.AreObjectsEqual(calcAuto,v.buffs))
				this.ForceChange := true
			coreId := v.core_id
			grid := JSON.stringify(v.grid)
			formationSaves := JSON.stringify(v.formation_saves)
			areaGoal := v.area_goal
			buffs := JSON.stringify(calcAuto)
			timestamp := this.GetNowEpoch() + 600000
			properties := "{""formation_enabled"":true,""toggle_preferences"":{""formation"":true,""reset"":true,""buff"":true}}"
			params .= "&core_id=" . coreId
			params .= "&grid=" . grid
			params .= "&game_instance_id=" . gameInstanceId
			params .= "&formation_saves=" . formationSaves
			params .= "&area_goal=" . areaGoal
			params .= "&buffs=" . buffs
			params .= "&checkin_timestamp=" . timestamp
			params .= "&properties=" . properties
		}
		params .= "&user_id=" . userID
		params .= "&hash=" . userHash
		params .= "&language_id=1"
		params .= "&timestamp=0"
		params .= "&request_id=0"
		params .= "&network_id=" . networkId
		params .= "&mobile_client_version=" . version
		params .= "&include_free_play_objectives=true"
		params .= "&instance_key=1"
		params .= "&offline_v2_build=1"
		params .= "&localization_aware=true"
		return params
	}
	
	EncodeDecodeURI(str, encode := true, component := true) {
		static Doc, JS
		if !Doc {
			Doc := ComObjCreate("htmlfile")
			Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
			JS := Doc.parentWindow
			( Doc.documentMode < 9 && JS.execScript() )
		}
		ret := JS[ (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "") ](str)
		StringLower, ret, ret
		return ret
	}
	
    AreObjectsEqual(obj1 := "", obj2 := "")
    {
        if (obj1.Count() != obj2.Count())
            return false
        if (!IsObject(obj1))
            return !IsObject(obj2) && (obj1 == obj2)
        for k, v in obj1
        {
            if (IsObject(v) && !this.AreObjectsEqual(obj2[k], v))
                return false
            else if (!IsObject(v) && obj2[k] != v && obj2.HasKey(k))
                return false
        }
        return true
    }
	
	ObjFullyClone(obj)
	{
		nobj := obj.Clone()
		for k,v in nobj
			if IsObject(v)
				nobj[k] := A_ThisFunc.(v)
		return nobj
	}
	
	HasValue(obj,val)
	{
		for k,v in obj
			if (v == val)
				return true
		return false
	}
	
	GetNowEpoch()
	{
		nowUTC := A_NowUTC
		nowUTC -= 19700101000000, S
		return nowUTC
	}
	
}