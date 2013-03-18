/**
 *	LiftDoor
 *
 *	Creation date: 19.03.2013 01:24
 *	Copyright 2013, FHS
 */
class LiftDoor extends HousePart
	placeable;



defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		CollideActors=TRUE //@warning: leave at TRUE until backwards compatibility code is removed (bCollideActors_OldValue, etc)
		BlockActors=TRUE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		
		SkeletalMesh=SkeletalMesh'Houses.Test1.LiftDoor'
		PhysicsAsset=None
		AnimSets(0)=AnimSet'Houses.Test1.LiftDoor_AnimSet'
		bUpdateSkelWhenNotRendered=false
	End Object
	CollisionComponent=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)
	bMovable = True
}
