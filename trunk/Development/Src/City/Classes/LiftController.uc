/**
 *	LiftController
 *
 *	Creation date: 19.03.2013 01:51
 *	Copyright 2013, FHS
 */
class LiftController extends Actor;

// ������ ������ � ������
var int Height;
// ������ ������ ����� ������
var int BlockHeight;

// ��������������� ����������
var Actor MyPawn;

// ������ �����
var LiftRoom Room;

// ��������� �������� ������ �����
const LiftbuttonOffset = vect(70, 140, 80);

// ����� �� ������ �����
var array<LiftDoor> Doors;

// ������ ������ ����� �� ������ �����
var array<LiftButton> Buttons;

// ������ ����� �����
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

// ��� �����������
event Destroyed()
{
	super.Destroyed();
}

defaultproperties
{
	Height = 10
	BlockHeight = 250
}