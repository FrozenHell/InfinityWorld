/**
 *	LiftButton
 *
 *	Creation date: 03.03.2013 01:13
 *	Copyright 2013, FHS
 */
class LiftButton extends TouchScreen
	notplaceable;

// состояние кнопки лифта
var int LiftState;

// этаж на котором расположена кнопка
var int Floor;

delegate CallLift(int newFloor);

simulated event PostBeginPlay()
{
	// не вызываем постбегин для тачскрина
	Super(UsableActor).PostBeginPlay();
	GFxMovie = new Class'City.GFxMovie_LiftButton';
	GFxMovie.initialize();
	SetState(LiftState);
}

// меняем состояние лифта
function SetState(int locState)
{
	LiftState = locState;
	if (LiftState == 0)
	{
		// лифт доступен для использования
		Actions[0].Name = "вызвать лифт";
		Actions[0].bActive = true;
	}
	else
	{
		// мы уже вызвали лифт или он недоступен
		//ActionName = "коснуться";
		Actions[0].bActive = false;
	}

	GFxMovie_LiftButton(GFxMovie).SetState(locState);
}

function Use(Pawn uInstigator, optional int actionIndex = 0)
{
	if (LiftState == 0)
	{
		CallLift(Floor);
		SetState(1);
	}
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh=StaticMesh'Houses.Lifts.LiftButton_mesh'
	End Object

	LiftState = 0;
	Floor = 0;
}
