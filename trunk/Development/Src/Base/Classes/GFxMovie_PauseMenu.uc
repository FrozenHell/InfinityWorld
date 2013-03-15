/**
 *	GFxMovie_PauseMenu
 *
 *	Creation date: 15.03.2013 01:37
 *	Copyright 2013, FHS
 */
class GFxMovie_PauseMenu extends GFxMoviePlayer;

// делегат для функции из онтроллера
delegate PauseMenuEvent(int intEvent);

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
	PauseMenuEvent(optionNum);
}

// инициализация ролика
function Initialize(PlayerController pCont)
{
	PlayerOwner = pCont;
}

defaultproperties
{
	MovieInfo=SwfMovie'GFUX.PauseMenu.PauseMenu'
}
