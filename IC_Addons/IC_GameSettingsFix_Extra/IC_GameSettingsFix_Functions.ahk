class IC_GameSettingsFix_Component
{
	TimerFunctions := {}
	DefaultSettings := {"TargetFramerate":600,"PercentOfParticlesSpawned":0,"resolution_x":1280,"resolution_y":720,"resolution_fullscreen":false,"ReduceFramerateWhenNotInFocus":false,"LevelupAmountIndex":4,"UseConsolePortraits":false,"FormationSaveIncludeFeatsCheck":false,"NarrowHeroBoxes":true}
	Settings := {}
	GameSettingsFileLocation := ""
	InstanceID := ""
	MadeChanges := false
	FixedCounter := 0

	; ================================
	; ===== LOADING AND SETTINGS =====
	; ================================
	
	Init()
	{
		Global
		Gui, Submit, NoHide
		this.LoadSettings()
		if (!this.IsGameClosed() AND (this.GameSettingsFileLocation == "" OR !FileExist(this.GameSettingsFileLocation)))
			this.FindSettingsFile()
		this.UpdateMainStatus("Waiting for Gem Farm to start.")
	}
	
	LoadSettings()
	{
		Global
		Gui, Submit, NoHide
		writeSettings := false
		this.Settings := g_SF.LoadObjectFromJSON(g_GSF_SettingsPath)
		if(!IsObject(this.Settings))
		{
			this.SetDefaultSettings()
			writeSettings := true
		}
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(g_GSF_SettingsPath, this.Settings)
		GuiControl, ICScriptHub:, g_GSF_TargetFramerate, % this.Settings["TargetFramerate"]
		GuiControl, ICScriptHub:, g_GSF_PercentOfParticlesSpawned, % this.Settings["PercentOfParticlesSpawned"]
		GuiControl, ICScriptHub:, g_GSF_resolution_x, % this.Settings["resolution_x"]
		GuiControl, ICScriptHub:, g_GSF_resolution_y, % this.Settings["resolution_y"]
		GuiControl, ICScriptHub:, g_GSF_resolution_fullscreen, % this.Settings["resolution_fullscreen"]
		GuiControl, ICScriptHub:, g_GSF_ReduceFramerateWhenNotInFocus, % this.Settings["ReduceFramerateWhenNotInFocus"]
		GuiControl, ICScriptHub:Choose, g_GSF_LevelupAmountIndex, % this.ConvertLevelUpIndexToUI(this.Settings["LevelupAmountIndex"])
		GuiControl, ICScriptHub:, g_GSF_UseConsolePortraits, % this.Settings["UseConsolePortraits"]
		GuiControl, ICScriptHub:, g_GSF_FormationSaveIncludeFeatsCheck, % this.Settings["FormationSaveIncludeFeatsCheck"]
		GuiControl, ICScriptHub:, g_GSF_NarrowHeroBoxes, % this.Settings["NarrowHeroBoxes"]
	}
	
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide
		local sanityChecked := this.SanityCheckSettings()
		this.CheckMissingOrExtraSettings()
		this.Settings["TargetFramerate"] := g_GSF_TargetFramerate
		this.Settings["PercentOfParticlesSpawned"] := g_GSF_PercentOfParticlesSpawned
		this.Settings["resolution_x"] := g_GSF_resolution_x
		this.Settings["resolution_y"] := g_GSF_resolution_y
		this.Settings["resolution_fullscreen"] := g_GSF_resolution_fullscreen
		this.Settings["ReduceFramerateWhenNotInFocus"] := g_GSF_ReduceFramerateWhenNotInFocus
		this.Settings["LevelupAmountIndex"] := this.ConvertLevelUpIndexFromUI(g_GSF_LevelupAmountIndex)
		this.Settings["UseConsolePortraits"] := g_GSF_UseConsolePortraits
		this.Settings["FormationSaveIncludeFeatsCheck"] := g_GSF_FormationSaveIncludeFeatsCheck
		this.Settings["NarrowHeroBoxes"] := g_GSF_NarrowHeroBoxes
		g_SF.WriteObjectToJSON(g_GSF_SettingsPath, this.Settings)
		if (!sanityChecked)
			this.UpdateMainStatus("Saved settings.")
	}
	
	SanityCheckSettings()
	{
		local sanityChecked := false
		if (!this.IsNumber(g_GSF_TargetFramerate) OR g_GSF_TargetFramerate <= 20)
		{
			g_GSF_TargetFramerate := this.DefaultSettings["TargetFramerate"]
			GuiControl, ICScriptHub:, g_GSF_TargetFramerate, % g_GSF_TargetFramerate
			sanityChecked := true
			this.UpdateMainStatus("Save Error. TargetFramerate was an invalid number.")
		}
		if (!this.IsNumber(g_GSF_PercentOfParticlesSpawned) OR g_GSF_PercentOfParticlesSpawned < 0 OR g_GSF_PercentOfParticlesSpawned > 100)
		{
			g_GSF_PercentOfParticlesSpawned := this.DefaultSettings["PercentOfParticlesSpawned"]
			GuiControl, ICScriptHub:, g_GSF_PercentOfParticlesSpawned, % g_GSF_PercentOfParticlesSpawned
			sanityChecked := true
			this.UpdateMainStatus("Save Error. PercentOfParticlesSpawned was an invalid number.")
		}
		if (!this.IsNumber(g_GSF_resolution_x) OR g_GSF_resolution_x < 0)
		{
			g_GSF_resolution_x := this.DefaultSettings["resolution_x"]
			GuiControl, ICScriptHub:, g_GSF_resolution_x, % g_GSF_resolution_x
			sanityChecked := true
			this.UpdateMainStatus("Save Error. resolution_x was an invalid number.")
		}
		if (!this.IsNumber(g_GSF_resolution_y) OR g_GSF_resolution_y < 0)
		{
			g_GSF_resolution_y := this.DefaultSettings["resolution_y"]
			GuiControl, ICScriptHub:, g_GSF_resolution_y, % g_GSF_resolution_y
			sanityChecked := true
			this.UpdateMainStatus("Save Error. resolution_y was an invalid number.")
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
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	UpdateGameSettingsFix()
	{
		this.UpdateMainStatus("Idle. Waiting for next game close.")
		if (this.IsGameClosed())
		{
			if (this.InstanceID == "")
				return
			this.UpdateMainStatus("Game is closed. Verifying settings.")
			if (this.GameSettingsFileLocation != "" AND FileExist(this.GameSettingsFileLocation))
			{
				g_GSF_settingsFile := this.ReadAndEditSettingsString(this.GameSettingsFileLocation)
				if (this.MadeChanges)
					this.WriteSettingsStringToFile(g_GSF_settingsFile, this.GameSettingsFileLocation)
			}
			this.InstanceID := ""
		}
		else
		{
			if (this.GameSettingsFileLocation == "")
				this.FindSettingsFile()
			if (this.InstanceID == "")
				this.InstanceID := g_SF.Memory.ReadInstanceID()
		}
	}
	
	FindSettingsFile()
	{
		local webRequestLogLoc := g_SF.Memory.GetWebRequestLogLocation()
		if (!InStr(webRequestLogLoc, "webRequestLog"))
			return
		local settingsFileLoc := StrReplace(webRequestLogLoc, "downloaded_files\webRequestLog.txt", "localSettings.json")
		if (!FileExist(settingsFileLoc))
			return
		this.GameSettingsFileLocation := settingsFileLoc
		GuiControl, ICScriptHub:, g_GSF_GameSettingsFileLocation, % settingsFileLoc
	}
	
	ReadAndEditSettingsString(g_GSF_settingsFileLoc)
	{
		local g_GSF_settingsFile
		this.MadeChanges := false
		FileRead, g_GSF_settingsFile, %g_GSF_settingsFileLoc%
		for k,v in this.Settings
		{
			g_GSF_before := g_GSF_settingsFile
			g_GSF_after := RegExReplace(g_GSF_before, """" k """: (false|true)", """" k """: " (v ? "true" : "false"))
			if (g_GSF_before != g_GSF_after) {
				g_GSF_settingsFile := g_GSF_after
				this.MadeChanges := true
				continue
			}
			g_GSF_after := RegExReplace(g_GSF_before, """" k """: ([0-9]+)", """" k """: " v)
			if (g_GSF_before != g_GSF_after) {
				g_GSF_settingsFile := g_GSF_after
				this.MadeChanges := true
			}
		}
		return g_GSF_settingsFile
	}
	
	WriteSettingsStringToFile(g_GSF_SettingsFile, g_GSF_settingsFileLoc)
	{
		g_GSF_newFile := FileOpen(g_GSF_settingsFileLoc, "w")
		if (!IsObject(g_GSF_newFile))
		{
			this.UpdateMainStatus("Error. Could not write to the settings file this time.")
			return
		}
		g_GSF_newFile.Write(g_GSF_settingsFile)
		g_GSF_newFile.Close()
		this.UpdateMainStatus("Game settings file had changes. Corrected.")
		this.FixedCounter++
		GuiControl, ICScriptHub:, g_GSF_NumTimesFixed, % this.FixedCounter
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
	
	; =====================
	; ===== GUI STUFF =====
	; =====================
	
	UpdateMainStatus(status)
	{
		GuiControl, ICScriptHub:Text, g_GSF_StatusText, % status
		Gui, Submit, NoHide
	}
	
	ConvertLevelUpIndexFromUI(g_GSF_levelUpIndexUI)
	{
		switch g_GSF_levelUpIndexUI
		{
			case "x1": return 0
			case "x10": return 1
			case "x25": return 2
			case "x100": return 3
			default: return 4
		}
	}
	
	ConvertLevelUpIndexToUI(g_GSF_levelUpIndexVal)
	{
		switch g_GSF_levelUpIndexVal
		{
			case 0: return "x1"
			case 1: return "x10"
			case 2: return "x25"
			case 3: return "x100"
			default: return "Next Upg"
		}
	}
	
	; =======================
	; ===== TIMER STUFF =====
	; =======================
	
	; Adds timed functions (typically to be started when briv gem farm is started)
	CreateTimedFunctions()
	{
		this.TimerFunctions := {}
		fncToCallOnTimer :=  ObjBindMethod(this, "UpdateGameSettingsFix")
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
	
}