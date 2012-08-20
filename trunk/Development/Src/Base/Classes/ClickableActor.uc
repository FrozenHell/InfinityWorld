class ClickableActor extends Actor
	placeable;

var() const editconst StaticMeshComponent	StaticMeshComponent;

var MaterialInstanceConstant Material_MatInst;
var() MaterialInstanceConstant Parent_MatInst;
// ID материала для замены InstConst материала
var() int MatID;

// Размер свечения объекта (Параметр 'Diffuse') до наводки мыши
var() float NormalMatInstFloat;
// Размер свечения объекта (Параметр 'Diffuse') при наводке мыши
var() float SelectMatInstFloat;

// Цвет свечения объекта (Параметр 'DiffuseColor') до наводки мыши
var() LinearColor NormalMatInstLinearColor;

// Цвет свечения объекта (Параметр 'DiffuseColor') при наводке мыши
var() LinearColor SelectMatInstLinearColor;

var bool bSelected;

simulated function PostBeginPlay()
{
	Material_MatInst = new(None) Class'MaterialInstanceConstant';
	Material_MatInst.SetParent(Parent_MatInst);
	StaticMeshComponent.SetMaterial(MatID, Material_MatInst);
}

function Select(bool b)
{
	if (b)
	{
		Material_MatInst.SetScalarParameterValue ('Diffuse', SelectMatInstFloat);
		Material_MatInst.SetVectorParameterValue('DiffuseColor', SelectMatInstLinearColor);
	}
	else
	{
		Material_MatInst.SetScalarParameterValue ('Diffuse', NormalMatInstFloat);
		Material_MatInst.SetVectorParameterValue('DiffuseColor', NormalMatInstLinearColor);
	}
}

function Change()
{
	bSelected = !bSelected;
	Select(bSelected);
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh=StaticMesh'LT_Light.SM.Mesh.S_LT_Light_SM_Light01'
	End Object
	CollisionComponent=StaticMeshComponent
	StaticMeshComponent=StaticMeshComponent
	Components.Add(StaticMeshComponent)
	bEdShouldSnap=true
	bStatic=false
	bMovable=true
	bCollideActors=true
	bBlockActors=true
	bWorldGeometry=true
	bGameRelevant=true
	bRouteBeginPlayEvenIfStatic=false
	bCollideWhenPlacing=false
	
	bSelected = false;
}