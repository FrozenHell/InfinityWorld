/**
 *	RPGPlayerController
 *
 *	Creation date: 11.04.2013 23:37
 *	Copyright 2013, FHS
 */
class RPGPlayerController extends UTPlayerController;

// ������ �� ������ "������������"
var bool bUsePressed;
// ����, ������� �������������� ������������
var Actor ActorForUse;
// ������������ ���������� �� ������� ����� ������������ �������
var float MaxUseRange;

// HUD
var GFxMovie_PlayerHUD GFxHUD;
var Actor HUDUsableActor;

// ���� �����
var GFxMovie_PauseMenu GFxPauseMenu;
var bool bGamePaused;

// --------- ������ -----------

// ������ Esc
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

// ������� ����� ����
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

// ������ ������� "������������"
exec function UseActor_pressed()
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;

	GetPlayerViewPoint(viewLocation, viewRotation);
	HitActor = Trace(hitLocation, hitNormal, viewLocation + MaxUseRange * vector(viewRotation), viewLocation, true);

	// ���� �� ������ �� �����, ������� ����� ������������
	if (Useable(HitActor) != None && Useable(HitActor).bGetUsable())
	{
		// ���������, ������ ����� �� ����� ����� ������������
		ActorForUse = HitActor;
		
		// ���������, ��� ���� ��� �� ���������
		bUsePressed = true;
		
		// ���� �� ������� ������, ��� ��������� ������� ����� ��������������
		SetTimer(1, false, 'ShowAdditionalActions');
	}
}

// ������ ����� ����� ������� "������������"
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

		// ���� �� �������� �� �����, ������� ����� ������������, � ��� ��� ����, ������� ��� ���� ����������
		if (Useable(HitActor) != None && HitActor == ActorForUse && Useable(HitActor).bGetUsable())
		{
			`log("���������� ������� �� ������");
		}
	}
}

// ��������� ������� "������������"
exec function UseActor_released(optional int idxAction = 0)
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;
	
	// ���� ��� ��� ����� ���������� �����
	if (bUsePressed)
	{
		bUsePressed = false;
		
		GetPlayerViewPoint(viewLocation, viewRotation);
		HitActor = Trace(hitLocation, hitNormal, viewLocation + MaxUseRange * vector(viewRotation), viewLocation, true);

		// ���� �� �������� �� �����, ������� ����� ������������, � ��� ��� ����, ������� ��� ���� ����������
		if (Useable(HitActor) != None && HitActor == ActorForUse && Useable(HitActor).bGetUsable(idxAction))
		{
			// ����������
			Useable(HitActor).Use(Pawn, idxAction);

			CheckUsableActors();
		}
	}
}

// ������� ����������� ��� ��������
function UpdateRotation(float fDeltaTime)
{
	CheckUsableActors();
	Super.UpdateRotation(fDeltaTime);
}


// ��������� �� ������� ������ ��������, ������� ����� ������������
function CheckUsableActors()
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;
	local int i;

	GetPlayerViewPoint(viewLocation, viewRotation);
	HitActor = Trace(hitLocation, hitNormal, viewLocation + MaxUseRange * vector(viewRotation), viewLocation, true);

	// ���� �� ������ ������ �� �����, ������� ����� ������������
	if (Useable(HitActor) != None && Useable(HitActor).bGetUsable())
	{
		// ���� ������ - ��� ��������� �����, ����� ������� ������ �� ����
		if (TouchScreen(HitActor) != None)
		{
			TouchScreen(HitActor).SetCursorPosition(hitLocation);	
		}
		
		// ������� "������� F ����� ..."
		if (HUDUsableActor != HitActor)
		{
			if (TouchScreen(HUDUsableActor) != None)
				TouchScreen(HUDUsableActor).UnFocus();

			HUDUsableActor = HitActor;
			// ������� �� HUD ��� ��������
			for (i = 0; i < Useable(HitActor).GetActionsCount(); i++)
				if (Useable(HitActor).bGetUsable(i))
					GFxHUD.AddAction(Useable(HitActor).GetActionName(i));
		}
	}
	else
	{
		// ���� ����� ���� ������ ���, �� ������� ��� ��������� � ������
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
	// �������������� ������� UTPlayerController, ����� �� ������� "Play!" ��� ������ ������� ������
}

reliable client function PlayStartupMessage(byte StartupStage)
{
	// �������������� ������� UTPlayerController, ����� �� ������ ����������� ��� ������ ������� ������
}

defaultproperties
{
	MaxUseRange = 150
	HUDUsableActor = None
	bGamePaused = false
	bUsePressed = false
}
