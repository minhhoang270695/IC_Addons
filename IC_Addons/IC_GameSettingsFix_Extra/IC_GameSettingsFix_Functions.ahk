class IC_GameSettingsFix_Component
{
	DefaultSettings := {"TargetFramerate":600,"PercentOfParticlesSpawned":0,"ReduceFramerateWhenNotInFocus":false,"UseConsolePortraits":false,"FormationSaveIncludeFeatsCheck":false,"NarrowHeroBoxes":true,"SoundMuted":false}
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
		GuiControl, ICScriptHub:, g_GSF_ReduceFramerateWhenNotInFocus, % this.Settings["ReduceFramerateWhenNotInFocus"]
		GuiControl, ICScriptHub:, g_GSF_UseConsolePortraits, % this.Settings["UseConsolePortraits"]
		GuiControl, ICScriptHub:, g_GSF_FormationSaveIncludeFeatsCheck, % this.Settings["FormationSaveIncludeFeatsCheck"]
		GuiControl, ICScriptHub:, g_GSF_NarrowHeroBoxes, % this.Settings["NarrowHeroBoxes"]
		GuiControl, ICScriptHub:, g_GSF_SoundMuted, % this.Settings["SoundMuted"]
	}
	
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide
		local sanityChecked := this.SanityCheckSettings()
		this.CheckMissingOrExtraSettings()
		this.Settings["TargetFramerate"] := g_GSF_TargetFramerate
		this.Settings["PercentOfParticlesSpawned"] := g_GSF_PercentOfParticlesSpawned
		this.Settings["ReduceFramerateWhenNotInFocus"] := g_GSF_ReduceFramerateWhenNotInFocus
		this.Settings["UseConsolePortraits"] := g_GSF_UseConsolePortraits
		this.Settings["FormationSaveIncludeFeatsCheck"] := g_GSF_FormationSaveIncludeFeatsCheck
		this.Settings["NarrowHeroBoxes"] := g_GSF_NarrowHeroBoxes
		this.Settings["SoundMuted"] := g_GSF_SoundMuted
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
		if (this.IsGameClosed() AND this.InstanceID != "")
		{
			this.UpdateMainStatus("Game is closed. Verifying settings.")
			if (this.GameSettingsFileLocation != "" AND FileExist(this.GameSettingsFileLocation))
			{
				g_GSF_settingsFile := this.ReadAndEditSettingsString(this.GameSettingsFileLocation)
				if (this.MadeChanges)
					this.WriteSettingsStringToFile(g_GSF_settingsFile, this.GameSettingsFileLocation)
			}
			this.InstanceID := ""
		}
		else if (!this.IsGameClosed())
		{
			if (this.GameSettingsFileLocation == "" OR !FileExist(this.GameSettingsFileLocation))
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
		this.GameSettingsFileLocation := settingsFileLoc
		GuiControl, ICScriptHub:, g_GSF_GameSettingsFileLocation, % settingsFileLoc
	}
	
	ReadAndEditSettingsString(g_GSF_settingsFileLoc)
	{
		local g_GSF_settingsFile
		local g_GSF_numChanges
		this.MadeChanges := false
		FileRead, g_GSF_settingsFile, %g_GSF_settingsFileLoc%
		for k,v in this.Settings
		{
			g_GSF_numChanges := 0
			g_GSF_before := g_GSF_settingsFile
			g_GSF_after := RegExReplace(g_GSF_before, """" k """: (false|true)", """" k """: " (v == 0 ? "false" : "true"), g_GSF_numChanges)
			if (g_GSF_before != g_GSF_after) {
				this.MadeChanges := true
				continue
			}
			g_GSF_after := RegExReplace(g_GSF_before, """" k """: ([0-9]+)", """" k """: " v)
			if (g_GSF_before != g_GSF_after)
				this.MadeChanges := true
		}
		return g_GSF_settingsFile
	}
	
	WriteSettingsStringToFile(g_GSF_SettingsFile, g_GSF_settingsFileLoc)
	{
		g_GSF_newFile := FileOpen(g_GSF_settingsFileLoc, "w")
		if (!IsObject(g_GSF_newFile))
		{
			this.UpdateMainStatus("Error. Could not write to the settings file this time.")
			this.InstanceID := ""
			g_GSF_settingsFile := ""
			return
		}
		g_GSF_newFile.Write(g_GSF_settingsFile)
		g_GSF_newFile.Close()
		g_GSF_settingsFile := ""
		this.UpdateMainStatus("Game settings file had changes. Corrected.")
		this.FixedCounter++
		GuiControl, ICScriptHub:, g_GSF_NumTimesFixed, % this.FixedCounter
	}
	
	IsGameClosed()
	{
		if(g_SF.Memory.ReadCurrentZone() == "")
			if (Not WinExist( "ahk_exe " . g_userSettings[ "ExeName"] ))
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
	}
	
}