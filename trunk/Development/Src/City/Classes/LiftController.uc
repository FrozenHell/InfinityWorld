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

// ���� �� ������� �������� ����
var int nextFloor;

// ������ �����
var LiftRoom Room;

// ������� ����������� �������� (-1, 0 ��� 1), �������� ������ �� ���������� ������� �����
var int currentDirection;

// �������� ������ �� ���������� ������� �����
var int currentFloor;

// ��������� �������� ������ �����
const LiftbuttonOffset = vect(70, 140, 80);

// ����� �� ������ �����
var array<LiftDoor> Doors;

// ������ ������ ����� �� ������ �����
var array<LiftButton> Buttons;

//-----------------------

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
		Buttons[i].Floor = i;
		Buttons[i].CallLift = CallLift;
	}
}

// ���-�� ������ ����
function CallLift(int newFloor)
{
	GoToState('Moving');
}

//������ ���� ��� ������� �� ������ �����
function ControlPanelAddFloor(int newFloor)
{
	//������ ���� ��� �������
}

// ������������� ��������� ���� ��� ����������� direct - ����������� (0, ���� �� �����)
function GetNextFloor(int direct)
{
	local int i, nextLow, nextHigh;

	nextHigh = -1;
	nextLow = -1;

	// ���� ��������� ���� ����
	i = currentFloor + 1;
	while (i < Height)
	{
		if (Buttons[i].LiftState == 1)
		{
			nextHigh = i;
			break;
		}

		i++;
	}

	// ���� ��������� ���� ����
	i = currentFloor - 1;
	while (i >= 0)
	{
		if (Buttons[i].LiftState == 1)
		{
			nextLow = i;
			break;
		}

		i--;
	}


	if (direct == 0)
	{
		// ������� ����� ������� �������
		if (nextHigh - currentFloor > currentFloor - nextLow)
		{
			if (nextLow != -1)
				nextFloor = nextLow;
			else if (nextHigh != -1)
				nextFloor = nextHigh;
			else
				nextFloor = currentFloor;
		}
		else
		{
			if (nextHigh != -1)
				nextFloor = nextHigh;
			else if (nextLow != -1)
				nextFloor = nextLow;
			else
				nextFloor = currentFloor;
		}
	}
	else if (direct == 1)
	{
		if (nextHigh != -1)
			nextFloor = nextHigh;
		else if (nextLow != -1)
			nextFloor = nextLow;
		else
			nextFloor = currentFloor;
	}
	else
	{
		if (nextLow != -1)
			nextFloor = nextLow;
		else if (nextHigh != -1)
			nextFloor = nextHigh;
		else
			nextFloor = currentFloor;
	}
	
	if (nextFloor == nextHigh)
	{
		currentDirection = 1;
	}
	else if (nextFloor == nextLow)
	{
		currentDirection = -1;
	}
	else
	{
		currentDirection = 0;
	}
}

// ��� �����������
event Destroyed()
{
	super.Destroyed();
}

//------------------------

// ���� �������
auto state Waiting
{
BEGIN:
}

// ���� ������ � ��� ����������� ��������
state OpenAndWait
{
BEGIN:
	Sleep(5);
	GetNextFloor(currentDirection);
	if (currentDirection != 0)
		GoToState('Moving');
	else
		GoToState('Waiting');
}

// ���� � ��������
state Moving
{
	// ������� ���
	function MoveToFloor()
	{
		Room.MoveSmooth(vect(0.0, 0.0, 1.0) * currentDirection);
		//`log("������� � �����"@nextFloor);
	}

	// �������� �� ��
	function bool bCheckCome()
	{
		return Room.Location.z == Location.z + BlockHeight * nextFloor;
	}

BEGIN:
	GetNextFloor(currentDirection);
GO:
	MoveToFloor();
	Sleep(0.01);
	if (!bCheckCome())
	{
		//`log("���� ������");
		GoTo('BEGIN');
	}
	else
	{
		Buttons[nextFloor].SetState(0);
		currentFloor = nextFloor;
		GoToState('OpenAndWait');
	}
}

defaultproperties
{
	Height = 10
	BlockHeight = 250
	nextFloor = 0
	currentDirection = 0
	currentFloor = 0
}