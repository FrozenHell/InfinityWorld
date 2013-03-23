/**
 *	GFxMovie_SimpleSelect
 *
 *	Creation date: 23.03.2013 07:42
 *	Copyright 2013, FHS
 */
class GFxMovie_SimpleSelect extends GFxMoviePlayer;

delegate MenuEvent(int intEvent);

// ����� ������
function bool Start(optional bool startPaused = false)
{
	super.Start(startPaused);
	PlayerOwner.PlayerInput.ResetInput();
	PlayerOwner.Pawn.ZeroMovementVariables();
	SetFocus(true);
	return true;
}

// ��������� ������
event OnClose()
{
	// ���������� ����������
	SetFocus(false, false);
}

// �������, ���������� �� AS
function OptionSelected(int optionNum)
{
	MenuEvent(optionNum);
}

// ������������� ������
function Initialize(PlayerController pCont)
{
	PlayerOwner = pCont;
}

defaultproperties
{
	//MovieInfo=
}
