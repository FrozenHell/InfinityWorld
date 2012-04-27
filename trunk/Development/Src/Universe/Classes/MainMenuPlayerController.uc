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

// Override this state because StartFire isn't called globally when in this function
auto state PlayerWaiting
{
	exec function StartFire(optional byte FireModeNum)
	{
		Global.StartFire(FireModeNum);
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

// отключать вращение, когда нам надо
function UpdateRotation(float DeltaTime) {
	if (mirotate) {
		Super.UpdateRotation(DeltaTime);
	}
};

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
				if (currentevent != None) {
					currentevent.Change();
				}
				`log("ЛКМ нажата");
				// ЛКМ нажата
				break;

			case RightMouseButton:
				mirotate = true;
				MainMenuHUD(myHUD).drawcursor = false;
				break;

			case MiddleMouseButton:
				// СКМ нажата
				break;

			case ScrollWheelUp:
				// колёсико вверх
				SpectatorCameraSpeed = SpectatorCameraSpeed<3000?SpectatorCameraSpeed+300:SpectatorCameraSpeed;
				break;

			case ScrollWheelDown:
				// колёсико вниз
				SpectatorCameraSpeed = SpectatorCameraSpeed>300?SpectatorCameraSpeed-300:SpectatorCameraSpeed;
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
	mirotate = false
	SpectatorCameraSpeed = 1200
	Name="Default__MainMenuPlayerController"
}
