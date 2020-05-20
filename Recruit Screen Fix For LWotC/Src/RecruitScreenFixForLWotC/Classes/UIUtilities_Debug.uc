class UIUtilities_Debug extends Object;

// ======================================================================================
// =========================== SETUP TO USE =============================================
//
// 1.]	Since the 'Z' key is not bound by default, make sure XComInput.ini has : 
//			[XComGame.XComHeadquartersInput]
//			Bindings=(Name="Z", Command="Z_Key_Press | onrelease Z_Key_Release", bPrimaryBinding=True)
// 2.]	Make sure your class uses : 
//			DependsOn(UIUtilities_Debug)
// 3.]	Make sure your class declares : 
//			var int DEBUG_COMPONENT_INDEX;
// 4.]	Within OnUnrealCommand declare :
//			local array<UIPanel> RegularPanels;
//			local array<string> FlashPanels;
//			local DEBUG_RETURN_VALUE RetVal;
// 5.]	Below CheckInputIsReleaseOrDirectionRepeat do something like this :
//			FlashPanels.length = 0;
//			RegularPanels.AddItem(UIResistanceManagement_ListItem_Custom(List.GetItem(0)).RegionLabel);
//			RegularPanels.AddItem(UIResistanceManagement_ListItem_Custom(List.GetItem(0)).RegionStatusLabel);
//			RetVal = class'UIUtilities_Debug'.static.UIDebug(self, cmd, DEBUG_COMPONENT_INDEX, RegularPanels, FlashPanels, 1);
//			DEBUG_COMPONENT_INDEX = RetVal.COMPONENT_INDEX;
//			if (retVal.HANDLED)
//			{
//				return true;
//			}
//
// NOTES : 
//			- RegularPanels stores UIPanels (and subclasses) that are accessed through normal code.
//			- FlashPanels stores strings to flash UI components, accessed via the movie controller (uncommon usage).
//			- Normally, you will add items to RegularPanels and ignore FlashPanels by setting its length to 0.
//			- The 6th parameter to UIDebug() determines how fast/slow UI component movement is in pixels.
//
// ======================================================================================
// =========================== USAGE INSTRUCTIONS =======================================
//
// 1.] Press the 'Z' key to select the 1st UI component.
// 2.] Press the 'Tab' key to select the next UI component.
// 3.] Press the 'Left Shift' key to select the previous UI component.
// 4.] Use the 'Arrow' keys to move the currently selected UI component up/down/left/right.

struct DEBUG_RETURN_VALUE
{
	var int COMPONENT_INDEX;
	var bool HANDLED;

	structdefaultproperties
	{
		COMPONENT_INDEX = 0
		HANDLED = true
	}
};

function static DEBUG_RETURN_VALUE UIDebug (UIScreen TheScreen, int cmd, int CurrentIndex, 
	array<UIPanel> RegularPanels, array<string> FlashPanels, optional int PixelsToMove  = 1)
{
	local int Loc;
	local string FlashPanel;
	local UIPanel RegularPanel;
	local DEBUG_RETURN_VALUE RetVal;

	RetVal.COMPONENT_INDEX = CurrentIndex;
	RetVal.HANDLED = true;

	if (CurrentIndex >= RegularPanels.Length)
	{
		RegularPanel = none;
	}
	else
	{
		RegularPanel = RegularPanels[CurrentIndex];
	}

	if (CurrentIndex >= FlashPanels.Length)
	{
		FlashPanel = "";
	}
	else
	{
		FlashPanel = FlashPanels[CurrentIndex];
	}

	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_KEY_Z:
			RetVal.COMPONENT_INDEX = 0;
			break;
	
		case class'UIUtilities_Input'.const.FXS_KEY_TAB:
			RetVal.COMPONENT_INDEX = CurrentIndex + 1;
			break;

		case class'UIUtilities_Input'.const.FXS_KEY_LEFT_SHIFT:
			RetVal.COMPONENT_INDEX = CurrentIndex - 1;
			break;

		case class'UIUtilities_Input'.const.FXS_ARROW_UP:
		case class'UIUtilities_Input'.const.FXS_ARROW_DOWN:
		case class'UIUtilities_Input'.const.FXS_ARROW_LEFT:
		case class'UIUtilities_Input'.const.FXS_ARROW_RIGHT:

			// KDM : There is no panel to look at so just escape
			if (RegularPanel == none && FlashPanel == "")
			{
				break;
			}

			// KDM : Move a component up or down
			if (cmd == class'UIUtilities_Input'.const.FXS_ARROW_UP || cmd == class'UIUtilities_Input'.const.FXS_ARROW_DOWN)
			{
				if (RegularPanel != none)
				{
					if (FlashPanel != "")
					{
						Loc = RegularPanel.MC.GetNum(FlashPanel $ "._y");
					}
					else
					{
						Loc = RegularPanel.Y;
					}
				}
				else
				{
					Loc = TheScreen.MC.GetNum(FlashPanel $ "._y");
				}
			
				if (cmd == class'UIUtilities_Input'.const.FXS_ARROW_UP)
				{
					Loc -= PixelsToMove;
				}
				else if (cmd == class'UIUtilities_Input'.const.FXS_ARROW_DOWN)
				{
					Loc += PixelsToMove;
				}
			
				if (RegularPanel != none)
				{
					if (FlashPanel != "")
					{
						RegularPanel.MC.ChildSetNum(FlashPanel, "_y", Loc);
					}
					else
					{
						RegularPanel.SetY(Loc);
					}
				}
				else
				{
					TheScreen.MC.ChildSetNum(FlashPanel, "_y", Loc);
				}

				`Log("The new Y value is :" @ Loc);
			}
			// KDM : Move a component left or right
			if (cmd == class'UIUtilities_Input'.const.FXS_ARROW_LEFT || cmd == class'UIUtilities_Input'.const.FXS_ARROW_RIGHT)
			{
				if (RegularPanel != none)
				{
					if (FlashPanel != "")
					{
						Loc = RegularPanel.MC.GetNum(FlashPanel $ "._x");
					}
					else
					{
						Loc = RegularPanel.X;
					}
				}
				else
				{
					Loc = TheScreen.MC.GetNum(FlashPanel $ "._x");
				}
			
				if (cmd == class'UIUtilities_Input'.const.FXS_ARROW_LEFT)
				{
					Loc -= PixelsToMove;
				}
				else if (cmd == class'UIUtilities_Input'.const.FXS_ARROW_RIGHT)
				{
					Loc += PixelsToMove;
				}
			
				if (RegularPanel != none)
				{
					if (FlashPanel != "")
					{
						RegularPanel.MC.ChildSetNum(FlashPanel, "_x", Loc);
					}
					else
					{
						RegularPanel.SetX(Loc);
					}
				}
				else
				{
					TheScreen.MC.ChildSetNum(FlashPanel, "_x", Loc);
				}

				`Log("The new X value is :" @ Loc);
			}
			break;

			default:
				RetVal.HANDLED = false;
				break;
	}

	return RetVal;
} 