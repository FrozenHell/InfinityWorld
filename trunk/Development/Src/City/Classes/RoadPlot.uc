/**
 *	RoadPlot
 *
 *	Creation date: 17.04.2013 05:21
 *	Copyright 2013, FHS
 */
class RoadPlot extends ArchitecturalMesh;

var() const editconst StaticMeshComponent StaticMeshComponent;

var MaterialInstanceConstant MatIC, MatInst_Parent;

simulated function PostBeginPlay()
{
	MatIC = new(None) Class'MaterialInstanceConstant';
	MatIC.SetParent(MatInst_Parent);
	StaticMeshComponent.SetMaterial(0, MatIC);
}

// scX - ширина, scY - длина
function SetScale(float scX, float scY)
{
	local vector locScale;
	locScale.X = scX;
	locScale.Y = scY;
	locScale.Z = 1;

	MatIC.SetScalarParameterValue('TileU', locScale.X);
	MatIC.SetScalarParameterValue('TileV', locScale.Y/2);

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
		StaticMesh = StaticMesh'Street.Road.RoadMesh'
	End Object
	CollisionComponent = StaticMeshComponent
	StaticMeshComponent = StaticMeshComponent
	Components.Add(StaticMeshComponent)

	MatInst_Parent = MaterialInstanceConstant'Street.Road.SimpleRoad_Mat_INST'
}