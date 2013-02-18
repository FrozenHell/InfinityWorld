/**
 *	City
 *
 *	Creation date: 16.02.2013 18:29
 *	Copyright 2013, FHS
 */
class City extends Actor;

// блоки здания
var array<MyHouse> Houses;

var Pawn MyPawn;

var int GenSeed;

// делегат для одноимённой функции из плеерконтроллера
delegate GetPlayerViewPoint(out vector out_Location, out Rotator out_rotation);

function Gen(Pawn locPawn, optional int seed = 0)
{
	local vector locPos;
	MyPawn = locPawn;
	GenSeed = seed;
	
	locPos = Location;
	
	locPos.Y -= 1000;
	CreateHouse(locPos);
	
	locPos.Y += 2000;
	CreateHouse(locPos);
}

function CheckPlayerPosition()
{
	local vector ViewLocation;
	local rotator ViewRotation;
	GetPlayerViewPoint(ViewLocation, ViewRotation);
	//distance = VSize(ViewLocation - Location);
}

function CreateHouse(vector locat)
{
	local MyHouse locHouse;
	locHouse = Spawn(class'City.myhouse', MyPawn,, locat, rot(0, 0, 0));
	locHouse.GetPlayerViewPoint = GetPlayerViewPoint;
	locHouse.gen2(MyPawn, 10, 10, 10, GenSeed);
	Houses.AddItem(locHouse);
}

function bool CheckHouseCreated(float X, float Y)
{
	local MyHouse localHouse;
	foreach Houses(localHouse)
	{
		if (localHouse.Location.X > X - 300 && localHouse.Location.X < X + 300
		&& localHouse.Location.Y > Y - 300 && localHouse.Location.Y < Y + 300)
			return true;
	}
	return false;
}

defaultproperties
{

}
