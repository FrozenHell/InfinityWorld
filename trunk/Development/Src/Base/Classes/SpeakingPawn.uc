/**
 *	SpeakingPawn
 *
 *	Creation date: 03.04.2012 18:08
 *	Copyright 2013, FrozenHell Skyline
 */
class SpeakingPawn extends UTPawn // надо будет наследовать от другого класса
	implements(Useable);

// поле, отображаемое на HUD ("Нажмите F чтобы"@ActionName)
var() String ActionName;

// Доступен ли объект для использования
var bool bUseable;

var Dialog Dialog;

// звуки
var SoundCue ExpectingSample;
var SoundCue WarningSample;
var SoundCue AttackingSample;

// нативные функции
function PlayExpectingSample()
{
    PlaySound (ExpectingSample);
}

function PlayWarningSound()
{
    PlaySound (WarningSample);
}

function PlayAttackingSound()
{
    PlaySound (AttackingSample);
}

// функция вызывается из класса Dialog
function DialogClosed()
{
	bUseable = true;
}

// забрать значение ActionName
public function String GetActionName()
{
	return ActionName;
}

// заговорить с пауном
public function Use(Pawn uInstigator)
{
	if (Dialog == None)
		Dialog = new class'Base.Dialog';
	Dialog.StartNewTalk(1, 1);
	Dialog.DialogClosed = DialogClosed;
	bUseable = false;
	//`log(Name@"был потревожен");
}

public function bool GetUseable()
{
	return bUseable;
}

defaultproperties
{
	SightRadius = 50000
    PeripheralVision = 0.00
    
	//ExpectingSample = SoundCue'ourgame.Expecting_Cue'
	//WarningSample = SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagAlarm_Cue'
	//AttackingSample = SoundCue'ourgame.Attacking_Cue'  
	
	ActionName="говорить"
	bUseable = true

	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)
}
