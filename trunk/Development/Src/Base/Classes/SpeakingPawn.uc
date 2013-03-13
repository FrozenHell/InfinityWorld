/**
 *	SpeakingPawn
 *
 *	Creation date: 03.04.2012 18:08
 *	Copyright 2013, FrozenHell Skyline
 */
class SpeakingPawn extends UTPawn // ���� ����� ����������� �� ������� ������
	implements(Useable);

// ����, ������������ �� HUD ("������� F �����"@ActionName)
var() String ActionName;

// �������� �� ������ ��� �������������
var bool bUseable;

// �����
var SoundCue ExpectingSample;
var SoundCue WarningSample;
var SoundCue AttackingSample;

// �������� �������
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

// ������� �������� ActionName
public function String GetActionName()
{
	return ActionName;
}

// ���������� � ������
public function Use(Pawn uInstigator)
{
	`log(Name@"��� ����������");
}

public function bool GetUseable()
{
	return bUseable;
}

defaultproperties
{
	SightRadius = 50000
    PeripheralVision = 0.00
    
    ExpectingSample = SoundCue'ourgame.Expecting_Cue'
    WarningSample = SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagAlarm_Cue'
    AttackingSample = SoundCue'ourgame.Attacking_Cue'  
	
	ActionName="��������"
	bUseable = true

	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)
}
