Global g_PSBGF_BuySilvers := false
Global g_PSBGF_ModronCallParams := ""
Global g_PSBGF_CurrentBuffs := ""
Global g_PSBGF_PreviousBuffs := ""
Global g_PSBGF_InstanceId := ""
Global g_PSBGF_Response := ""
Global g_PSBGF_LogFile := A_LineFile . "\..\logs.json"

class IC_PotionSustain_SharedData_Class extends IC_SharedData_Class
{
	PSBGF_SetBuySilvers(set)
	{
		g_PSBGF_BuySilvers := set
	}
	
	PSBGF_GetBuySilvers()
	{
		return g_PSBGF_BuySilvers
	}
	
	PSBGF_SetModronCallParams(set)
	{
		g_PSBGF_ModronCallParams := set
		RegExMatch(set,"&buffs=[^&]+",g_PSBGF_CurrentBuffs)
	}
	
	PSBGF_GetModronCallParams()
	{
		return g_PSBGF_ModronCallParams
	}
	
	PSBGF_GetIsDifferentCall()
	{
		return g_PSBGF_ModronCallParams != "" AND g_PSBGF_PreviousBuffs != g_PSBGF_CurrentBuffs
	}
	
	PSBGF_SetInstanceId(set)
	{
		g_PSBGF_InstanceId := set
	}
	
    PSBGF_Running()
	{
		return true
	}
	
	PSBGF_GetResponse()
	{
		return g_PSBGF_Response
	}
	
}

class IC_PotionSustain_BrivGemFarm_Class extends IC_BrivSharedFunctions_Class
{
	DoChests(numSilverChests, numGoldChests)
    {
		buySilvers := g_PSBGF_BuySilvers
        serverRateBuy := 250
        serverRateOpen := 1000

        StartTime := A_TickCount
        g_SharedData.LoopString := "Stack Sleep: " . " Buying or Opening Chests"
        loopString := ""
        startingPurchasedSilverChests := g_SharedData.PurchasedSilverChests
        startingPurchasedGoldChests := g_SharedData.PurchasedGoldChests
        startingOpenedGoldChests := g_SharedData.OpenedGoldChests
        startingOpenedSilverChests := g_SharedData.OpenedSilverChests
        currentChestTallies := startingPurchasedSilverChests + startingPurchasedGoldChests + startingOpenedGoldChests + startingOpenedSilverChests
        ElapsedTime := 0
		
		if (g_PSBGF_ModronCallParams != "" AND g_PSBGF_PreviousBuffs != g_PSBGF_CurrentBuffs AND g_PSBGF_InstanceId != "")
		{
			this.SendModronSaveCall(g_PSBGF_ModronCallParams)
			RegExMatch(g_PSBGF_ModronCallParams,"&buffs=[^&]+",g_PSBGF_PreviousBuffs)
			g_PSBGF_ModronCallParams := ""
		}

        doHybridStacking := ( g_BrivUserSettings[ "ForceOfflineGemThreshold" ] > 0 ) OR ( g_BrivUserSettings[ "ForceOfflineRunThreshold" ] > 1 )
        while( ( g_BrivUserSettings[ "RestartStackTime" ] > ElapsedTime ) OR doHybridStacking)
        {
            g_SharedData.LoopString := "Stack Sleep: " . g_BrivUserSettings[ "RestartStackTime" ] - ElapsedTime . " " . loopString
            effectiveStartTime := doHybridStacking ? A_TickCount + 30000 : StartTime ; 30000 is an arbitrary time that is long enough to do buy/open (100/99) of both gold and silver chests.

            ;BUYCHESTS
            gems := g_SF.TotalGems - g_BrivUserSettings[ "MinGemCount" ]
            amount := Min(Floor(gems / 50), serverRateBuy )
            if (buySilvers AND amount > 0)
                this.BuyChests( chestID := 1, effectiveStartTime, amount )
            gems := g_SF.TotalGems - g_BrivUserSettings[ "MinGemCount" ] ; gems can change from previous buy, reset
            amount := Min(Floor(gems / 500) , serverRateBuy )
            if (!buySilvers AND amount > 0)
                this.BuyChests( chestID := 2, effectiveStartTime, amount )
            ; OPENCHESTS
            amount := Min(g_SF.TotalSilverChests, serverRateOpen)
            if (amount > 0)
                this.OpenChests( chestID := 1, effectiveStartTime, amount)
            amount := Min(g_SF.TotalGoldChests, serverRateOpen)
            if (amount > 0)
                this.OpenChests( chestID := 2, effectiveStartTime, amount )

            updatedTallies := g_SharedData.PurchasedSilverChests + g_SharedData.PurchasedGoldChests + g_SharedData.OpenedGoldChests + g_SharedData.OpenedSilverChests
            currentLoopString := this.GetChestDifferenceString(startingPurchasedSilverChests, startingPurchasedGoldChests, startingOpenedGoldChests, startingOpenedSilverChests)
            loopString := currentLoopString == "" ? loopString : currentLoopString

            if (!g_BrivUserSettings[ "DoChestsContinuous" ] ) ; Do one time if not continuous
                return loopString == "" ? "Chests ----" : loopString
            if (updatedTallies == currentChestTallies) ; call failed, likely ran out of time. Don't want to call more if out of time.
                return loopString == "" ? "Chests ----" : loopString
            currentChestTallies := updatedTallies
            ElapsedTime := A_TickCount - StartTime
        }
        return loopString
    }
	
	SendModronSaveCall(params)
	{
		params .= "&instance_id=" . g_PSBGF_InstanceId
		response := g_ServerCall.ServerCall("savemodron",params)
		if(IsObject(response) AND response.success)
			g_PSBGF_Response := ""
		else
		{
			if (!IsObject(response))
				g_PSBGF_Response := % response
			else
				g_PSBGF_Response := % JSON.stringify(response)
			FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
			sanitisedParams := RegExReplace(params, "&user_id=[a-zA-Z0-9]+", "&user_id=____")
			sanitisedParams := RegExReplace(sanitisedParams, "&hash=[a-zA-Z0-9]+", "&hash=____")
			sanitisedParams := RegExReplace(sanitisedParams, "&instance_id=[a-zA-Z0-9]+", "&instance_id=____")
			FileAppend, [%CurrentTime%] `nParams: %sanitisedParams%`nResponse: %g_PSBGF_Response%`n`n, %g_PSBGF_LogFile%
		}
	}
}