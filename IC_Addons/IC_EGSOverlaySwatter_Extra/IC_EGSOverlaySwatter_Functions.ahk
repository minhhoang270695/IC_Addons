class IC_EGSOverlaySwatter_Component
{
	TimerFunctions := {}
	EGSPlatformID := 21
	DefaultSettings := {"DisableOverlay":true,"EGSFolder":"C:\Program Files (x86)\Epic Games","CheckDefaultFolder":false}
	Settings := {}
	DisableOverlay := this.DefaultSettings["DisableOverlay"]
	EGSFolder := this.DefaultSettings["EGSFolder"]
	CheckDefaultFolder := this.DefaultSettings["CheckDefaultFolder"]
	EGSFolderExists := true
	MadeChanges := false
	Error := 0
	PlatformID := ""

	; ================================
	; ===== LOADING AND SETTINGS =====
	; ================================
	
	Init()
	{
		Global
		Gui, Submit, NoHide
		this.LoadSettings()
		;this.CreateTooltips()
		this.UpdateMainStatus("Waiting for Gem Farm to start.")
	}
	
	LoadSettings()
	{
		Global
		Gui, Submit, NoHide
		writeSettings := false
		this.Settings := g_SF.LoadObjectFromJSON(g_EGSOS_SettingsPath)
		if(!IsObject(this.Settings))
		{
			this.SetDefaultSettings()
			writeSettings := true
		}
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(g_EGSOS_SettingsPath, this.Settings)
		GuiControl, ICScriptHub:, g_EGSOS_DisableOverlay, % this.Settings["DisableOverlay"]
		GuiControl, ICScriptHub:, g_EGSOS_EGSFolderLocation, % this.Settings["EGSFolder"]
		GuiControl, ICScriptHub:, g_EGSOS_CheckDefaultFolder, % this.Settings["CheckDefaultFolder"]
		this.DisableOverlay := this.Settings["DisableOverlay"]
		this.EGSFolder := this.Settings["EGSFolder"]
		this.CheckDefaultFolder := this.Settings["CheckDefaultFolder"]
		this.EGSFolderExists := this.IsFolder(this.EGSFolder)
	}
	
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide
		local sanityChecked := this.SanityCheckSettings()
		this.CheckMissingOrExtraSettings()
		
		this.Settings["DisableOverlay"] := g_EGSOS_DisableOverlay
		this.Settings["EGSFolder"] := g_EGSOS_EGSFolderLocation
		this.Settings["CheckDefaultFolder"] := g_EGSOS_CheckDefaultFolder
		this.DisableOverlay := g_EGSOS_DisableOverlay
		this.EGSFolder := g_EGSOS_EGSFolderLocation
		this.CheckDefaultFolder := g_EGSOS_CheckDefaultFolder
		
		g_SF.WriteObjectToJSON(g_EGSOS_SettingsPath, this.Settings)
		
		if (!sanityChecked)
			this.UpdateMainStatus("Saved settings.")
	}
	
	SanityCheckSettings()
	{
		local sanityChecked := false
		if (g_EGSOS_CheckDefaultFolder AND g_EGSOS_EGSFolderLocation == this.DefaultSettings["EGSFolder"])
		{
			g_EGSOS_CheckDefaultFolder := false
			GuiControl, ICScriptHub:, g_EGSOS_CheckDefaultFolder, % g_EGSOS_CheckDefaultFolder
			this.UpdateMainStatus("Save Error. EGS Folder is default. Disabling Check Default.")
			sanityChecked := true
		}
		this.EGSFolderExists := this.IsFolder(g_EGSOS_EGSFolderLocation)
		if (!this.EGSFolderExists)
		{
			g_EGSOS_DisableOverlay := false
			GuiControl, ICScriptHub:, g_EGSOS_DisableOverlay, % g_EGSOS_DisableOverlay
			this.UpdateMainStatus("Save Error. EGS Folder does not exist. Cannot disable.")
		}
		return sanityChecked
	}
	
	SetDefaultSettings()
	{
		this.Settings := {}
		for k,v in this.DefaultSettings
			this.Settings[k] := v
	}
	
	CheckMissingOrExtraSettings()
	{
		local madeEdit := false
		for k,v in this.DefaultSettings
		{
			if (this.Settings[k] == "") {
				this.Settings[k] := v
				madeEdit := true
			}
		}
		for k,v in this.Settings
		{
			if (!this.DefaultSettings.HasKey(k)) {
				this.Settings.Delete(k)
				madeEdit := true
			}
		}
		return madeEdit
	}
	
	CreateTooltips()
	{
		;EGSFolderLocationTT := GUIFunctions.GetToolTipTarget("g_EGSOS_EGSFolderLocationH")
		;g_MouseToolTips[EGSFolderLocationTT] := "The location where you have installed EGS."
	}
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	UpdateEGSOverlaySwatter()
	{
		if (this.PlatformID != this.EGSPlatformID)
			return
		else if (!this.EGSFolderExists)
		{
			this.UpdateMainStatus("Saved EGS Folder Location does not exist.")
			return
		}
		this.UpdateMainStatus("Idle. Waiting for next game close.")
		if (this.IsGameClosed())
		{
			if (this.InstanceID == "")
				return
			this.UpdateMainStatus("Game is closed. Checking Overlay Status.")
			this.EGSFolderExists := this.IsFolder(this.EGSFolder)
			overlayFiles := this.FilesList(this.EGSFolder)
			if (this.CheckDefaultFolder AND this.IsFolder(this.DefaultSettings["EGSFolder"]))
			{
				for k,v in this.FilesList(this.DefaultSettings["EGSFolder"])
				{
					overlayFiles.push(v)
				}
			}
			if (ObjLength(overlayFiles) == 0)
			{
				this.AddFilesToGUIList([])
				if (this.DisableOverlay)
					this.UpdateOverlayStatus("No overlay files can be found - already disabled.")
				else
					this.UpdateOverlayStatus("Cannot enable overlay because no overlay files exist.")
			}
			else
			{
				this.ToggleOverlayFiles(overlayFiles)
				if (this.MadeChanges)
					this.UpdateMainStatus("EGS Overlay files have been " (this.DisableOverlay ? "disabled" : "enabled") ".")
				this.UpdateOverlayStatus(this.DisableOverlay ? "Disabled." : "Enabled.")
				if (this.Error > 0)
					this.UpdateOverlayStatus("One or more overlay files could not be renamed. Need to run as admin.")
			}
			this.InstanceID := ""
		}
		else
		{
			if (this.InstanceID == "")
				this.InstanceID := g_SF.Memory.ReadInstanceID()
		}
	}
	
	IsGameClosed()
	{
		if(g_SF.Memory.ReadCurrentZone() == "" AND Not WinExist( "ahk_exe " . g_userSettings[ "ExeName"] ))
			return true
		return false
	}
	
	IsNumber(inputText)
	{
		if inputText is number
			return true
		return false
	}
	
	IsFolder(inputFolder)
	{
		return InStr(FileExist(inputFolder),"D")
	}
	
	FilesList(dir) {
		local list := []
		Loop, Files, %dir%\*.*, DRF
		{
			if (!RegExMatch(A_LoopFileExt, "i)(txt|exe)"))
				continue
			local currFile := A_LoopFileFullPath
			if (InStr(currFile, "SelfUpdateStaging"))
				continue
			if (RegExMatch(A_LoopFileName, "EOSOverlayRenderer-Win(32|64)-Shipping"))
				list.push(currFile)
		}
		return list
	}
	
	ToggleOverlayFiles(overlayFiles)
	{
		if (ObjLength(overlayFiles) == 0)
			return
		filesRenamed := []
		this.Error := 0
		for k,v in overlayFiles
		{
			egsosAdded := false
			if (this.DisableOverlay AND !InStr(v, ".txt")) ; Overlay file is not disabled.
			{
				vWithTxt := % v ".txt"
				FileMove, %v%, %vWithTxt%, 1
				if (ErrorLevel == 0)
				{
					this.MadeChanges := true
					filesRenamed.push(wWithTxt)
					egsosAdded := true
				}
				else
					this.Error := 1
			}
			else if (!this.DisableOverlay AND InStr(v, ".txt")) ; Overlay is disabled.
			{
				vWithoutTxt := SubStr(v, 1, -4)
				FileMove, %v%, %vWithoutTxt%, 1
				if (ErrorLevel == 0)
				{
					this.MadeChanges := true
					filesRenamed.push(vWithoutTxt)
					egsosAdded := true
				}
				else
					this.Error := 1
			}
			if (!egsosAdded)
				filesRenamed.push(v)
		}
		this.AddFilesToGUIList(filesRenamed)
	}
	
	; =====================
	; ===== GUI STUFF =====
	; =====================
	
	UpdateMainStatus(status)
	{
		GuiControl, ICScriptHub:Text, g_EGSOS_StatusText, % status
		Gui, Submit, NoHide
	}
	
	UpdateOverlayStatus(status)
	{
		GuiControl, ICScriptHub:Text, g_EGSOS_OverlayStatus, % status
		Gui, Submit, NoHide
	}
	
	AddFilesToGUIList(filesRenamed)
	{
		local restore_gui_on_return := GUIFunctions.LV_Scope("ICScriptHub", "g_EGSOS_OverlayFilesList")
		LV_Delete()
		for k,v in filesRenamed
		{
			local newV := StrReplace(v, "\\", "\")
			LV_Add(,newV)
		}
		if (ObjLength(filesRenamed) > 0)
			LV_ModifyCol(1)
		else
			LV_ModifyCol(500)
	}
	
	; =======================
	; ===== TIMED STUFF =====
	; =======================
	
	; Adds timed functions (typically to be started when briv gem farm is started)
	CreateTimedFunctions()
	{
		this.TimerFunctions := {}
		fncToCallOnTimer :=  ObjBindMethod(this, "UpdateEGSOverlaySwatter")
		this.TimerFunctions[fncToCallOnTimer] := 1000
	}

	; Starts the saved timed functions (typically to be started when briv gem farm is started)
	StartTimedFunctions()
	{
		for k,v in this.TimerFunctions
		{
			SetTimer, %k%, %v%, 0
		}
	}
	
	; Called when briv gem farm is started
	GetPlatformID()
	{
		this.PlatformID := g_SF.Memory.ReadPlatform()
		if (this.PlatformID != this.EGSPlatformID)
		{
			GuiControl, ICScriptHub:Hide, g_EGSOverlaySwatterSave_Clicked
			GuiControl, ICScriptHub:Hide, g_EGSOS_SettingsGroupBox
			GuiControl, ICScriptHub:Hide, g_EGSOS_DisableOverlay
			GuiControl, ICScriptHub:Hide, g_EGSOS_EGSFolderLocationH
			GuiControl, ICScriptHub:Hide, g_EGSOS_EGSFolderLocation
			GuiControl, ICScriptHub:Hide, g_EGSOS_CheckDefaultFolder
			GuiControl, ICScriptHub:Hide, g_EGSOS_InfoGroupBox
			GuiControl, ICScriptHub:Hide, g_EGSOS_OverlayStatusH
			GuiControl, ICScriptHub:Hide, g_EGSOS_OverlayStatus
			GuiControl, ICScriptHub:Hide, g_EGSOS_OverlayFilesList
			this.StopTimedFunctions()
			this.UpdateMainStatus("Why have you enabled this addon? You're not on the EGS platform.")
		}
	}

	; Stops the saved timed functions (typically to be stopped when briv gem farm is stopped)
	StopTimedFunctions()
	{
		for k,v in this.TimerFunctions
		{
			SetTimer, %k%, Off
			SetTimer, %k%, Delete
		}
		this.UpdateMainStatus("Waiting for Gem Farm to start.")
	}
	
	; ======================
	; ===== MISC STUFF =====
	; ======================
	
	ConfirmLastBackslash(folderLocation)
	{
		if (SubStr(folderLocation, 0) != "\")
			folderLocation .= "\"
		return folderLocation
	}
	
}