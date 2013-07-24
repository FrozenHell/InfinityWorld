/**
 *	BaseAmmo
 *
 *	Creation date: 19.04.2013 12:45
 *	Copyright 2013, Nikita Gorelov
 */
class BaseAmmo extends BaseItem;

function PostBeginPlay()
{
	super.PostBeginPlay(); 		
}

defaultproperties
{
	Class_ID = 2	
	Mass = 0.0
	Description = "Base class for any ammo"
	Item_type = AMMO	
	
	//Components.Remove(StaticMeshComponent0)	
	
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh=StaticMesh'Pickups.Ammo_Shock.Mesh.S_Ammo_ShockRifle'
	End Object
	CollisionComponent=StaticMeshComponent1
	StaticMeshComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)

	
}

