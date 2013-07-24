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

var LiftPanel Panel;

// ������� ����������� �������� (-1, 0 ��� 1), �������� ������ �� ���������� ������� �����
var int currentDirection;

// �������� ������ �� ���������� ������� �����
var int currentFloor;

// ��������� �������� ������ �����
const LiftbuttonOffset = vect(70, 140, 80);

// ��������� �������� ������ �����
const LiftPanelOffset = vect(-70, 119, 80);
const LiftPanelRotation = rot(0, 11764080, 0);

// ����� �� ������ �����
var array<LiftDoor> Doors;

// ������ ������ ����� �� ������ �����
var array<LiftButton> Buttons;

// ��������� �� �� � ��������
var bool bMoving;

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

	localLocation = Location;
	localLocation.z += i * BlockHeight;
	localLocation += vector(rotator(LiftPanelOffset) + Rotation) * VSize(LiftPanelOffset);
	Panel = Spawn(class'City.LiftPanel', MyPawn,, localLocation, Rotation+LiftPanelRotation);
	Panel.ControlPanelAddFloor = ControlPanelAddFloor;
	Panel.InitPanel(Height);

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
	StartMoving();
}

// ������ ���� ��� ������� �� ������ �����
function ControlPanelAddFloor(int newFloor)
{
	Buttons[newFloor].SetState(1);
	StartMoving();
}

// �������� ����, ���� ����������
function StartMoving()
{
	if (IsInState('Waiting'))
		GoToState('Moving');
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
	local LiftDoor localDoor;
	local LiftButton localButton;

	// ������� ��� �����
	foreach Doors(localDoor)
		localDoor.Destroy();

	// ������� ������ Doors
	Doors.Remove(0, Doors.Length);

	// ������� ��� ������ ������ �����
	foreach Buttons(localButton)
		localButton.Destroy();

	// ������� ������ Buttons
	Buttons.Remove(0, Buttons.Length);

	// ������� ������ ����������
	Panel.Destroy();
	
	// ������� ������ �����
	Room.Destroy();

	// ��������� ������� ����
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
	Doors[currentFloor].OpenDoor();
	Sleep(5);
	Doors[currentFloor].CloseDoor();
	GetNextFloor(currentDirection);
	if (currentDirection != 0)
		GoToState('Moving');
	else
		GoToState('Waiting');
}

// ���� � ��������
state Moving
{
	simulated event Tick(float deltatime)
	{
		if (bMoving)
		{
			Room.MoveSmooth(vect(0.0, 0.0, 100.0) * currentDirection * deltatime);
			Panel.MoveSmooth(vect(0.0, 0.0, 100.0) * currentDirection * deltatime);
			if (bCheckCome())
			{
				// ��������
				bMoving = false;
				Room.MoveSmooth(vect(0.0, 0.0, 1.0) * ((Location.z + BlockHeight * nextFloor) - Room.Location.z));
				Panel.SetLocation(Room.Location + vector(rotator(LiftPanelOffset) + Rotation) * VSize(LiftPanelOffset));
				Buttons[nextFloor].SetState(0);
				currentFloor = nextFloor;
				GoToState('OpenAndWait');
			}
		}
	}

	// �������� �� ��
	function bool bCheckCome()
	{
		if (currentDirection == 1)
			return Room.Location.z >= Location.z + BlockHeight * nextFloor;
		else
			return Room.Location.z <= Location.z + BlockHeight * nextFloor;
	}

BEGIN:
	GetNextFloor(currentDirection);
GO:
	bMoving = true;
}

defaultproperties
{
	Height = 10
	BlockHeight = 250
	nextFloor = 0
	currentDirection = 0
	currentFloor = 0
}