class TestFloor extends ArchitecturalMesh;

var() const editconst StaticMeshComponent StaticMeshComponent;

var MaterialInstanceConstant MatIC, MatInst_Parent;

simulated function PostBeginPlay()
{
	MatIC = new(None) Class'MaterialInstanceConstant';
	MatIC.SetParent(MatInst_Parent);
	StaticMeshComponent.SetMaterial(0, MatIC);
}

public function SetScale(vector locScale)
{
	MatIC.SetScalarParameterValue('TileU', locScale.X);
	MatIC.SetScalarParameterValue('TileV', locScale.Y);
	SetDrawScale3D(locScale);
}

defaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent
		StaticMesh=StaticMesh'Houses.Test1.polopotolok'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshComponent)
	StaticMeshComponent = StaticMeshComponent;

	MatInst_Parent = MaterialInstanceConstant'Houses.LODs.LODTopMaterial_INST'
}