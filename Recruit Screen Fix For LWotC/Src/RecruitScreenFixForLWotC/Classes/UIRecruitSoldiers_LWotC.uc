class UIRecruitSoldiers_LWotC extends UIRecruitSoldiers;

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
