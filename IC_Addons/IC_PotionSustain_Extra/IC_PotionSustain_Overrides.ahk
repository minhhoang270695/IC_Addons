Global g_PSBGF_SmallPotThresh := -1
Global g_PSBGF_SmallPotCount := -1

class IC_PotionSustain_SharedData_Class extends IC_SharedData_Class
{
	PSBGF_SetData(thresh,count)
	{
		g_PSBGF_SmallPotThresh := thresh
		g_PSBGF_SmallPotCount := count
	}
	
	PSBGF_GetSmallPotThresh()
	{
		return g_PSBGF_SmallPotThresh
	}
	
	PSBGF_GetSmallPotCount()
	{
		return g_PSBGF_SmallPotCount
	}
	
    PSBGF_Running()
	{
		return true
	}
}

class IC_PotionSustain_BrivGemFarm_Class extends IC_BrivSharedFunctions_Class
{
	DoChests(numSilverChests, numGoldChests)
    {
		buySilvers := false
		if (g_PSBGF_SmallPotThresh >= 0 AND g_PSBGF_SmallPotCount >= 0 AND g_PSBGF_SmallPotCount < g_PSBGF_SmallPotThresh)
			buySilvers = true
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
            if (g_BrivUserSettings[ "OpenSilvers" ] AND amount > 0)
                this.OpenChests( chestID := 1, effectiveStartTime, amount)
            amount := Min(g_SF.TotalGoldChests, serverRateOpen)
            if (g_BrivUserSettings[ "OpenGolds" ] AND amount > 0)
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
}