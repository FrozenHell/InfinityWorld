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

// вращаем ли мы камеру
var bool mirotate;

// текущий объект
var ClickableActor currentevent;

// галактика
var mygalaxy CurrGalax;

// текущая звёздная система
var PlanetSystem CurrSyst;

// текущая планета
var UnPlanet CurrPlan;

// точка, вокруг которой вращаем камеру
var vector ViewPoint;

// новая точка фокуса, в которую производится плавный переход
var vector NewTPos;

// новый актёр для слежения
var Actor NewTAct;

// время перехода камеры
var float DMoveTime;

// текущее время от начала перехода
var float MoveTime;

// время на один шаг
var float DTime;

// шаг движения точки фокуса камеры
var float delta;

// расстояние, на котором находится камера
var float CameraRange;

// угол камеры к центру объекта, как если бы она смотрела в центр
var rotator CameraAngle;

// текущий вид (галактика, звезда, планета, спутник)
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
		// двигаем на скалярную величину (или делаем последний точный шаг)
		ViewPoint+= VSize(NewTPos-ViewPoint)>delta?Normal(NewTPos-ViewPoint)*delta:NewTPos-ViewPoint;
		// обновляем позицию камеры
		updcamrot();
		return ViewPoint == NewTPos;
	}
	
	function bool UpdTActPos() {
		// двигаем на скалярную величину (или делаем последний точный шаг)
		ViewPoint+= VSize(NewTAct.Location-ViewPoint)>delta?Normal(NewTAct.Location-ViewPoint)*delta:NewTAct.Location-ViewPoint;
		// обновляем позицию камеры
		updcamrot();
		return VSize(NewTAct.Location-ViewPoint)<delta;
	}
	
Begin:
	MainMenuHUD(myHUD).PickHouse = PickHouse;
	GoTo('EndAll');

// переходим к виду на планету
WatchPlanet:
	if (CurrentView != MP_Planet) GoTo('EndAll');
	ViewPoint = CurrPlan.Location;
	updcamrot();
	Sleep(0.04);
	GoTo('WatchPlanet');

// плавно меняем положение цели камеры затем переходя на обзор планеты	
ChangePlanet:
	DMoveTime = 3;
	DTime = 0.05;
	delta = VSize(NewTAct.Location-ViewPoint)*DTime/DMoveTime;
ChangePlanetCyc:
	Sleep(DTime);
	// достигли ли нужной точки
	if (UpdTActPos()) GoTo('WatchPlanet');
	GoTo('ChangePlanetCyc');

// плавно меняем положение цели камеры
MoveTCam:
	DMoveTime = 3;
	DTime = 0.05;
	delta = VSize(NewTPos-ViewPoint)*DTime/DMoveTime;
MoveTCamCyc:
	Sleep(DTime);
	// достигли ли нужной точки
	if (UpdTPos()) GoTo('EndAll');
	GoTo('MoveTCamCyc');

EndAll:

}

// создаём галактику
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

// функция вызывается из Hud-а
function PickHouse(ClickableActor clicableevent) {
	if (currentevent != None) currentevent.select(false);
	currentevent = clicableevent;
	if (currentevent != None) currentevent.select(true);
}

// пытаемся повернуть камеру
function UpdateRotation(float DeltaTime) {
	local Rotator	DeltaRot, ViewRotation;
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
		// обновляем положение камеры
		updcamrot();
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

// принудительное обновление камеры
function updcamrot() {
	local vector CameraPos;
	local rotator ViewRotation;
	
	ViewRotation = CameraAngle;
	// направляем будущий вектор вниз
	ViewRotation.Pitch = 0;
	// ищем орт векторного произведения
	CameraPos = Normal( CameraAngle.Pitch>PI*RadToUnrRot ? vector(ViewRotation) Cross vector(CameraAngle) : vector(CameraAngle) Cross vector(ViewRotation) );
	// ищем новое положение камеры
	SetLocation(ViewPoint + vector(CameraAngle)* -CameraRange + CameraPos*CameraRange * 0.3);  // 0.3 - соотношение CameraRange и вектора сдвыгающего камеру вбок. В зависимости от разрешения экрана и FOV может быть разным
}

// кликнули по объекту
function ClickToAct(ClickableActor ClAct) {
	if ((ministar(ClAct) != None)&&(CurrentView == MP_Galaxy)) { // звезда в галактике
		CurrentView = MP_System;
		CurrGalax.ZoomIn();
		//CurrGalax.destroy();
		//CurrSyst = Spawn(class'City.PlanetSystem',UnPawn(Owner),,ViewPoint,Rot(0,0,0));
		//CurrSyst.generate(UnPawn(Owner),1);
	} else if (System_Star(ClAct) != None) { // звезда в системе
		NewTPos = ClAct.Location;
		CurrentView = MP_System;
		GoToState('PlayerWaiting','MoveTCam');
	} else if (UnPlanet(ClAct) != None) { // планета в системе
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
				// ЛКМ нажата
				
				// если кликнули по ClickableActor
				if (currentevent != None) {
					// выделить его цветом
					ClickToAct(currentevent);
				}
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
	CurrentView = MP_Galaxy
	CameraRange = 10000
	mirotate = false
	Name="Default__MainMenuPlayerController"
}
