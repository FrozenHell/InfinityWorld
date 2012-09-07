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

var() const editconst StaticMeshComponent	StaticMeshComponent;

public function Use(Pawn uInstigator)
{
	`log(Name@"был использован");
	PlaySound(SoundCue'A_Gameplay.Gameplay.MessageBeepCue', true);
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
