class UIRecruitmentListItem_LWotC extends UIRecruitmentListItem;

simulated function InitRecruitItem(XComGameState_Unit Recruit)
{
	super.InitRecruitItem(Recruit);

	UpdateExistingUI();
	AddIcons(Recruit);

	// LW : Hack : Undo the height override set by UIListItemString; don't use SetHeight, as UIListItemString can't handle it.
	Height = 64;
	MC.ChildSetNum("theButton", "_height", 64);
	List.OnItemSizeChanged(self);
}

function UpdateExistingUI()
{
	local UIPanel DividerLine;

	bAnimateOnInit = false;

	// LW : Move confirm button up.
	ConfirmButton.SetY(0);
	// LW : Move soldier name up
	MC.ChildSetNum("soldierName", "_y", 5);
	// LW : Update flag size and position
	MC.BeginChildFunctionOp("flag", "setImageSize");  
	MC.QueueNumber(81);
	MC.QueueNumber(42);
	MC.EndOp();
	MC.ChildSetNum("flag", "_x", 7);
	MC.ChildSetNum("flag", "_y", 10.5);
	// LW : Extend divider line
	DividerLine = Spawn(class'UIPanel', self);
	DividerLine.InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	DividerLine.SetColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	DividerLine.SetSize(1, 21.5);
	DividerLine.SetPosition(90.6, 36.75);
	DividerLine.SetAlpha(66.40625);
}

function AddIcons(XComGameState_Unit Recruit)
{
	local bool PsiStatIsVisible;
	local float XLoc, YLoc, XDelta;
	
	PsiStatIsVisible = `XCOMHQ.IsTechResearched('AutopsySectoid');

	// KDM : Stat icons, and their associated stat values, have to be manually placed.
	XLoc = 97;
	YLoc = 34.5f;
	XDelta = 65.0f;

	if (PsiStatIsVisible)
	{
		XDelta -= 10.0f;
	}

	InitIconValuePair(Recruit, eStat_Offense, "Aim", "UILibrary_LWToolbox.StatIcons.Image_Aim", XLoc, YLoc);
	XLoc += XDelta;
	InitIconValuePair(Recruit,	eStat_Defense, "Defense", "UILibrary_LWToolbox.StatIcons.Image_Defense", XLoc, YLoc);
	XLoc += XDelta;
	InitIconValuePair(Recruit, eStat_HP, "Health", "UILibrary_LWToolbox.StatIcons.Image_Health", XLoc, YLoc);
	XLoc += XDelta;
	InitIconValuePair(Recruit, eStat_Mobility, "Mobility", "UILibrary_LWToolbox.StatIcons.Image_Mobility", XLoc, YLoc);
	XLoc += XDelta;
	InitIconValuePair(Recruit, eStat_Will, "Will", "UILibrary_LWToolbox.StatIcons.Image_Will", XLoc, YLoc);
	XLoc += XDelta;
	InitIconValuePair(Recruit, eStat_Hacking, "Hacking", "UILibrary_LWToolbox.StatIcons.Image_Hacking", XLoc, YLoc);
	XLoc += XDelta;
	InitIconValuePair(Recruit, eStat_Dodge, "Dodge", "UILibrary_LWToolbox.StatIcons.Image_Dodge", XLoc, YLoc);
	
	if (PsiStatIsVisible)
	{
		XLoc += XDelta;
		InitIconValuePair(Recruit, eStat_PsiOffense, "Psi", "gfxXComIcons.promote_psi", XLoc, YLoc);
	}
}

function InitIconValuePair(XComGameState_Unit Recruit, ECharStatType StatType, string MCRoot, string ImagePath, float XLoc, float YLoc)
{
	local float IconScale, XOffset, YOffset;
	local UIImage StatIcon;
	local UIText StatValue;

	IconScale = 0.65f;
	XOffset = 26.0f;
	
	if (GetLanguage() == "JPN")
	{
		YOffset = -3.0;
	}

	if (StatIcon == none)
	{
		StatIcon = Spawn(class'UIImage', self);
		StatIcon.bAnimateOnInit = false;
		StatIcon.InitImage(, ImagePath);
		StatIcon.SetScale(IconScale);
		StatIcon.SetPosition(XLoc, YLoc);
	}
	
	if (StatValue == none)
	{
		StatValue = Spawn(class'UIText', self);
		StatValue.bAnimateOnInit = false;
		// KDM : Give each stat UIText a unique name, so that it can be accessed by that name when list item focus changes.
		StatValue.InitText(name(MCRoot $ "_LWotC"));
		StatValue.SetPosition(XLoc + XOffset, YLoc + YOffset);
	}

	StatValue.Text = string(int(Recruit.GetCurrentStat(StatType)));
	StatValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(StatValue.Text, eUIState_Normal));
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	RefreshStatText();
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();
	RefreshStatText();
}

function RefreshStatText()
{
	UpdateText("Aim");
	UpdateText("Defense");
	UpdateText("Health");
	UpdateText("Mobility");
	UpdateText("Will");
	UpdateText("Hacking");
	UpdateText("Dodge");
	UpdateText("Psi");
}

function UpdateText(string MCRoot)
{
	local bool Focused;
	local string OriginalText;
	local UIText StatValue;

	Focused = bIsFocused;
	
	// KDM : Get the UIText according to its name.
	StatValue = UIText(GetChildByName(name(MCRoot $ "_LWotC"), false));
	
	if (StatValue != none)
	{
		OriginalText = StatValue.Text;
		// KDM : Change the text colour based on whether this list item is focused or not.
		StatValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(OriginalText, (Focused ? -1 : eUIState_Normal)));
	}
}


/*
event OnReceiveFocus(UIScreen Screen)
{
    local UIRecruitSoldiers RecruitScreen;
    local int i;

    RecruitScreen = UIRecruitSoldiers(Screen);
    if (RecruitScreen == none)
    {
        return;
    }

    for (i = 0; i < RecruitScreen.List.ItemContainer.ChildPanels.Length; i++)
    {
        class'UIRecruitmentListItem_LW'.static.UpdateItemsForFocus(UIRecruitmentListItem(RecruitScreen.List.ItemContainer.ChildPanels[i]));
    }
}

event OnLoseFocus(UIScreen Screen)
{
    local UIRecruitSoldiers RecruitScreen;
    local int i;

    RecruitScreen = UIRecruitSoldiers(Screen);
    if (RecruitScreen == none)
    {
        return;
    }

    for (i = 0; i < RecruitScreen.List.ItemContainer.ChildPanels.Length; i++)
    {
        class'UIRecruitmentListItem_LW'.static.UpdateItemsForFocus(UIRecruitmentListItem(RecruitScreen.List.ItemContainer.ChildPanels[i]));
    }
}

static function UpdateItemsForFocus(UIRecruitmentListItem ListItem)
{
	local bool bReverse;

	bReverse = ListItem.bIsFocused && !ListItem.bDisabled;

	UpdateText(ListItem, "Aim", bReverse);
	UpdateText(ListItem, "Defense", bReverse);
	UpdateText(ListItem, "Health", bReverse);
	UpdateText(ListItem, "Mobility", bReverse);
	UpdateText(ListItem, "Will", bReverse);
	UpdateText(ListItem, "Hacking", bReverse);
	UpdateText(ListItem, "Dodge", bReverse);
	UpdateText(ListItem, "Psi", bReverse);
}

static function UpdateText(UIRecruitmentListItem ListItem, string MCRoot, bool bReverse)
{
	local name LookupMCName;
	local UIText Value;
	local string OldText;

	LookupMCName = name("RecruitmentItem_" $ MCRoot $ "Value_LW");
	Value = UIText(ListItem.GetChildByName(LookupMCName, false));
	if (Value != none)
	{
		OldText = Value.Text;
		Value.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(OldText, (bReverse ? -1 : eUIState_Normal)));
	}
}

*/















/*
static function AddRecruitStats(XComGameState_Unit Recruit, UIRecruitmentListItem ListItem)
{
	local UIPanel kLine;

	ListItem.bAnimateOnInit = false;

	//shift confirm button up
	ListItem.ConfirmButton.SetY(0);

	//shift soldier name up
	ListItem.MC.ChildSetNum("soldierName", "_y", 5);

	// update flag size and position
	ListItem.MC.BeginChildFunctionOp("flag", "setImageSize");  
	ListItem.MC.QueueNumber(81);			// add number Value
	ListItem.MC.QueueNumber(42);			// add number Value
	ListItem.MC.EndOp();					// add delimiter and process command
	ListItem.MC.ChildSetNum("flag", "_x", 7);
	ListItem.MC.ChildSetNum("flag", "_y", 10.5);

	// extend divider line
	kLine = ListItem.Spawn(class'UIPanel', ListItem);
	kLine.InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	kLine.SetColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	kLine.SetSize(1, 21.5).SetPosition(90.6, 36.75).SetAlpha(66.40625);

	AddIcons(Recruit, ListItem);

	// HAX: Undo the height override set by UIListItemString
	Listitem.Height = 64; // don't use SetHeight here, as UIListItemString can't handle it
	ListItem.MC.ChildSetNum("theButton", "_height", 64);

	ListItem.List.OnItemSizeChanged(ListItem);
}

static function AddIcons(XComGameState_Unit Unit, UIRecruitmentListItem ListItem)
{
	local float IconXPos, IconYPos, IconXDelta;
	local bool PsiStatIsVisible;

	PsiStatIsVisible = `XCOMHQ.IsTechResearched('AutopsySectoid');

	IconYPos = 34.5f;
	IconXPos = 97;
	IconXDelta = 65.0f;

	if(PsiStatIsVisible) {
		IconXDelta -= 10.0f;
	}

	InitIconValuePair(Unit, ListItem,	eStat_Offense,	"Aim",		"UILibrary_LWToolbox.StatIcons.Image_Aim",		IconXPos, IconYPos);
	IconXPos += IconXDelta;
	InitIconValuePair(Unit, ListItem,	eStat_Defense,	"Defense",	"UILibrary_LWToolbox.StatIcons.Image_Defense",	IconXPos, IconYPos);
	IconXPos += IconXDelta;
	InitIconValuePair(Unit, ListItem,	eStat_HP,		"Health",	"UILibrary_LWToolbox.StatIcons.Image_Health",	IconXPos, IconYPos);
	IconXPos += IconXDelta;
	InitIconValuePair(Unit, ListItem,	eStat_Mobility,	"Mobility",	"UILibrary_LWToolbox.StatIcons.Image_Mobility",	IconXPos, IconYPos);
	IconXPos += IconXDelta;
	InitIconValuePair(Unit, ListItem,	eStat_Will,		"Will",		"UILibrary_LWToolbox.StatIcons.Image_Will",		IconXPos, IconYPos);
	IconXPos += IconXDelta;
	InitIconValuePair(Unit, ListItem,	eStat_Hacking,	"Hacking",	"UILibrary_LWToolbox.StatIcons.Image_Hacking",	IconXPos, IconYPos);
	IconXPos += IconXDelta;
	InitIconValuePair(Unit, ListItem,	eStat_Dodge,	"Dodge",	"UILibrary_LWToolbox.StatIcons.Image_Dodge",	IconXPos, IconYPos);
	
	if(PsiStatIsVisible) {
		IconXPos += IconXDelta;
		InitIconValuePair(Unit, ListItem,   eStat_PsiOffense, "Psi",	"gfxXComIcons.promote_psi",      IconXPos, IconYPos);
	}
}

static function InitIconValuePair(XComGameState_Unit Unit, UIRecruitmentListItem ListItem, ECharStatType StatType, string MCRoot,  string ImagePath, float XPos, float YPos)
{
	local UIImage Icon;
	local UIText Value;
	local float IconScale, IconToValueOffsetX, IconToValueOffsetY;

	IconScale = 0.65f;
	IconToValueOffsetX = 26.0f;
	if(GetLanguage() == "JPN")
	{
		IconToValueOffsetY = -3.0;
	}
	if(Icon == none)
	{
		Icon = ListItem.Spawn(class'UIImage', ListItem);
		Icon.InitImage(name("RecruitmentItem_" $ MCRoot $ "Icon_LW"), ImagePath).SetScale(IconScale).SetPosition(XPos, YPos);
		Icon.bAnimateOnInit = false;
	}
	if(Value == none)
	{
		Value = UIText(ListItem.Spawn(class'UIText', ListItem).InitText().SetPosition(XPos + IconToValueOffsetX, YPos + IconToValueOffsetY));
		Value.MCName = name("RecruitmentItem_" $ MCRoot $ "Value_LW");
		Value.bAnimateOnInit = false;
	}
	Value.Text = string(int(Unit.GetCurrentStat(StatType)));
	Value.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(Value.Text, eUIState_Normal));
}
*/