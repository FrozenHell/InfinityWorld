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

enum EModelPart {
	MP_Galaxy,
	MP_System,
	MP_Planet,
	MP_Sputnik
};

// вращаем ли мы камеру
var bool bRotation;

var vector TestTest;

// текущий объект
var ClickableActor currentevent;

// галактика
var MyGalaxy CurrGalax;

// текущая звёздная система
var PlanetSystem CurrSyst;

// текущая планета
var UnPlanet CurrPlan;

// точка, вокруг которой вращаем камеру
var vector ViewPoint;

// новая точка фокуса, в которую производится плавный переход
var vector NewFocusPos;

// новый актёр для слежения
var Actor NewFocusAct;

// время перехода камеры
var float DeltaMoveTime;

// текущее время от начала перехода
var float MoveTime;

// время на один шаг
var float DeltaTime;

// шаг движения точки фокуса камеры
var float Delta;

// расстояние, на котором находится камера
var float CameraRange;

// угол камеры к центру объекта, как если бы она смотрела в центр
var rotator CameraAngle;

// текущий вид (галактика, звезда, планета, спутник)
var EModelPart CurrentView;

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
	
	function bool UpdCamToFocusPos()
	{
		if (VSize(NewFocusPos - ViewPoint) > Delta)
			ViewPoint += Normal(NewFocusPos - ViewPoint) * Delta; // двигаем на скалярную величину
		else
			ViewPoint += NewFocusPos - ViewPoint; // последний шаг
		
		// обновляем позицию камеры
		UpdCamRot();
		return ViewPoint == NewFocusPos;
	}
	
	// движение камеры к актёру
	function bool UpdCamToFocusActPos()
	{
		if (VSize(NewFocusAct.Location - ViewPoint) > Delta)
			ViewPoint += Normal(NewFocusAct.Location - ViewPoint) * Delta; // двигаем на скалярную величину
		else
			ViewPoint += NewFocusAct.Location - ViewPoint; // делаем последний точный шаг
		// обновляем позицию камеры
		UpdCamRot();
		return VSize(NewFocusAct.Location-ViewPoint) < Delta;
	}
	
Begin:
	MainMenuHUD(myHUD).PickHouse = PickHouse;
	SetLocation(vect(-10000, 0, 0));
	SetRotation(UnrRot(0, 0, 0));
	GoTo('EndAll');

// переходим к виду на планету
WatchPlanet:
	if (CurrentView != MP_Planet) GoTo('EndAll');
	ViewPoint = CurrPlan.Location;
	UpdCamRot();
	Sleep(0.04);
	GoTo('WatchPlanet');

// плавно меняем положение цели камеры затем переходя на обзор планеты	
ChangePlanet:
	DeltaMoveTime = 3;
	DeltaTime = 0.05;
	Delta = VSize(NewFocusAct.Location - ViewPoint) * DeltaTime / DeltaMoveTime;
ChangePlanetCyc:
	Sleep(DeltaTime);
	// достигли ли нужной точки
	if (UpdCamToFocusActPos()) GoTo('WatchPlanet');
	GoTo('ChangePlanetCyc');

// плавно меняем положение цели камеры
MoveTCam:
	DeltaMoveTime = 3;
	DeltaTime = 0.05;
	Delta = VSize(NewFocusPos - ViewPoint) * DeltaTime / DeltaMoveTime;
MoveTCamCyc:
	Sleep(DeltaTime);
	// достигли ли нужной точки
	if (UpdCamToFocusPos()) GoTo('EndAll');
	GoTo('MoveTCamCyc');

EndAll:

}

function rotator UnrRot(float pitch, float yaw, float roll)
{
	local rotator rota;
	local float DegToRot;
	DegToRot = DegToRad * RadToUnrRot;
	rota.Pitch = pitch * DegToRot;
	rota.Yaw = yaw * DegToRot;
	rota.Roll = roll * DegToRot;
	return rota;
}

// создаём галактику
exec function InitGalaxy(optional int numStars = 10000)
{
	if ((CurrGalax) == None)
	{
		// создаём объект - галактику
		CurrGalax = Spawn(class'City.mygalaxy', Pawn(Owner),, vect(0, 0, 0), rot(0, 0, 0));
		// передаём ссылку на функцию
		CurrGalax.GetPlayerViewPoint = GetPlayerViewPoint;
		// переключаем галактику в режим космоса
		CurrGalax.Cosmos = true;
		// заполняем галактику звёздами в количестве numStars
		CurrGalax.gen(Pawn(Owner), numStars);
	}
	UpdCamRot();
}

// функция вызывается из Hud-а
function PickHouse(ClickableActor clicableevent)
{
	if (currentevent != None)
		currentevent.select(false);
	currentevent = clicableevent;
	if (currentevent != None)
		currentevent.select(true);
}

// пытаемся повернуть камеру
/*function UpdateRotation(float fDeltaTime)
{
	local Rotator	deltaRot, viewRotation;
	// если мы в режиме вращения камеры
	if (bRotation)
	{
		// вычисляем дельту поворота
		deltaRot.Yaw	= PlayerInput.aTurn;
		deltaRot.Pitch	= PlayerInput.aLookUp;
		viewRotation = CameraAngle;
		// поворачиваем вектор viewRotation на дельту
		ProcessViewRotation(fDeltaTime, viewRotation, deltaRot);
		// полученный вектор записываем в CameraAngle
		CameraAngle = viewRotation;
		// применяем поворот к камере
		SetRotation(viewRotation);
		ViewShake(fDeltaTime);
		// обновляем положение камеры
		UpdCamRot();
	}
}*/

function UpdateRotation(float fDeltaTime)
{
	// если мы в режиме вращения камеры
	if (bRotation)
	{
		// вычисляем дельту поворота
		TestTest.y = ((TestTest.y - PlayerInput.aLookUp / 1000 > 1.57) ? 1.57 : (TestTest.y - PlayerInput.aLookUp / 1000 < -1.57) ? -1.57 : TestTest.y - PlayerInput.aLookUp / 1000);
		CurrGalax.RotateGf(0, TestTest.y, TestTest.x += PlayerInput.aTurn / 1000);
	}
}

// принудительное обновление камеры
function UpdCamRot()
{
	local vector cameraPos;
	local rotator viewRotation;
	
	viewRotation = CameraAngle;
	// направляем будущий вектор вниз
	viewRotation.Pitch = 0;
	// ищем орт векторного произведения
	cameraPos = Normal(CameraAngle.Pitch > PI * RadToUnrRot ? vector(viewRotation) Cross vector(CameraAngle) : vector(CameraAngle) Cross vector(viewRotation));
	// ищем новое положение камеры
	SetLocation(ViewPoint + vector(CameraAngle) * -CameraRange + cameraPos * CameraRange * 0.3);  // 0.3 - соотношение CameraRange и вектора сдвигающего камеру вбок. В зависимости от разрешения экрана и FOV может быть разным
}

// изменяем расстояние камеры
function ChangeRange(float mod) {
	switch (CurrentView)
	{
		case MP_Galaxy: // галактика
			CurrGalax.ScaleG(mod);
			break;
		// будет задействовано позже
		default:
			break;
	}
}


// кликнули по объекту
function ClickToAct(ClickableActor clAct)
{
	if (ministar(clAct) != None && CurrentView == MP_Galaxy) // звезда в галактике
	{
		CurrentView = MP_System;
		CurrGalax.MoveGf(-clAct.Location);
		CurrGalax.ZoomIn();
		//CurrGalax.destroy();
		//CurrSyst = Spawn(class'City.PlanetSystem', UnPawn(Owner),, ViewPoint, Rot(0, 0, 0));
		//CurrSyst.generate(UnPawn(Owner),1);
	}
	else if (System_Star(clAct) != None) // звезда в системе
	{
		NewFocusPos = clAct.Location;
		CurrentView = MP_System;
		GoToState('PlayerWaiting', 'MoveTCam');
	}
	else if (UnPlanet(clAct) != None)  // планета в системе
	{
		CurrentView = MP_Planet;
		NewFocusAct = clAct;
		CurrPlan = UnPlanet(clAct);
		GoToState('PlayerWaiting', 'ChangePlanet');
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
					// ЛКМ нажата
					
					// если кликнули по ClickableActor
					if (currentevent != None)
					{
						// выделить его цветом
						ClickToAct(currentevent);
					}
					break;

				case ME_RightMouseButton:
					// ПКМ нажата
					bRotation = true;
					mainMenuHUD(myHUD).drawcursor = false;
					break;

				case ME_MiddleMouseButton:
					// СКМ нажата
					break;

				case ME_ScrollWheelUp:
					// колёсико вверх
					ChangeRange(1.1);
					break;

				case ME_ScrollWheelDown:
					// колёсико вниз
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
					// ЛКМ отпущена
					break;

				case ME_RightMouseButton:
					// ПКМ отпущена
					bRotation = false;
					MainMenuHUD(myHUD).drawcursor = true;
					break;

				case ME_MiddleMouseButton:
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

// ------------- конец служебных функций -------------


defaultproperties
{
	// Set the input class to the mouse interface player input
  InputClass=class'MainMenuPlayerInput'
	CurrentView = MP_Galaxy
	CameraRange = 10000
	bRotation = false
	Name="Default__MainMenuPlayerController"
}
