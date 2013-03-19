/**
 *	GFxMovie_TouchScreen
 *
 *	Creation date: 02.03.2013 15:16
 *	Copyright 2013, FHS
 */
class GFxMovie_TouchScreen extends GFxMoviePlayer;

function bool Start(optional bool startPaused = false)
{
	super.Start(startPaused);
	// переходим на первый кадр ролика
	Advance(0.f);
	//PlayerOwner.PlayerInput.ResetInput();
	//PlayerOwner.Pawn.ZeroMovementVariables();
	return true;
}

function Initialize()
{
	Start(true);
}

function MoveCursor(float locX, float locY)
{
	local ASValue arg;
	local array<ASValue> args;
	// первый аргумент
	arg.Type = AS_Number;
	arg.n = locX;
	args.AddItem(arg);
	// второй аргумент
	arg.Type = AS_Number;
	arg.n = locY;
	args.AddItem(arg);
	// вызываем функцию из AS
	Invoke("_root.MoveCursor", args);
}

// нажали на экран
function Tap()
{
	ActionScriptVoid("_root.Tap");
}

// экран больше не в фокусе
function UnFocus()
{
	ActionScriptVoid("_root.UnFocus");
}


defaultproperties
{
	MovieInfo=SwfMovie'TouchScreen.TouchScreen_Movie'
	RenderTexture=TextureRenderTarget2D'TouchScreen.TouchScreen_RT'
}
