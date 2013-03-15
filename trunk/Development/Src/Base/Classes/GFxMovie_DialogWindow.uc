/**
 *	GFxMovie_DialogWindow
 *
 *	Creation date: 15.03.2013 00:05
 *	Copyright 2013, FHS
 */
class GFxMovie_DialogWindow extends GFxMoviePlayer;

delegate DialogEvent(int option);

function bool Start(optional bool startPaused = false)
{
	super.Start(startPaused);
	// ��������� �� ������ ���� ������
	Advance(0.f);
	//PlayerOwner.PlayerInput.ResetInput();
	//PlayerOwner.Pawn.ZeroMovementVariables();
	return true;
}

// ��������� ������
function NewDialog(string Quest)
{
	local ASValue arg;
	local array<ASValue> args;
	// ��������
	arg.Type = AS_String;
	arg.s = Quest;
	args.AddItem(arg);
	// �������� ������� �� AS
	Invoke("_root.NewDialog", args);
}

// ��������� ������� ������
function AddOption(string option)
{
	local ASValue arg;
	local array<ASValue> args;
	// ��������
	arg.Type = AS_String;
	arg.s = option;
	args.AddItem(arg);
	// �������� ������� �� AS
	Invoke("_root.AddOption", args);
}

// ������ ���� ����� ������� ������ �������
function ClearDialog()
{
	ActionScriptVoid("_root.ClearDialog");
}

// �������, ���������� �� AS
function OptionSelected(int option)
{
	DialogEvent(option);
}

// ��������� ������
event OnClose()
{
	// ���������� ����������
	SetFocus(false);
}

defaultproperties
{
	MovieInfo=SwfMovie'GFUX.GameDialogs.DialogWindow'
}