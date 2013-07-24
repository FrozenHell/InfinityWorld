/**
 *	BaseSpecial
 *
 *	Creation date: 19.04.2013 12:49
 *	Copyright 2013, Nikita
 */
class BaseSpecial extends BaseItem;

function PostBeginPlay()
{
	super.PostBeginPlay(); 	
}

defaultproperties
{
	Class_ID = 6	
	Mass = 1.0
	Description = "Base class for any special items"
	Item_type = SPECIAL		
	
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh = StaticMesh'GDC_Materials.Meshes.MeshSphere_02'
	End Object
	CollisionComponent=StaticMeshComponent1
	StaticMeshComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)
	
}
