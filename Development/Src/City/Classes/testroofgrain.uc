class TestRoofGrain extends ArchitecturalMesh;

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
	scaleVector.X = scale;
	scaleVector.Y = 1.0;
	scaleVector.Z = 1.0;
	MatIC.SetScalarParameterValue('TileU', scale);
	MatIC.SetScalarParameterValue('TileV', 1);
	SetDrawScale3D(scaleVector);
}

defaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent
		StaticMesh=StaticMesh'Houses.Test1.rooflen'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshComponent)
	StaticMeshComponent = StaticMeshComponent;

	MatInst_Side = MaterialInstanceConstant'Houses.Test1.FloorMaterial_INST'
}