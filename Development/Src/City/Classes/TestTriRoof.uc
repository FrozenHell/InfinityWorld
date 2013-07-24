/**
 *	TestTriRoof
 *
 *	Creation date: 09.03.2013 16:17
 *	Copyright 2013, FHS
 */
class TestTriRoof extends ArchitecturalMesh;

var() const editconst StaticMeshComponent StaticMeshComponent;

var MaterialInstanceConstant MatInst_Parent, MatIC;

simulated function PostBeginPlay()
{
	MatIC = new(None) Class'MaterialInstanceConstant';
	MatIC.SetParent(MatInst_Parent);
	StaticMeshComponent.SetMaterial(0, MatIC);
}

function SetScale(float scX, float scY, float scZ)
{
	local vector locScale;
	locScale.X = scX;
	locScale.Y = scY;
	locScale.Z = scZ;

	MatIC.SetScalarParameterValue('TileU', locScale.X);
	MatIC.SetScalarParameterValue('TileV', locScale.Y);

	SetDrawScale3D(locScale);
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent
		StaticMesh = StaticMesh'Houses.Test1.tricenterroof'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	CollisionComponent = StaticMeshComponent
	StaticMeshComponent = StaticMeshComponent
	Components.Add(StaticMeshComponent)

	MatInst_Parent = MaterialInstanceConstant'Houses.Test1.TriCenterMaterial_INST'
}