/**
 *	LiftDoor
 *
 *	Creation date: 19.03.2013 01:24
 *	Copyright 2013, FHS
 */
class LiftDoor extends SkeletalMeshActor;

// открыта или закрыта дверь
var bool bClosed;

var AnimNodeSlot FullBodyAnimSlot;

/*
simulated function OnToggle(SeqAct_Toggle action)
{
	local AnimNodeSequence SeqNode;

	SeqNode = AnimNodeSequence(SkeletalMeshComponent.Animations);

	// Turn ON
	if (action.InputLinks[0].bHasImpulse)
	{
		// If animation is not playing - start playing it now.
		if(!SeqNode.bPlaying)
		{
			// This starts the animation playing from the beginning. Do we always want that?
			SeqNode.PlayAnim(SeqNode.bLooping, SeqNode.Rate, 0.0);
		}
	}
	// Turn OFF
	else if (action.InputLinks[1].bHasImpulse)
	{
		// If animation is playing, stop it now.
		if(SeqNode.bPlaying)
		{
			SeqNode.StopAnim();
		}
	}
	// Toggle
	else if (action.InputLinks[2].bHasImpulse)
	{
		// Toggle current animation state.
		if(SeqNode.bPlaying)
		{
			SeqNode.StopAnim();
		}
		else
		{
			SeqNode.PlayAnim(SeqNode.bLooping, SeqNode.Rate, 0.0);
		}
	}
}*/

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetPhysics(PHYS_Interpolating);
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
   super.PostInitAnimTree( SkelComp );
   
   //if (SkelComp == Mesh)
   //{
      FullBodyAnimSlot = AnimNodeSlot(SkelComp.FindAnimNode('DoorOpening'));
   //}
}

function OpenDoor()
{
	FullBodyAnimSlot.PlayCustomAnim('DoorOpening', 1.0, 0.1, 0.1, False, True);
}

function CloseDoor()
{
	
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		CollideActors=TRUE //@warning: leave at TRUE until backwards compatibility code is removed (bCollideActors_OldValue, etc)
		BlockActors=TRUE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		
		SkeletalMesh=SkeletalMesh'Houses.Lifts.LiftDoor'
		PhysicsAsset=None
		AnimSets(0)=AnimSet'Houses.Lifts.LiftDoor_AnimSet'
		bUpdateSkelWhenNotRendered=false
	End Object
	CollisionComponent=SkeletalMeshComponent0
	SkeletalMeshComponent=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)
	bMovable = True
	bStatic = false
	bNoDelete = false
	
	bClosed = true;
}
