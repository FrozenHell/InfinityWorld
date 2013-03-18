/**
 *	TriangleHouse
 *
 *	Creation date: 08.02.2013 15:38
 *	Copyright 2013, FrozenHell Skyline
 */
class TriangleHouse extends Actor;

// прямоугольные блоки здания
var array<MyHouse> Blocks;

<<<<<<< .mine
// треугольные части здания
var array<TestTriFloor> TriParts;
// треугольные части для крыши
var array<TestTriRoof> RoofParts;

// массив навигационых узлов в виде списка
var array<NavNode> NavList;

=======
// треугольные части здания
var array<TestTriFloor> TriParts;

var array<TestTriRoof> RoofParts;

>>>>>>> .r46
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

event Destroyed()
{
	local MyHouse localBlock;
<<<<<<< .mine
	local TestTriFloor localPart;
	local TestTriRoof localPart2;

=======
	local TestTriFloor localPart;
	local TestTriRoof localPart2;
	
>>>>>>> .r46
	// уничтожаем все блоки
	foreach Blocks(localBlock)
		localBlock.Destroy();
<<<<<<< .mine
	foreach TriParts(localPart)
		localPart.Destroy();
	foreach RoofParts(localPart2)
		localPart2.Destroy();

=======
	foreach TriParts(localPart)
		localPart.Destroy();
	foreach RoofParts(localPart2)
		localPart2.Destroy();
	
>>>>>>> .r46
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
<<<<<<< .mine

	DrawTriHousePart(0, 0, Rotation.Yaw/RadToUnrRot, type, size);
=======
	
	DrawTriHousePart(0, 0, Rotation.Yaw/RadToUnrRot, type, size);
>>>>>>> .r46
}

<<<<<<< .mine
function MyHouse DrawBloxx(float posX, float posY, float angle, int seedMod, int type) // type либо 1 либо 2
=======
function DrawBloxx(float posX, float posY, float angle, int seedMod, int type) // type либо 1 либо 2
>>>>>>> .r46
{
	local vector locPos;
	local rotator locRot;
	local MyHouse localBlock;
<<<<<<< .mine

	locPos.x = posX;
	locPos.y = posY;
	locPos += Location;
	locRot.Yaw = Rotation.Yaw + angle * RadToUnrRot;

	localBlock = Spawn(class'City.myhouse', MyPawn,, locPos, locRot);
=======
	
	locPos.x = posX;
	locPos.y = posY;
	locPos += Location;
	locRot.Yaw = Rotation.Yaw + angle * RadToUnrRot;
	
	localBlock = Spawn(class'City.myhouse', MyPawn,, locPos, locRot);
>>>>>>> .r46
	localBlock.GetPlayerViewPoint = GetPlayerViewPoint;
	localBlock.gen2(Pawn(MyPawn), type, Length*type, Width, Height, GenSeed + seedMod);
	Blocks.AddItem(localBlock);

	return localBlock;
}

function SpawnTriangleCenterPart(float posX, float posY, float posZ, float angle)
{
	local vector locPos;
	local rotator locRot;
<<<<<<< .mine
	local TestTriFloor localPart;
	local TestTriRoof localPart2;

=======
	local TestTriFloor localPart;
	local TestTriRoof localPart2;
	
>>>>>>> .r46
	locPos.x = posX;
	locPos.y = posY;
	locPos.z = posZ;
	locPos += Location;
<<<<<<< .mine
	locRot.Yaw = Rotation.Yaw + (angle - DegToRad * 90) * RadToUnrRot;

	localPart = Spawn(class'City.testtrifloor', MyPawn,, locPos, locRot);
	TriParts.AddItem(localPart);

	// если это последний этаж
	if (posZ == (Height - 1) * HeiW)
	{	// ставим крышу
		localPart2 = Spawn(class'City.testtriroof', MyPawn,, locPos, locRot);
		RoofParts.AddItem(localPart2);
	}
=======
	locRot.Yaw = Rotation.Yaw + (angle - DegToRad * 90) * RadToUnrRot;
	
	localPart = Spawn(class'City.testtrifloor', MyPawn,, locPos, locRot);
	TriParts.AddItem(localPart);
	
	// если это последний этаж
	if (posZ == (Height - 1) * HeiW)
	{	// ставим крышу
		localPart2 = Spawn(class'City.testtriroof', MyPawn,, locPos, locRot);
		RoofParts.AddItem(localPart2);
	}
>>>>>>> .r46
}

<<<<<<< .mine
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
=======
function DrawCenter(float posX, float posY, float posZ, float angle)
{
	local float wi;
	local float le;
	local float xp;
	local float yp;
	local float newx;
	local float newy;
	local int i, j;
>>>>>>> .r46

<<<<<<< .mine
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

			// создаём связи
			if (j == Width - i)
			{
				addr = block1.Length - 1 + (block1.Width - i) * block1.Length + floor * block1.Length * block1.Width;
				if (TestWall(block1.Cells[addr].South) == None)
					BindNodes(localNode1, block1.Cells[addr].NodeNorth);
			}
			else
			{
				BindNodes(localNode1, localNode3);
			}

			if (j == Width - 1)
			{
				//addr = block3.Length - 1 + (block3.Width - i) * block3.Length + floor * block3.Length * block3.Width;
				//BindNodes(localNode1, block3.Cells[addr].NodeNorth);
			}
			else
			{
				localNode3 = localNodes[j - Width + i];
				BindNodes(localNode1, localNode3);
			}

			// добавляем дополнительный блок
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
			else
			{
				addr = block2.Length - 1 + (block2.Width - j - 1) * block2.Length + floor * block2.Length * block2.Width;
				if (TestWall(block2.Cells[addr].South) == None)
					BindNodes(localNode1, block2.Cells[addr].NodeNorth);
			}
		}
}

// связать два узла двусторонней связью
static function BindNodes(NavNode A, NavNode B)
=======
	for (i = 0; i <= width; i++)
		for (j = width - i; j < width; j++)
		{
			wi = (width - i) * WidW * 2 - (width - 1) * WidW + i * WidW/2 - WidW / 2;
			le = (width - 1 - j) * WidW - i * WidW / 2 + WidW / 2;
			xp = (sqrt(3.0) / 3.0) * wi;
			yp = le;
			newx = xp * cos(angle) - yp * sin(angle);
			newy = yp * cos(angle) + xp * sin(angle);
			
			SpawnTriangleCenterPart(posX + newx, posY + newy, posZ, angle);
			if (i < width)
			{
				wi -= WidW;
				xp = (sqrt(3.0) / 3.0) * wi;
				newx = xp * cos(angle) - yp * sin(angle);
				newy = yp * cos(angle) + xp * sin(angle);
				SpawnTriangleCenterPart(posX + newx, posY + newy, posZ, angle + DegToRad * 180);
			}
		}
}

function DrawTriHousePart(float posX, float posY, float angle, int type, int next, optional int deep = 0) // если есть косяки, уберите optional и откомпилируйте
>>>>>>> .r46
{
<<<<<<< .mine
	A.AddRelation(B);
	B.AddRelation(A);
}
=======
	// --- begin этот блок кода следует вынести в отдельную функцию ---
	local int i;
	for (i = 0; i < Height; i++)
		DrawCenter(posX, posY, i * HeiW, angle);
	// --- end этот блок кода следует вынести в отдельную функцию ---
>>>>>>> .r46

<<<<<<< .mine
function DrawTriHousePart(float posX, float posY, float angle, int type, int next, optional int deep = 0, optional MyHouse prevBranch) // если есть косяки, уберите optional и откомпилируйте
{
	local int i;
	local MyHouse block1, block2, block3;
	// номер ветки, которая считается с обратного конца (-1 если такой нет)
	local int unormalBranch;

=======
>>>>>>> .r46
	if (type == 0)
	{
		if ((next <= 1) && (deep < 5))
		{
<<<<<<< .mine
			block1 = DrawBloxx(posX - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length / 2 * WidW)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length/2 * WidW)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
=======
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length / 2 * WidW)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length/2 * WidW)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
>>>>>>> .r46
		}
		else
		{
<<<<<<< .mine
			block1 = DrawBloxx(posX - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW  + WallWidth/2)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW + WallWidth/2)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
=======
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length * WidW  + WallWidth/2)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length * WidW + WallWidth/2)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
>>>>>>> .r46
		}

		if ((next > 1) && (deep < 5))
			DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW + WallWidth/2)) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW + WallWidth/2)) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI,type , next - 1, deep + 1, block1);

<<<<<<< .mine
		block2 = DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + (Length * WidW/2 + WallWidth/2)) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + (Length * WidW/2 + WallWidth/2)) * sin(angle), angle, SeedIterator++, 1);
=======
		DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + (Length * WidW/2 + WallWidth/2)) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + (Length * WidW/2 + WallWidth/2)) * sin(angle), angle, SeedIterator++, 1);
>>>>>>> .r46

		if (deep == 0 && next < 6)
<<<<<<< .mine
		{
			block3 = DrawBloxx(posX - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW/2 + WallWidth/2)) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * (Width * WidW) + (Length * WidW/2 + WallWidth/2)) * sin(angle+2.0/3*PI), angle+2.0/3 * PI, SeedIterator++, 1);
			unormalBranch = -1;
		}
		else
		{
			block3 = prevBranch;
			unormalBranch = 3;
		}
=======
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length * WidW/2 + WallWidth/2)) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length * WidW/2 + WallWidth/2)) * sin(angle+2.0/3*PI), angle+2.0/3 * PI, SeedIterator++, 1);
>>>>>>> .r46
	}

	if (type == 1)
	{
		if (next > 1)
		{
<<<<<<< .mine
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW  + Length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
=======
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW  + length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
>>>>>>> .r46
			if (deep % 2 == 0)
			{
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI,type , next - 1, deep + 1);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI,type , next - 1, deep + 1);
>>>>>>> .r46
			}
			else
			{
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI,type , next - 1, deep + 1);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI,type , next - 1, deep + 1);
>>>>>>> .r46
			}
		}
		else
		{
			if (deep % 2 == 0)
			{
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
>>>>>>> .r46
			}
			else
			{
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 0);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 0);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 0);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 0);
>>>>>>> .r46
			}
		}

		if (deep == 0)
		{
<<<<<<< .mine
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
=======
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
>>>>>>> .r46
		}
	}

	if (type == 2)
	{
		if ((deep + 1) % 4 < 2)
		{
			if (next <= 1)
			{
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
>>>>>>> .r46
			}
			else
			{
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
>>>>>>> .r46
			}

			if (next > 1)
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI, type, next - 1, deep + 1);

<<<<<<< .mine
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW  + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
=======
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW  + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
>>>>>>> .r46
			if (deep == 0)
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
>>>>>>> .r46
		}
		else
		{
			if (next <= 1)
			{
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
>>>>>>> .r46
			}
			else
			{
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
>>>>>>> .r46
			}

			if (next > 1)
			{
<<<<<<< .mine
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI ,type , next - 1, deep + 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle), angle, SeedIterator++, 2);
=======
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI ,type , next - 1, deep + 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle), angle, SeedIterator++, 2);
>>>>>>> .r46
			}
			else
			{
<<<<<<< .mine
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
=======
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
>>>>>>> .r46
			}
		}
	}

	if (type == 3)
	{
		if (next > 1)
		{
<<<<<<< .mine
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
=======
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
>>>>>>> .r46
			if (deep % 2 == 0)
			{
<<<<<<< .mine
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI, type, next - 1, deep + 1);
=======
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI, type, next - 1, deep + 1);
>>>>>>> .r46
			}
			else
			{
<<<<<<< .mine
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 2);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle), angle, SeedIterator++, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI, type , next - 1, deep + 1);
=======
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 2);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle), angle, SeedIterator++, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI, type , next - 1, deep + 1);
>>>>>>> .r46
			}
		}
		else
		{
<<<<<<< .mine
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
=======
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
>>>>>>> .r46
			if (deep % 2 == 0)
			{
<<<<<<< .mine
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 2);
=======
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 2);
>>>>>>> .r46
			}
			else
			{
<<<<<<< .mine
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW) * sin(angle), angle, SeedIterator++, 2);
=======
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle), angle, SeedIterator++, 2);
>>>>>>> .r46
			}
		}

		if (deep == 0)
		{
<<<<<<< .mine
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * Width * WidW + Length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
=======
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
>>>>>>> .r46
		}
	}

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
<<<<<<< .mine

	SeedIterator = 0;
=======
	
	SeedIterator = 0;
>>>>>>> .r46
}
