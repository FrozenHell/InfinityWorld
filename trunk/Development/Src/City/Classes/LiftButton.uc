/**
 *	LiftButton
 *
 *	Creation date: 03.03.2013 01:13
 *	Copyright 2013, FHS
 */
class LiftButton extends TouchScreen
	notplaceable;

// ��������� ������ �����
var int LiftState;

// ���� �� ������� ����������� ������
var int Floor;

delegate CallLift(int newFloor);

simulated event PostBeginPlay()
{
	// �� �������� ��������� ��� ���������
	Super(UsableActor).PostBeginPlay();
	GFxMovie = new Class'City.GFxMovie_LiftButton';
	GFxMovie.initialize();
	SetState(LiftState);
}

// ������ ��������� �����
function SetState(int locState)
{
	LiftState = locState;
	if (LiftState == 0)
	{
		// ���� �������� ��� �������������
		ActionName = "������� ����";
		bUseable = true;
	}
	else
	{
		// �� ��� ������� ���� ��� �� ����������
		//ActionName = "���������";
		bUseable = false;
	}
	
	GFxMovie_LiftButton(GFxMovie).SetState(locState);
}

function Use(Pawn uInstigator)
{
	if (LiftState == 0)
	{
		CallLift(Floor);
		SetState(1);
	}
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh=StaticMesh'Houses.Lifts.LiftButton_mesh'
	End Object

	LiftState = 0;
	Floor = 0;
}
