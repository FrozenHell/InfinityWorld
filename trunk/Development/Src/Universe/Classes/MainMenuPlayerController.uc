class MainMenuPlayerController extends PlayerController;

// Mouse event enum
enum EMouseEvent
{
	LeftMouseButton,
	RightMouseButton,
	MiddleMouseButton,
	ScrollWheelUp,
	ScrollWheelDown,
};

// ������� �� �� ������
var bool mirotate;
// ���������� ���
var ClickableActor currentevent;

// �����, ������ ������� ������� ������
var vector ViewPoint;

// ����������, �� ������� ��������� ������
var float CameraRange;

// ���� ������ � ������ �������, ��� ���� �� ��� �������� � �����
var rotator CameraAngle;

// Override this state because StartFire isn't called globally when in this function
auto state PlayerWaiting {
	exec function StartFire(optional byte FireModeNum)
	{
		Global.StartFire(FireModeNum);
	}
	
	function PlayerMove( float DeltaTime ) {
		UpdateRotation(DeltaTime);
	}
	
Begin:
	MainMenuHUD(myHUD).PickHouse = PickHouse;
}

exec function initgalaxy(optional int numst = 1000) {
	local mygalaxy galaxy;
	galaxy = Spawn(class'City.mygalaxy',Pawn(Owner),,vect(0,0,0),rot(0,0,0));
	galaxy.GetPlayerViewPoint = GetPlayerViewPoint;
	//say("Generated"@numst@"stars");
	galaxy.gen(Pawn(Owner),numst);
}

function PickHouse(ClickableActor clicableevent) {
	currentevent = clicableevent;
}

// �������� ��������� ������
function UpdateRotation(float DeltaTime) {
	local Rotator	DeltaRot, ViewRotation;
	local vector CameraPos;
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
		// ���������� ������� ������ ����
		ViewRotation.Pitch = 0;
		// ���� ��� ���������� ������������
		CameraPos = Normal( CameraAngle.Pitch>PI*RadToUnrRot ? vector(ViewRotation) Cross vector(CameraAngle) : vector(CameraAngle) Cross vector(ViewRotation) );
		// ���� ����� ��������� ������
		SetLocation(viewpoint + vector(CameraAngle)* -CameraRange + CameraPos*CameraRange * 0.3); // 0.3 - ����������� CameraRange � ������� ����������� ������ ����. � ����������� �� ���������� ������ � FOV ����� ���� ������
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

// ��������� ��� ��������������� ���������� ������
function updcamrot() {
	local vector CameraPos;
	local rotator ViewRotation;
	
	ViewRotation = CameraAngle;
	ViewRotation.Pitch = 0;
	CameraPos = Normal( CameraAngle.Pitch>PI*RadToUnrRot ? vector(ViewRotation) Cross vector(CameraAngle) : vector(CameraAngle) Cross vector(ViewRotation) );
	// ���� ����� ��������� ������
	SetLocation(viewpoint + vector(CameraAngle)* -CameraRange + CameraPos*CameraRange * 0.3);
}

/*
function UpdateRotation( float DeltaTime ) {
	local Rotator	DeltaRot, newRotation, ViewRotation;

	ViewRotation = Rotation;
	if (Pawn!=none)
	{
		Pawn.SetDesiredRotation(ViewRotation);
	}

	// Calculate Delta to be applied on ViewRotation
	DeltaRot.Yaw	= PlayerInput.aTurn;
	DeltaRot.Pitch	= PlayerInput.aLookUp;

	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
	SetRotation(ViewRotation);

	ViewShake( deltaTime );

	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;

	if ( Pawn != None )
		Pawn.FaceRotation(NewRotation, deltatime);
}*/


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
					currentevent.change();
				}
				
				ChCamRange(-1000);				
				updcamrot();
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
	CameraRange = 10000
	mirotate = false
	Name="Default__MainMenuPlayerController"
}
