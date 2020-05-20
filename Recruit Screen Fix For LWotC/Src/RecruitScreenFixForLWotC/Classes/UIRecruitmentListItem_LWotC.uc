class UIRecruitmentListItem_LWotC extends UIRecruitmentListItem config(RecruitScreenSettings);

var config int STAT_FONT_SIZE_CTRL;
var config int STAT_Y_OFFSET_CTRL;
var config int STAT_FONT_SIZE_MK;
var config int STAT_Y_OFFSET_MK;

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

	if (`ISCONTROLLERACTIVE)
	{
		YOffset += STAT_Y_OFFSET_CTRL;
	}
	else
	{
		YOffset += STAT_Y_OFFSET_MK;
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
	StatValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(StatValue.Text, eUIState_Normal, GetFontSize()));
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
		StatValue.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(OriginalText, (Focused ? -1 : eUIState_Normal), GetFontSize()));
	}
}

function int GetFontSize()
{
	if (`ISCONTROLLERACTIVE)
	{
		return STAT_FONT_SIZE_CTRL;
	}
	else
	{
		return STAT_FONT_SIZE_MK;
	}
}
