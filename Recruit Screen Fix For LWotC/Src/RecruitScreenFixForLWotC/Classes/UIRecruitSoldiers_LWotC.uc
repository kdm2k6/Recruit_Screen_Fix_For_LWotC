class UIRecruitSoldiers_LWotC extends UIRecruitSoldiers DependsOn(UIUtilities_Debug);

var int DEBUG_COMPONENT_INDEX;

simulated function UpdateData()
{
	local int i;
	local XComGameState_Unit Recruit;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	AS_SetTitle(m_strListTitle);

	List.ClearItems();
	m_arrRecruits.Length = 0;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	if(ResistanceHQ != none)
	{
		for(i = 0; i < ResistanceHQ.Recruits.Length; i++)
		{
			Recruit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ResistanceHQ.Recruits[i].ObjectID));
			m_arrRecruits.AddItem(Recruit);
			// KDM : Create and add our custom list item to the list.
			UIRecruitmentListItem_LWotC(List.CreateItem(class'UIRecruitmentListItem_LWotC')).InitRecruitItem(Recruit);
		}
	}

	if(m_arrRecruits.Length > 0)
	{
		List.SetSelectedIndex(0, true);
		List.Navigator.SelectFirstAvailable();
	}
	else
	{
		List.SetSelectedIndex(-1, true);
		AS_SetEmpty(m_strNoRecruits);
	}
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local array<UIPanel> RegularPanels;
	local array<string> FlashPanels;
	local DEBUG_RETURN_VALUE RetVal;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	FlashPanels.length = 0;
	RegularPanels.AddItem(UIListItemString(List.GetItem(0)).ConfirmButton);
	RegularPanels.AddItem(UIRecruitmentListItem_LWotC(List.GetItem(0)).DividerLine);
	RetVal = class'UIUtilities_Debug'.static.UIDebug(self, cmd, DEBUG_COMPONENT_INDEX, RegularPanels, FlashPanels, 1);
	DEBUG_COMPONENT_INDEX = RetVal.COMPONENT_INDEX;
	if (retVal.HANDLED)
	{
		return true;
	}

	return super.OnUnrealCommand(cmd, arg);
}