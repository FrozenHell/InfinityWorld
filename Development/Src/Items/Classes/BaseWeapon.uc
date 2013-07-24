/**
 *	BaseWeapon
 *
 *	Creation date: 19.04.2013 12:47
 *	Copyright 2013, Nikita Gorelov
 */
class BaseWeapon extends BaseItem;

function PostBeginPlay()
{
	super.PostBeginPlay(); 	
}

defaultproperties
{
	Class_ID = 3	
	Mass = 1.0
	Description = "Base class for any weapons"
	Item_type = WEAPON		
	
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh = StaticMesh'Pickups.UDamage.Mesh.S_Pickups_UDamage'
	End Object
	CollisionComponent=StaticMeshComponent1
	StaticMeshComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)
}

