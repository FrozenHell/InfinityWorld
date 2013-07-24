class TestSpaceEx extends ArchitecturalMesh;

defaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
	StaticMesh=StaticMesh'Houses.Test1.noneex'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshCompopo)
}