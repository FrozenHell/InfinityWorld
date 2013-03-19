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

// этаж на который движется лифт
var int nextFloor;

// кабина лифта
var LiftRoom Room;

// текущее направление движения (-1, 0 или 1), меняется только по достижению нужного этажа
var int currentDirection;

// меняется только по достижению нужного этажа
var int currentFloor;

// локальное смещение кнопки лифта
const LiftbuttonOffset = vect(70, 140, 80);

// двери на каждом этаже
var array<LiftDoor> Doors;

// кнопки вызова лифта на каждом этаже
var array<LiftButton> Buttons;

//-----------------------

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
		Buttons[i].Floor = i;
		Buttons[i].CallLift = CallLift;
	}
}

// кто-то вызвал лифт
function CallLift(int newFloor)
{
	GoToState('Moving');
}

//Выбран этаж для поездки на панели лифта
function ControlPanelAddFloor(int newFloor)
{
	//Выбран этаж для поездки
}

// устанавливаем следующий этаж для путешествия direct - направление (0, если не важно)
function GetNextFloor(int direct)
{
	local int i, nextLow, nextHigh;

	nextHigh = -1;
	nextLow = -1;

	// ищем ближайший этаж выше
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

	// ищем ближайший этаж ниже
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
		// находим самый близкий вариант
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

// при уничтожении
event Destroyed()
{
	super.Destroyed();
}

//------------------------

// лифт ожидает
auto state Waiting
{
BEGIN:
}

// лифт открыт и ждёт продолжения действия
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

// лифт в движении
state Moving
{
	// сделать шаг
	function MoveToFloor()
	{
		Room.MoveSmooth(vect(0.0, 0.0, 1.0) * currentDirection);
		//`log("Движусь к этажу"@nextFloor);
	}

	// приехали ли мы
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
		//`log("едем дальше");
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