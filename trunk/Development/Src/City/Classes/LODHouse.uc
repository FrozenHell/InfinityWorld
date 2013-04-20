/**
 *	LODHouse
 *
 *	Creation date: 02.04.2013 21:17
 *	Copyright 2013, FHS
 */
class LODHouse extends ArchitecturalMesh;

var() const editconst StaticMeshComponent StaticMeshComponent;

var MaterialInstanceConstant MatIC_Front, MatIC_Side, MatIC_Top;
var MaterialInstanceConstant MatInst_Wall, MatInst_Roof;

simulated function PostBeginPlay()
{
	MatIC_Front = new(None) Class'MaterialInstanceConstant';
	MatIC_Front.SetParent(MatInst_Wall);
	MatIC_Side = new(None) Class'MaterialInstanceConstant';
	MatIC_Side.SetParent(MatInst_Wall);
	MatIC_Top = new(None) Class'MaterialInstanceConstant';
	MatIC_Top.SetParent(MatInst_Roof);
	StaticMeshComponent.SetMaterial(0, MatIC_Front);
	StaticMeshComponent.SetMaterial(1, MatIC_Side);
	StaticMeshComponent.SetMaterial(2, MatIC_Top);
}

function SetScale(float scX, float scY, float scZ)
{
	local vector locScale;
	locScale.X = scX + 0.05;
	locScale.Y = scY + 0.05;
	locScale.Z = scZ + 0.1;

	MatIC_Front.SetScalarParameterValue('TileU', locScale.Y);
	MatIC_Front.SetScalarParameterValue('TileV', locScale.Z);
	MatIC_Side.SetScalarParameterValue('TileU', locScale.X);
	MatIC_Side.SetScalarParameterValue('TileV', locScale.Z);
	MatIC_Top.SetScalarParameterValue('TileU', locScale.X);
	MatIC_Top.SetScalarParameterValue('TileV', locScale.Y);

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
		StaticMesh=StaticMesh'Houses.LODs.HouseLod'
	End Object
	CollisionComponent = StaticMeshComponent
	StaticMeshComponent = StaticMeshComponent
	Components.Add(StaticMeshComponent)

	MatInst_Wall = MaterialInstanceConstant'Houses.LODs.LODSideMaterial_INST'
	MatInst_Roof = MaterialInstanceConstant'Houses.LODs.LODTopMaterial_INST'
}
