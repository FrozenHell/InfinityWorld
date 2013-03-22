/**
 *	TriangleHouse
 *
 *	Creation date: 08.02.2013 15:38
 *	Copyright 2013, FrozenHell Skyline
 */
class TriangleHouse extends Actor;

// прямоугольные блоки здания
var array<MyHouse> Blocks;

// треугольные части здания
var array<TestTriFloor> TriParts;
// треугольные части для крыши
var array<TestTriRoof> RoofParts;

// массив навигационых узлов в виде списка
var array<NavNode> NavList;

var Actor MyPawn;

var int GenSeed;

var int HouseType;

var float Length, Width, Height, LenW, WidW, HeiW;
var float WallWidth;

// вспомогательная переменная
var int SeedIterator;

// делегат для одноимённой функции из плеерконтроллера
delegate GetPlayerViewPoint(out vector out_Location, out Rotator out_rotation);

// --------- функции ---------

// возвращает число от 0 до 4 (два бита из числа a в позиции b*2)
private function int is2bit(int a, int b)
{
	return((a >> (b + b)) % 4);
}

event Destroyed()
{
	local MyHouse localBlock;
	local TestTriFloor localPart;
	local TestTriRoof localPart2;

	// уничтожаем все блоки
	foreach Blocks(localBlock)
		localBlock.Destroy();
	foreach TriParts(localPart)
		localPart.Destroy();
	foreach RoofParts(localPart2)
		localPart2.Destroy();

	super.Destroyed();
}

function Gen(Pawn locPawn, int len, int wid, int hei, int type, int size, int seed)
{
	MyPawn = locPawn;
	Length = len;
	Width = wid;
	Height = hei;
	WallWidth = 0.0;

	GenSeed = seed;
	HouseType = type;

	DrawTriHousePart(0, 0, Rotation.Yaw/RadToUnrRot, type, size, 0);
}

function MyHouse DrawBloxx(float posX, float posY, float angle, int seedMod, int type) // type либо 1 либо 2
{
	local vector locPos;
	local rotator locRot;
	local MyHouse localBlock;

	locPos.x = posX;
	locPos.y = posY;
	locPos += Location;
	locRot.Yaw = Rotation.Yaw + angle * RadToUnrRot;

	localBlock = Spawn(class'City.myhouse', MyPawn,, locPos, locRot);
	localBlock.GetPlayerViewPoint = GetPlayerViewPoint;
	localBlock.gen2(Pawn(MyPawn), type, Length*type, Width, Height, GenSeed + seedMod);
	Blocks.AddItem(localBlock);

	return localBlock;
}

function SpawnTriangleCenterPart(float posX, float posY, float posZ, float angle)
{
	local vector locPos;
	local rotator locRot;
	local TestTriFloor localPart;
	local TestTriRoof localPart2;

	locPos.x = posX;
	locPos.y = posY;
	locPos.z = posZ;
	locPos += Location;
	locRot.Yaw = Rotation.Yaw + (angle - DegToRad * 90) * RadToUnrRot;

	localPart = Spawn(class'City.testtrifloor', MyPawn,, locPos, locRot);
	TriParts.AddItem(localPart);

	// если это последний этаж
	if (posZ == (Height - 1) * HeiW)
	{	// ставим крышу
		localPart2 = Spawn(class'City.testtriroof', MyPawn,, locPos, locRot);
		RoofParts.AddItem(localPart2);
	}
}

function DrawCenter(float posX, float posY, float floor, float angle, Myhouse block1, Myhouse block2, Myhouse block3, int unormalBranch)
{
	local float wi;
	local float le;
	local float xp;
	local float yp;
	local float newx;
	local float newy;
	local int i, j;
	local vector locPos;
	local int addr;
	local float posZ;

	local array<NavNode> localNodes;
	local NavNode localNode1, localNode2, localNode3;

	posZ = floor * HeiW;

	for (i = 1; i <= Width; i++)
		for (j = Width - i; j < Width; j++)
		{
			wi = (Width - i) * WidW * 2 - (Width - 1) * WidW + i * WidW/2 - WidW / 2;
			le = (Width - 1 - j) * WidW - i * WidW / 2 + WidW / 2;
			xp = (sqrt(3.0) / 3.0) * wi;
			yp = le;
			newx = xp * cos(angle) - yp * sin(angle);
			newy = yp * cos(angle) + xp * sin(angle);

			SpawnTriangleCenterPart(posX + newx, posY + newy, posZ, angle);

			locPos.x = posX + newx;
			locPos.y = posY + newy;
			locPos.z = posZ + 70;
			locPos += Location;

			// создаём путевой узел
			localNode1 = Spawn(class'Base.NavNode', MyPawn,, locPos, rot(0, 0, 0));
			NavList.AddItem(localNode1);

			// если это не крайний ряд, то добавляем дополнительный блок
			if (i < Width)
			{
				wi -= WidW;
				xp = (sqrt(3.0) / 3.0) * wi;
				newx = xp * cos(angle) - yp * sin(angle);
				newy = yp * cos(angle) + xp * sin(angle);
				SpawnTriangleCenterPart(posX + newx, posY + newy, posZ, angle + DegToRad * 180);

				locPos.x = posX + newx;
				locPos.y = posY + newy;
				locPos.z = posZ + 70;
				locPos += Location;

				localNode2 = Spawn(class'Base.NavNode', MyPawn,, locPos, rot(0, 0, 0));
				NavList.AddItem(localNode2);
				localNodes[j - Width + i] = localNode2;

				BindNodes(localNode1, localNode2);
			}
			else // если это крайний ряд, то связываем с соседним домом
			{	
				// добавляем связи с соседним зданием
				addr = block2.Length - 1 + (block2.Width - j - 1) * block2.Length + floor * block2.Length * block2.Width;
				if (is2bit(block2.MyData.NavigationData[4 + addr], 1) != 1)
					BindNodes(localNode1, block2.Cells[addr].NodeNorth);
			}
			
			if (j == Width - 1)
			{
				if (unormalBranch != 3)
				{
					addr = block3.Length - 1 + (i - 1) * block3.Length + floor * block3.Length * block3.Width;
					if (is2bit(block3.MyData.NavigationData[4 + addr], 1) != 1)
						BindNodes(localNode1, block3.Cells[addr].NodeNorth);
				}
				else
				{
					addr = 0 + (block1.Width - i) * block3.Length + floor * block3.Length * block3.Width;
					if (is2bit(block3.MyData.NavigationData[4 + addr], 1) != 1)
						BindNodes(localNode1, block3.Cells[addr].NodeSouth);
				}
			}
			else
			{
				localNode3 = localNodes[j - Width + i];
				BindNodes(localNode1, localNode3);
			}
			
			// создаём связи
			if (j == Width - i)
			{
				addr = block1.Length - 1 + (block1.Width - i) * block1.Length + floor * block1.Length * block1.Width;
				if (is2bit(block1.MyData.NavigationData[4 + addr], 1) != 1)
					BindNodes(localNode1, block1.Cells[addr].NodeNorth);
			}
			else
			{
				BindNodes(localNode1, localNode3);
			}
		}
}

// связать два узла двусторонней связью
static function BindNodes(NavNode A, NavNode B)
{
	A.AddRelation(B);
	B.AddRelation(A);
}

function DrawTriHousePart(float posX, float posY, float angle, int type, int next, int deep = 0, optional MyHouse prevBranch) // если есть косяки, уберите optional и откомпилируйте
{
	local int i;
	local MyHouse block1, block2, block3;
	// номер ветки, которая считается с обратного конца (-1 если такой нет)
	local int unormalBranch;

	if (type == 0)
	{
		if ((next <= 1) && (deep < 5))
		{
			block1 = DrawBloxx(posX - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length / 2 * WidW)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length/2 * WidW)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
		}
		else
		{
			block1 = DrawBloxx(posX - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW  + WallWidth/2)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW + WallWidth/2)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
		}
		
		if ((next > 1) && (deep < 5))
		{
			DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW + WallWidth/2)) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW + WallWidth/2)) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI,type , next - 1, deep + 1, block1);
		}

		block2 = DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + (Length * WidW/2 + WallWidth/2)) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + (Length * WidW/2 + WallWidth/2)) * sin(angle), angle, SeedIterator++, 1);

		if (deep == 0)
		{
			if (next < 6)
			{
				block3 = DrawBloxx(posX - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW/2 + WallWidth/2)) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW/2 + WallWidth/2)) * sin(angle+2.0/3*PI), angle+2.0/3 * PI, SeedIterator++, 1);
				unormalBranch = -1;
			}
			else
			{
				block3 = Blocks[5];
				unormalBranch = 3;
			}
		}
		else
		{
			block3 = prevBranch;
			unormalBranch = 3;
		}
	}

	/*if (type == 1)
	{
		if (next > 1)
		{
			block1 = DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW  + Length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
			if (deep % 2 == 0)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI,type , next - 1, deep + 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI,type , next - 1, deep + 1);
			}
		}
		else
		{
			if (deep % 2 == 0)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 0);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 0);
			}
		}

		if (deep == 0)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
		}
	}

	if (type == 2)
	{
		if ((deep + 1) % 4 < 2)
		{
			if (next <= 1)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
			}

			if (next > 1)
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI, type, next - 1, deep + 1);

			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW  + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
			if (deep == 0)
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
		}
		else
		{
			if (next <= 1)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			}

			if (next > 1)
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI ,type , next - 1, deep + 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle), angle, SeedIterator++, 2);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
			}
		}
	}

	if (type == 3)
	{
		if (next > 1)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
			if (deep % 2 == 0)
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI, type, next - 1, deep + 1);
			}
			else
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 2);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle), angle, SeedIterator++, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI, type , next - 1, deep + 1);
			}
		}
		else
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			if (deep % 2 == 0)
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 2);
			}
			else
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle), angle, SeedIterator++, 2);
			}
		}

		if (deep == 0)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
		}
	}*/

	// --- begin этот блок кода следует вынести в отдельную функцию ---
	// для всех этажей строим центральную часть
	for (i = 0; i < Height; i++)
		DrawCenter(posX, posY, i, angle, block1, block2, block3, unormalBranch);
	// --- end этот блок кода следует вынести в отдельную функцию ---

}

defaultproperties
{
	Length = 10
	Width = 10
	Height = 10
	LenW = 600
	WidW = 600
	HeiW = 250

	SeedIterator = 0;
}
