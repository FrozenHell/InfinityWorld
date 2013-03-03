/**
 *	UsableActor
 *
 *	Creation date: 01.04.2012 22:10
 *	Copyright 2012, FrozenHell Skyline
 *	
 *	���� ��� ������������ ����������� �������, ��������� � �������������� ��������
 *	�� ����������� ��� � �������� �������
 */
class UsableActor extends Actor
	placeable
	implements(Useable);

// ������� ������ ��� �������
var() const editconst StaticMeshComponent	StaticMeshComponent;

// UsableActor_ID ��� Event ������� "Use UsabeActor"
var() int Kismet_ID;

public function Use(Pawn uInstigator)
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
		// ���� ��� ���������� ������ ����� �����
		if (individualEvent.IsA('SeqEvent_UseUsableActor') && SeqEvent_UseUsableActor(individualEvent).UsableActor_ID == Kismet_ID)
		{
			// ���������� Event
			SequenceEvent(individualEvent).CheckActivate(self, uInstigator);
			// �������, ��������� ������ ���� Event
			break;
		}
	}
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
}