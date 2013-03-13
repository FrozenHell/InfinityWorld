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

var array<TestTriRoof> RoofParts;

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
	
	DrawTriHousePart(0, 0, Rotation.Yaw/RadToUnrRot, type, size);
}

function DrawBloxx(float posX, float posY, float angle, int seedMod, int type) // type либо 1 либо 2
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

function DrawCenter(float posX, float posY, float posZ, float angle)
{
	local float wi;
	local float le;
	local float xp;
	local float yp;
	local float newx;
	local float newy;
	local int i, j;

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
{
	// --- begin этот блок кода следует вынести в отдельную функцию ---
	local int i;
	for (i = 0; i < Height; i++)
		DrawCenter(posX, posY, i * HeiW, angle);
	// --- end этот блок кода следует вынести в отдельную функцию ---

	if (type == 0)
	{
		if ((next <= 1) && (deep < 5))
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length / 2 * WidW)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length/2 * WidW)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
		}
		else
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length * WidW  + WallWidth/2)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length * WidW + WallWidth/2)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
		}

		if ((next > 1) && (deep < 5))
			DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length * WidW + WallWidth/2)) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length * WidW + WallWidth/2)) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI,type , next - 1, deep + 1);

		DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + (Length * WidW/2 + WallWidth/2)) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + (Length * WidW/2 + WallWidth/2)) * sin(angle), angle, SeedIterator++, 1);

		if (deep == 0 && next < 6)
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length * WidW/2 + WallWidth/2)) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length * WidW/2 + WallWidth/2)) * sin(angle+2.0/3*PI), angle+2.0/3 * PI, SeedIterator++, 1);
	}

	if (type == 1)
	{
		if (next > 1)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW  + length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
			if (deep % 2 == 0)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI,type , next - 1, deep + 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI,type , next - 1, deep + 1);
			}
		}
		else
		{
			if (deep % 2 == 0)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 0);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 0);
			}
		}

		if (deep == 0)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
		}
	}

	if (type == 2)
	{
		if ((deep + 1) % 4 < 2)
		{
			if (next <= 1)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
			}

			if (next > 1)
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI, type, next - 1, deep + 1);

			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW  + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
			if (deep == 0)
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 1);
		}
		else
		{
			if (next <= 1)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			}

			if (next > 1)
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI ,type , next - 1, deep + 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle), angle, SeedIterator++, 2);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
			}
		}
	}

	if (type == 3)
	{
		if (next > 1)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 2);
			if (deep % 2 == 0)
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI, type, next - 1, deep + 1);
			}
			else
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 2);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle), angle, SeedIterator++, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI, type , next - 1, deep + 1);
			}
		}
		else
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, SeedIterator++, 1);
			if (deep % 2 == 0)
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, SeedIterator++, 2);
			}
			else
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle), angle, SeedIterator++, 2);
			}
		}

		if (deep == 0)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, SeedIterator++, 1);
		}
	}
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
