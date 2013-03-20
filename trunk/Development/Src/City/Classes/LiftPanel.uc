/**
 *	LiftPanel
 *
 *	Creation date: 20.03.2013 16:28
 *	Copyright 2013, Alekseu
 */
class LiftPanel extends TouchScreen;

delegate ControlPanelAddFloor(int newFloor);

simulated event PostBeginPlay()
{
	// не вызываем постбегин для тачскрина
	Super(UsableActor).PostBeginPlay();
	GFxMovie = new Class'City.GFxMovie_LiftPanel';
	GFxMovie.initialize();
	
	SetPhysics(PHYS_Interpolating);
}

function InitPanel(int buldingHeight)
{
	GFxMovie_LiftPanel(GFxMovie).InitPanel(buldingHeight);
	GFxMovie_LiftPanel(GFxMovie).ControlPanelAddFloor = ControlPanelAddFloor;
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
}
