// PURPOSE : UIAvengerHUD updates its resource display based upon the screen being shown; unfortunately, it deals with UIRecruitSoldiers,
// but not our custom recruit screen. Therefore, we need to create a listener which listens for the event 'UpdateResources', and sets 
// up the resource display for our custom recruit screen.
class X2EventListener_UpdateResources_RecruitScreen extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate_OnUpdateResources_RecruitScreen());
	
	return Templates;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnUpdateResources_RecruitScreen()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'UpdateResources_RecruitScreen');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('UpdateResources', OnUpdateResources_RecruitScreen, ELD_Immediate);

	return Template;
}

static function EventListenerReturn OnUpdateResources_RecruitScreen(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;

	// KDM : If our custom recruit screen is on top of the screen stack, then set up UIAvengerHUD's resource display.
	if (HQPres.ScreenStack.GetCurrentClass() == class'UIRecruitSoldiers_LWotC')
	{
		// KDM : Display the same information a normal recruit screen would show.
		HQPres.m_kAvengerHUD.UpdateMonthlySupplies();
		HQPres.m_kAvengerHUD.UpdateSupplies();
		HQPres.m_kAvengerHUD.ShowResources();
	}

	return ELR_NoInterrupt;
}
