global g_BrivGemFarm_HideDefaultProfile := new IC_BrivGemFarm_HideDefaultProfile_Component

if(IsObject(IC_BrivGemFarm_Component))
{
	g_BrivGemFarm_HideDefaultProfile.InjectAddon()
}
else
{
	MsgBox, 48, Missing Dependency, The HideDefaultProfile addon requires the IC Core (v0.1.1) and Briv Gem Farm (v1.4.7) addons to function. You are either missing one or both of those - or they are not sufficiently updated.
	return
}

g_BrivGemFarm_HideDefaultProfile.Init()

Class IC_BrivGemFarm_HideDefaultProfile_Component
{

	; ================================
	; ===== LOADING AND SETTINGS =====
	; ================================

	InjectAddon()
	{
		local splitStr := StrSplit(A_LineFile, "\")
		local addonDirLoc := splitStr[(splitStr.Count()-1)]
		local addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_BrivGemFarm_HideDefaultProfile_Addon.ahk`n"
		FileAppend, %addonLoc%, %g_BrivFarmModLoc%
	}
	
	Init()
	{
		Global
		this.HideDefaultProfile()
		Gui, Submit, NoHide
	}
	
	HideDefaultProfile()
	{
		local bgf_hdp_selected := BrivDropDownSettings
		local bgf_hdp_ddl := ""
		ControlGet, bgf_hdp_ddl, List, , , ahk_id %BrivDropDownSettingsHWND%
		bgf_hdp_newString := "|"
		Loop, Parse, bgf_hdp_ddl, `n
		{
			if (A_LoopField == "Default")
				continue
			bgf_hdp_newString .= A_LoopField "|"
			if (A_LoopField == bgf_hdp_selected)
				bgf_hdp_newString .= "|"
		}
		if (bgf_hdp_newString == "|")
			bgf_hdp_newString .= "Default||"
		GuiControl, ICScriptHub:, BrivDropDownSettings, %bgf_hdp_newString%
	}
	
}