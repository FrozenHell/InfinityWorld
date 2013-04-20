/**
 *	UsableActor
 *
 *	Creation date: 01.04.2012 22:10
 *	Copyright 2013, FHS
 *	
 *	���� ��� ������������ ����������� �������, ��������� � �������������� ��������
 *	�� ����������� ��� � �������� �������
 */
class UsableActor extends Actor
	placeable
	implements(Useable);

// ��������, ������� ����� ��������� ��� ��������
var() array<Action> Actions;

// ������� ������ ��� �������
var() const editconst StaticMeshComponent StaticMeshComponent;

// UsableActor_ID ��� Event ������� "Use UsabeActor"
var() int Kismet_ID;

// ������� �������� ActionName
public function String GetActionName(optional int actionIndex = 0)
{
	return Actions[actionIndex].Name;
}

public function Use(Pawn uInstigator, optional int actionIndex = 0)
{
	// �������� foreach
	local SequenceObject individualEvent;
	// ��� ������� ������� �������������� ������������� UsableActor
	local array<SequenceObject> eventList;
	
	// ������������� ���� �������������
	PlaySound(SoundCue'A_Gameplay.Gameplay.MessageBeepCue', true);
	
	// ���� ��� ����������� ������������� UsableActor
	WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqEvent_UseUsableActor', true, eventList);
	// ���� ��� SeqEvent � �������
	foreach eventList(individualEvent)
	{
		// ���� ��� ���������� ������� �������� ������ ����� �����
		if (
			individualEvent.IsA('SeqEvent_UseUsableActor')
			&&
			SeqEvent_UseUsableActor(individualEvent).UsableActor_ID == Kismet_ID
			&&
			SeqEvent_UseUsableActor(individualEvent).UsableActor_ActionId == actionIndex
			)
		{
			// ���������� Event
			SequenceEvent(individualEvent).CheckActivate(self, uInstigator);
			// �������, ��������� ������ ���� Event
			break;
		}
	}
	
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

public function FirstAction(Pawn uInstigator)
{
	// ������ ��������
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
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh=StaticMesh'LT_Light.SM.Mesh.S_LT_Light_SM_Light01'
	End Object
	CollisionComponent=StaticMeshComponent0
	StaticMeshComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)
	bEdShouldSnap=true
	bStatic=false
	bMovable=true
	bCollideActors=true
	bBlockActors=true
	bWorldGeometry=true
	bGameRelevant=true
	bRouteBeginPlayEvenIfStatic=false
	bCollideWhenPlacing=false
	Actions[0] = (Name = "������������", bActive = true)
}
