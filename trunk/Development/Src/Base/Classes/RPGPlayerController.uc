/**
 *	RPGPlayerController
 *
 *	Creation date: 11.04.2013 23:37
 *	Copyright 2013, FHS
 */
class RPGPlayerController extends UTPlayerController;

// нажата ли кнопка "Использовать"
var bool bUsePressed;
// актёр, который предполагается использовать
var Actor ActorForUse;
// максимальное расстояние на котором можно использовать объекты
var float MaxUseRange;

// HUD
var GFxMovie_PlayerHUD GFxHUD;
var Actor HUDUsableActor;

// меню паузы
var GFxMovie_PauseMenu GFxPauseMenu;
var bool bGamePaused;

// --------- методы -----------

// нажали Esc
exec function ShowPauseMenu()
{
	if (!bGamePaused)
	{
		GFxPauseMenu.Start(false);
		bGamePaused = true;
	}
	else
	{
		GFxPauseMenu.Close(false);
		bGamePaused = false;
	}
}

// выбрали пункт меню
function PauseMenuEvent(int intEvent)
{
	switch (intEvent)
	{
		case 0:
			ShowPauseMenu();
			break;
		case 1:
			ConsoleCommand("Disconnect");
			break;
		case 2:
			ConsoleCommand("Quit");
			break;
		default:
			break;
	}
}

// нажали клавишу "Использовать"
exec function UseActor_pressed()
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;

	GetPlayerViewPoint(viewLocation, viewRotation);
	HitActor = Trace(hitLocation, hitNormal, viewLocation + MaxUseRange * vector(viewRotation), viewLocation, true);

	// если мы нажали на актёра, который можно использовать
	if (Useable(HitActor) != None && Useable(HitActor).bGetUsable())
	{
		// указываем, какого актёра на мужно будет использовать
		ActorForUse = HitActor;
		
		// указываем, что актёр ещё не обработан
		bUsePressed = true;
		
		// пока не истечёт таймер, его повторные запуски будут игнорироваться
		SetTimer(1, false, 'ShowAdditionalActions');
	}
}

// прошло время после нажатия "Использовать"
function ShowAdditionalActions()
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;

	if (bUsePressed)
	{
		bUsePressed = false;

		GetPlayerViewPoint(viewLocation, viewRotation);
		HitActor = Trace(hitLocation, hitNormal, viewLocation + MaxUseRange * vector(viewRotation), viewLocation, true);

		// если мы наведены на актёра, который можно использовать, и это тот актёр, который нам надо обработать
		if (Useable(HitActor) != None && HitActor == ActorForUse && Useable(HitActor).bGetUsable())
		{
			`log("длительное нажатие на объект");
		}
	}
}

// отпустили клавишу "Использовать"
exec function UseActor_released(optional int idxAction = 0)
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;
	
	// если нам ещё нужно обработать актёра
	if (bUsePressed)
	{
		bUsePressed = false;
		
		GetPlayerViewPoint(viewLocation, viewRotation);
		HitActor = Trace(hitLocation, hitNormal, viewLocation + MaxUseRange * vector(viewRotation), viewLocation, true);

		// если мы наведены на актёра, который можно использовать, и это тот актёр, который нам надо обработать
		if (Useable(HitActor) != None && HitActor == ActorForUse && Useable(HitActor).bGetUsable(idxAction))
		{
			// используем
			Useable(HitActor).Use(Pawn, idxAction);

			CheckUsableActors();
		}
	}
}

// функция выполняется при повороте
function UpdateRotation(float fDeltaTime)
{
	CheckUsableActors();
	Super.UpdateRotation(fDeltaTime);
}


// проверяем на наличие вблизи объектов, которые можно использовать
function CheckUsableActors()
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;
	local int i;

	GetPlayerViewPoint(viewLocation, viewRotation);
	HitActor = Trace(hitLocation, hitNormal, viewLocation + MaxUseRange * vector(viewRotation), viewLocation, true);

	// если мы навели прицел на актёра, который можно использовать
	if (Useable(HitActor) != None && Useable(HitActor).bGetUsable())
	{
		// если объект - это сенсорный экран, тогда двигаем курсор по нему
		if (TouchScreen(HitActor) != None)
		{
			TouchScreen(HitActor).SetCursorPosition(hitLocation);	
		}
		
		// выводим "Нажмите F чтобы ..."
		if (HUDUsableActor != HitActor)
		{
			if (TouchScreen(HUDUsableActor) != None)
				TouchScreen(HUDUsableActor).UnFocus();

			HUDUsableActor = HitActor;
			// выводим на HUD все действия
			for (i = 0; i < Useable(HitActor).GetActionsCount(); i++)
				if (Useable(HitActor).bGetUsable(i))
					GFxHUD.AddAction(Useable(HitActor).GetActionName(i));
		}
	}
	else
	{
		// если перед нами ничего нет, то убираем все подсказки с экрана
		if (HUDUsableActor != None)
		{
			if (TouchScreen(HUDUsableActor) != None)
				TouchScreen(HUDUsableActor).UnFocus();

			HUDUsableActor = None;
			GFxHUD.RemoveActions();
		}
	}
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	GFxHUD = new Class'Base.GFxMovie_PlayerHUD';
	GFxHUD.Initialize();
	
	GFxPauseMenu = new Class'Base.GFxMovie_PauseMenu';
	GFxPauseMenu.Initialize(self);
	GFxPauseMenu.MenuEvent = PauseMenuEvent;
}


function PlayAnnouncement(class<UTLocalMessage> InMessageClass, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
	// перезаписываем функцию UTPlayerController, чтобы не слышать "Play!" при старте каждого уровня
}

reliable client function PlayStartupMessage(byte StartupStage)
{
	// перезаписываем функцию UTPlayerController, чтобы не видеть приветствия при старте каждого уровня
}

defaultproperties
{
	MaxUseRange = 150
	HUDUsableActor = None
	bGamePaused = false
	bUsePressed = false
}
