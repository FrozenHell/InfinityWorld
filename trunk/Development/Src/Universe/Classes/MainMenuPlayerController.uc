class MainMenuPlayerController extends PlayerController;

// Mouse event enum
enum EMouseEvent
{
	LeftMouseButton,
	RightMouseButton,
	MiddleMouseButton,
	ScrollWheelUp,
	ScrollWheelDown
};

enum ModelPart {
	MP_Galaxy,
	MP_System,
	MP_Planet,
	MP_Sputnik
};

// ������� �� �� ������
var bool mirotate;

// ������� ������
var ClickableActor currentevent;

// ���������
var mygalaxy CurrGalax;

// ������� ������� �������
var PlanetSystem CurrSyst;

// ������� �������
var UnPlanet CurrPlan;

// �����, ������ ������� ������� ������
var vector ViewPoint;

// ����� ����� ������, � ������� ������������ ������� �������
var vector NewTPos;

// ����� ���� ��� ��������
var Actor NewTAct;

// ����� �������� ������
var float DMoveTime;

// ������� ����� �� ������ ��������
var float MoveTime;

// ����� �� ���� ���
var float DTime;

// ��� �������� ����� ������ ������
var float delta;

// ����������, �� ������� ��������� ������
var float CameraRange;

// ���� ������ � ������ �������, ��� ���� �� ��� �������� � �����
var rotator CameraAngle;

// ������� ��� (���������, ������, �������, �������)
var ModelPart CurrentView;

// Override this state because StartFire isn't called globally when in this function
auto state PlayerWaiting {
	
	exec function StartFire(optional byte FireModeNum)
	{
		Global.StartFire(FireModeNum);
	}
	
	function PlayerMove( float DeltaTime ) {
		UpdateRotation(DeltaTime);
	}
	
	function bool UpdTPos() {
		// ������� �� ��������� �������� (��� ������ ��������� ������ ���)
		ViewPoint+= VSize(NewTPos-ViewPoint)>delta?Normal(NewTPos-ViewPoint)*delta:NewTPos-ViewPoint;
		// ��������� ������� ������
		updcamrot();
		return ViewPoint == NewTPos;
	}
	
	function bool UpdTActPos() {
		// ������� �� ��������� �������� (��� ������ ��������� ������ ���)
		ViewPoint+= VSize(NewTAct.Location-ViewPoint)>delta?Normal(NewTAct.Location-ViewPoint)*delta:NewTAct.Location-ViewPoint;
		// ��������� ������� ������
		updcamrot();
		return VSize(NewTAct.Location-ViewPoint)<delta;
	}
	
Begin:
	MainMenuHUD(myHUD).PickHouse = PickHouse;
	GoTo('EndAll');

// ��������� � ���� �� �������
WatchPlanet:
	if (CurrentView != MP_Planet) GoTo('EndAll');
	ViewPoint = CurrPlan.Location;
	updcamrot();
	Sleep(0.04);
	GoTo('WatchPlanet');

// ������ ������ ��������� ���� ������ ����� �������� �� ����� �������	
ChangePlanet:
	DMoveTime = 3;
	DTime = 0.05;
	delta = VSize(NewTAct.Location-ViewPoint)*DTime/DMoveTime;
ChangePlanetCyc:
	Sleep(DTime);
	// �������� �� ������ �����
	if (UpdTActPos()) GoTo('WatchPlanet');
	GoTo('ChangePlanetCyc');

// ������ ������ ��������� ���� ������
MoveTCam:
	DMoveTime = 3;
	DTime = 0.05;
	delta = VSize(NewTPos-ViewPoint)*DTime/DMoveTime;
MoveTCamCyc:
	Sleep(DTime);
	// �������� �� ������ �����
	if (UpdTPos()) GoTo('EndAll');
	GoTo('MoveTCamCyc');

EndAll:

}

// ������ ���������
exec function initgalaxy(optional int numst = 10000) {
	if ((CurrGalax) == None) {
		CurrGalax = Spawn(class'City.mygalaxy',Pawn(Owner),,vect(0,0,0),rot(0,0,0));
		CurrGalax.GetPlayerViewPoint = GetPlayerViewPoint;
		//say("Generated"@numst@"stars");
		CurrGalax.gen(Pawn(Owner),numst);
	}
	SetRotation(rot(0,10000,0));
	updcamrot();
}

// ������� ���������� �� Hud-�
function PickHouse(ClickableActor clicableevent) {
	if (currentevent != None) currentevent.select(false);
	currentevent = clicableevent;
	if (currentevent != None) currentevent.select(true);
}

// �������� ��������� ������
function UpdateRotation(float DeltaTime) {
	local Rotator	DeltaRot, ViewRotation;
	// ���� �� � ������ �������� ������
	if (mirotate) {
		// ��������� ������ ��������
		DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aLookUp;
		ViewRotation = CameraAngle;
		// ������������ ������ ViewRotation �� ������
		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		// ���������� ������ ���������� � CameraAngle
		CameraAngle = ViewRotation;
		// ��������� ������� � ������
		SetRotation(ViewRotation);
		ViewShake( deltaTime );
		// ��������� ��������� ������
		updcamrot();
	}
}

// �������� ���������� ������
function ChCamRange(int inc, optional bool mult = false) {
	local int newrange, maxrange, minrange;
	maxrange = 20000;
	minrange = 1000;
	newrange = mult ? CameraRange * inc : CameraRange + inc;
	if (newrange>minrange && newrange<maxrange) CameraRange = newrange;
}

// �������������� ���������� ������
function updcamrot() {
	local vector CameraPos;
	local rotator ViewRotation;
	
	ViewRotation = CameraAngle;
	// ���������� ������� ������ ����
	ViewRotation.Pitch = 0;
	// ���� ��� ���������� ������������
	CameraPos = Normal( CameraAngle.Pitch>PI*RadToUnrRot ? vector(ViewRotation) Cross vector(CameraAngle) : vector(CameraAngle) Cross vector(ViewRotation) );
	// ���� ����� ��������� ������
	SetLocation(ViewPoint + vector(CameraAngle)* -CameraRange + CameraPos*CameraRange * 0.3);  // 0.3 - ����������� CameraRange � ������� ����������� ������ ����. � ����������� �� ���������� ������ � FOV ����� ���� ������
}

// �������� �� �������
function ClickToAct(ClickableActor ClAct) {
	if ((ministar(ClAct) != None)&&(CurrentView == MP_Galaxy)) { // ������ � ���������
		CurrentView = MP_System;
		CurrGalax.ZoomIn();
		//CurrGalax.destroy();
		//CurrSyst = Spawn(class'City.PlanetSystem',UnPawn(Owner),,ViewPoint,Rot(0,0,0));
		//CurrSyst.generate(UnPawn(Owner),1);
	} else if (System_Star(ClAct) != None) { // ������ � �������
		NewTPos = ClAct.Location;
		CurrentView = MP_System;
		GoToState('PlayerWaiting','MoveTCam');
	} else if (UnPlanet(ClAct) != None) { // ������� � �������
		CurrentView = MP_Planet;
		NewTAct = ClAct;
		CurrPlan = UnPlanet(ClAct);
		GoToState('PlayerWaiting','ChangePlanet');
	}
	updcamrot();
}

// Handle mouse inputs
function HandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent)
{
	local MainMenuHUD MainMenuHUD;
	
	// Type cast to get our HUD
	MainMenuHUD = MainMenuHUD(myHUD);
	if (MainMenuHUD != None)
	{
		// Detect what kind of input this is
		if (InputEvent == IE_Pressed)
		{
			// Handle pressed event
			switch (MouseEvent)
			{
			case LeftMouseButton:
				// ��� ������
				
				// ���� �������� �� ClickableActor
				if (currentevent != None) {
					// �������� ��� ������
					ClickToAct(currentevent);
				}
				break;

			case RightMouseButton:
				// ��� ������
				mirotate = true;
				MainMenuHUD(myHUD).drawcursor = false;
				break;

			case MiddleMouseButton:
				// ��� ������
				break;

			case ScrollWheelUp:
				// ������� �����
				ChCamRange(-1000);
				updcamrot();
				break;

			case ScrollWheelDown:
				// ������� ����
				ChCamRange(1000);
				updcamrot();
				break;

			default:
				break;
			}
		}
		else if (InputEvent == IE_Released)
		{
			// Handle released event
			switch (MouseEvent)
			{
			case LeftMouseButton:
				// ��� ��������
				break;

			case RightMouseButton:
				// ��� ��������
				mirotate = false;
				MainMenuHUD(myHUD).drawcursor = true;
				break;

			case MiddleMouseButton:
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
exec function StartFire(optional byte FireModeNum)
{
	HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Pressed);
	Super.StartFire(FireModeNum);
}

// Hook used for the left and right mouse button when released
exec function StopFire(optional byte FireModeNum)
{
	HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Released);
	Super.StopFire(FireModeNum);
}

// Called when the middle mouse button is pressed
exec function MiddleMousePressed()
{
	HandleMouseInput(MiddleMouseButton, IE_Pressed);
}

// Called when the middle mouse button is released
exec function MiddleMouseReleased()
{
	HandleMouseInput(MiddleMouseButton, IE_Released);
}

// Called when the middle mouse wheel is scrolled up
exec function MiddleMouseScrollUp()
{
	HandleMouseInput(ScrollWheelUp, IE_Pressed);
}

// Called when the middle mouse wheel is scrolled down
exec function MiddleMouseScrollDown()
{
	HandleMouseInput(ScrollWheelDown, IE_Pressed);
}

// ------------- ����� ��������� ������� -------------


defaultproperties
{
	// Set the input class to the mouse interface player input
  InputClass=class'MainMenuPlayerInput'
	CurrentView = MP_Galaxy
	CameraRange = 10000
	mirotate = false
	Name="Default__MainMenuPlayerController"
}
