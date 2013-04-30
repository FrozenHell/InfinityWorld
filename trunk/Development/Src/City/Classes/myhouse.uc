/*
 FrozenHell Skyline, 2012
*/
class MyHouse extends Actor
	DLLBind(house);

struct Cell
{
	// ����� � ����� �������� ����������� � ����� ����
	var Actor North, East, West, South, Lex, Wex, Pol, Roof, Grain;
	// ����� ��� ��� ���� ����
	var bool bVisible;
	// ������� ���� �����, ����������� � ���� ������ (����� ������ �� ������ �������� ������)
	var NavNode NodeNorth, NodeEast, NodeWest, NodeSouth, NodeTop, NodeBottom, NodeCenter;

	structdefaultproperties
	{
		bVisible = false;
	}
};

var int UtoR, Utor2, UtoR3;

var float ASin, ACos;
// ��������� �������� ���� � ��������� �������� ����
var int DistNear, DistFar;
// ������� ����
var int CurrentFloor;
var MyNavigationStruct MyData, MyData2;
// ��������� ������
var vector ViewLocation;
// ������� ������
var rotator ViewRotation;
var Actor MyPawn;
var int Length, Width, Height, LenW, WidW, HeiW;
// ���������� �� ������ �� ����
var int Distance;
var rotator Angle;
// ��������������� ���������� ��� ����������� ������ ��������� �����
var vector HouseCenter;
// ��� ������ (0 - �������, 1 - ����� �����������)
var int BuildingType;

// �����
var array<LiftController> Lifts;

// ���� false - ���������� � ���� �� ��������� � ������ � ���������� ������ LOD
var bool bInitialized;

// ���� ������
var int HouseSeed;

/*
 * Visiblity
 * 00000000 - ������ ��������� ������(��� ������ ���� ��������� ������� LOD)
 * 00000001 - ������ ��������� ��������� � ������
 * 00000010 - ��������� �������� �����
 * 00000100 - ��������� ��������� �����
 * 00001000 - ��������� �������� �����
 * 00010000 - ��������� ����� �����
 * 00100000 - ��������� ����� ������
 * 01000000 - ��������� ��������� ������ (-2,-1,�������,+1,+2)
*/
var int Visiblity; // ���������� ���������� ���������

// ������ ������� �����������
var LODHouse LOD;

// ����� LOD'�
const LOD_SHIFT = vect(0.0, 0.0, -25.0);

// ������ ����� ������
var array<Cell> Cells;

// ������ ������������ ����� � ���� ������
var array<NavNode> NavList;

dllimport final function GetNavData(out MyNavigationStruct NavData, int type, int len, int wid, int hei, int seed);
dllimport final function GetNavData2(out MyNavigationStruct NavData,out MyNavigationStruct NavData2, int len, int wid, int hei, int xpos, int ypos, int zpos);

// ������� ��� ���������� ������� �� ����������������
delegate GetPlayerViewPoint(out vector out_Location, out Rotator out_rotation);

// -------------------------------������--------------------------------
auto state Created
{
	function CheckView() {
		if (!IsNearPawn())
			DrawHouse();
		else
			DrawHouse(true);
	}

Begin:
	GetPlayerViewPoint(ViewLocation, ViewRotation);
	distance = VSize(ViewLocation - Location);
	Sleep(5 + distance * 0.0001);
	CheckView();
	Goto ('Begin');
}
// ----------------------------����� �������-----------------------------

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	UtoR = 90 * DegToRad * RadToUnrRot;
	UtoR2 = 180 * DegToRad * RadToUnrRot;
	UtoR3 = 270 * DegToRad * RadToUnrRot;
}

event Destroyed()
{
	// ������� ������������� ����
	ClearNavNet();
	// ������� ������ ������
	Clear();
	
	// ������� �����
	RemoveLifts();

	super.Destroyed();
}

// ������� ������� ��� ������ ����
function Clear()
{
	local int i;
	if (Visiblity != 0)
	{
		for (i = 0; i < length * Width * Height; i++)
		{
			if (Cells[i].bVisible)
			{
				Cells[i].North.destroy();
				Cells[i].East.destroy();
				Cells[i].South.destroy();
				Cells[i].West.destroy();
				Cells[i].Pol.destroy();
				// ��������� �������� ���������� �� ��� ���� �����
				if (Cells[i].Lex != None) Cells[i].Lex.destroy();
				if (Cells[i].Wex != None) Cells[i].Wex.destroy();
				if (Cells[i].Roof != None) Cells[i].Roof.destroy();
				if (Cells[i].Grain != None) Cells[i].Grain.destroy();
				// ������� ��� ������ ������
				Cells[i].bVisible = false;
			}
		}
		Visiblity = 0;
	}
	// ������� ������� Cells
	Cells.Remove(0, Cells.Length);
}

// ���������� 1 ��� 0 (��� ����� "�" � ������� "b")
private function int isbit(int a, int b)
{
	return((a >> b) % 2);
}

// ���������� true ��� false (��� ����� "�" � ������� "b")
private function bool isBitB(int a, int b)
{
	return((a >> b) % 2 == 1);
}

// ���������� ����� �� 0 �� 4 (��� ���� �� ����� a � ������� b*2)
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

private function rotator QwatRot(float qYaw) // ����� ����� ����������� �������
{
	local rotator rota;
	//Rota.Pitch = 0; // ��������� �� �����
	rota.Yaw = angle.Yaw +(qYaw == 0 ? 0 : qYaw == 1 ? UtoR : qYaw == 2 ? Utor2 : Utor3); // �� �� ��� qYaw * 90 * DegToRad * RadToUnrRot;
	//Rota.Roll = 0;
	return rota;
}

// ��������� ������
private function cell DrawCell(int celll, const out vector posit, int wzPos, int wxPos, int wyPos, bool st)
{
	local cell yachejka;
	yachejka.South = drawHPart(Is2Bit(celll, 3), 3, posit);
	yachejka.East = drawHPart(Is2Bit(celll, 2), 0, posit);
	yachejka.North = drawHPart(Is2Bit(celll, 1), 1, posit);
	yachejka.West = drawHPart(Is2Bit(celll, 0), 2, posit);

	if (!st) // ��� � ��������
	{
		yachejka.Pol = Spawn(class'City.testfloor', MyPawn,, posit, angle);
	}
	else
	{
		if ((wzPos == 1) && st) // ��� ������� ����� ��������
		{
			yachejka.Pol = Spawn(class'City.teststairfloor', MyPawn,, posit, angle);
		}
		else // ��������
		{
			yachejka.Pol = Spawn(class'City.teststair', MyPawn,, posit, angle);
		}
	}

	if (wxPos == 1)
		yachejka.Lex = drawHOutPart(IsBit(celll, 7) * 2 + IsBit(celll, 6), 3, posit);
	else if (wxPos == 2)
		yachejka.Lex = drawHOutPart(IsBit(celll, 3) * 2 + IsBit(celll,2), 1, posit);

	if (wyPos == 1)
		yachejka.Wex = drawHOutPart(IsBit(celll, 5) * 2 + IsBit(celll, 4), 0, posit);
	else if
		(wyPos == 2) yachejka.Wex = drawHOutPart(IsBit(celll, 1) * 2 + IsBit(celll, 0), 2, posit);


	if (wzPos == 2) // ���� ��������� ����
	{
		if (!st)
			yachejka.Roof = Spawn(class'City.testroof', MyPawn,, posit, angle);
		else
			yachejka.Roof = Spawn(class'City.testroofstair', MyPawn,, posit, angle);
		if (wxPos == 1)
		{
			if (wyPos == 1)
				yachejka.Grain = Spawn(class'City.testroofang', MyPawn,, posit, qwatrot(3)); // ������� ����� ����
			else if (wyPos == 2)
				yachejka.Grain = Spawn(class'City.testroofang', MyPawn,, posit, qwatrot(2)); // ������ ����� ����
			else
				yachejka.Grain = Spawn(class'City.testroofgrain', MyPawn,, posit, qwatrot(3)); // ���� - ��������
		}
		else if (wxPos == 2)
		{
			if (wyPos == 1)
				yachejka.Grain = Spawn(class'City.testroofang', MyPawn,, posit, qwatrot(0)); // ������� ������ ����
			else if (wyPos == 2)
				yachejka.Grain = Spawn(class'City.testroofang', MyPawn,, posit, qwatrot(1)); // ������ ������ ����
			else
				yachejka.Grain = Spawn(class'City.testroofgrain', MyPawn,, posit, qwatrot(1)); // ����� - ��������
		}
		else if (wyPos == 1)
			yachejka.Grain = Spawn(class'City.testroofgrain', MyPawn,, posit, qwatrot(0)); // ���� - ��������
		else if
			(wyPos == 2) yachejka.Grain = Spawn(class'City.testroofgrain', MyPawn,, posit, qwatrot(2)); // ��� - ��������
	}
	else if (wxPos == 1)
	{ // ���� �� ��������� ����
		if (wyPos == 1)
			yachejka.Grain = Spawn(class'City.testgrain',MyPawn,, posit, qwatrot(3)); // ������� ����� ����
		else if (wyPos == 2)
			yachejka.Grain = Spawn(class'City.testgrain', MyPawn,, posit, qwatrot(2)); // ������ ����� ����
	}
	else if (wxPos == 2)
	{
		if (wyPos == 1)
			yachejka.Grain = Spawn(class'City.testgrain', MyPawn,, posit, qwatrot(0)); // ������� ������ ����
		else if
			(wyPos == 2) yachejka.Grain = Spawn(class'City.testgrain', MyPawn,, posit, qwatrot(1)); // ������ ������ ����
	}

	yachejka.bVisible = true;
	return yachejka;
}

// ������������� ������ � ��������� ������ (���������� ��������� ����� - ���� ������)
function Gen(Pawn locPawn, int locType, optional int len = 10, optional int wid = 10, optional int hei = 10, optional int seed = 0)
{
	Length = len;
	Width = wid;
	Height = hei;
	BuildingType = locType;
	HouseSeed = seed;
	MyPawn = locPawn;
	HouseCenter.X = 0; // ������ �� �����, ������ �������� ����� ���������� ����
	HouseCenter.Y = 0;
	Angle.Yaw = Rotation.Yaw;
	ASin = Sin(Rotation.Yaw / RadToUnrRot);
	ACos = Cos(Rotation.Yaw / RadToUnrRot);
	DrawHouse();
}

// ������������� ������ � ��������� ������ (���������� ��������� ����� - ����� ������)
function gen2(Pawn locPawn, int locType, optional int len = 10, optional int wid = 10, optional int hei = 10, optional int seed = 0)
{
	Length = len;
	Width = wid;
	Height = hei;
	BuildingType = locType;
	HouseSeed = seed;
	MyPawn = locPawn;
	HouseCenter.x = ((Length - 1) * LenW / 2); // ������ �� �����, ������ �������� ����� ���������� ����
	HouseCenter.y = ((Width - 1) * WidW / 2);
	Angle.Yaw = Rotation.Yaw;
	ASin = Sin(Rotation.Yaw / RadToUnrRot);
	ACos = Cos(Rotation.Yaw / RadToUnrRot);
	DrawHouse();
}

// ���������� ����
private function DrawHouse(optional bool full = false)
{
	local int i, j, k, wxPos, wyPos, wzPos, celll;
	local vector pos; // ������� ������
	local vector nav; // ��������������� ���������� ��� ����������� ��������� ������ � ������������� ����������� ������

	// ����� ������� � ������� ������
	GetPlayerViewPoint(ViewLocation, ViewRotation);

	nav.x = (ViewLocation.x - Location.x) * ACos + (ViewLocation.y - Location.y) * ASin;
	nav.y = (Location.x - ViewLocation.x) * ASin + (ViewLocation.y - Location.y) * aCos;
	nav.z = ViewLocation.z - Location.z;

	if (SetVisibility(nav)) // ���� ���-�� ����������
	{
		GetVisibleMass();

		if (bInitialized)
		{
			for (k = 0; k < Height; k++)
			{
				for (j = 0; j < Width; j++)
				{
					for (i = 0; i < Length; i++)
					{
						celll = i + j * Length + k * Length * Width;
						// ���� ������ ������ ���� ������, � ��� ������
						if ((full || (MyData2.NavigationData[celll] == 2)) &&  !Cells[celll].bVisible)
						{
							pos.x = Location.x + (LenW * i - HouseCenter.x) * aCos - (WidW * j - HouseCenter.y) * ASin;
							pos.y = Location.y + (LenW * i - HouseCenter.x) * ASin + (WidW * j - HouseCenter.y) * aCos;
							pos.z = Location.z + HeiW * k;
							wxPos = i == 0 ? 1 : i == Length - 1 ? 2 : 0; // ������ ��������� � ����, ������ ��� � ������� ����?
							wyPos = j == 0 ? 1 : j == Width - 1 ? 2 : 0; // ��� ������ ���
							wzPos = k == 0 ? 1 : k == Height - 1 ? 2 : 0; // ��� ��������� ���
							// ������ �
							Cells[celll] = DrawCell(MyData.NavigationData[4 + celll], pos, wzPos, wxPos, wyPos, (i == MyData.NavigationData[0] && j == MyData.NavigationData[1]) || (i == MyData.NavigationData[2] && j == MyData.NavigationData[3]));
							// ��������� �������� � ���������� ������ ����������: ��������� �� � ������ ��������
						}
						else if (!(full || (MyData2.NavigationData[celll] == 2)) && Cells[celll].bVisible) // �����, ���� ������ ������ ���� ������, � ��� ������
						{
							// ������� ���������� ������
							if (Cells[celll].North != None) Cells[celll].North.destroy();
							if (Cells[celll].East != None) Cells[celll].East.destroy();
							if (Cells[celll].South != None) Cells[celll].South.destroy();
							if (Cells[celll].West != None) Cells[celll].West.destroy();
							if (Cells[celll].Pol != None) Cells[celll].Pol.destroy();
							// ��������� �������� ���������� �� ��� ���� �����
							if (Cells[celll].Lex != None) Cells[celll].Lex.destroy();
							if (Cells[celll].Wex != None) Cells[celll].Wex.destroy();
							if (Cells[celll].Roof != None) Cells[celll].Roof.destroy();
							if (Cells[celll].Grain != None) Cells[celll].Grain.destroy();
							// �������, ��� ������ ������
							Cells[celll].bVisible = false;
						}
					}
				}
			}
		}

		if (Visiblity == 0)
		{
			if (Lifts.Length != 0)
				RemoveLifts();

			if (NavList.Length != 0)
				ClearNavNet();

		}
		else if (bInitialized)
		{
			if (Lifts.Length == 0)
				AddLifts();

			if (NavList.Length == 0)
				GenNavNet();
		}
	}
}

// ���������, ���� �� ���������������� ������
function CheckInitialize()
{
	// ��������������, ���� ��� �� ���������������� � ����� �����
	if (!bInitialized && Visiblity != 0)
		Initialize();
}

// ��������� ������ ��� ������
function Initialize()
{
	local int i;
	local cell celll; 
	
	GetNavData(MyData, BuildingType, Length, Width, Height, HouseSeed);
	
	// ��� ���������� ����� �������������, ���� �������� �� ������� ��������� ������
	// ������, ����� ��������� �� �������
	for (i = 0; i < Length * Width * Height; i++)
		Cells[i] = celll;
	
	bInitialized = true;
}

private function actor drawHPart(int partType, int ang, const out vector posit) // ���������� ������ "�� ������", � �� "�� ��������", const ������� � ���, ��� ������ �� ����� �������� � ���� �������
{
	local actor mypExem;
	switch (partType)
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

private function actor drawHOutPart(int partType, int ang, const out vector posit) // ���������� ������ "�� ������", � �� "�� ��������", const ������� � ���, ��� ������ �� ����� �������� � ���� �������
{
	local actor mypExem;
	switch (partType)
	{
		case 0:
			// ���������� � ������� ���� ����������
			mypExem = None;//Spawn(class'City.testwindowex', MyPawn,, posit, qwatrot(ang));
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

// ������� ������ ���������� Visiblity � ���������� -1 ���� ��������� ���, ����� ������� ���� (0 - ���� ���� �� �����)
function bool SetVisibility(vector nav)
{
	// ���������� - ��������� ������ Visiblity
	local int vis;
	// ����
	local int floor;
	local bool changed;
	// ������ ���������� vis ����������� ��������
	// ���� ���������, ���� ��� ��������� ����� ������, ��� ������ � ���, ��� ��� ���� ������ ��� ���������� LOD
	vis = 0;
	floor = 0;
	// ���� ��� �� ������
	if (Vsize(nav) < DistFar)
	{
		// ���� �� � ������ ������
		if (nav.x < -0.5 * Length * LenW)
			vis += 2; // +00000010
		// ���� �� � ������� ������
		if (nav.x > 0.5 * Length * LenW)
			vis += 4; // +00000100
		// ���� �� � ������ ������
		if (nav.y > 0.5 * Width * WidW)
			vis += 8; // +00001000
		// ���� �� � ��� ������
		if (nav.y < -0.5 * Width * WidW)
			vis += 16; // +00010000
		// ���� ��� ����� ������
		if (nav.z > Height * HeiW)
		{
			if (vis == 0)
			{
				vis = 62; // ��� �����
			}
			else
			{
				vis += 32;
			}
		}

		// ���� ��� ����� ������
		if (Vsize(nav) < DistNear)
		{
			// ���������� ������� ����
			floor = (nav.z + 30) / HeiW;
			vis += 64;
		}
	}

	// ���� ��� ��������� - ���������� -1
	if (vis == Visiblity && (!isBitB(vis, 6) || floor == Currentfloor))
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

// ����������� ������ ��������� � ����������� �� Visiblity
function GetVisibleMass()
{
	local int i, j, k;

	if (Visiblity != 0)
	{
		CheckInitialize();
		
		for (k = 0; k < Height; k++)
		{
			for (j = 0; j < Width; j++)
			{
				for (i = 0; i < Length; i++)
				{
					if ((isBitB(Visiblity, 1) && (i == 0))||(isBitB(Visiblity, 2) && (i == Length - 1)) || (isBitB(Visiblity, 3) && (j == Width - 1)) || (isBitB(Visiblity, 4) && (j == 0)) || (isBitB(Visiblity, 5) && (k == Height - 1)) || (isBitB(Visiblity, 6) && (abs(k - Currentfloor) < 3)))
						MyData2.NavigationData[i + j*Length + k*Length*Width] = 2;
					else
						MyData2.NavigationData[i + j*Length + k*Length*Width] = 0;
				}
			}
		}
		
		if (LOD != none)
		{
			Lod.Destroy();
		}
	}
	else
	{
		for (i = 0; i < Length * Width * Height; i++)
		{
			MyData2.NavigationData[i] = 0;
		}
		
		if (LOD == none)
		{
			LOD = Spawn(class'City.LODHouse', MyPawn,, Location+LOD_SHIFT, Rotation);
			LOD.SetScale(Length, Width, Height);
		}
		else
		{
			`warn("������ ������� �������� ������");
		}
	}
}

function Pawn FindNearlyPawn()
{
	local Pawn locPawn, nearlyPawn;
	local float locDist;
	locDist = 100000;
	foreach AllActors(class'Pawn', locPawn)
	{
		if (Vsize(FindNearlyPawn().Location - Location) < locDist)
		{
			nearlyPawn = locPawn;
			locDist = Vsize(FindNearlyPawn().Location - Location);
		}
	}
	return nearlyPawn;
}

function bool IsnearPawn()
{
	local Pawn locPawn, nearlyPawn;
	local float locDist;
	locDist = 100000;
	foreach AllActors(class'Pawn', locPawn)
	{
		if (Vsize(locPawn.Location - Location) < locDist)
		{
			nearlyPawn = locPawn;
			locDist = Vsize(locPawn.Location - Location);
		}
	}
	if (nearlyPawn != None)
		return Vsize(nearlyPawn.Location - Location) < DistNear;
	else
		return false;
}

function AddLifts()
{
	local int i;
	local vector liftLocation;
	
	for (i = 0; i < 2; i++)
	{
		liftLocation = Location;
		liftLocation.x += (LenW * MyData.NavigationData[i * 2] - HouseCenter.x) * aCos - (WidW * MyData.NavigationData[i * 2 + 1] - HouseCenter.y) * ASin;
		liftLocation.y += (LenW * MyData.NavigationData[i * 2] - HouseCenter.x) * ASin + (WidW * MyData.NavigationData[i * 2 + 1] - HouseCenter.y) * aCos;
		Lifts[i] = Spawn(class'City.LiftController', MyPawn,, liftLocation, qwatrot(0));
		Lifts[i].Create(MyPawn, Height, HeiW);
	}
}

function RemoveLifts()
{
	local LiftController localLift;

	foreach Lifts(localLift)
		localLift.Destroy();
}


/*
 * ��� ��� ������������� �������� ����� ������� � �������� ������, �� ������ ��
 * ������� ��������� ������������� ����� � ���������� ������ ������. �� �����
 * ���� ��������� ����������� �� ������� � ��������� ������ ������ � �������� ������
 * ��� �������� � �������� � ������ ���������.
*/


// ������� ���� ��������� ��� ������
function GenNavNet()
{
	local int i, j, k, localCell, addr;
	local vector pos;
	local NavNode localNode1, localNode2;
	// �������� �� ������ �� �����
	for (k = 0; k < Height; k++)
		for (j = 0; j < Width; j++)
			for (i = 0; i < Length; i++)
			{
				addr = i + j * Length + k * Length * Width;

				// ��������� �������� ���������� ������ ������
				pos.x = Location.x + (LenW * i - HouseCenter.x) * aCos - (WidW * j - HouseCenter.y) * aSin;
				pos.y = Location.y + (LenW * i - HouseCenter.x) * aSin + (WidW * j - HouseCenter.y) * aCos;
				pos.z = Location.z + HeiW * k + 70; // 70 - ������ ��� �����

				// ������� ���������� � ������
				localCell = MyData.NavigationData[4 + addr];

				// ���� ��� ��������
				if (((i == MyData.NavigationData[0] && j == MyData.NavigationData[1]) || (i == MyData.NavigationData[2] && j == MyData.NavigationData[3])))
				{
					// ������ ������ ���� � ������� ��� � ������
					Cells[addr].NodeBottom = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, WidW * 0.35), rot(0, 0, 0));
					NavList.AddItem(Cells[addr].NodeBottom);

					// ������ ��������� ���� � ������� ��� � ������
					Cells[addr].NodeEast = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos,, WidW * 0.4), rot(0, 0, 0));
					NavList.AddItem(Cells[addr].NodeEast);

					// ��������� ��������� � ������ ����
					BindNodes(Cells[addr].NodeEast, Cells[addr].NodeBottom);

					// ������ ������ ������������� ���� � ������� ��� � ������
					localNode1 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, LenW * 0.35, WidW * 0.35), rot(0, 0, 0));
					NavList.AddItem(localNode1);

					// ��������� ������ ������������� � ��������� ����
					BindNodes(localNode1, Cells[addr].NodeEast);

					// ��������� ������ ������������� � ������ ����
					BindNodes(localNode1, Cells[addr].NodeBottom);

					// ������ ������ ������������� ���� � ������� ��� � ������
					localNode2 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, LenW * 0.35, -WidW * 0.35, HeiW * 0.55), rot(0, 0, 0));
					NavList.AddItem(localNode2);

					// ��������� ������ ������������� � ������ ������������� ����
					BindNodes(localNode1, localNode2);

					// ���� ��� �� ��������� ����
					if (k < Height - 1)
					{
						// ������ ������� ���� � ������� ��� � ������
						Cells[addr].NodeTop = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, -WidW * 0.35, HeiW * 0.55), rot(0, 0, 0));
						NavList.AddItem(Cells[addr].NodeTop);

						// ��������� ������ ������������� � ������� ����
						BindNodes(localNode2, Cells[addr].NodeTop);
					}
					else // ���� ���� ���������
					{
						// ������ ������ ������������� ���� (��������� ����� � ������ �������) � ������� ��� � ������
						localNode1 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, -WidW * 0.35, HeiW * 0.55), rot(0, 0, 0));
						NavList.AddItem(localNode1);

						// ��������� ������ ������������� � ������ ������������� ����
						BindNodes(localNode2, localNode1);

						// ������ �������� ������������� ���� (��������� ����� � ������ �������) � ������� ��� � ������
						localNode2 = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, WidW * 0.35, HeiW), rot(0, 0, 0));
						NavList.AddItem(localNode1);

						// ��������� ������ ������������� � �������� ������������� ����
						BindNodes(localNode1, localNode2);

						// ������ ������� ���� � ������� ��� � ������ (������ ���� �������� ����� �� ������� ����� �������)
						Cells[addr].NodeTop = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.35, WidW, HeiW+10), rot(0, 0, 0));
						NavList.AddItem(Cells[addr].NodeTop);

						// ��������� �������� ������������� � ������� ����
						BindNodes(localNode2, Cells[addr].NodeTop);
					}

					// ���� ���� �� ������
					if (k > 0) // ����� ��������� �� ��������� (���� � ������)
						BindNodes(Cells[addr].NodeBottom, Cells[addr - Length * Width].NodeTop);
				}
				else // ���� �� ��������
				{
					// ������ ���� ����� (���� � �������)
					Cells[addr].NodeCenter = Spawn(class'Base.NavNode', MyPawn,, pos, rot(0, 0, 0));
					Cells[addr].NodeNorth = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, LenW * 0.4), rot(0, 0, 0));
					Cells[addr].NodeSouth = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos, -LenW * 0.4), rot(0, 0, 0));
					Cells[addr].NodeWest = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos,, -WidW * 0.4), rot(0, 0, 0));
					Cells[addr].NodeEast = Spawn(class'Base.NavNode', MyPawn,, LocShift(pos,, WidW * 0.4), rot(0, 0, 0));

					// ������� ���� � ������, ����� �� ��������
					NavList.AddItem(Cells[addr].NodeCenter);
					NavList.AddItem(Cells[addr].NodeNorth);
					NavList.AddItem(Cells[addr].NodeSouth);
					NavList.AddItem(Cells[addr].NodeWest);
					NavList.AddItem(Cells[addr].NodeEast);

					// ��������� ��� ���� ����� �����
					BindNodes(Cells[addr].NodeCenter, Cells[addr].NodeNorth);
					BindNodes(Cells[addr].NodeCenter, Cells[addr].NodeSouth);
					BindNodes(Cells[addr].NodeCenter, Cells[addr].NodeWest);
					BindNodes(Cells[addr].NodeCenter, Cells[addr].NodeEast);
					BindNodes(Cells[addr].NodeWest, Cells[addr].NodeNorth);
					BindNodes(Cells[addr].NodeEast, Cells[addr].NodeNorth);
					BindNodes(Cells[addr].NodeWest, Cells[addr].NodeSouth);
					BindNodes(Cells[addr].NodeEast, Cells[addr].NodeSouth);
				}


				// ��������� ����������� ����� � ������ �������� ����� (������ ���� ���� ����� ��� �������)
				if (i != 0 && Is2Bit(localCell, 3) > 1)
				{
					BindNodes(Cells[addr].NodeSouth, Cells[addr - 1].NodeNorth);
				}
				if (j != 0 && Is2Bit(localCell, 2) > 1)
				{
					BindNodes(Cells[addr].NodeWest, Cells[addr - Length].NodeEast);
				}
			}
}

// ������� ��� ���� ������������ ������
static function BindNodes(NavNode A, NavNode B)
{
	A.AddRelation(B);
	B.AddRelation(A);
}

function ClearNavNet()
{
	local NavNode localNode;
	// ������� ��� ���� ������
	foreach NavList(localNode)
		localNode.Destroy();
	// ������� ������ NavList
	NavList.Remove(0, NavList.Length);
}

/*
 * ��������� ���������� ���������� ����� �� �������������� ������
 * ���������:
 * localCenter - ����� ������������ ������� �������������� ������� �����
 * xShift, yShift, zShift - ������ � ������������� (�� ���������) ���������
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
	DistNear = 5000
	DistFar = 20000
	BuildingType = 0
	Visiblity = 1
	
	bInitialized = false
}