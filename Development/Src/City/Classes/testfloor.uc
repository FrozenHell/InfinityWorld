class TestFloor extends ArchitecturalMesh;

var() const editconst StaticMeshComponent StaticMeshComponent;

var MaterialInstanceConstant MatIC1, MatIC2, MatInst_Top, MatInst_Bottom;

simulated function PostBeginPlay()
{
	MatIC1 = new(None) Class'MaterialInstanceConstant';
	MatIC1.SetParent(MatInst_Top);
	StaticMeshComponent.SetMaterial(0, MatIC1);
	
	MatIC2 = new(None) Class'MaterialInstanceConstant';
	MatIC2.SetParent(MatInst_Bottom);
	StaticMeshComponent.SetMaterial(1, MatIC2);
}

public function SetScale(vector locScale)
{
	MatIC1.SetScalarParameterValue('TileU', locScale.X);
	MatIC1.SetScalarParameterValue('TileV', locScale.Y);
	MatIC2.SetScalarParameterValue('TileU', locScale.X);
	MatIC2.SetScalarParameterValue('TileV', locScale.Y);
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

	MatInst_Top = MaterialInstanceConstant'Houses.Test1.FloorMaterial_INST'
	MatInst_Bottom = MaterialInstanceConstant'Houses.Test1.FloorMaterial_INST'
}