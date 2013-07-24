/**
 *	LODTriHouse
 *
 *	Creation date: 02.04.2013 21:17
 *	Copyright 2013, FHS
 */
class LODTriHouse extends ArchitecturalMesh;

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
		bAllowApproximateOcclusion = TRUE
		bForceDirectLightMap = TRUE
		bUsePrecomputedShadows = TRUE
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
		StaticMesh = StaticMesh'Houses.Test1.tricenterroof'
	End Object
	CollisionComponent = StaticMeshComponent
	StaticMeshComponent = StaticMeshComponent
	Components.Add(StaticMeshComponent)

	MatInst_Parent = MaterialInstanceConstant'Houses.LODs.LODTopMaterial_INST'
}
