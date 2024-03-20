
#include %A_LineFile%\..\IC_PotionSustain_Overrides.ahk
#include *i %A_LineFile%\..\..\..\SharedFunctions\SH_UpdateClass.ahk
if (IsObject(SH_UpdateClass))
{
	SH_UpdateClass.UpdateClassFunctions(g_BrivGemFarm, IC_PotionSustain_BrivGemFarm_Class)
	SH_UpdateClass.UpdateClassFunctions(g_SharedData, IC_PotionSustain_SharedData_Class)
}
else
{
	#include *i %A_LineFile%\..\..\..\SharedFunctions\IC_UpdateClass_Class.ahk
	IC_UpdateClass_Class.UpdateClassFunctions(g_BrivGemFarm, IC_PotionSustain_BrivGemFarm_Class)
	IC_UpdateClass_Class.UpdateClassFunctions(g_SharedData, IC_PotionSustain_SharedData_Class)
}