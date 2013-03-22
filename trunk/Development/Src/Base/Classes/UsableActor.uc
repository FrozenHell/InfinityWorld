/**
 *	UsableActor
 *
 *	Creation date: 01.04.2012 22:10
 *	Copyright 2013, FHS
 *	
 *	Актёр для тестирования определённых функций, связанных с использованием объектов
 *	Не используйте его в конечном проекте
 */
class UsableActor extends Actor
	placeable
	implements(Useable);

// действия, которые можно совершить над объектом
var() array<Action> Actions;

// Игровая модель для объекта
var() const editconst StaticMeshComponent StaticMeshComponent;

// UsableActor_ID для Event кисмета "Use UsabeActor"
var() int Kismet_ID;

// забрать значение ActionName
public function String GetActionName(optional int actionIndex = 0)
{
	return Actions[actionIndex].Name;
}

public function Use(Pawn uInstigator, optional int actionIndex = 0)
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
		// если это обработчик нужного действия именно этого актёра
		if (
			individualEvent.IsA('SeqEvent_UseUsableActor')
			&&
			SeqEvent_UseUsableActor(individualEvent).UsableActor_ID == Kismet_ID
			&&
			SeqEvent_UseUsableActor(individualEvent).UsableActor_ActionId == actionIndex
			)
		{
			// активируем Event
			SequenceEvent(individualEvent).CheckActivate(self, uInstigator);
			// выходим, обработав только один Event
			break;
		}
	}
}

public function bool GetUseable(optional int actionIndex = 0)
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
	Actions[0] = (Name = "использовать", bActive = true)
}
