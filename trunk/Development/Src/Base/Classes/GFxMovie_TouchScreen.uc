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
	// ��������� �� ������ ���� ������
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
	// ������ ��������
	arg.Type = AS_Number;
	arg.n = locX;
	args.AddItem(arg);
	// ������ ��������
	arg.Type = AS_Number;
	arg.n = locY;
	args.AddItem(arg);
	// �������� ������� �� AS
	Invoke("_root.MoveCursor", args);
}

// ������ �� �����
function Tap()
{
	ActionScriptVoid("_root.Tap");
}

// ����� ������ �� � ������
function UnFocus()
{
	ActionScriptVoid("_root.UnFocus");
}


defaultproperties
{
	MovieInfo=SwfMovie'TouchScreen.TouchScreen_Movie'
	RenderTexture=TextureRenderTarget2D'TouchScreen.TouchScreen_RT'
}
