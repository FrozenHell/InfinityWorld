/**
 *	TestTriFloor
 *
 *	Creation date: 22.02.2013 11:10
 *	Copyright 2013, FHS
 */
class TestTriFloor extends ArchitecturalMesh;

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

	MatIC.SetScalarParameterValue('TileU', scX);
	MatIC.SetScalarParameterValue('TileV', scY);

	locScale.X = scX;
	locScale.Y = scY;
	locScale.Z = scZ;
	
	SetDrawScale3D(locScale);
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent
		StaticMesh = StaticMesh'Houses.Test1.tricenterfloor'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	CollisionComponent = StaticMeshComponent
	StaticMeshComponent = StaticMeshComponent
	Components.Add(StaticMeshComponent)

	MatInst_Parent = MaterialInstanceConstant'Houses.Test1.TriCenterMaterial_INST'
}