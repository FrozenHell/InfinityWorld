/**
 *	City
 *
 *	Creation date: 16.02.2013 18:29
 *	Copyright 2013, FHS
 */
class City extends Actor
	DLLBind(city);

struct NaviStruct
{
	var array<int> NaviData;
};

// блоки здания
var array<MyHouse> Houses;

var Pawn MyPawn;

// семя этого города для ГПСЧ
var int CitySeed;

var int UtoR, Utor2, UtoR3;

// сдвиг уровня первого этажа над уровнем тротуара
const HouseUpShift = vect(0, 0, 15);

dllimport final function GetNavData(out NaviStruct NavData, int count, int seed);
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
	local NaviStruct Data;
	local int i,j;
	local int clustersCount;
	local int thisCluster;
	// параметры конкретного здания или кластера
	local int hWid, hLen, hPosX, hPosY;
	MyPawn = locPawn;
	CitySeed = seed;

	// получаем данные
	GetNavData(Data, 20, CitySeed);

	clustersCount = Data.NaviData[0];
	thisCluster = 0;
	for (i = 0; i < clustersCount; i++)
	{
		hLen = Data.NaviData[1 + i * 5 + 1];
		hWid = Data.NaviData[1 + i * 5 + 2];
		hPosX = Data.NaviData[1 + i * 5 + 3];
		hPosY = Data.NaviData[1 + i * 5 + 4];
		CreateTrotuar(hPosX, hPosY, hLen, hWid);
		for	(j = thisCluster; j < Data.NaviData[1 + i * 5]; j++)
		{
			hLen = Data.NaviData[1 + clustersCount * 5 + thisCluster + j * 4];
			hWid = Data.NaviData[1 + clustersCount * 5 + thisCluster + j * 4 + 1];
			hPosX = Data.NaviData[1 + clustersCount * 5 + thisCluster + j * 4 + 2];
			hPosY = Data.NaviData[1 + clustersCount * 5 + thisCluster + j * 4 + 3];
			CreateHouse(hPosX, hPosY, hLen, hWid, 5);
		}
		thisCluster = Data.NaviData[1 + i * 5];
	}

	locPos = Location;

	/*CreateHouse(locPos, 10, 10, 10);

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
	CreateRoadTriWay(locPos, QwatRot(0));*/
}

function CreateHouse(int posX, int posY, int sizeX, int sizeY, int sizeZ)
{
	local MyHouse locHouse;
	local vector locPos;
	locPos = Location;
	locPos.x += posX * class'myhouse'.default.LenW;
	locPos.y += posY * class'myhouse'.default.WidW;
	locHouse = Spawn(class'City.myhouse', MyPawn,, locPos + HouseUpShift, rot(0, 0, 0));
	locHouse.GetPlayerViewPoint = GetPlayerViewPoint;
	locHouse.Gen(MyPawn, 0, sizeX, sizeY, sizeZ, CitySeed + (locPos.x * locPos.y));
	Houses.AddItem(locHouse);
}

function CreateTrotuar(int posX, int posY, int sizeX, int sizeY)
{
	local Trotuar locTrot;
	local vector locPos;
	locPos = Location;
	locPos.x += posX * class'myhouse'.default.LenW;
	locPos.y += posY * class'myhouse'.default.WidW;
	locTrot = Spawn(class'City.Trotuar', MyPawn,, locPos, rot(0, 0, 0));
	locTrot.SetScale(sizeX, sizeY);
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
