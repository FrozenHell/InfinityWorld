/**
 *	GFxMovie_PlayerHUD
 *
 *	Creation date: 02.03.2013 20:29
 *	Copyright 2013, FHS
 */
class GFxMovie_PlayerHUD extends GFxMoviePlayer;

function bool Start(optional bool startPaused = false)
{
	super.Start(startPaused);
	// переходим на первый кадр ролика
	Advance(0.f);
	//PlayerOwner.PlayerInput.ResetInput();
	//PlayerOwner.Pawn.ZeroMovementVariables();
	return true;
}

function initialize()
{
	Start(true);
}

function AddAction(String ActionName)
{
	local ASValue arg;
	local array<ASValue> args;
	
	arg.Type = AS_String;
	arg.s = ActionName;
	args.AddItem(arg);
	
	Invoke("_root.AddAction", args);
}

function RemoveActions()
{
	ActionScriptVoid("_root.RemoveActions");
}

defaultproperties
{
	MovieInfo=SwfMovie'GFxUI_UniverseHUD.HUD_Movie'
}
