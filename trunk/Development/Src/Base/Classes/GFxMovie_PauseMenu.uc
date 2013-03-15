/**
 *	GFxMovie_PauseMenu
 *
 *	Creation date: 15.03.2013 01:37
 *	Copyright 2013, FHS
 */
class GFxMovie_PauseMenu extends GFxMoviePlayer;

// ������� ��� ������� �� ����������
delegate PauseMenuEvent(int intEvent);

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
	PauseMenuEvent(optionNum);
}

// ������������� ������
function Initialize(PlayerController pCont)
{
	PlayerOwner = pCont;
}

defaultproperties
{
	MovieInfo=SwfMovie'GFUX.PauseMenu.PauseMenu'
}
