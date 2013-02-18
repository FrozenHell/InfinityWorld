class MainMenuPlayerController extends PlayerController;

// Mouse event enum
enum EMouseEvent
{
	ME_LeftMouseButton,
	ME_RightMouseButton,
	ME_MiddleMouseButton,
	ME_ScrollWheelUp,
	ME_ScrollWheelDown
};

// ������� ��� (���������, ������, �������, �������)
var enum EModelPart
{
	MP_Galaxy,
	MP_System,
	MP_Planet,
	MP_Sputnik
} CurrentView;

// ������� �� �� ������
var bool bRotation;

// ���� �������� ������ � ��������
var vector RotationDeg;

// ������� ������
var ClickableActor CurrentObject;

// ���������
var MyGalaxy CurrGalax;

// ������� ������� �������
var PlanetSystem CurrSyst;

// ������� �������
var UnPlanet CurrPlan;

// �����, ������ ������� ������� ������
var vector ViewPoint;

// ����� ����� ������, � ������� ������������ ������� �������
var vector NewFocusPos;

// ����� ���� ��� ��������
var Actor NewFocusAct;

// ����� �������� ������
var float DeltaMoveTime;

// ������� ����� �� ������ ��������
var float MoveTime;

// ����� �� ���� ���
var float DeltaTime;

// ��� �������� ����� ������ ������
var float Delta;

// ����������, �� ������� ��������� ������
var float CameraRange;

// ���� ������ � ������ �������, ��� ���� �� ��� �������� � �����
var rotator CameraAngle;

// Override this state because StartFire isn't called globally when in this function
auto state PlayerWaiting
{
	exec function StartFire(optional byte fireModeNum)
	{
		Global.StartFire(fireModeNum);
	}
	
	function PlayerMove(float fDeltaTime)
	{
		UpdateRotation(fDeltaTime);
	}
	
Begin:
	MainMenuHUD(myHUD).PickHouse = PickHouse;
	SetLocation(vect(-10000, 0, 0));
	SetRotation(UnrRot(0, 0, 0));
	GoTo('EndAll');

// ��������� � ���� �� �������
WatchPlanet:
	if (CurrentView != MP_Planet) GoTo('EndAll');
	ViewPoint = CurrPlan.Location;
	UpdCamRot();
	Sleep(0.04);
	GoTo('WatchPlanet');

EndAll:

}

// ������ ���������
exec function InitGalaxy(optional int numStars = 10000)
{
	if ((CurrGalax) == None)
	{
		// ������ ������ - ���������
		CurrGalax = Spawn(class'City.mygalaxy', Pawn(Owner),, vect(0, 0, 0), rot(0, 0, 0));
		// ������� ������ �� �������
		CurrGalax.GetPlayerViewPoint = GetPlayerViewPoint;
		// ����������� ��������� � ����� �������
		CurrGalax.bCosmos = true;
		// ��������� ��������� ������� � ���������� numStars
		CurrGalax.gen(Pawn(Owner), numStars);
	}
	UpdCamRot();
}

// ������� �������, ����������� �� ��������� � ��������
protected function rotator UnrRot(float pitch, float yaw, float roll)
{
	local rotator rota;
	local float DegToRot;
	DegToRot = DegToRad * RadToUnrRot;
	rota.Pitch = pitch * DegToRot;
	rota.Yaw = yaw * DegToRot;
	rota.Roll = roll * DegToRot;
	return rota;
}

// ������� ���������� �� Hud-�
function PickHouse(ClickableActor clicableObject)
{
	if (CurrentObject != None)
		CurrentObject.select(false);
	CurrentObject = clicableObject;
	if (CurrentObject != None)
		CurrentObject.select(true);
}

// �������� ��������� ������
/*function UpdateRotation(float fDeltaTime)
{
	local Rotator	deltaRot, viewRotation;
	// ���� �� � ������ �������� ������
	if (bRotation)
	{
		// ��������� ������ ��������
		deltaRot.Yaw	= PlayerInput.aTurn;
		deltaRot.Pitch	= PlayerInput.aLookUp;
		viewRotation = CameraAngle;
		// ������������ ������ viewRotation �� ������
		ProcessViewRotation(fDeltaTime, viewRotation, deltaRot);
		// ���������� ������ ���������� � CameraAngle
		CameraAngle = viewRotation;
		// ��������� ������� � ������
		SetRotation(viewRotation);
		ViewShake(fDeltaTime);
		// ��������� ��������� ������
		UpdCamRot();
	}
}*/

function UpdateRotation(float fDeltaTime)
{
	// ���� �� � ������ �������� ������
	if (bRotation)
	{
		// ��������� ������ ��������
		RotationDeg.y = ((RotationDeg.y - PlayerInput.aLookUp / 2000 > 1.57) ? 1.57 : (RotationDeg.y - PlayerInput.aLookUp / 2000 < -1.57) ? -1.57 : RotationDeg.y - PlayerInput.aLookUp / 2000);
		CurrGalax.RotateG(0, RotationDeg.y, RotationDeg.x += PlayerInput.aTurn / 2000);
	}
}

// �������������� ���������� ������
function UpdCamRot()
{
	local vector cameraPos;
	local rotator viewRotation;
	
	viewRotation = CameraAngle;
	// ���������� ������� ������ ����
	viewRotation.Pitch = 0;
	// ���� ��� ���������� ������������
	cameraPos = Normal(CameraAngle.Pitch > PI * RadToUnrRot ? vector(viewRotation) Cross vector(CameraAngle) : vector(CameraAngle) Cross vector(viewRotation));
	// ���� ����� ��������� ������
	SetLocation(ViewPoint + vector(CameraAngle) * -CameraRange + cameraPos * CameraRange * 0.3);  // 0.3 - ����������� CameraRange � ������� ����������� ������ ����. � ����������� �� ���������� ������ � FOV ����� ���� ������
}

// �������� ���������� ������
function ChangeRange(float mod) {
	switch (CurrentView)
	{
		case MP_Galaxy: // ���� ���������
			CurrGalax.ScaleG(mod);
			break;
		// ��������� ����� ������������� ���� �����
		default:
			break;
	}
}


// �������� �� �������
function ClickToAct(ClickableActor clAct)
{
	local SequenceObject individualEvent;
	local array<SequenceObject> eventList;
	
	if (ministar(clAct) != None && CurrentView == MP_Galaxy) // ������ � ���������
	{
		//CurrentView = MP_System;
		CurrGalax.NewFocus(MiniStar(clAct));
		//CurrGalax.ZoomIn();
		//CurrGalax.destroy();
		//CurrSyst = Spawn(class'City.PlanetSystem', UnPawn(Owner),, ViewPoint, Rot(0, 0, 0));
		//CurrSyst.generate(UnPawn(Owner), 1);
	}
	else if (System_Star(clAct) != None) // ������ � �������
	{
		NewFocusPos = clAct.Location;
		CurrentView = MP_System;
		GoToState('PlayerWaiting', 'MoveTCam');
	}
	else if (UnPlanet(clAct) != None) // ������� � �������
	{
		CurrentView = MP_Planet;
		NewFocusAct = clAct;
		CurrPlan = UnPlanet(clAct);
		GoToState('PlayerWaiting', 'ChangePlanet');
	}
	
	// �������� ������� � Kismet
	WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqEvent_ClickTouchingActor', true, eventList);
	foreach eventList(individualEvent)
	{
		if (individualEvent.IsA('SeqEvent_ClickTouchingActor') && SeqEvent_ClickTouchingActor(individualEvent).ClickableActor_ID == clAct.Kismet_ID)
		{
			SequenceEvent(individualEvent).CheckActivate(self, Pawn);
			break;
		}
	}
	
	UpdCamRot();
}

// Handle mouse inputs
function HandleMouseInput(EMouseEvent mouseEvent, EInputEvent inputEvent)
{
	local MainMenuHUD mainMenuHUD;
	
	// Type cast to get our HUD
	mainMenuHUD = mainMenuHUD(myHUD);
	if (mainMenuHUD != None)
	{
		// Detect what kind of input this is
		if (inputEvent == IE_Pressed)
		{
			// Handle pressed event
			switch (mouseEvent)
			{
				case ME_LeftMouseButton:
					// ��� ������
					
					// ���� �������� �� ClickableActor
					if (CurrentObject != None)
					{
						// �������� ��� ������
						ClickToAct(CurrentObject);
					}
					break;

				case ME_RightMouseButton:
					// ��� ������
					bRotation = true;
					mainMenuHUD(myHUD).drawcursor = false;
					break;

				case ME_MiddleMouseButton:
					// ��� ������
					break;

				case ME_ScrollWheelUp:
					// ������� �����
					ChangeRange(1.1);
					break;

				case ME_ScrollWheelDown:
					// ������� ����
					ChangeRange(0.9);
					break;

				default:
					break;
			}
		}
		else if (inputEvent == IE_Released)
		{
			// Handle released event
			switch (mouseEvent)
			{
				case ME_LeftMouseButton:
					// ��� ��������
					break;

				case ME_RightMouseButton:
					// ��� ��������
					bRotation = false;
					MainMenuHUD(myHUD).drawcursor = true;
					break;

				case ME_MiddleMouseButton:
					// ��� ��������
					break;

				default:
					break;
			}
		}
	}
}


// ------------- ��������� ������� ��������������� ������� ���� -------------

// Hook used for the left and right mouse button when pressed
exec function StartFire(optional byte fireModeNum)
{
	HandleMouseInput((fireModeNum == 0) ? ME_LeftMouseButton : ME_RightMouseButton, IE_Pressed);
	Super.StartFire(fireModeNum);
}

// Hook used for the left and right mouse button when released
exec function StopFire(optional byte fireModeNum)
{
	HandleMouseInput((fireModeNum == 0) ? ME_LeftMouseButton : ME_RightMouseButton, IE_Released);
	Super.StopFire(fireModeNum);
}

// Called when the middle mouse button is pressed
exec function MiddleMousePressed()
{
	HandleMouseInput(ME_MiddleMouseButton, IE_Pressed);
}

// Called when the middle mouse button is released
exec function MiddleMouseReleased()
{
	HandleMouseInput(ME_MiddleMouseButton, IE_Released);
}

// Called when the middle mouse wheel is scrolled up
exec function MiddleMouseScrollUp()
{
	HandleMouseInput(ME_ScrollWheelUp, IE_Pressed);
}

// Called when the middle mouse wheel is scrolled down
exec function MiddleMouseScrollDown()
{
	HandleMouseInput(ME_ScrollWheelDown, IE_Pressed);
}

// ------------- ����� ��������� ������� -------------


defaultproperties
{
	// Set the input class to the mouse interface player input
  InputClass = class'MainMenuPlayerInput'
	CurrentView = MP_Galaxy
	CameraRange = 10000
	bRotation = false
	Name="Default__MainMenuPlayerController"
}
