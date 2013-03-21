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
	GFxMovie_MainMenuScreen(GFxMovie).NewLevelChanged = NewLevelChanged;
	GFxMovie.initialize();
}

function SetCursorPosition(vector globPosition)
{
	local vector localPosition;
	// переводим вектор в локальную систему координат
	localPosition = globPosition - Location;
	localPosition = localPosition << Rotation;
	
	// устонавливаем курсор
	GFxMovie.MoveCursor((51.2 + localPosition.x) * 10, (38.4 - localPosition.z) * 10);
}

function NewLevelChanged(int newLevel)
{
	local UnPlayerController PC;
	// передача события в GameInfo
	
	`log("Level might be changed");
	
	if (newLevel == 1)
	{
		`log("I want to search any PC of our game");
		foreach AllActors(class'UnPlayerController', PC)
		{
			`log("I find"@PC);
			PC.ConsoleCommand("Start un-bottest");
		}
	}
	
	if (newLevel == 2)
	{
		`log("I want to search any PC of our game");
		foreach AllActors(class'UnPlayerController', PC)
		{
			`log("I find"@PC);
			PC.ConsoleCommand("Start un-testhouse");
		}
	}
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
