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
	// переходим на первый кадр ролика
	Advance(0.f);
	//PlayerOwner.PlayerInput.ResetInput();
	//PlayerOwner.Pawn.ZeroMovementVariables();
	return true;
}

// запускаем диалог
function NewDialog(string Quest)
{
	local ASValue arg;
	local array<ASValue> args;
	// аргумент
	arg.Type = AS_String;
	arg.s = Quest;
	args.AddItem(arg);
	// вызываем функцию из AS
	Invoke("_root.NewDialog", args);
}

// добавляем вариант ответа
function AddOption(string option)
{
	local ASValue arg;
	local array<ASValue> args;
	// аргумент
	arg.Type = AS_String;
	arg.s = option;
	args.AddItem(arg);
	// вызываем функцию из AS
	Invoke("_root.AddOption", args);
}

// чистим окно перед показом нового диалога
function ClearDialog()
{
	ActionScriptVoid("_root.ClearDialog");
}

// функция, вызываемая из AS
function OptionSelected(int option)
{
	DialogEvent(option);
}

// остановка ролика
event OnClose()
{
	// возвращаем управление
	SetFocus(false);
}

defaultproperties
{
	MovieInfo=SwfMovie'GFUX.GameDialogs.DialogWindow'
}