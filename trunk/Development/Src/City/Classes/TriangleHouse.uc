/**
 *	TriangleHouse
 *
 *	Creation date: 08.02.2013 15:38
 *	Copyright 2013, FrozenHell Skyline
 */
class TriangleHouse extends Actor;

// блоки здания
var array<MyHouse> Blocks;

var Actor MyPawn;

var int GenSeed;

var int HouseType;

var float Length, Width, Height, LenW, WidW, HeiW;
var float WallWidth;

// делегат для одноимённой функции из плеерконтроллера
delegate GetPlayerViewPoint(out vector out_Location, out Rotator out_rotation);

// --------- функции ---------

event Destroyed()
{
	local MyHouse localBlock;
	// уничтожаем все блоки
	foreach Blocks(localBlock)
		localBlock.Destroy();

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
	
	DrawTriHousePart(0, 0, 0, type, size);
}

function SpawnPart(vector posit, rotator rotat, int type, int seed)
{
	local MyHouse localBlock;
	
	localBlock = Spawn(class'City.myhouse', MyPawn,, posit, rotat);
	localBlock.GetPlayerViewPoint = GetPlayerViewPoint;
	localBlock.gen2(Pawn(MyPawn), Length*type, Width, Height, seed);
	Blocks.AddItem(localBlock);
}

function DrawBloxx(float posX, float posY, float angle, int type)
{
	local vector locPos;
	local rotator locRot;
	locPos.x = posX;
	locPos.y = posY;
	locPos += Location;
	locRot.Yaw = Rotation.Yaw + angle * RadToUnrRot;
	SpawnPart(locPos, locRot, type, GenSeed);
}


function DrawTriHousePart(float posX, float posY, float angle, int type, int next, optional int deep = 0) // если есть косяки, уберите optional и откомпилируйте
{

	//DrawCenter(X, Y, angle);

	if (type == 0)
	{
		if ((next <= 1) && (deep < 5))
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length / 2 * WidW)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length/2 * WidW)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 1);
		}
		else
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length * WidW  + WallWidth/2)) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length * WidW + WallWidth/2)) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 2);
		}

		if ((next > 1) && (deep < 5))
			DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length * WidW + WallWidth/2)) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length * WidW + WallWidth/2)) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI,type , next - 1, deep + 1);

		DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + (Length * WidW/2 + WallWidth/2)) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + (Length * WidW/2 + WallWidth/2)) * sin(angle), angle, 1);

		if (deep == 0 && next < 6)
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * (width * WidW) + (Length * WidW/2 + WallWidth/2)) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * (width * WidW) + (length * WidW/2 + WallWidth/2)) * sin(angle+2.0/3*PI), angle+2.0/3 * PI, 1);
	}

	if (type == 1)
	{
		if (next > 1)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW  + length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 2);
			if (deep % 2 == 0)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI,type , next - 1, deep + 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, 1);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI,type , next - 1, deep + 1);
			}
		}
		else
		{
			if (deep % 2 == 0)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, 0);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 0);
			}
		}

		if (deep == 0)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, 1);
		}
	}

	if (type == 2)
	{
		if ((deep + 1) % 4 < 2)
		{
			if (next <= 1)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 2);
			}

			if (next > 1)
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI, type, next - 1, deep + 1);

			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW  + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, 1);
			if (deep == 0)
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+2.0/3*PI), angle+2.0/3*PI, 1);
		}
		else
		{
			if (next <= 1)
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 1);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 1);
			}

			if (next > 1)
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI ,type , next - 1, deep + 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle), angle, 2);
			}
			else
			{
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, 1);
			}
		}
	}

	if (type == 3)
	{
		if (next > 1)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 2);
			if (deep % 2 == 0)
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+2.0/3*PI, type, next - 1, deep + 1);
			}
			else
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 2);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle), angle, 2);
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+4.0/3*PI), PI + angle+4.0/3*PI, type , next - 1, deep + 1);
			}
		}
		else
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle+4.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle+4.0/3*PI), angle+4.0/3*PI, 1);
			if (deep % 2 == 0)
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle+2.0/3*PI), PI + angle, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle+2.0/3*PI), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle+2.0/3*PI), angle+2.0/3*PI, 2);
			}
			else
			{
				DrawTriHousePart(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * 2 * sin(angle), PI + angle+4.0/3*PI, 0, 0, 1);
				DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW) * sin(angle), angle, 2);
			}
		}

		if (deep == 0)
		{
			DrawBloxx(posX - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * cos(angle), posY - ((sqrt(3.0)/6.0) * width * WidW + length * WidW/2) * sin(angle), angle, 1);
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
}
