/**
 *	RoadTriWay
 *
 *	Creation date: 17.04.2013 05:21
 *	Copyright 2013, FHS
 */
class RoadTriWay extends ArchitecturalMesh;

var() const editconst StaticMeshComponent StaticMeshComponent;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent
		bAllowApproximateOcclusion = TRUE
		bForceDirectLightMap = TRUE
		bUsePrecomputedShadows = TRUE
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
		StaticMesh = StaticMesh'Street.Road.TriWayRoad'
	End Object
	CollisionComponent = StaticMeshComponent
	StaticMeshComponent = StaticMeshComponent
	Components.Add(StaticMeshComponent)
}