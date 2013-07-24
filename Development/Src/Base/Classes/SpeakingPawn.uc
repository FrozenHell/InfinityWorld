/**
 *	SpeakingPawn
 *
 *	Creation date: 03.04.2012 18:08
 *	Copyright 2013, FrozenHell Skyline
 */
class SpeakingPawn extends UTPawn // ���� ����� ����������� �� ������� ������
	implements(Useable);

// ��������, ������� ����� ��������� ��� ��������
var() array<Action> Actions;

var Dialog Dialog;

// �����
var SoundCue ExpectingSample;
var SoundCue WarningSample;
var SoundCue AttackingSample;

// �������� �������
function PlayExpectingSample()
{
    //PlaySound(ExpectingSample);
}

function PlayWarningSound()
{
    //PlaySound(WarningSample);
}

function PlayAttackingSound()
{
    //PlaySound(AttackingSample);
}

// ������� ���������� �� ������ Dialog
function DialogClosed()
{
	Actions[0].bActive = true;
}

// ������� �������� ActionName
public function String GetActionName(optional int actionIndex = 0)
{
	return Actions[actionIndex].Name;
}

public function Use(Pawn uInstigator, optional int actionIndex = 0)
{
	switch (actionIndex)
	{
		case 1:
			AdditionalAction1(uInstigator);
			break;
		case 2:
			AdditionalAction2(uInstigator);
			break;
		case 3:
			AdditionalAction3(uInstigator);
			break;
		case 4:
			AdditionalAction4(uInstigator);
			break;
		case 0:
		default:
			FirstAction(uInstigator);
			break;
	}
}

// ���������� � ������
public function FirstAction(Pawn uInstigator)
{
	if (Dialog == None)
		Dialog = new class'Base.Dialog';
	Dialog.StartNewTalk(1, 1);
	Dialog.DialogClosed = DialogClosed;
	Actions[0].bActive = false;
	//`log(Name@"��� ����������");
}

public function AdditionalAction1(Pawn uInstigator)
{
	// ������ �������������� ��������
}

public function AdditionalAction2(Pawn uInstigator)
{
	// ������ �������������� ��������
}

public function AdditionalAction3(Pawn uInstigator)
{
	// ������ �������������� ��������
}

public function AdditionalAction4(Pawn uInstigator)
{
	// �������� �������������� ��������
}

public function bool bGetUsable(optional int actionIndex = 0)
{
	return Actions[actionIndex].bActive;
}

public function int GetActionsCount()
{
	return Actions.Length;
}

defaultproperties
{
	SightRadius = 50000
    PeripheralVision = 0.00
    
	//ExpectingSample = SoundCue'ourgame.Expecting_Cue'
	//WarningSample = SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagAlarm_Cue'
	//AttackingSample = SoundCue'ourgame.Attacking_Cue'  

	Actions[0] = (Name = "��������", bActive = true)

	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)
}
