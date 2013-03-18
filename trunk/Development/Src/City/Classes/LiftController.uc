/**
 *	LiftController
 *
 *	Creation date: 19.03.2013 01:51
 *	Copyright 2013, FHS
 */
class LiftController extends Actor;

// высота здания в блоках
var int Height;
// высота одного блока здания
var int BlockHeight;

// вспомогательная переменная
var Actor MyPawn;

// кабина лифта
var LiftRoom Room;

// локальное смещение кнопки лифта
const LiftbuttonOffset = vect(70, 140, 80);

// двери на каждом этаже
var array<LiftDoor> Doors;

// кнопки вызова лифта на каждом этаже
var array<LiftButton> Buttons;

// создаём шахту лифта
function Create(Actor locPawn, int lHeight, int lBlHeight)
{
	local int i;
	local vector localLocation;

	Height = lHeight;
	BlockHeight = lBlHeight;
	MyPawn = locPawn;

	Room = Spawn(class'City.LiftRoom', MyPawn,, Location, Rotation);

	for (i = 0; i < Height; i++)
	{
		localLocation = Location;
		localLocation.z += i * BlockHeight;
		Doors[i] = Spawn(class'City.LiftDoor', MyPawn,, localLocation, Rotation);

		localLocation += vector(rotator(LiftbuttonOffset) + Rotation) * VSize(LiftbuttonOffset);
		Buttons[i] = Spawn(class'City.LiftButton', MyPawn,, localLocation, Rotation);
	}
}

// при уничтожении
event Destroyed()
{
	super.Destroyed();
}

defaultproperties
{
	Height = 10
	BlockHeight = 250
}