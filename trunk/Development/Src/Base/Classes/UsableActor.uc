/**
 *	UsableActor
 *
 *	Creation date: 01.04.2012 22:10
 *	Copyright 2012, FrozenHell Skyline
 *	
 *	Актёр для тестирования определённых функций, связанных с использованием объектов
 *	Не используйте его в конечном проекте
 */
class UsableActor extends Actor
	placeable
	implements(Useable);

// Игровая модель для объекта
var() const editconst StaticMeshComponent	StaticMeshComponent;

// UsableActor_ID для Event кисмета "Use UsabeActor"
var() int Kismet_ID;

public function Use(Pawn uInstigator)
{
	// итератор foreach
	local SequenceObject individualEvent;
	// все объекты кисмета обрабатывающие использование UsableActor
	local array<SequenceObject> eventList;
	
	// Воспроизвести звук использования
	PlaySound(SoundCue'A_Gameplay.Gameplay.MessageBeepCue', true);
	
	// ищем все обработчики использования UsableActor
	WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqEvent_UseUsableActor', true, eventList);
	// Ищем наш SeqEvent в кисмете
	foreach eventList(individualEvent)
	{
		// если это обработчик именно этого актёра
		if (individualEvent.IsA('SeqEvent_UseUsableActor') && SeqEvent_UseUsableActor(individualEvent).UsableActor_ID == Kismet_ID)
		{
			// активируем Event
			SequenceEvent(individualEvent).CheckActivate(self, uInstigator);
			// выходим, обработав только один Event
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
