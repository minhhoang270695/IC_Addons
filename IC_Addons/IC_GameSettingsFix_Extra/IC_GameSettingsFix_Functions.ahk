class IC_GameSettingsFix_Component
{
	TimerFunctions := {}
	DefaultSettings := {"TargetFramerate":600,"PercentOfParticlesSpawned":0,"resolution_x":1280,"resolution_y":720,"resolution_fullscreen":false,"ReduceFramerateWhenNotInFocus":false,"LevelupAmountIndex":4,"UseConsolePortraits":false,"FormationSaveIncludeFeatsCheck":false,"NarrowHeroBoxes":true,"CurrentProfile":""}
	Settings := {}
	GameSettingsFileLocation := ""
	InstanceID := ""
	MadeChanges := false
	FixedCounter := 0
	CurrentProfile := this.DefaultSettings["CurrentProfile"]

	; ================================
	; ===== LOADING AND SETTINGS =====
	; ================================
	
	Init()
	{
		Global
		Gui, Submit, NoHide
		this.LoadSettings()
		this.UpdateProfilesDDL(this.CurrentProfile)
		this.CreateTooltips()
		if (!this.IsGameClosed() AND (this.GameSettingsFileLocation == "" OR !FileExist(this.GameSettingsFileLocation)))
			this.FindSettingsFile()
		this.UpdateMainStatus("Waiting for Gem Farm to start.")
	}
	
	LoadSettings(gsfPathToGetSettings := "")
	{
		Global
		Gui, Submit, NoHide
		writeSettings := false
		if (gsfPathToGetSettings == "")
			gsfPathToGetSettings := g_GSF_SettingsPath
		this.Settings := g_SF.LoadObjectFromJSON(gsfPathToGetSettings)
		if(!IsObject(this.Settings))
		{
			this.SetDefaultSettings()
			writeSettings := true
		}
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(gsfPathToGetSettings, this.Settings)
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
		this.CurrentProfile := this.Settings["CurrentProfile"]
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
		this.Settings["CurrentProfile"] := this.CurrentProfile
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
	
	CreateTooltips()
	{
		TargetFramerateTT := GUIFunctions.GetToolTipTarget("g_GSF_TargetFramerateH")
		ParticlesTT := GUIFunctions.GetToolTipTarget("g_GSF_PercentOfParticlesSpawnedH")
		ResolutionXTT := GUIFunctions.GetToolTipTarget("g_GSF_resolution_xH")
		ResolutionYTT := GUIFunctions.GetToolTipTarget("g_GSF_resolution_yH")
		ResolutionFSTT := GUIFunctions.GetToolTipTarget("g_GSF_resolution_fullscreenH")
		ReduceFPSFocusTT := GUIFunctions.GetToolTipTarget("g_GSF_ReduceFramerateWhenNotInFocusH")
		IncludeFeatsTT := GUIFunctions.GetToolTipTarget("g_GSF_FormationSaveIncludeFeatsCheckH")
		LevelUpIndexTT := GUIFunctions.GetToolTipTarget("g_GSF_LevelupAmountIndexH")
		ConsolePortraitsTT := GUIFunctions.GetToolTipTarget("g_GSF_UseConsolePortraitsH")
		NarrowBenchTT := GUIFunctions.GetToolTipTarget("g_GSF_NarrowHeroBoxesH")
		g_MouseToolTips[TargetFramerateTT] := "Settings -> Graphics -> Target Framerate:`nThis sets the upper-limit for FPS for the game."
		g_MouseToolTips[ParticlesTT] := "Settings -> Graphics -> Particle Amount:`nThe graphics for some abilities can create other little graphical effects`ncalled particles. This sets the proportion of them that can be created."
		g_MouseToolTips[ResolutionXTT] := "Settings -> Display -> Resolution:`nThe width of your game window in pixels."
		g_MouseToolTips[ResolutionYTT] := "Settings -> Display -> Resolution:`nThe height of your game window in pixels."
		g_MouseToolTips[ResolutionFSTT] := "Settings -> Display -> Fullscreen:`nDetermines whether the game covers the entire screen or not."
		g_MouseToolTips[ReduceFPSFocusTT] := "Settings -> Graphics -> Reduce framerate when in background:`nThis will limit the fps of the game (and therefore slow it down) while`nit's hidden behind other windows."
		g_MouseToolTips[IncludeFeatsTT] := "Formation Manager -> Include currently equipped Feats with save:`nDetermines whether a formation save will have feats included or not`nwhen saved."
		g_MouseToolTips[LevelUpIndexTT] := "Level Up Button (Left of BUD/Ultimate bar):`nDetermines how champions are levelled up."
		g_MouseToolTips[ConsolePortraitsTT] := "Settings -> Interface -> Console UI Portraits:`nDetermines whether the portraits for the champions on the bench are the`ncreepy ones that stare into your soul or not."
		g_MouseToolTips[NarrowBenchTT] := "Settings -> Interface -> Narrow Bench Boxes:`nDetermines whether you can see all champions on the bench on low`nresolutions or not."
	}
	
	SaveProfile()
	{
		local profileName
		local defaultText := this.CurrentProfile
		InputBox, profileName, Profile Name, Input the profile name:,,,150,,,,,%defaultText%
		if (profileName == "")
		{
			this.UpdateMainStatus("Cancelled saving profile.")
			return
		}
		local profilePath := g_GSF_ProfilesPath . profileName . ".json"
		if (FileExist(profilePath))
		{
			MsgBox, 52, Overwrite?, This profile already exists. Overwrite it?
			IfMsgBox, No
			{
				this.UpdateMainStatus("Cancelled saving profile.")
				return
			}
		}
		this.CurrentProfile := profileName
		this.SaveSettings()
		local profileSettings = {}
		for k,v in this.Settings
		{
			profileSettings.push(k, v)
		}
		if (!this.IsFolder(g_GSF_ProfilesPath))
			FileCreateDir, % g_GSF_ProfilesPath
		g_SF.WriteObjectToJSON(profilePath, this.Settings)
		this.UpdateProfilesDDL(profileName)
		this.UpdateMainStatus("Saved profile: " profileName)
	}
	
	LoadProfile()
	{
		Global
		Gui, Submit, NoHide
		g_GSF_CurrProfilePath := g_GSF_ProfilesPath g_GSF_Profiles ".json"
		g_GSF_ProfileSettings := g_SF.LoadObjectFromJSON(g_GSF_CurrProfilePath)
		this.Settings := {}
		for k,v in g_GSF_ProfileSettings
		{
			this.Settings.push(k, v)
		}
		this.LoadSettings(g_GSF_CurrProfilePath)
		this.SaveSettings()
		this.UpdateMainStatus("Loaded profile: " g_GSF_Profiles)
	}
	
	DeleteProfile()
	{
		Global
		Gui, Submit, NoHide
		MsgBox, 52, Delete?, Are you sure you want to delete the '%g_GSF_Profiles%' profile?
		IfMsgBox, No
		{
			this.UpdateMainStatus("Cancelled deleting profile.")
			return
		}
		g_GSF_CurrProfilePath := g_GSF_ProfilesPath g_GSF_Profiles ".json"
		FileDelete, % g_GSF_CurrProfilePath
		if (ErrorLevel > 0)
			this.UpdateMainStatus("Failed to delete profile for unknown reasons.")
		else
			this.UpdateMainStatus("Deleted profile: " g_GSF_Profiles)
		if (g_GSF_Profiles == this.CurrentProfile)
		{
			this.CurrentProfile := ""
			this.SaveSettings()
		}
		this.UpdateProfilesDDL(this.CurrentProfile)
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
			this.FixGameSettings()
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
	
	FixGameSettings()
	{
		this.UpdateMainStatus("Game is closed. Verifying settings.")
		if (this.GameSettingsFileLocation != "" AND FileExist(this.GameSettingsFileLocation))
		{
			g_GSF_settingsFile := this.ReadAndEditSettingsString(this.GameSettingsFileLocation)
			if (this.MadeChanges)
				this.WriteSettingsStringToFile(g_GSF_settingsFile, this.GameSettingsFileLocation)
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
		this.ApplySettingsFileLocationGUI(settingsFileLoc)
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
	
	FixSettingsNow()
	{
		if (!this.IsGameClosed())
		{
			MsgBox, 48, Error, Cannot change settings while the game is running.
			return
		}
		this.FixGameSettings()
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
	
	ApplySettingsFileLocationGUI(settingsFileLoc)
	{
		local displayGSFL := this.AddLineBreakToSettingsFileLocation(settingsFileLoc)
		if (displayGSFL[2] >= 1)
		{
			; If a new line was added - increase the height of the 
			GuiControlGet, pos, ICScriptHub:Pos, g_GSF_GameSettingsFileLocation
			local rowHeight := posH
			GuiControlGet, pos, ICScriptHub:Pos, g_GSF_InfoGroupBox
			local oldHeight := posH
			local heightOffset := rowHeight * (displayGSFL[2]+1)
			local newHeight := oldHeight + (heightOffset-rowHeight)
			GuiControl, ICScriptHub:Move, g_GSF_InfoGroupBox, h%newHeight%
			GuiControl, ICScriptHub:Move, g_GSF_GameSettingsFileLocation, h%heightOffset%
		}
		GuiControl, ICScriptHub:, g_GSF_GameSettingsFileLocation, % displayGSFL[1]
	}
	
	UpdateProfilesDDL(nameToSelect := "")
	{
		local ddlList := ""
		local foundName := false
		for k,v in this.ProfilesList(g_GSF_ProfilesPath)
		{
			local profileName := StrReplace(v, ".json", "")
			ddlList .= profileName "|"
			if (profileName == nameToSelect)
			{
				ddlList .= "|"
				foundName := true
			}
		}
		GuiControl, ICScriptHub:, g_GSF_Profiles, |
		GuiControl, ICScriptHub:, g_GSF_Profiles, % ddlList
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
		this.UpdateMainStatus("Waiting for Gem Farm to start.")
	}
	
	; ======================
	; ===== MISC STUFF =====
	; ======================
	
	AddLineBreakToSettingsFileLocation(settingsFileLoc, limit := 80)
	{
		local split := StrSplit(settingsFileLoc, "\")
		local wrapped := ""
		local numNewLinesAdded := 0
		local currLimit := limit
		for k,v in split
		{
			if (StrLen(wrapped) + StrLen(v) + 1  >= currLimit)
			{
				wrapped .= "`n"
				numNewLinesAdded++
				currLimit += limit
			}
			if (k > 1)
				wrapped .= "\"
			wrapped .= v
		}
		return [wrapped,numNewLinesAdded]
	}
	
	ProfilesList(dir)
	{
		local list := []
		if (!this.IsFolder(dir))
			return list
		Loop, Files, %dir%\*.json, DRF
		{
			list.push(A_LoopFileName)
		}
		return list
	}
	
	IsFolder(inputFolder)
	{
		return InStr(FileExist(inputFolder),"D")
	}
	
}