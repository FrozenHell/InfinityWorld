/**
 *	HouseLOD
 *
 *	Creation date: 02.04.2013 21:17
 *	Copyright 2013, FHS
 */
class HouseLOD extends HousePart;

var() const editconst StaticMeshComponent StaticMeshComponent;

var MaterialInstanceConstant MatIC_Front, MatIC_Side, MatIC_Top;
var MaterialInstanceConstant MatInst_Wall, MatInst_Roof;

var bool bSelected;

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
	MatIC_Front.SetScalarParameterValue('TileU', scY);
	MatIC_Front.SetScalarParameterValue('TileV', scZ);
	MatIC_Side.SetScalarParameterValue('TileU', scX);
	MatIC_Side.SetScalarParameterValue('TileV', scZ);
	MatIC_Top.SetScalarParameterValue('TileU', scX);
	MatIC_Top.SetScalarParameterValue('TileV', scY);

	locScale.X = scX;
	locScale.Y = scY;
	locScale.Z = scZ + 1.0;
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
