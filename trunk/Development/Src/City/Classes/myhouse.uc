/*
 FrozenHell Skyline, 2012
*/
class MyHouse extends Actor
	DLLBind(house);

struct Cell
{
	// стены и части строения привязанные к этому узлу
	var Actor North, East, West, South, Pol, Roof, Grain;
	// видим или нет этот блок
	var bool bVisible;
	// крайние узлы путей, привязанные к этой ячейке (нужны только на момент создания здания)
	var NavNode NodeNorth, NodeEast, NodeWest, NodeSouth, NodeTop, NodeBottom, NodeCenter;

	structdefaultproperties
	{
		bVisible = false;
	}
};

// пол какого-либо этажа
struct Floor
{
	var vector Pos;
	var vector Scale;
};

struct NaviStruct
{
	var array<int> NaviData;
};

var int UtoR, Utor2, UtoR3;

var float ASin, ACos;
// дистанция ближнего вида и дистанция дальнего вида
var int DistNear, DistFar;
// текуший этаж
var int CurrentFloor;
var NaviStruct MyData, MyData2;
// положение игрока
var vector ViewLocation;
// поворот игрока
var rotator ViewRotation;
var Actor MyPawn;
var int Length, Width, Height, LenW, WidW, HeiW;
// расстояние от игрока до дома
var int Distance;
// угол поворота здания
var rotator Angle;
// вспомогательная переменная для определения точных координат ячеек
var vector HouseCenter;
// тип здания (0 - обычное, 1 - часть трёхлучевого)
var int BuildingType;

// сдвиг информации о стенах в данных
var int WallsOffset;

// элементы пола
var array<actor> Floors;
// информация об элементах пола
var array<Floor> FloorsInfo;
// количество элементов пола
var int FloorsCount;

// количество лестниц в здании
var int StairsCount;
// лифты
var array<LiftController> Lifts;

// грани здания
var TestGrain SWGrain, SEGrain, NWGrain, NEGrain;
var TestRoofGrain TWGrain, TEGrain, TSgrain, TNGrain;

// пока false - информация о доме не загружена в память а существует только LOD
var bool bInitialized;

// семя здания для ГПСЧ
var int HouseSeed;

/*
 * Visiblity
 * 00000000 - здание полностью скрыто(или вместо него подгружен дальний LOD)
 * 00000001 - здание полностью загружено в память
 * 00000010 - загружена западная часть
 * 00000100 - загружена восточная часть
 * 00001000 - загружена северная часть
 * 00010000 - загружена южная часть
 * 00100000 - загружена крыша здания
 * 01000000 - загружены несколько этажей (-2,-1,текущий,+1,+2)
*/
var int Visiblity; // переменная показывает видимость

// низкий уровень детализации
var LODHouse LOD;

// сдвиг LOD'а
const LOD_SHIFT = vect(0.0, 0.0, -25.0);

// массив ячеек здания
var array<Cell> Cells;

// массив навигационых узлов в виде списка
var array<NavNode> NavList;

dllimport final function GetNavData(out NaviStruct NavData, int type, int len, int wid, int hei, int stairscoll, int seed);
dllimport final function GetNavData2(out NaviStruct NavData,out NaviStruct NavData2, int len, int wid, int hei, int xpos, int ypos, int zpos);

// делегат для одноимённой функции из плеерконтроллера
delegate GetPlayerViewPoint(out vector out_Location, out Rotator out_rotation);

// -------------------------------стейты--------------------------------
auto state Created
{
	function CheckView() {
		if (!IsNearPawn())
			DrawHouse();
		else
			DrawHouse(true);
	}

Begin:
	GetPlayerViewPoint(ViewLocation, ViewRotation);
	distance = VSize(ViewLocation - Location);
	Sleep(5 + distance * 0.0001);
	CheckView();
	Goto ('Begin');
}
// ----------------------------конец стейтов-----------------------------

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	UtoR = 90 * DegToRad * RadToUnrRot;
	UtoR2 = 180 * DegToRad * RadToUnrRot;
	UtoR3 = 270 * DegToRad * RadToUnrRot;
}

event Destroyed()
{
	// очищаем навигационную сеть
	ClearNavNet();
	// очищаем ячейки здания
	Clear();

	// удаляем лифты
	RemoveLifts();

	super.Destroyed();
}

// функция удаляет все ячейки дома
function Clear()
{
	local int i;
	if (Visiblity != 0)
	{
		for (i = 0; i < length * Width * Height; i++)
		{
			if (Cells[i].bVisible)
			{
				Cells[i].North.destroy();
				Cells[i].East.destroy();
				Cells[i].South.destroy();
				Cells[i].West.destroy();
				Cells[i].Pol.destroy();
				if (Cells[i].Roof != None) Cells[i].Roof.destroy();
				if (Cells[i].Grain != None) Cells[i].Grain.destroy();
				// указать что ячейка скрыта
				Cells[i].bVisible = false;
			}
		}
		Visiblity = 0;
	}
	// очистка массива Cells
	Cells.Remove(0, Cells.Length);
}

// возвращает 1 или 0 (бит числа "а" в позиции "b")
private function int getBit(int a, int b)
{
	return((a >> b) % 2);
}

// возвращает true или false (бит числа "а" в позиции "b")
private function bool isBit(int a, int b)
{
	return((a >> b) % 2 == 1);
}

// возвращает число от 0 до 3 (два бита из числа a в позиции b*2)
private function int get2bit(int a, int b)
{
	return((a >> (b << 1)) & 3);
}

/*
 *	static function rotator UnrRot(float pitch, float yaw, float roll)
 *	{
 *		local rotator rota;
 *		local float degToRot;
 *		degToRot = DegToRad * RadToUnrRot;
 *		Rota.Pitch = pitch * degToRot;
 *		Rota.Yaw = yaw * degToRot;
 *		Rota.Roll = roll * degToRot;
 *		return Rota;
 *	}
*/

private function rotator QwatRot(float qYaw) // очень часто выполняемая функция
{
	local rotator rota;
	rota.Yaw = angle.Yaw + (qYaw == 0 ? 0 : qYaw == 1 ? UtoR : qYaw == 2 ? Utor2 : Utor3); // то же что qYaw * 90 * DegToRad * RadToUnrRot;
	return rota;
}

// рисование ячейки
private function cell DrawCell(int celll, const out vector posit, int wzPos, int wxPos, int wyPos, bool st)
{
	local cell yachejka;
	if (wxPos == 1)
	{
		yachejka.South = drawHOutPart(get2bit(celll, 3), 3, posit);
	}
	else
	{
		if (wxPos == 2)
		{
			yachejka.North = drawHOutPart(get2bit(celll, 1), 1, posit);
		}
		yachejka.South = drawHPart(get2bit(celll, 3), 3, posit);
	}
	
	if (wyPos == 1)
	{
		yachejka.East = drawHOutPart(get2bit(celll, 2), 0, posit);
	}
	else
	{
		if (wyPos == 2)
		{
			yachejka.West = drawHOutPart(get2bit(celll, 0), 2, posit);
		}
		yachejka.East = drawHPart(get2bit(celll, 2), 0, posit);
	}

	// если тут лестница
	if (st)
	{
		if (wzPos == 1) // если это первый этаж
		{
			yachejka.Pol = Spawn(class'City.teststairfloor', MyPawn,, posit, angle);
		}
		else // любой кроме первого
		{
			yachejka.Pol = Spawn(class'City.teststair', MyPawn,, posit, angle);
		}

		if (wzPos == 2) // последний этаж
		{
			yachejka.Roof = Spawn(class'City.testroofstair', MyPawn,, posit, angle);
		}
	}

	yachejka.bVisible = true;
	return yachejka;
}

// инициализация здания и выделение памяти (координаты положения актёра - угол здания)
function Gen(Pawn locPawn, int locType, int len, int wid, int hei, int seed)
{
	Length = len;
	Width = wid;
	Height = hei;
	BuildingType = locType;
	HouseSeed = seed;
	MyPawn = locPawn;
	HouseCenter.X = 0; // совсем не центр, скорее реальная точка приложения дома
	HouseCenter.Y = 0;
	Angle.Yaw = Rotation.Yaw;
	ASin = Sin(Rotation.Yaw / RadToUnrRot);
	ACos = Cos(Rotation.Yaw / RadToUnrRot);
	DrawHouse();
}

// инициализация здания и выделение памяти (координаты положения актёра - центр здания)
function gen2(Pawn locPawn, int locType, int len, int wid, int hei, int seed)
{
	Length = len;
	Width = wid;
	Height = hei;
	BuildingType = locType;
	HouseSeed = seed;
	MyPawn = locPawn;
	HouseCenter.x = ((Length - 1) * LenW / 2); // совсем не центр, скорее реальная точка приложения дома
	HouseCenter.y = ((Width - 1) * WidW / 2);
	Angle.Yaw = Rotation.Yaw;
	ASin = Sin(Rotation.Yaw / RadToUnrRot);
	ACos = Cos(Rotation.Yaw / RadToUnrRot);
	DrawHouse();
}

public function SetStairsCount(int stairs)
{
	// если здание ещё не сгенерировано
	if (!bInitialized)
	{
		// меняем количество лестниц
		StairsCount = stairs;
	}
}

// прорисовка дома
private function DrawHouse(optional bool full = false)
{
	local int i, j, k, wxPos, wyPos, wzPos, celll;
	local vector pos; // позиция ячейки
	local vector nav; // вспомогательная переменная для определения положения игрока в относительных координатах здания

	// узнаём позицию и поворот игрока
	GetPlayerViewPoint(ViewLocation, ViewRotation);

	// поворачиваем вектор
	nav.x = (ViewLocation.x - Location.x) * ACos + (ViewLocation.y - Location.y) * ASin;
	nav.y = (Location.x - ViewLocation.x) * ASin + (ViewLocation.y - Location.y) * aCos;
	nav.z = ViewLocation.z - Location.z;

	if (SetVisibility(nav)) // если что-то изменилось
	{
		GetVisibleMass();

		if (bInitialized)
		{
			for (k = 0; k < Height; k++)
			{
				for (j = 0; j < Width; j++)
				{
					for (i = 0; i < Length; i++)
					{
						celll = i + j * Length + k * Length * Width;
						// если ячейка должна быть видима, а она скрыта
						if ((full || (MyData2.NaviData[celll] == 2)) && !Cells[celll].bVisible)
						{
							pos.x = Location.x + (LenW * i - HouseCenter.x) * aCos - (WidW * j - HouseCenter.y) * ASin;
							pos.y = Location.y + (LenW * i - HouseCenter.x) * ASin + (WidW * j - HouseCenter.y) * aCos;
							pos.z = Location.z + HeiW * k;
							wxPos = i == 0 ? 1 : i == Length - 1 ? 2 : 0; // ячейка находится с краю, внутри или с другого краю?
							wyPos = j == 0 ? 1 : j == Width - 1 ? 2 : 0; // для другой оси
							wzPos = k == 0 ? 1 : k == Height - 1 ? 2 : 0; // для последней оси
							// создаём её
							Cells[celll] = DrawCell(MyData.NaviData[WallsOffset + celll], pos, wzPos, wxPos, wyPos, IsStairHere(i, j, k));
						}
						else if (!(full || (MyData2.NaviData[celll] == 2)) && Cells[celll].bVisible) // иначе, если ячейка должна быть скрыта, а она видима
						{
							// очищаем содержимое ячейки
							if (Cells[celll].North != None) Cells[celll].North.destroy();
							if (Cells[celll].East != None) Cells[celll].East.destroy();
							if (Cells[celll].South != None) Cells[celll].South.destroy();
							if (Cells[celll].West != None) Cells[celll].West.destroy();
							if (Cells[celll].Pol != None) Cells[celll].Pol.destroy();
							if (Cells[celll].Roof != None) Cells[celll].Roof.destroy();
							if (Cells[celll].Grain != None) Cells[celll].Grain.destroy();
							// говорим, что ячейка скрыта
							Cells[celll].bVisible = false;
						}
					}
				}
			}
		}

		if (Visiblity != 0)
		{
			if (Lifts.Length == 0)
				AddLifts();

			if (NavList.Length == 0)
				GenNavNet();

			if (Floors.Length == 0)
				AddFloors();

			if (TWGrain == None)
				AddGrains();
		}
		else if (bInitialized)
		{
			if (Lifts.Length != 0)
				RemoveLifts();

			if (NavList.Length != 0)
				ClearNavNet();

			if (Floors.Length != 0)
				RemoveFloors();

			if (TWGrain != None)
				RemoveGrains();
		}
	}
}

// проверяем, надо ли инициализировать здание
function CheckInitialize()
{
	// инициализируем, если ещё не инициализировано и игрок рядом
	if (!bInitialized && Visiblity != 0)
		Initialize();
}

// добавить полы на все этажи
function AddFloors()
{
	local int i, k;
	local vector pos;
	local testfloor localFloor;
	local testroof localRoof;

	// для каждого куска пола
	for (i = 0; i < FloorsCount; i++)
	{
		// получаем координаты
		pos = FloorsInfo[i].Pos;
		// рисуем для каждого этажа
		for (k = 0; k < Height; k++)
		{
			pos.z = Location.z + HeiW * k;
			localFloor = Spawn(class'City.testfloor', MyPawn,, pos, angle);
			localFloor.SetScale(FloorsInfo[i].Scale);
			Floors.AddItem(localFloor);
		}
		
		// рисуем для крыши
		pos.z = Location.z + HeiW * (Height - 1);
		localRoof = Spawn(class'City.testroof', MyPawn,, pos, angle);
		localRoof.SetScale(FloorsInfo[i].Scale);
		Floors.AddItem(localRoof);
	}
}

// удалить все полы
function RemoveFloors()
{
	local int i;

	for (i = 0; i < FloorsCount; i++)
		Floors[i].Destroy();
	Floors.Remove(0, Floors.Length);
}

// добавить все грани
function AddGrains()
{
	local vector localPos;
	local float height1;
	height1 = Location.Z + (Height - 1) * HeiW;

	localPos = Location;
	localPos.Y -= ((Length - 1) * LenW) / 2;
	localPos.Z = height1;
	TWGrain = Spawn(class'City.testroofgrain', MyPawn,, localPos, QwatRot(0));
	TWGrain.SetScale(Width);

	localPos = Location;
	localPos.X -= ((Width - 1) * WidW) / 2;
	localPos.Z = height1;
	TSgrain = Spawn(class'City.testroofgrain', MyPawn,, localPos, QwatRot(3));
	TSgrain.SetScale(Length);

	localPos = Location;
	localPos.Y += ((Length - 1) * LenW) / 2;
	localPos.Z = height1;
	TEGrain = Spawn(class'City.testroofgrain', MyPawn,, localPos, QwatRot(2));
	TEGrain.SetScale(Width);

	localPos = Location;
	localPos.X += ((Width - 1) * WidW) / 2;
	localPos.Z = height1;
	TNgrain = Spawn(class'City.testroofgrain', MyPawn,, localPos, QwatRot(1));
	TNgrain.SetScale(Length);

	localPos = Location + LOD_SHIFT;
	localPos.Y -= ((Length - 1) * LenW) / 2;
	localPos.X += ((Width - 1) * WidW) / 2;
	SEGrain = Spawn(class'City.testgrain', MyPawn,, localPos, QwatRot(0));
	SEGrain.SetScale(Height);

	localPos = Location + LOD_SHIFT;
	localPos.Y += ((Length - 1) * LenW) / 2;
	localPos.X += ((Width - 1) * WidW) / 2;
	NEGrain = Spawn(class'City.testgrain', MyPawn,, localPos, QwatRot(1));
	NEGrain.SetScale(Height);

	localPos = Location + LOD_SHIFT;
	localPos.Y += ((Length - 1) * LenW) / 2;
	localPos.X -= ((Width - 1) * WidW) / 2;
	NWGrain = Spawn(class'City.testgrain', MyPawn,, localPos, QwatRot(2));
	NWGrain.SetScale(Height);

	localPos = Location + LOD_SHIFT;
	localPos.Y -= ((Length - 1) * LenW) / 2;
	localPos.X -= ((Width - 1) * WidW) / 2;
	SWGrain = Spawn(class'City.testgrain', MyPawn,, localPos, QwatRot(3));
	SWGrain.SetScale(Height);
}

// удалить все грани
function RemoveGrains()
{
	TWGrain.Destroy();
	TSgrain.Destroy();
	TEGrain.Destroy();
	TNGrain.Destroy();
	SWGrain.Destroy();
	SEGrain.Destroy();
	NWGrain.Destroy();
	NEGrain.Destroy();
}

// выделение памяти под здание
private function Initialize()
{
	local int i, offset;
	local int pos1X, pos1Y, pos2X, pos2Y;
	local float posX, posY;
	local cell celll;
	local Floor locFloor;

	// забираем информацию о здании
	GetNavData(MyData, BuildingType, Length, Width, Height, StairsCount, HouseSeed);

	// пересчитываем и сохраняем координаты кусков пола
	offset = StairsCount * 2 + 1;
	for (i = 0; i < MyData.NaviData[offset - 1]; i++)
	{
		pos1X = MyData.NaviData[offset + i * 4];
		pos1Y = MyData.NaviData[offset + i * 4 + 1];
		pos2X = MyData.NaviData[offset + i * 4 + 2];
		pos2Y = MyData.NaviData[offset + i * 4 + 3];

		locFloor.Scale.X = pos2X - pos1X;
		locFloor.Scale.Y = pos2Y - pos1Y;
		locFloor.Scale.Z = 1.0;

		posX = (pos2X + pos1X - 1) / 2.0;
		posY = (pos2Y + pos1Y - 1) / 2.0;
		locFloor.Pos = Location;
		locFloor.Pos.x += (LenW * posX - HouseCenter.x) * aCos - (WidW * posY - HouseCenter.y) * ASin;
		locFloor.Pos.y += (LenW * posX - HouseCenter.x) * ASin + (WidW * posY - HouseCenter.y) * aCos;

		FloorsInfo[i] = locFloor;
	}

	FloorsCount = MyData.NaviData[offset - 1];
	WallsOffset = offset + FloorsCount * 4;

	// выделяем память под ячейки здания
	for (i = 0; i < Length * Width * Height; i++)
		Cells[i] = celll;

	bInitialized = true;
}

// есть ли лестница в этих координатах
function bool IsStairHere(int xPos, int yPos, int zPos)
{
	local int i;
	local bool stairHere;
	stairHere = false;
	// для всех лестниц
	for (i = 0; i < StairsCount; i++)
	{
		// если это координаты лестницы
		if (MyData.NaviData[i * 2] == xPos
			&&
			MyData.NaviData[i * 2 + 1] == yPos)
		{ // возвращаем истину
			stairHere = true;
		}
	}

	return stairHere;
}

// рисовать стену ячейки
private function actor drawHPart(int partType, int ang, const out vector posit) // передавать вектор "по ссылке", а не "по значению", const говорит о том, что вектор не будет меняться в этой функции
{
	local actor mypExem;
	switch (partType)
	{
		case 1:
			mypExem = Spawn(class'City.testwall', MyPawn,, posit, qwatrot(ang));
			break;
		case 2:
			mypExem = Spawn(class'City.testdoor', MyPawn,, posit, qwatrot(ang));
			break;
		case 3:
			mypExem = Spawn(class'City.testspace', MyPawn,, posit, qwatrot(ang));
			break;
		default:
			`warn("Попытка создать несуществующий элемент здания");
			break;
	}
	return mypExem;
}

// рисовать стену ячейки, которая выходит наружу здания
private function actor drawHOutPart(int partType, int ang, const out vector posit) // передавать вектор "по ссылке", а не "по значению", const говорит о том, что вектор не будет меняться в этой функции
{
	local actor mypExem;
	switch (partType)
	{
		case 0:
			mypExem = Spawn(class'City.testwindow', MyPawn,, posit, qwatrot(ang));
			break;
		case 1:
			mypExem = Spawn(class'City.testwallex', MyPawn,, posit, qwatrot(ang));
			break;
		case 2:
			mypExem = Spawn(class'City.testdoorex', MyPawn,, posit, qwatrot(ang));
			break;
		case 3:
			mypExem = Spawn(class'City.testspaceex', MyPawn,, posit, qwatrot(ang));
			break;
		default:
			`warn("Попытка создать несуществующий элемент здания");
			break;
	}
	return mypExem;
}

// функция меняет переменную Visiblity и возвращает -1 если изменений нет, иначе текущий этаж (0 - если этаж не важен)
private function bool SetVisibility(vector nav)
{
	// переменная - локальный аналог Visiblity
	local int vis;
	// этаж
	local int currFloor;
	local bool changed;
	// ставим переменной vis стандартное значение
	// ноль останется, если дом находится очень далеко, что скажет о том, что дом надо скрыть или подгрузить LOD
	vis = 0;
	currFloor = 0;
	// если дом не далеко
	if (Vsize(nav) < DistFar)
	{
		// если мы с запада здания
		if (nav.x < -0.5 * Length * LenW)
			vis += 2; // +00000010
		// если мы с востока здания
		if (nav.x > 0.5 * Length * LenW)
			vis += 4; // +00000100
		// если мы с севера здания
		if (nav.y > 0.5 * Width * WidW)
			vis += 8; // +00001000
		// если мы с юга здания
		if (nav.y < -0.5 * Width * WidW)
			vis += 16; // +00010000
		// если дом очень близко
		if (nav.z > Height * HeiW)
		{
			if (vis == 0)
			{
				vis = 62; // все стены
			}
			else
			{
				vis += 32;
			}
		}

		// если дом очень близко
		if (Vsize(nav) < DistNear)
		{
			// определяем текущий этаж
			currFloor = (nav.z + 30) / HeiW;
			vis += 64;
		}
	}

	// если нет изменений - возвращаем -1
	if (vis == Visiblity && (!isBit(vis, 6) || currFloor == Currentfloor))
	{
		changed = false;
	}
	else
	{
		changed = true;
		Currentfloor = currFloor;
		Visiblity = vis;
	}
	return changed;
}

// прописывает массив видимости в зависимости от Visiblity
function GetVisibleMass()
{
	local int i, j, k;

	if (Visiblity != 0)
	{
		CheckInitialize();

		for (k = 0; k < Height; k++)
		{
			for (j = 0; j < Width; j++)
			{
				for (i = 0; i < Length; i++)
				{
					if ((isBit(Visiblity, 1) && (i == 0))||(isBit(Visiblity, 2) && (i == Length - 1)) || (isBit(Visiblity, 3) && (j == Width - 1)) || (isBit(Visiblity, 4) && (j == 0)) || (isBit(Visiblity, 5) && (k == Height - 1)) || (isBit(Visiblity, 6) && (abs(k - Currentfloor) < 3)))
						MyData2.NaviData[i + j*Length + k*Length*Width] = 2;
					else
						MyData2.NaviData[i + j*Length + k*Length*Width] = 0;
				}
			}
		}

		if (LOD != none)
		{
			LOD.Destroy();
		}
	}
	else
	{
		for (i = 0; i < Length * Width * Height; i++)
		{
			MyData2.NaviData[i] = 0;
		}

		if (LOD == none)
		{
			LOD = Spawn(class'City.LODHouse', MyPawn,, Location + LOD_SHIFT, Rotation);
			LOD.SetScale(Length, Width, Height);
		}
		else
		{
			`warn("ошибка: LOD не должен существовать в данный момент");
		}
	}
}

// найти ближайшего Pawn который находится рядом со зданием
function Pawn FindNearlyPawn()
{
	local Pawn locPawn, nearlyPawn;
	local float locDist;
	locDist = 100000;
	foreach AllActors(class'Pawn', locPawn)
	{
		if (Vsize(FindNearlyPawn().Location - Location) < locDist)
		{
			nearlyPawn = locPawn;
			locDist = Vsize(FindNearlyPawn().Location - Location);
		}
	}
	return nearlyPawn;
}

// рядом со зданием есть Pawn
function bool IsNearPawn()
{
	local Pawn locPawn, nearlyPawn;
	local float locDist;
	locDist = 100000;
	foreach AllActors(class'Pawn', locPawn)
	{
		if (Vsize(locPawn.Location - Location) < locDist)
		{
			nearlyPawn = locPawn;
			locDist = Vsize(locPawn.Location - Location);
		}
	}
	if (nearlyPawn != None)
		return Vsize(nearlyPawn.Location - Location) < DistNear;
	else
		return false;
}

// добавить все лифты
function AddLifts()
{
	local int i;
	local vector liftLocation;

	for (i = 0; i < StairsCount; i++)
	{
		liftLocation = Location;
		liftLocation.x += (LenW * MyData.NaviData[i * 2] - HouseCenter.x) * aCos - (WidW * MyData.NaviData[i * 2 + 1] - HouseCenter.y) * ASin;
		liftLocation.y += (LenW * MyData.NaviData[i * 2] - HouseCenter.x) * ASin + (WidW * MyData.NaviData[i * 2 + 1] - HouseCenter.y) * aCos;
		Lifts[i] = Spawn(class'City.LiftController', MyPawn,, liftLocation, qwatrot(0));
		Lifts[i].Create(MyPawn, Height, HeiW);
	}
}

// удалить лифты
function RemoveLifts()
{
	local LiftController localLift;

	foreach Lifts(localLift)
		localLift.Destroy();
}


/*
 * Так как навигационные маршруты тесно связаны с ячейками здания, то стоило бы
 * связать генерацию навигационных узлов с генерацией каждой ячейки. Но тогда
 * пути навигации приходилось бы удалять и создавать заново вместе с ячейками здания
 * при выгрузке и загрузке в память последних.
*/


// создать сеть навигации для здания
function GenNavNet()
{
	local int i, j, k, localCell, addr;
	local vector pos;
	local NavNode localNode1, localNode2;
	// проходим всё здание по циклу
	for (k = 0; k < Height; k++)
		for (j = 0; j < Width; j++)
			for (i = 0; i < Length; i++)
			{
				addr = i + j * Length + k * Length * Width;

				// вычисляем реальные координаты центра ячейки
				pos.x = Location.x + (LenW * i - HouseCenter.x) * aCos - (WidW * j - HouseCenter.y) * aSin;
				pos.y = Location.y + (LenW * i - HouseCenter.x) * aSin + (WidW * j - HouseCenter.y) * aCos;
				pos.z = Location.z + HeiW * k + 70; // 70 - высота над полом

				// находим информацию о ячейке
				localCell = MyData.NaviData[WallsOffset + addr];

				// если это лестница
				if (IsStairHere(i, j, k))
				{
					// создаём нижний узел и заносим его в список
					Cells[addr].NodeBottom = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, WidW * 0.35), rot(0, 0, 0));
					NavList.AddItem(Cells[addr].NodeBottom);

					// создаём восточный узел и заносим его в список
					Cells[addr].NodeEast = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos,, WidW * 0.4), rot(0, 0, 0));
					NavList.AddItem(Cells[addr].NodeEast);

					// связываем восточный и нижний узлы
					BindNodes(Cells[addr].NodeEast, Cells[addr].NodeBottom);

					// создаём первый промежуточный узел и заносим его в список
					localNode1 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, LenW * 0.35, WidW * 0.35), rot(0, 0, 0));
					NavList.AddItem(localNode1);

					// связываем первый промежуточный и восточный узлы
					BindNodes(localNode1, Cells[addr].NodeEast);

					// связываем первый промежуточный и нижный узлы
					BindNodes(localNode1, Cells[addr].NodeBottom);

					// создаём второй промежуточный узел и заносим его в список
					localNode2 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, LenW * 0.35, -WidW * 0.35, HeiW * 0.55), rot(0, 0, 0));
					NavList.AddItem(localNode2);

					// связываем первый промежуточный и второй промежуточный узлы
					BindNodes(localNode1, localNode2);

					// если это не последний этаж
					if (k < Height - 1)
					{
						// создаём верхний узел и заносим его в список
						Cells[addr].NodeTop = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, -WidW * 0.35, HeiW * 0.55), rot(0, 0, 0));
						NavList.AddItem(Cells[addr].NodeTop);

						// связываем второй промежуточный и верхний узлы
						BindNodes(localNode2, Cells[addr].NodeTop);
					}
					else // если этаж последний
					{
						// создаём третий промежуточный узел (используя место в памяти первого) и заносим его в список
						localNode1 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, -WidW * 0.35, HeiW * 0.55), rot(0, 0, 0));
						NavList.AddItem(localNode1);

						// связываем второй промежуточный и третий промежуточный узлы
						BindNodes(localNode2, localNode1);

						// создаём четвёртый промежуточный узел (используя место в памяти второго) и заносим его в список
						localNode2 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, WidW * 0.35, HeiW), rot(0, 0, 0));
						NavList.AddItem(localNode1);

						// связываем третий промежуточный и четвёртый промежуточный узлы
						BindNodes(localNode1, localNode2);

						// создаём верхний узел и заносим его в список (высота узла завышена чтобы он казался самым высоким)
						Cells[addr].NodeTop = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, WidW, HeiW+10), rot(0, 0, 0));
						NavList.AddItem(Cells[addr].NodeTop);

						// связываем четвёртый промежуточный и верхний узлы
						BindNodes(localNode2, Cells[addr].NodeTop);
					}

					// если этаж не первый
					if (k > 0) // тогда связываем по вертикали (этот с нижним)
						BindNodes(Cells[addr].NodeBottom, Cells[addr - Length * Width].NodeTop);
				}
				else // если не лестница
				{
					// создаём пять узлов (ромб с центром)
					Cells[addr].NodeCenter = Spawn(class'Base.NavNode', MyPawn,, pos, rot(0, 0, 0));
					Cells[addr].NodeNorth = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, LenW * 0.4), rot(0, 0, 0));
					Cells[addr].NodeSouth = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.4), rot(0, 0, 0));
					Cells[addr].NodeWest = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos,, -WidW * 0.4), rot(0, 0, 0));
					Cells[addr].NodeEast = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos,, WidW * 0.4), rot(0, 0, 0));

					// заносим узлы в список, чтобы не потерять
					NavList.AddItem(Cells[addr].NodeCenter);
					NavList.AddItem(Cells[addr].NodeNorth);
					NavList.AddItem(Cells[addr].NodeSouth);
					NavList.AddItem(Cells[addr].NodeWest);
					NavList.AddItem(Cells[addr].NodeEast);

					// связываем все узлы между собой
					BindNodes(Cells[addr].NodeCenter, Cells[addr].NodeNorth);
					BindNodes(Cells[addr].NodeCenter, Cells[addr].NodeSouth);
					BindNodes(Cells[addr].NodeCenter, Cells[addr].NodeWest);
					BindNodes(Cells[addr].NodeCenter, Cells[addr].NodeEast);
					BindNodes(Cells[addr].NodeWest, Cells[addr].NodeNorth);
					BindNodes(Cells[addr].NodeEast, Cells[addr].NodeNorth);
					BindNodes(Cells[addr].NodeWest, Cells[addr].NodeSouth);
					BindNodes(Cells[addr].NodeEast, Cells[addr].NodeSouth);
				}


				// добавляем необходимые связи с узлами соседних ячеек (только если есть двери или проходы)
				if (i != 0 && get2Bit(localCell, 3) > 1)
				{
					BindNodes(Cells[addr].NodeSouth, Cells[addr - 1].NodeNorth);
				}
				if (j != 0 && get2Bit(localCell, 2) > 1)
				{
					BindNodes(Cells[addr].NodeWest, Cells[addr - Length].NodeEast);
				}
			}
}

// связать два узла двусторонней связью
static function BindNodes(NavNode A, NavNode B)
{
	A.AddRelation(B);
	B.AddRelation(A);
}

// очистить навигационную сеть
function ClearNavNet()
{
	local NavNode localNode;
	// удаляем все узлы здания
	foreach NavList(localNode)
		localNode.Destroy();
	// очищаем массив NavList
	NavList.Remove(0, NavList.Length);
}

/*
 * Вычисляем абсолютные координаты точки по относительному сдвигу
 * параметры:
 * localCenter - точка относительно которой предпологается сделать сдвиг
 * xShift, yShift, zShift - сдвиги в относительной (не повёрнутой) плоскости
*/
function vector LocShift(vector localCenter, optional float xShift = 0.0, optional float yShift = 0.0, optional float zShift = 0.0)
{
	local vector shifted;

	shifted.x = localCenter.x + xShift * aCos - yShift * aSin;
	shifted.y = localCenter.y + xShift * aSin + yShift * aCos;
	shifted.z = localCenter.z + zShift;

	return shifted;
}

defaultproperties
{
	Length = 10
	Width = 10
	Height = 10
	LenW = 600
	WidW = 600
	HeiW = 250
	DistNear = 5000
	DistFar = 20000
	BuildingType = 0
	Visiblity = 1
	StairsCount = 2
	WallsOffset = 0;
	FloorsCount = 0;

	bInitialized = false
}