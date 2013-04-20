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

var int UtoR, Utor2, UtoR3;

// сдвиг уровня первого этажа над уровнем тротуара
const HouseUpShift = vect(0, 0, 15);

// делегат для одноимённой функции из плеерконтроллера
delegate GetPlayerViewPoint(out vector out_Location, out rotator out_rotation);

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	UtoR = 90 * DegToRad * RadToUnrRot;
	UtoR2 = 180 * DegToRad * RadToUnrRot;
	UtoR3 = 270 * DegToRad * RadToUnrRot;
}


// угол 0, 90, 180, 270 градусов
private function rotator QwatRot(float qYaw)
{
	local rotator rota;
	rota.Yaw = qYaw == 0 ? 0 : qYaw == 1 ? UtoR : qYaw == 2 ? Utor2 : Utor3; // то же что qYaw * 90 * DegToRad * RadToUnrRot;
	return rota;
}

function Gen(Pawn locPawn, optional int seed = 0)
{
	local vector locPos;
	MyPawn = locPawn;
	GenSeed = seed;

	locPos = Location;

	CreateHouse(locPos, 10, 10, 10);

	locPos.Y = 7800;
	CreateHouse(locPos, 10, 10, 10);
	
	locPos.Y = 7800 + 6600;
	CreateHouse(locPos, 10, 10, 10);

	locPos.Y = 7800 * 0.5;
	CreateRoad(locPos, 11, QwatRot(1));

	locPos.X = 7800 * 0.5;
	locPos.Y = 7800 + 6600 * 0.5;
	CreateRoad(locPos, 22, QwatRot(0));

	locPos.X = -7800 * 0.5;
	locPos.Y = 0;
	CreateRoad(locPos, 11, QwatRot(0));

	locPos.X = 7800 * 0.5;
	locPos.Y = 0;
	CreateRoad(locPos, 11, QwatRot(0));

	locPos.X = -7800 * 0.5;
	locPos.Y = 7800 + 6600 * 0.5;
	CreateRoad(locPos, 22, QwatRot(0));

	locPos.X = 7800 * 0.5;
	locPos.Y = 7800 * 0.5;
	CreateRoadTriWay(locPos, QwatRot(2));

	locPos.X = -7800 * 0.5;
	locPos.Y = 7800 * 0.5;
	CreateRoadTriWay(locPos, QwatRot(0));
}

function CreateHouse(vector locat, int sizeX, int sizeY, int sizeZ)
{
	local MyHouse locHouse;
	local Trotuar locTrot;
	locHouse = Spawn(class'City.myhouse', MyPawn,, locat + HouseUpShift, rot(0, 0, 0));
	locHouse.GetPlayerViewPoint = GetPlayerViewPoint;
	locHouse.gen2(MyPawn, 0, sizeX, sizeY, sizeZ, GenSeed);
	Houses.AddItem(locHouse);
	
	locTrot = Spawn(class'City.Trotuar', MyPawn,, locat, rot(0, 0, 0));
	locTrot.SetScale(sizeX + 1, sizeY + 1);
}

function CreateRoad(vector locat, float len, rotator angle)
{
	local RoadPlot localroad;
	localroad = Spawn(class'City.RoadPlot', MyPawn,, locat, angle);
	localroad.SetScale(1.0, len);
}

function CreateRoadTriWay(vector locat, rotator angle)
{
	Spawn(class'City.RoadTriWay', MyPawn,, locat, angle);
}

defaultproperties
{

}
