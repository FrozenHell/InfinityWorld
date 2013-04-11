/**
 *	UnPlayerController
 *
 *	Creation date: 03.01.2012 18:08
 *	Copyright 2013, FHS
 */
class UnPlayerController extends RPGPlayerController;

var MyGalaxy Galaxy;
var TriangleHouse House;
var bool bGalaxyGenerated, bHouseGenerated;

// переменные для работы с тестовым уровнем TestHouse
var int TestHouseType;
var int TestHouseHeight;
var bool bTestHouseCreated;
var Actor TestHouse;
var int TestHouseSeed;
var float TestHouseAngle;
var int housesCount; // количество домов для genmorehouses
var int hCountX, hCountY; // ширина и высота города для genmorehouses
// для режима охотник-жертва
var GFxMovie_HunterHUD GFxHunterHUD;
var Pawn Pray;
var bool bHunt;

// вступительный ролик
var GFxMovie_Intro StartMovie;

function rotator UnrRot(float pitch, float yaw, float roll)
{
	local rotator rota;
	local float degToRot;
	degToRot = DegToRad * RadToUnrRot;
	rota.Pitch = pitch * degToRot;
	rota.Yaw = yaw * degToRot;
	rota.Roll = roll * degToRot;
	return rota;
}

function vector Vec(int x, int y, int z)
{
	local vector ve;
	ve.X = x;
	ve.Y = y;
	ve.Z = z;
	return ve;
}

exec function drawgalaxy(optional int numStars = 1000)
{
	if (!bGalaxyGenerated)
	{
		galaxy = Spawn(class'City.mygalaxy', UnPawn(Owner),, vect(240, 100000, 1000), rot(0, 0, 0));
		galaxy.RotateG(0, 10, -0.5);
		galaxy.GetPlayerViewPoint = GetPlayerViewPoint;
		bGalaxyGenerated = true;
		galaxy.gen(UnPawn(Owner), numStars);
		//say("Generated"@numStars@"stars");
	}
}

exec function rotateGalax(float Pitch, float Yaw, float Roll)
{
	galaxy.RotateG(Pitch, Yaw, Roll);
}

exec function cleargalaxy()
{
	if (bGalaxyGenerated)
	{
		galaxy.destroy();
		bGalaxyGenerated = false;
	}
}

exec function drawhouse(optional int seed = 0)
{
	if (!bHouseGenerated)
	{
		House = Spawn(class'City.TriangleHouse', UnPawn(Owner),, vect(0, -100, 210), rot(0, 0, 0));
		House.GetPlayerViewPoint = GetPlayerViewPoint;
		House.Gen(UnPawn(Owner), 6, 6, 15, 0, 1, 16);
		//House.Gen(UnPawn(Owner), 4, 4, 3, 0, 1, 16);
		bHouseGenerated = true;
	}
}

exec function genmorehouses()
{
	local MyHouse how;

	how = Spawn(class'City.myhouse', UnPawn(Owner),, vec((housesCount%hCountX) * 5000 - 50000, (housesCount/hCountX) * 5000 - 50000, -40), rot(0, 0, 0));
	how.GetPlayerViewPoint = GetPlayerViewPoint;
	how.gen2(UnPawn(Owner), 0, 5, 5, Round(RandRange(3, 10)), housesCount);

	housesCount++;
	if (housesCount < hCountX * hCountY)
	{
		SetTimer(0.05, false, 'genmorehouses');
		`log(housesCount);
	}
}

exec function clearhouse()
{
	if (bHouseGenerated)
	{
		house.destroy();
		bHouseGenerated = false;
		say("Clearing House");
	}
}

exec function drawtrihouse(optional int type = 0, optional int size = 1)
{
	local TriangleHouse lochouse;
	lochouse = Spawn(class'City.TriangleHouse', UnPawn(Owner),, vect(0, -100, 0), rot(0, 0, 0));
	lochouse.GetPlayerViewPoint = GetPlayerViewPoint;
	lochouse.Gen(UnPawn(Owner), 4, 4, 15, type, size, 1);
}

// тестируем навигационные сети
exec function getnearnavnode()
{
	local NavNode node, minNode, minMinNode;
	local ministar star;
	local int i, j, k;

	// ищем ближайшую ноду и создаём там светящуюся точку
	node = SearchNearNavNode();
	star = Spawn(class'City.ministar', UnPawn(Owner),, node.Location, rot(0, 0, 0));
	star.Change(); // подсветить белым

	// показать связи
	for (i = 0; i < node.Links.Length; i++)
	{
		minNode = node.Links[i];
		Spawn(class'City.ministar', UnPawn(Owner),, node.Location - (node.Location - minNode.Location)/3, rot(0, 0, 0));

		star = Spawn(class'City.ministar', UnPawn(Owner),, minNode.Location, UnrRot(0, 0, 0));
		star.Change(); // подсветить белым

		for (j = 0; j < minNode.Links.Length; j++)
		{
			minMinNode = minNode.Links[j];
			Spawn(class'City.ministar', UnPawn(Owner),, minNode.Location - (minNode.Location - minMinNode.Location)/3, rot(0, 0, 0));

			star = Spawn(class'City.ministar', UnPawn(Owner),, minMinNode.Location, UnrRot(0, 0, 0));
			star.Change(); // подсветить белым

			for (k = 0; k < minMinNode.Links.Length; k++)
			{
				Spawn(class'City.ministar', UnPawn(Owner),, minMinNode.Location - (minMinNode.Location - minMinNode.Links[k].Location)/3, rot(0, 0, 0));
			}
		}
	}
}

function NavNode SearchNearNavNode()
{
	local vector viewLocation;
	local rotator viewRotation;
	local NavNode locNode, NearestNode;
	local float minRange;

	// ищем координаты игрока
	GetPlayerViewPoint(viewLocation, viewRotation);

	minRange = 100000.0;

	foreach AllActors(class'NavNode', locNode)
	{
		if (VSize(viewLocation - locNode.Location) < minRange)
		{
			minRange = VSize(viewLocation - locNode.Location);
			NearestNode = locNode;
		}
	}

	return NearestNode;
}

exec function gen_ps()
{
	local PlanetSystem PS1;
	PS1 = Spawn(class'City.PlanetSystem', UnPawn(Owner),, vec(50, 30, 300), UnrRot(0, 0, 0));
	PS1.generate(UnPawn(Owner), 1);
}

exec function GenCity()
{
	local City miniCity;
	miniCity = Spawn(class'City.City', UnPawn(Owner),, vec(0, 0, 0), UnrRot(0, 0, -40));
	miniCity.GetPlayerViewPoint = GetPlayerViewPoint;
	miniCity.Gen(UnPawn(Owner), 0);
}

// --- обработчики нажатий на кнопки на тестовом уровне
exec function BtnCreate()
{
	if (!bTestHouseCreated)
	{
		switch (TestHouseType)
		{
			case 0:
				TestHouse = Spawn(class'City.MyHouse', UnPawn(Owner),, vect(0, -10000, -40), UnrRot(0, TestHouseAngle, 0));
				MyHouse(TestHouse).GetPlayerViewPoint = GetPlayerViewPoint;
				MyHouse(TestHouse).gen2(UnPawn(Owner), 0, 10, 10, TestHouseHeight, TestHouseSeed);
				break;
			case 1:
			case 2:
			case 3:
			case 4:
				TestHouse = Spawn(class'City.TriangleHouse', UnPawn(Owner),, vect(0, -10000, -40), UnrRot(0, TestHouseAngle, 0));
				TriangleHouse(TestHouse).GetPlayerViewPoint = GetPlayerViewPoint;
				TriangleHouse(TestHouse).Gen(UnPawn(Owner), 4, 4, TestHouseHeight, TestHouseType - 1, 5, TestHouseSeed);
				break;
			default:
				`warn("Выбран неверный тип при построении тестового здания");
				break;
		}

		bTestHouseCreated = true;
	}
}

exec function BtnRemove()
{
	if (bTestHouseCreated)
	{
		TestHouse.Destroy();
		bTestHouseCreated = false;
	}
}

exec function BtnFlrInc()
{
	if (TestHouseHeight < 15)
	{
		if (bTestHouseCreated)
		{
			BtnRemove();
			TestHouseHeight++;
			BtnCreate();
		}
		else
			TestHouseHeight++;
	}
	Say("Height"@TestHouseHeight@"floors");
}

exec function BtnFlrSub()
{
	if (TestHouseHeight > 2)
	{
		if (bTestHouseCreated)
		{
			BtnRemove();
			TestHouseHeight--;
			BtnCreate();
		}
		else
			TestHouseHeight--;
	}
	Say("Height"@TestHouseHeight@"floors");
}

exec function BtnTypeInc()
{
	if (TestHouseType < 4)
	{
		if (bTestHouseCreated)
		{
			BtnRemove();
			TestHouseType++;
			BtnCreate();
		}
		else
			TestHouseType++;
	}
	Say("Type"@TestHouseType);
}

exec function BtnTypeSub()
{
	if (TestHouseType > 0)
	{
		if (bTestHouseCreated)
		{
			BtnRemove();
			TestHouseType--;
			BtnCreate();
		}
		else
			TestHouseType--;
	}
	Say("Type"@TestHouseType);
}

exec function BtnAngleInc()
{
	if (bTestHouseCreated)
	{
		BtnRemove();
		if (TestHouseAngle < 360.0)
			TestHouseAngle += 10.0;
		else
			TestHouseAngle = 0.0;
		BtnCreate();
	}
	else
	{
		if (TestHouseAngle < 360.0)
			TestHouseAngle += 10.0;
		else
			TestHouseAngle = 0.0;
	}

	Say("Angle"@TestHouseAngle);
}

exec function BtnAngleSub()
{
	if (bTestHouseCreated)
	{
		BtnRemove();
		if (TestHouseAngle > 0)
			TestHouseAngle -= 10.0;
		else
			TestHouseAngle = 350.0;
		BtnCreate();
	}
	else
	{
		if (TestHouseAngle > 0)
			TestHouseAngle -= 10.0;
		else
			TestHouseAngle = 350.0;
	}
	Say("Angle"@TestHouseAngle);
}

exec function BtnSeedInc()
{
	if (TestHouseSeed < 20000)
	{
		if (bTestHouseCreated)
		{
			BtnRemove();
			TestHouseSeed++;
			BtnCreate();
		}
		else
			TestHouseSeed++;
	}
	Say("Seed"@TestHouseSeed);
}

exec function BtnSeedSub()
{
	if (TestHouseSeed > 0)
	{
		if (bTestHouseCreated)
		{
			BtnRemove();
			TestHouseSeed--;
			BtnCreate();
		}
		else
			TestHouseSeed--;
	}
	Say("Seed"@TestHouseSeed);
}
// --- конец обработчиков кнопок на тестовом уровне



// начинаем охоту
exec function StartHunt()
{
	local HunterController locPray;
	GFxHunterHUD = new Class'Base.GFxMovie_HunterHUD';
	GFxHunterHUD.initialize(1);
	foreach AllActors(class'HunterController', locPray)
	{
		if (locPray.Pawn.IsAliveAndWell())
		{
			Pray = locPray.Pawn;
			break;
		}
	}

	bHunt = true;
}

// остонавливаем охоту
exec function StopHunt()
{
	GFxHunterHUD.Close();
	bHunt = false;
}

// бот-жертва добежал
function BotPrayWin()
{
	Say("NPC Win");
	Pray.TornOff();
	StopHunt();
	NextRound();
}

// игрок-охотник убил жертву
function PlayerHunterWin()
{
	//Say("Player Win");
	StopHunt();
	NextRound();
}

// следующий раунд
function NextRound()
{
	local NavNode locNode;
	
	foreach AllActors(class'NavNode', locNode)
	{
		// спавним на одной из 20 первых нод
		if (locNode.Location.z < 500 && Rand(20) < 3)
		{
			break;
		}
	}
	SpawnPray(locNode.Location);
}

// обновляем информацию о цели
function UpdateRotation(float fDeltaTime)
{
	local vector viewLocation;
	local rotator viewRotation;
	local float zShift;

	if (bHunt)
	{
		// если жертва существует и жива
		if (Pray != None && Pray.IsAliveAndWell())
		{
			// ищем координаты игрока
			GetPlayerViewPoint(viewLocation, viewRotation);

			// ищем разницу в высоте
			zShift = Pray.Location.z - viewLocation.z;
			if (abs(zShift) < 120.0)
				zShift = 0;

			// поворачиваем стрелку в сторону жертвы
			GFxHunterHUD.Redraw((rotator(viewLocation - Pray.Location).Yaw - viewRotation.Yaw) / RadToUnrRot, zShift);
		}
		else // если жертва мертва или её нет, считаем что выиграл игрок
			PlayerHunterWin();
	}

	Super.UpdateRotation(fDeltaTime);
}

// создать новую жертву
public function SpawnPray(vector posSpawn)
{
	local SequenceObject individualEvent;
	local array<SequenceObject> eventList;
	
	// ищем все SeqEvent'ы нужного типа
	WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqEvent_RemoteVectorEvent', true, eventList);
	// Ищем наш SeqEvent среди собратьев его типа
	foreach eventList(individualEvent)
	{
		// если это нужный SeqEvent
		if (individualEvent.IsA('SeqEvent_RemoteVectorEvent') && SeqEvent_RemoteVectorEvent(individualEvent).EventName == 'SpawnPray')
		{
			// передаём в SeqEvent позицию, в которой будем создавать бота
			SeqEvent_RemoteVectorEvent(individualEvent).Position = posSpawn;
			// активируем SeqEvent
			SequenceEvent(individualEvent).CheckActivate(self, Pawn);
		}
	}
}

// функция, запускаемая при старте новой игры
exec function StartNewGame()
{
	StartMovie = new Class'Universe.GFxMovie_Intro';
	StartMovie.Initialize(self);
	StartMovie.MenuEvent = CloseIntro;
	StartMovie.Start(false);
}

function CloseIntro(int param)
{
	local float minRange;
	local SpeakingPawn localSpPawn, NearestSpPawn;
	local vector viewLocation;
	local rotator viewRotation;

	// закрываем и очищаем ролик
	StartMovie.Close(false);
	StartMovie = None;

	minRange = 100000.0;

	GetPlayerViewPoint(viewLocation, viewRotation);

	// ищем ближайшего пауна с которым можно поговорить
	foreach AllActors(class'SpeakingPawn', localSpPawn)
	{
		if (localSpPawn.bGetUsable() && VSize(viewLocation - localSpPawn.Location) < minRange)
		{
			minRange = VSize(viewLocation - localSpPawn.Location);
			NearestSpPawn = localSpPawn;
		}
	}

	// если такие нашлись, то начинаем диалог
	if (NearestSpPawn != None)
	{
		//NearestSpPawn.Use(Pawn);
	}
}

defaultproperties
{
	Name="Default__UnPlayerController"
	bGalaxyGenerated = false
	bHouseGenerated = false
	TestHouseType = 0
	TestHouseHeight = 10
	bTestHouseCreated = false
	TestHouseSeed = 0
	TestHouseAngle = 0.0
	bHunt = false

	
	hCountX = 15
	hCountY = 15
	housesCount = 0
}
