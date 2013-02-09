/*
 FrozenHell Skyline, 2012
*/
class MyHouse extends Actor
	DLLBind(house);

struct Cell
{
	// стены и части строения привязанные к этому узлу
	var Actor North, East, West, South, Lex, Wex, Pol, Roof, Grain;
	// видим или нет этот блок
	var bool bVisible;
	// крайние узлы путей, привязанные к этой ячейке (нужны только на момент создания здания)
	var NavNode NodeNorth, NodeEast, NodeWest, NodeSouth, NodeTop, NodeBottom, NodeCenter;

	structdefaultproperties
	{
		bVisible = false;
	}
};

var int UtoR, Utor2, UtoR3;

var float ASin, ACos;
// дистанция ближнего вида и дистанция дальнего вида
var int Dist1, DistFar;
// текуший этаж
var int CurrentFloor;
var MyNavigationStruct MyData, MyData2;
// положение игрока
var vector ViewLocation;
// поворот игрока
var rotator ViewRotation;
var Actor MyPawn;
var int Length, Width, Height, LenW, WidW, HeiW;
// расстояние от игрока до дома
var int Distance;
var rotator Angle;
// вспомогательная переменная для определения точных координат ячеек
var vector HouseCenter;

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

// массив ячеек здания
var array<Cell> Cells;

// массив навигационых узлов в виде списка
var array<NavNode> NavList;

dllimport final function GetNavData(out MyNavigationStruct NavData, int len, int wid, int hei, int seed);
dllimport final function GetNavData2(out MyNavigationStruct NavData,out MyNavigationStruct NavData2, int len, int wid, int hei, int xpos, int ypos, int zpos);

// делегат для одноимённой функции из плеерконтроллера
delegate GetPlayerViewPoint(out vector out_Location, out Rotator out_rotation);

// -------------------------------стейты--------------------------------
auto state Created
{
	function CheckView() {
		DrawHouse();
	}

Begin:
	GetPlayerViewPoint(ViewLocation, ViewRotation);
	distance = VSize(ViewLocation - Location);
	CheckView();
	Sleep(5 + distance * 0.0001);
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
	// тут должна вызываться функция очистки узлов
	Clear();
	super.Destroyed();
}

// функция удаляет все ячейки дома
function Clear()
{
	local int i;
	if (Visiblity != 0) {
		for (i = 0; i < length * Width * Height; i++)
		{
			if (Cells[i].bVisible)
			{
				Cells[i].North.destroy();
				Cells[i].East.destroy();
				Cells[i].South.destroy();
				Cells[i].West.destroy();
				Cells[i].Pol.destroy();
				// следующие элементы характерны не для всех ячеек
				if (Cells[i].Lex != None) Cells[i].Lex.destroy();
				if (Cells[i].Wex != None) Cells[i].Wex.destroy();
				if (Cells[i].Roof != None) Cells[i].Roof.destroy();
				if (Cells[i].Grain != None) Cells[i].Grain.destroy();
				// указать что ячейка скрыта
				Cells[i].bVisible = false;
			}
		}
		Visiblity = 0;
	}
}

// возвращает 1 или 0 (бит числа "а" в позиции "b")
private function int isbit(int a, int b)
{
	return((a >> b) % 2);
}

// возвращает true или false (бит числа "а" в позиции "b")
private function bool isBitB(int a, int b)
{
	return((a >> b) % 2 == 1);
}

// возвращает число от 0 до 4
private function int is2bit(int a, int b)
{
	return((a >> (b + b)) % 4);
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
	//Rota.Pitch = 0; // обнуления не нужны
	rota.Yaw = angle.Yaw +(qYaw == 0 ? 0 : qYaw == 1 ? UtoR : qYaw == 2 ? Utor2 : Utor3); // то же что qYaw * 90 * DegToRad * RadToUnrRot;
	//Rota.Roll = 0;
	return rota;
}

// рисование ячейки
private function cell DrawCell(int celll, const out vector posit, int wzPos, int wxPos, int wyPos, bool st)
{
	local cell yachejka;
	yachejka.North = drawHPart(Is2Bit(celll, 3), 3, posit);
	yachejka.East = drawHPart(Is2Bit(celll, 2), 0, posit);
	yachejka.South = drawHPart(Is2Bit(celll, 1), 1, posit);
	yachejka.West = drawHPart(Is2Bit(celll, 0), 2, posit);

	if (!st)
		yachejka.Pol = Spawn(class'City.testfloor', MyPawn,, posit, angle);
	else
		yachejka.Pol = Spawn(class'City.teststair', MyPawn,, posit, angle);

	if (wxPos == 1)
		yachejka.Lex = drawHOutPart(IsBit(celll, 7)*2+IsBit(celll, 6), 3, posit);
	else if (wxPos == 2)
		yachejka.Lex = drawHOutPart(IsBit(celll, 3) * 2 + IsBit(celll,2), 1, posit);

	if (wyPos == 1)
		yachejka.Wex = drawHOutPart(IsBit(celll, 5) * 2 + IsBit(celll, 4), 0, posit);
	else if
		(wyPos == 2) yachejka.Wex = drawHOutPart(IsBit(celll, 1) * 2 + IsBit(celll, 0), 2, posit);

	// пол первого этажа лестницы
	if ((wzPos == 1) && st)
		yachejka.Roof=Spawn(class'City.teststairfloor', MyPawn,, posit, angle);

	if (wzPos == 2) // если последний этаж
	{
		if (!st)
			yachejka.Roof = Spawn(class'City.testroof', MyPawn,, posit, angle);
		else
			yachejka.Roof = Spawn(class'City.testroofstair', MyPawn,, posit, angle);
		if (wxPos == 1)
		{
			if (wyPos == 1)
				yachejka.Grain = Spawn(class'City.testroofang', MyPawn,, posit, qwatrot(3)); // верхний левый угол
			else if (wyPos == 2)
				yachejka.Grain = Spawn(class'City.testroofang', MyPawn,, posit, qwatrot(2)); // нижний левый угол
			else
				yachejka.Grain = Spawn(class'City.testroofgrain', MyPawn,, posit, qwatrot(3)); // лево - середина
		}
		else if (wxPos == 2)
		{
			if (wyPos == 1)
				yachejka.Grain = Spawn(class'City.testroofang', MyPawn,, posit, qwatrot(0)); // верхний правый угол
			else if (wyPos == 2)
				yachejka.Grain = Spawn(class'City.testroofang', MyPawn,, posit, qwatrot(1)); // нижний правый угол
			else
				yachejka.Grain = Spawn(class'City.testroofgrain', MyPawn,, posit, qwatrot(1)); // право - середина
		}
		else if (wyPos == 1)
			yachejka.Grain = Spawn(class'City.testroofgrain', MyPawn,, posit, qwatrot(0)); // верх - середина
		else if
			(wyPos == 2) yachejka.Grain = Spawn(class'City.testroofgrain', MyPawn,, posit, qwatrot(2)); // низ - середина
	}
	else if (wxPos == 1)
	{ // если не последний этаж
		if (wyPos == 1)
			yachejka.Grain = Spawn(class'City.testgrain',MyPawn,, posit, qwatrot(3)); // верхний левый угол
		else if (wyPos == 2)
			yachejka.Grain = Spawn(class'City.testgrain', MyPawn,, posit, qwatrot(2)); // нижний левый угол
	}
	else if (wxPos == 2)
	{
		if (wyPos == 1)
			yachejka.Grain = Spawn(class'City.testgrain', MyPawn,, posit, qwatrot(0)); // верхний правый угол
		else if
			(wyPos == 2) yachejka.Grain = Spawn(class'City.testgrain', MyPawn,, posit, qwatrot(1)); // нижний правый угол
	}

	yachejka.bVisible = true;
	return yachejka;
}

// инициализация здания и выделение памяти (координаты положения актёра - угол здания)
function Gen(Pawn locPawn, optional int len = 10, optional int wid = 10, optional int hei = 10, optional int seed = 0)
{
	Length = len;
	Width = wid;
	Height = hei;
	GetNavData(MyData, Length, Width, Height, seed);
	MyPawn = locPawn;
	HouseCenter.X = 0; // совсем не центр, скорее реальная точка приложения дома
	HouseCenter.Y = 0;
	Angle.Yaw = Rotation.Yaw;
	ASin = Sin(Rotation.Yaw / RadToUnrRot);
	ACos = Cos(Rotation.Yaw / RadToUnrRot);
	Initialize();
	DrawHouse();
	GenNavNet();
}

// инициализация здания и выделение памяти (координаты положения актёра - центр здания)
function gen2(Pawn locPawn, optional int len = 10, optional int wid = 10, optional int hei = 10, optional int seed = 0)
{
	Length = len;
	Width = wid;
	Height = hei;
	GetNavData(MyData, Length, Width, Height, seed);
	MyPawn = locPawn;
	HouseCenter.x = ((Length - 1) * LenW / 2); // совсем не центр, скорее реальная точка приложения дома
	HouseCenter.y = ((Width - 1) * WidW / 2);
	Angle.Yaw = Rotation.Yaw;
	ASin = Sin(Rotation.Yaw / RadToUnrRot);
	ACos = Cos(Rotation.Yaw / RadToUnrRot);
	initialize();
	DrawHouse();
	GenNavNet();
}

// прорисовка дома
private function DrawHouse(optional bool full = false)
{
	local int i, j, k, wxPos, wyPos, wzPos, celll;
	local vector pos; // позиция ячейки
	local vector nav; // вспомогательная переменная для определения положения игрока в относительных координатах здания

	// узнаём позицию и поворот игрока
	GetPlayerViewPoint(ViewLocation, ViewRotation);

	nav.x = (ViewLocation.x - Location.x) * ACos + (ViewLocation.y - Location.y) * ASin;
	nav.y = (Location.x - ViewLocation.x) * ASin + (ViewLocation.y - Location.y) * aCos;
	nav.z = ViewLocation.z - Location.z;
	//GetNavData2(MyData, MyData2, Length, Width, Height, nav.x, nav.y, nav.z);
	if (SetVisibility(nav)) // если что-то изменилось
	{
		GetVisibleMass();

		for (k = 0; k < Height; k++)
			for (j = 0; j < Width; j++)
				for (i = 0; i < Length; i++)
				{
					celll = i + j * Length + k * Length * Width;
					// если ячейка должна быть видима, а она скрыта
					if ((full || (MyData2.NavigationData[celll] == 2)) && !Cells[celll].bVisible)
					{
						pos.x = Location.x + (LenW * i - HouseCenter.x) * aCos - (WidW * j - HouseCenter.y) * ASin;
						pos.y = Location.y + (LenW * i - HouseCenter.x) * ASin + (WidW * j - HouseCenter.y) * aCos;
						pos.z = Location.z + HeiW * k;
						wxPos = i == 0 ? 1 : i == Length - 1 ? 2 : 0; // ячейка находится с краю, внутри или с другого краю?
						wyPos = j == 0 ? 1 : j == Width - 1 ? 2 : 0; // для другой оси
						wzPos = k == 0 ? 1 : k == Height - 1 ? 2 : 0; // для последней оси
						// создаём её
						Cells[celll] = DrawCell(MyData.NavigationData[4 + celll], pos, wzPos, wxPos, wyPos, (i == MyData.NavigationData[0] && j == MyData.NavigationData[1]) || (i == MyData.NavigationData[2] && j == MyData.NavigationData[3]));
						// последний параметр в предыдущей строке определяет: находится ли в ячейке лестница
					}
					else if (!(full || (MyData2.NavigationData[celll] == 2)) && Cells[celll].bVisible) // иначе, если ячейка должна быть скрыта, а она видима
					{
						// очищаем содержимое ячейки
						Cells[celll].North.destroy();
						Cells[celll].East.destroy();
						Cells[celll].South.destroy();
						Cells[celll].West.destroy();
						Cells[celll].Pol.destroy();
						// следующие элементы характерны не для всех ячеек
						if (Cells[celll].Lex != None) Cells[celll].Lex.destroy();
						if (Cells[celll].Wex != None) Cells[celll].Wex.destroy();
						if (Cells[celll].Roof != None) Cells[celll].Roof.destroy();
						if (Cells[celll].Grain != None) Cells[celll].Grain.destroy();
						// говорим, что ячейка скрыта
						Cells[celll].bVisible = false;
					}
				}
	}
}

// выделение памяти под здание
function initialize()
{
	local int i;
	local cell celll; // тут происходит нечто неоптимальное, если смотреть со стороны выделения памяти
	// однако, иначе поступать не выходит
	for (i = 0; i < Length * Width * Height; i++)
		Cells[i] = celll;
}

private function actor drawHPart(int type, int ang, const out vector posit) // передавать вектор "по ссылке", а не "по значению", const говорит о том, что вектор не будет меняться в этой функции
{
	local actor mypExem;
	switch (type)
	{
		case 0:
			mypExem = Spawn(class'City.testwindow', MyPawn,, posit, qwatrot(ang));
			break;
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
			break;
	}
	return mypExem;
}

private function actor drawHOutPart(int type, int ang, const out vector posit) // передавать вектор "по ссылке", а не "по значению", const говорит о том, что вектор не будет меняться в этой функции
{
	local actor mypExem;
	switch (type)
	{
		case 0:
			mypExem = Spawn(class'City.testwindowex', MyPawn,, posit, qwatrot(ang));
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
			break;
	}
	return mypExem;
}

// функция меняет переменную Visiblity и возвращает -1 если изменений нет, иначе текущий этаж (0 - если этаж не важен)
function bool SetVisibility(vector nav)
{
	// переменная - локальный аналог Visiblity
	local int vis;
	// этаж
	local int floor;
	local bool changed;
	// ставим переменной vis стандартное значение
	// ноль останется, если дом находится очень далеко, что скажет о том, что дом надо скрыть или подгрузить LOD
	vis = 0;
	floor = 0;
	// если дом не далеко
	if (Vsize(nav) < DistFar)
	{
		// если мы с запада здания ТУТ НАДО УЧЕСТЬ ВОЗМОЖНОСТЬ ПОВОРОТА ЗДАНИЯ!!!
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
		if (Vsize(nav) < Dist1)
		{
			// определяем текущий этаж
			floor = (nav.z + 30) / HeiW;
			vis += 64;
		}
	}

	// если нет изменений - возвращаем -1
	if (vis == Visiblity && (!isBitB(vis, 6) || floor==Currentfloor))
	{
		changed = false;
	}
	else
	{
		changed = true;
		Currentfloor = floor;
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
		for (k = 0; k < Height; k++)
		{
			for (j = 0; j < Width; j++)
			{
				for (i = 0; i < Length; i++)
				{
					if ((isBitB(Visiblity, 1) && (i == 0))||(isBitB(Visiblity, 2) && (i == Length - 1)) || (isBitB(Visiblity, 3) && (j == Width - 1)) || (isBitB(Visiblity, 4) && (j == 0)) || (isBitB(Visiblity, 5) && (k == Height - 1)) || (isBitB(Visiblity, 6) && (abs(k - Currentfloor) < 3)))
						MyData2.NavigationData[i+j*Length+k*Length*Width] = 2;
					else
						MyData2.NavigationData[i+j*Length+k*Length*Width] = 0;
				}
			}
		}
	}
	else
	{
		for (i = 0; i < Length * Width * Height; i++)
		{
			MyData2.NavigationData[i] = 0;
		}
	}
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
				localCell = MyData.NavigationData[4 + addr];

				// если это лестница
				if (((i == MyData.NavigationData[0] && j == MyData.NavigationData[1]) || (i == MyData.NavigationData[2] && j == MyData.NavigationData[3])))
				{
					// создаём нижний узел и заносим его в список
					Cells[addr].NodeBottom = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -WidW * 0.35, LenW * 0.35), rot(0, 0, 0));
					NavList.AddItem(Cells[addr].NodeBottom);

					// создаём северный узел и заносим его в список
					Cells[addr].NodeNorth = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos,, LenW * 0.4), rot(0, 0, 0));
					NavList.AddItem(Cells[addr].NodeNorth);

					// создаём верхний узел и заносим его в список
					Cells[addr].NodeTop = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -WidW * 0.35, -LenW * 0.35, HeiW * 0.55), rot(0, 0, 0));
					NavList.AddItem(Cells[addr].NodeTop);

					// связываем северный и нижний узлы
					BindNodes(Cells[addr].NodeNorth, Cells[addr].NodeBottom);

					// создаём первый промежуточный узел и заносим его в список
					localNode1 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, WidW * 0.35, LenW * 0.35), rot(0, 0, 0));
					NavList.AddItem(localNode1);

					// связываем первый промежуточный и северный узлы
					BindNodes(localNode1, Cells[addr].NodeNorth);

					// связываем первый промежуточный и нижный узлы
					BindNodes(localNode1, Cells[addr].NodeBottom);

					// создаём второй промежуточный узел и заносим его в список
					localNode2 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, WidW * 0.35, -LenW * 0.35, HeiW * 0.55), rot(0, 0, 0));
					NavList.AddItem(localNode2);

					// связываем первый промежуточный и второй промежуточный узлы
					BindNodes(localNode1, localNode2);

					// связываем второй промежуточный и верхний узлы
					BindNodes(localNode2, Cells[addr].NodeTop);

					// если этаж не первый
					if (k > 0) // тогда связываем по вертикали
						BindNodes(Cells[addr].NodeBottom, Cells[addr - Length * Width].NodeTop);
				}
				else // если не лестница
				{
					// создаём пять узлов (ромб с центром)
					Cells[addr].NodeCenter = Spawn(class'Base.NavNode', MyPawn,, pos, rot(0, 0, 0));
					Cells[addr].NodeNorth = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos,, LenW * 0.4), rot(0, 0, 0));
					Cells[addr].NodeSouth = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos,, -LenW * 0.4), rot(0, 0, 0));
					Cells[addr].NodeWest = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, WidW * 0.4), rot(0, 0, 0));
					Cells[addr].NodeEast = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -WidW * 0.4), rot(0, 0, 0));

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
				if (Is2Bit(localCell, 2) > 1 && j != 0)
				{
					BindNodes(Cells[addr].NodeSouth, Cells[addr - Length].NodeNorth);
				}
				if (Is2Bit(localCell, 3) > 1 && i != 0)
				{
					BindNodes(Cells[addr].NodeEast, Cells[addr - 1].NodeWest);
				}
			}
}

// связать два узла двусторонней связью
static function BindNodes(NavNode A, NavNode B)
{
	A.AddRelation(B);
	B.AddRelation(A);
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
	Dist1 = 5000
	DistFar = 20000
}