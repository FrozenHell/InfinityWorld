/**
 *	BaseArmor
 *
 *	Creation date: 19.04.2013 12:48
 *	Copyright 2013, Nikita
 */
class BaseArmor extends BaseItem;

function PostBeginPlay()
{
	super.PostBeginPlay(); 	
}

defaultproperties
{
	Class_ID = 4	
	Mass = 1.0
	Description = "Base class for any armors"
	Item_type = ARMOR		
	
	//Components.Remove(StaticMeshComponent0)	
	
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh=StaticMesh'Pickups.Armor.Mesh.S_Pickups_Armor'
	End Object
	CollisionComponent=StaticMeshComponent1
	StaticMeshComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)
	
}
