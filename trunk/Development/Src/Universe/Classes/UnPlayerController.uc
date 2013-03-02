/**
 *	UnPlayerController
 *
 *	Creation date: 03.01.2012 18:08
 *	Copyright 2013, FHS
 */
class UnPlayerController extends UTPlayerController;

var MyGalaxy Galaxy;
var MyHouse House;
var bool bGalaxyGenerated, bHouseGenerated;

// HUD
var GFxMovie_PlayerHUD GFxHUD;
var Actor HUDUsableActor;

// ���������� ��� ������ � �������� ������� TestHouse
var int TestHouseType;
var int TestHouseHeight;
var bool bTestHouseCreated;
var Actor TestHouse;
var int TestHouseSeed;
var float TestHouseAngle;

// ��� ������ �������-������
var GFxMovie_HunterHUD GFxHunterHUD;
var Pawn Pray;
var bool bHunt;

exec function rotator UnrRot(float pitch, float yaw, float roll)
{
	local rotator rota;
	local float degToRot;
	degToRot = DegToRad * RadToUnrRot;
	rota.Pitch = pitch * degToRot;
	rota.Yaw = yaw * degToRot;
	rota.Roll = roll * degToRot;
	return rota;
}

exec function vector Vec(int x, int y, int z)
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
		galaxy = Spawn(class'City.mygalaxy', UnPawn(Owner),, vect(500, 0, 1000), rot(0, 0, 0));
		galaxy.GetPlayerViewPoint = GetPlayerViewPoint;
		bGalaxyGenerated = true;
		galaxy.gen(UnPawn(Owner), numStars);
		say("Generated"@numStars@"stars");
	}
}

exec function rotateGalax(float Pitch, float Yaw, float Roll)
{
	//galaxy.RotateGf(Pitch, Yaw, Roll);
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
		House = Spawn(class'City.myhouse', UnPawn(Owner),, vect(0, -100, 210), rot(0, 0, 0));
		House.GetPlayerViewPoint = GetPlayerViewPoint;
		House.gen2(UnPawn(Owner), 4, 4, 5, 0);
		bHouseGenerated = true;
	}
}

exec function genmorehouses()
{
	local int i, j;
	local MyHouse how;
	for (i = 0; i < 4; i++)
	{
		for (j = 0; j < 4; j++)
		{
			how = Spawn(class'City.myhouse', UnPawn(Owner),, vec(i * 5000, j * 5000, 210), rot(0, 0, 0));
			how.GetPlayerViewPoint = GetPlayerViewPoint;
			how.gen2(UnPawn(Owner), 5, 5, 10, i + j);
		}
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

// ��������� ������������� ����
exec function getnearnavnode()
{
	local NavNode node, minNode, minMinNode;
	local ministar star;
	local int i, j, k;

	// ���� ��������� ���� � ������ ��� ���������� �����
	node = SearchNearNavNode();
	star = Spawn(class'City.ministar', UnPawn(Owner),, node.Location, rot(0, 0, 0));
	star.Change(); // ���������� �����

	// �������� �����
	for (i = 0; i < node.LinksSize; i++)
	{
		minNode = node.Links[i];
		Spawn(class'City.ministar', UnPawn(Owner),, node.Location - (node.Location - minNode.Location)/3, rot(0, 0, 0));

		star = Spawn(class'City.ministar', UnPawn(Owner),, minNode.Location, UnrRot(0, 0, 0));
		star.Change(); // ���������� �����

		for (j = 0; j < minNode.LinksSize; j++)
		{
			minMinNode = minNode.Links[j];
			Spawn(class'City.ministar', UnPawn(Owner),, minNode.Location - (minNode.Location - minMinNode.Location)/3, rot(0, 0, 0));

			star = Spawn(class'City.ministar', UnPawn(Owner),, minMinNode.Location, UnrRot(0, 0, 0));
			star.Change(); // ���������� �����

			for (k = 0; k < minMinNode.LinksSize; k++)
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

	// ���� ���������� ������
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

// --- ����������� ������� �� ������ �� �������� ������
exec function BtnCreate()
{
	if (!bTestHouseCreated)
	{
		switch (TestHouseType)
		{
			case 0:
				TestHouse = Spawn(class'City.MyHouse', UnPawn(Owner),, vect(0, -10000, -40), UnrRot(0, TestHouseAngle, 0));
				MyHouse(TestHouse).GetPlayerViewPoint = GetPlayerViewPoint;
				MyHouse(TestHouse).gen2(UnPawn(Owner), 10, 10, TestHouseHeight, TestHouseSeed);
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
				`warn("������ �������� ��� ��� ���������� ��������� ������");
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
// --- ����� ������������ ������ �� �������� ������


// ������ ������� "������������"
exec function use_actor()
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;
	// ���������� �� ������� ����� ������������ �������
	local float maxRange;
	maxRange = 100;
	GetPlayerViewPoint(viewLocation, viewRotation);
	HitActor = Trace(hitLocation, hitNormal, viewLocation + maxRange * vector(viewRotation), viewLocation, true);

	// ���� �� ������ �� �����, ������� ����� ������������
	if (Useable(HitActor) != None)
	{
		// ������������
		Useable(HitActor).Use(Pawn);
	}
}

// �������� �����
exec function StartHunt()
{
	local Pawn locPray;
	GFxHunterHUD = new Class'Base.GFxMovie_HunterHUD';
	GFxHunterHUD.initialize(1);
	foreach AllActors(class'Pawn', locPray)
	{
		if (locPray!=Pawn && locPray.IsAliveAndWell())
		{
			Pray = locPray;
			break;
		}
	}

	bHunt = true;
}

// ������������� �����
exec function StopHunt()
{
	GFxHunterHUD.Close();
	bHunt = false;
}

// ���-������ �������
function BotPrayWin()
{
	Say("NPC Win");
	Pray.TornOff();
	StopHunt();
	NextRound();
}

// �����-������� ���� ������
function PlayerHunterWin()
{
	Say("Player Win");
	StopHunt();
	NextRound();
}

// ��������� �����
function NextRound()
{
	local NavNode locNode;
	
	foreach AllActors(class'NavNode', locNode)
	{
		// ������� �� ����� �� 20 ������ ���
		if (locNode.Location.z < 500 && Rand(20) < 3)
		{
			break;
		}
	}
	SpawnPray(locNode.Location);
}

// ��������� ���������� � ����
function UpdateRotation(float fDeltaTime)
{
	local vector viewLocation;
	local rotator viewRotation;
	local float zShift;

	if (bHunt)
	{
		// ���� ������ ���������� � ����
		if (Pray != None && Pray.IsAliveAndWell())
		{
			// ���� ���������� ������
			GetPlayerViewPoint(viewLocation, viewRotation);

			// ���� ������� � ������
			zShift = Pray.Location.z - viewLocation.z;
			if (abs(zShift) < 120.0)
				zShift = 0;

			// ������������ ������� � ������� ������
			GFxHunterHUD.Redraw((rotator(viewLocation - Pray.Location).Yaw - viewRotation.Yaw) / RadToUnrRot, zShift);
		}
		else // ���� ������ ������ ��� � ���, ������� ��� ������� �����
			PlayerHunterWin();
	}
	
	CheckTouchscreens();
	Super.UpdateRotation(fDeltaTime);
}

// ������� ����� ������
public function SpawnPray(vector posSpawn)
{
	local SequenceObject individualEvent;
	local array<SequenceObject> eventList;
	
	// ���� ��� SeqEvent'� ������� ����
	WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqEvent_RemoveVectorEvent', true, eventList);
	// ���� ��� SeqEvent ����� ��������� ��� ����
	foreach eventList(individualEvent)
	{
		// ���� ��� ������ SeqEvent
		if (individualEvent.IsA('SeqEvent_RemoveVectorEvent') && SeqEvent_RemoveVectorEvent(individualEvent).EventName == 'SpawnPray')
		{
			// ������� � SeqEvent �������, � ������� ����� ��������� ����
			SeqEvent_RemoveVectorEvent(individualEvent).Position = posSpawn;
			// ���������� SeqEvent
			SequenceEvent(individualEvent).CheckActivate(self, Pawn);
		}
	}
}

// ��������� �� ������� ������ ��������, ������� ����� ������������
function CheckTouchscreens()
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;
	// ���������� �� ������� ����� ������������ �������
	local float maxRange;
	maxRange = 150;
	GetPlayerViewPoint(viewLocation, viewRotation);
	HitActor = Trace(hitLocation, hitNormal, viewLocation + maxRange * vector(viewRotation), viewLocation, true);

	// ���� �� ������ ������ �� �����, ������� ����� ������������
	if (Useable(HitActor) != None)
	{
		// ���� ������ - ��� ��������� �����, ����� ������� ������ �� ����
		if (TouchScreen(HitActor) != None)
		{
			TouchScreen(HitActor).SetCursorPosition(hitLocation);	
		}
		
		// ������� "������� F ����� ..."
		if (HUDUsableActor != HitActor)
		{
			HUDUsableActor = HitActor;
			GFxHUD.AddIcon(Useable(HitActor).GetActionName());
		}
	}
	else
	{
		// ���� ����� ���� ������ ���, �� ������� ��� ��������� � ������
		if (HUDUsableActor != None)
		{
			HUDUsableActor = None;
			GFxHUD.RemoveIcon();
		}
	}
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	GFxHUD = new Class'Universe.GFxMovie_PlayerHUD';
	GFxHUD.initialize();
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
	HUDTypeUse = 0;
}
