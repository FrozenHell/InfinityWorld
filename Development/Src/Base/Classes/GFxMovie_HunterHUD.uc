/**
 *	GFxMovie_HunterHUD
 *
 *	Creation date: 17.02.2013 04:20
 *	Copyright 2013, FHS
 */
class GFxMovie_HunterHUD extends GFxMoviePlayer;

function bool Start(optional bool startPaused = false)
{
	super.Start(startPaused);
	// переходим на первый кадр ролика
	Advance(0.f);
	//PlayerOwner.PlayerInput.ResetInput();
	//PlayerOwner.Pawn.ZeroMovementVariables();
	return true;
}

function initialize(int floor)
{
	Start(true);
}

function Clear()
{
	ActionScriptVoid("_root.Clear");
}

function Redraw(float angle, float height)
{
	ActionScriptVoid("_root.Redraw");
}

defaultproperties
{
	MovieInfo=SwfMovie'HunterPray.HUD.HunterHUD'
	bAllowInput=false
	bAllowFocus=false
}
