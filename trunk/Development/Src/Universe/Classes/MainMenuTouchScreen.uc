/**
 *	MainMenuTouchScreen
 *
 *	Creation date: 03.03.2013 17:29
 *	Copyright 2013, FHS
 */
class MainMenuTouchScreen extends TouchScreen;

simulated event PostBeginPlay()
{
	Super(UsableActor).PostBeginPlay();
	GFxMovie = new Class'Universe.GFxMovie_MainMenuScreen';
	GFxMovie.initialize();
}

function SetCursorPosition(vector globPosition)
{
	local vector localPosition;
	// переводим вектор в локальную систему координат
	localPosition = globPosition - Location;
	localPosition = localPosition << Rotation;
	
	// устонавливаем курсор
	GFxMovie.MoveCursor((51.2+localPosition.x) * 10, (38.4-localPosition.z) * 10);
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh=StaticMesh'MainMenu.Room.MainMenuScreen_TouchLayer'
	End Object
}
