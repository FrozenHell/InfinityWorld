class TestRoofAng extends ArchitecturalMesh;

defaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
	StaticMesh=StaticMesh'Houses.Test1.roofang'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshCompopo)
}