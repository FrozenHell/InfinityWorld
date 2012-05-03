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

// вращаем ли мы камеру
var bool mirotate;
// выделенный дом
var ClickableActor currentevent;

// точка, вокруг которой вращаем камеру
var vector ViewPoint;

// расстояние, на котором находится камера
var float CameraRange;

// угол камеры к центру объекта, как если бы она смотрела в центр
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

// пытаемся повернуть камеру
function UpdateRotation(float DeltaTime) {
	local Rotator	DeltaRot, ViewRotation;
	local vector CameraPos;
	// если мы в режиме вращения камеры
	if (mirotate) {
		// вычисляем дельту поворота
		DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aLookUp;
		ViewRotation = CameraAngle;
		// поворачиваем вектор ViewRotation на дельту
		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		// полученный вектор записываем в CameraAngle
		CameraAngle = ViewRotation;
		// применяем поворот к камере
		SetRotation(ViewRotation);
		ViewShake( deltaTime );
		// направляем будущий вектор вниз
		ViewRotation.Pitch = 0;
		// ищем орт векторного произведения
		CameraPos = Normal( CameraAngle.Pitch>PI*RadToUnrRot ? vector(ViewRotation) Cross vector(CameraAngle) : vector(CameraAngle) Cross vector(ViewRotation) );
		// ищем новое положение камеры
		SetLocation(viewpoint + vector(CameraAngle)* -CameraRange + CameraPos*CameraRange * 0.3); // 0.3 - соотношение CameraRange и вектора сдвыгающего камеру вбок. В зависимости от разрешения экрана и FOV может быть разным
	}
}

// изменяем расстояние камеры
function ChCamRange(int inc, optional bool mult = false) {
	local int newrange, maxrange, minrange;
	maxrange = 20000;
	minrange = 1000;
	newrange = mult ? CameraRange * inc : CameraRange + inc;
	if (newrange>minrange && newrange<maxrange) CameraRange = newrange;
}

// необходим для принудительного обновления камеры
function updcamrot() {
	local vector CameraPos;
	local rotator ViewRotation;
	
	ViewRotation = CameraAngle;
	ViewRotation.Pitch = 0;
	CameraPos = Normal( CameraAngle.Pitch>PI*RadToUnrRot ? vector(ViewRotation) Cross vector(CameraAngle) : vector(CameraAngle) Cross vector(ViewRotation) );
	// ищем новое положение камеры
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
				// ЛКМ нажата
				
				// если кликнули по ClickableActor
				if (currentevent != None) {
					// выделить его цветом
					currentevent.change();
				}
				
				ChCamRange(-1000);				
				updcamrot();
				break;

			case RightMouseButton:
				// ПКМ нажата
				mirotate = true;
				MainMenuHUD(myHUD).drawcursor = false;
				break;

			case MiddleMouseButton:
				// СКМ нажата
				break;

			case ScrollWheelUp:
				// колёсико вверх
				ChCamRange(-1000);
				updcamrot();
				break;

			case ScrollWheelDown:
				// колёсико вниз
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
				// ЛКМ отпущена
				break;

			case RightMouseButton:
				// ПКМ отпущена
				mirotate = false;
				MainMenuHUD(myHUD).drawcursor = true;
				break;

			case MiddleMouseButton:
				// СКМ отпущена
				break;

			default:
				break;
			}
		}
	}
}


// ------------- служебные функции перехватывающие команды мыши -------------

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

// ------------- конец служебных функций -------------


defaultproperties
{
	// Set the input class to the mouse interface player input
  InputClass=class'MainMenuPlayerInput'
	CameraRange = 10000
	mirotate = false
	Name="Default__MainMenuPlayerController"
}
