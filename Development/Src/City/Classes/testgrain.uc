class TestGrain extends ArchitecturalMesh;

var() const editconst StaticMeshComponent StaticMeshComponent;

var MaterialInstanceConstant MatIC, MatInst_Side;

simulated function PostBeginPlay()
{
	MatIC = new(None) Class'MaterialInstanceConstant';
	MatIC.SetParent(MatInst_Side);
	StaticMeshComponent.SetMaterial(0, MatIC);
}

public function SetScale(float scale)
{
	local vector scaleVector;

	MatIC.SetScalarParameterValue('TileU', 1.0);
	MatIC.SetScalarParameterValue('TileV', scale + 0.1);

	scaleVector.Y = 1.0;
	scaleVector.X = 1.0;
	scaleVector.Z = scale + 0.1;
	SetDrawScale3D(scaleVector);
}

defaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent
		StaticMesh=StaticMesh'Houses.Test1.grain'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshComponent)
	StaticMeshComponent = StaticMeshComponent;

	MatInst_Side = MaterialInstanceConstant'Houses.Test1.ExWallMaterial_INST'
}