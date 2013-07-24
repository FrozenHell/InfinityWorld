/**
 *	BaseQuest
 *
 *	Creation date: 19.04.2013 12:49
 *	Copyright 2013, Nikita
 */
class BaseQuest extends BaseItem;

function PostBeginPlay()
{
	super.PostBeginPlay(); 	
}

defaultproperties
{
	Class_ID = 5	
	Mass = 0.0
	Description = "Base class for any quest items"
	Item_type = QUEST
	
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
