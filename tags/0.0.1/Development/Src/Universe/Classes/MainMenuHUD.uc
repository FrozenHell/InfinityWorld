class MainMenuHUD extends HUD;

// The texture which represents the cursor on the screen
var const Texture2D CursorTexture;
// The color of the cursor
var const Color CursorColor;
// Pending left mouse button pressed event
var bool PendingLeftPressed;
// Pending left mouse button released event
var bool PendingLeftReleased;
// Pending right mouse button pressed event
var bool PendingRightPressed;
// Pending right mouse button released event
var bool PendingRightReleased;
// Pending middle mouse button pressed event
var bool PendingMiddlePressed;
// Pending middle mouse button released event
var bool PendingMiddleReleased;
// Pending mouse wheel scroll up event
var bool PendingScrollUp;
// Pending mouse wheel scroll down event
var bool PendingScrollDown;
// Cached mouse world origin
var Vector CachedMouseWorldOrigin;
// Cached mouse world direction
var Vector CachedMouseWorldDirection;
// Use ScaleForm?
var bool UsingScaleForm;

// ѕоказывать ли курсор
var bool DrawCursor;
// выделен ли дом
var bool bPickHouse;

delegate PickHouse(ClickableActor clicablehouse);

event PostRender()
{
  local MainMenuPlayerInput MainMenuPlayerInput;
	local ClickableActor thisActor;

	// если мы не в режиме вращени€ камеры
	if (DrawCursor)
	{
		// Ensure that we have a valid PlayerOwner and CursorTexture
		if (PlayerOwner != None && CursorTexture != None)
		{
			// Cast to get the MainMenuPlayerInput
			MainMenuPlayerInput = MainMenuPlayerInput(PlayerOwner.PlayerInput); 

			if (MainMenuPlayerInput != None)
			{
				// Set the canvas position to the mouse position
				Canvas.SetPos(MainMenuPlayerInput.MousePosition.X, MainMenuPlayerInput.MousePosition.Y); 
				// Set the cursor color
				Canvas.DrawColor = CursorColor;
				// Draw the texture on the screen
				Canvas.DrawTile(CursorTexture, CursorTexture.SizeX, CursorTexture.SizeY, 0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, true);
			}
		}
		// провер€ем, видим ли мы дом
		thisActor = GetMouseActor();
		if (thisActor != None)
		{
			if (!bPickHouse)
			{
				bPickHouse = true;
				PickHouse(thisactor);
				//`log("я вижу дом");
			}
		}
		else if (bpickhouse)
		{
			bPickHouse = false;
			PickHouse(None);
			//`log("я не вижу дом");
		}
	}
	else if (bpickhouse) { // если мы в режиме вращени€ камеры и дом выделен
		// снимаем выделение с дома
		bPickHouse = false;
		PickHouse(None);
		//`log("я ничего не вижу");
	}

  Super.PostRender();
}

function ClickableActor GetMouseActor(optional out Vector HitLocation, optional out Vector HitNormal) {
	local MainMenuPlayerInput MainMenuPlayerInput;
	local Vector2D MousePosition;
	local Actor HitActor;
	local ClickableActor thisactor;

	// Ensure that we have a valid canvas and player owner
	if (Canvas == None || PlayerOwner == None)
	{
		return None;
	}

	// Type cast to get the new player input
	MainMenuPlayerInput = MainMenuPlayerInput(PlayerOwner.PlayerInput);

	// Ensure that the player input is valid
	if (MainMenuPlayerInput == None)
	{
		return None;
	}

	// We stored the mouse position as an IntPoint, but it's needed as a Vector2D
	MousePosition.X = MainMenuPlayerInput.MousePosition.X;
	MousePosition.Y = MainMenuPlayerInput.MousePosition.Y;
	// Deproject the mouse position and store it in the cached vectors
	Canvas.DeProject(MousePosition, CachedMouseWorldOrigin, CachedMouseWorldDirection);

	// Perform a trace actor interator. An interator is used so that we get the top most mouse interaction
	// interface. This covers cases when other traceable objects (such as static meshes) are above mouse
	// interaction interfaces.
	ForEach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, CachedMouseWorldOrigin + CachedMouseWorldDirection * 65536.f, CachedMouseWorldOrigin,,, TRACEFLAG_Bullet)
	{
		// Type cast to see if the HitActor implements that mouse interaction interface
		thisactor = ClickableActor(HitActor);
		if (thisactor != None)
		{
			return thisactor;
		}
	}

	return None;
}

/*
function Vector GetMouseWorldLocation() {
  local MainMenuPlayerInput MainMenuPlayerInput;
  local Vector2D MousePosition;
  local Vector MouseWorldOrigin, MouseWorldDirection, HitLocation, HitNormal;

  // Ensure that we have a valid canvas and player owner
  if ( Canvas == None ||  PlayerOwner == None)
	{
    return Vect(0, 0, 0);
  }
	
  // Type cast to get the new player input
  MainMenuPlayerInput = MainMenuPlayerInput(PlayerOwner.PlayerInput);

  // Ensure that the player input is valid
  if (MainMenuPlayerInput == None)
	{
    return Vect(0, 0, 0);
  }

  // We stored the mouse position as an IntPoint, but it's needed as a Vector2D
  MousePosition.X = MainMenuPlayerInput.MousePosition.X;
  MousePosition.Y = MainMenuPlayerInput.MousePosition.Y;
  // Deproject the mouse position and store it in the cached vectors

  Canvas.DeProject(MousePosition, MouseWorldOrigin, MouseWorldDirection);

  // Perform a trace to get the actual mouse world location.
  Trace(HitLocation, HitNormal, MouseWorldOrigin + MouseWorldDirection * 65536.f, MouseWorldOrigin , true,,, TRACEFLAG_Bullet);

  return HitLocation;
}
*/

defaultproperties
{
	// Set to false if you wish to use Unreal's player input to retrieve the mouse coordinates
	UsingScaleForm = true
	bpickhouse = false
	DrawCursor = true
	CursorColor=(R=255,G=255,B=255,A=255)
	CursorTexture=Texture2D'EngineResources.Cursors.Arrow'
}