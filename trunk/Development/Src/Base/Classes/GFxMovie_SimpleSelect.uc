/**
 *	GFxMovie_SimpleSelect
 *
 *	Creation date: 23.03.2013 07:42
 *	Copyright 2013, FHS
 */
class GFxMovie_SimpleSelect extends GFxMoviePlayer;

delegate MenuEvent(int intEvent);

// вызов ролика
function bool Start(optional bool startPaused = false)
{
	super.Start(startPaused);
	PlayerOwner.PlayerInput.ResetInput();
	PlayerOwner.Pawn.ZeroMovementVariables();
	SetFocus(true);
	return true;
}

// остановка ролика
event OnClose()
{
	// возвращаем управление
	SetFocus(false, false);
}

// функция, вызываемая из AS
function OptionSelected(int optionNum)
{
	MenuEvent(optionNum);
}

// инициализация ролика
function Initialize(PlayerController pCont)
{
	PlayerOwner = pCont;
}

defaultproperties
{
	//MovieInfo=
}
