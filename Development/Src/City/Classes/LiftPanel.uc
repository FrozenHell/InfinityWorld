/**
 *	LiftPanel
 *
 *	Creation date: 20.03.2013 16:28
 *	Copyright 2013, FHS
 */
class LiftPanel extends TouchScreen;

// текстура, на которую проецируетс€ GFx ролик
var TextureRenderTarget2D TextureRT;
var MaterialInstanceConstant MatIC, MatInst_Parent;

delegate ControlPanelAddFloor(int newFloor);

simulated event PostBeginPlay()
{
	// не вызываем постбегин дл€ тачскрина
	Super(UsableActor).PostBeginPlay();

	SetPhysics(PHYS_Interpolating);
}

function InitPanel(int buldingHeight)
{
	GFxMovie = new Class'City.GFxMovie_LiftPanel';
	GFxMovie_LiftPanel(GFxMovie).ControlPanelAddFloor = ControlPanelAddFloor;

	TextureRT = new Class'TextureRenderTarget2D';
	TextureRT.Create(768, 1024);
	//GFxMovie.RenderTexture = TextureRT;

	MatIC = new(None) Class'MaterialInstanceConstant';
	MatIC.SetParent(MatInst_Parent);
	MatIC.SetTextureParameterValue('MovieTexture', TextureRT);
	//StaticMeshComponent.SetMaterial(0, MatIC);
	StaticMeshComponent.SetMaterial(0, MatInst_Parent);

	GFxMovie.initialize();

	GFxMovie_LiftPanel(GFxMovie).InitPanel(buldingHeight);
}

function SetCursorPosition(vector globPosition)
{
	local vector localPosition;
	// переводим вектор в локальную систему координат
	localPosition = globPosition - Location;
	localPosition = localPosition << Rotation;

	// устонавливаем курсор
	GFxMovie.MoveCursor((9.0 + localPosition.x) * 50, (12.0 - localPosition.z) * 50);
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh=StaticMesh'Houses.Lifts.LiftPanel'
	End Object

	bStatic = false
	bMovable = true
	MatInst_Parent = MaterialInstanceConstant'Houses.Lifts.LiftPanel_Material_INST'
}
