class UIScreenListener_RecruitSoldiers extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIRecruitSoldiers_LWotC RecruitScreen;
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;

	HQPres.ScreenStack.Pop(Screen);
	RecruitScreen = HQPres.Spawn(class'UIRecruitSoldiers_LWotC', HQPres);
	HQPres.ScreenStack.Push(RecruitScreen);
}

defaultproperties
{ 
	// KDM : Only listen for the UIRecruit_Soldiers screen.
	ScreenClass = class'UIRecruit_Soldiers';
}
