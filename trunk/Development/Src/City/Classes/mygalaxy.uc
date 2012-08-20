/*
*	������ ������ ��������� ��� ����� ���������.
*	Location ��������� - ��� � ����� (� ������ ���������� � �������, ����� ������ ���� � ������ ���������)
* �������� �� ����� ��������� ��������� � ����� (GalaxyCenter - Location)
*/
class MyGalaxy extends Actor
	DLLBind(galaxy);

struct MyNavigationStruct
{
	var array<int> NavigationData;
};

// ������� 3�3
struct Matr3
{
	var float m11, m12, m13, m21, m22, m23, m31, m32, m33;
};

// ������������ ���������� (������-�� ���� ������ ������������)
const WorldSize = 262000;

// � ������� �� �� ���������
var bool Cosmos; // ���� false �� �� ��������� � ��������������� ������
// �����
var array<Actor> Stars;
// ���������, ���������� �� DLL
var MyNavigationStruct MyData;
// ����� (����� ��� ���������� ��������� ����������� �������)
var Pawn MyPawn;
// ��������� �� ���������
var bool bGenerated;
// ���������� ����
var int MaxStars;
// �������� ��������� ��������
var float GalaxyScale;
// ��������� ������ ��������� ������������ ������
var vector GalaxyCenter;

// ����������� ������� ������ �� ����������
var float RangeScale;

dllimport final function GetNavData(out MyNavigationStruct NavData, int nStars);

delegate GetPlayerViewPoint(out vector out_Location, out rotator out_Rotation);

// ��������� ������� �� �������
final operator(16) vector * (vector A, Matr3 B)
{
	local vector localVector;
	localVector.x = (B.m11 * A.x + B.m21 * A.y + B.m31 * A.z);
	localVector.y = (B.m12 * A.x + B.m22 * A.y + B.m32 * A.z);
	localVector.z = (B.m13 * A.x + B.m23 * A.y + B.m33 * A.z);
	return localVector;
}

// ��������� � ������ �������� ������
auto state InMenu
{
	// ��������� ������� ��������� ����
	function Resize()
	{
		local int i;
		local float newSize;
		local vector viewLocation; // ��������� ������
		local rotator viewRotation; // ������� ������
		GetPlayerViewPoint(viewLocation, viewRotation);
		for (i = 0; i < MaxStars; i++)
		{
			if (Stars[i] != None)
			{
				newSize = VSize(Stars[i].Location - viewLocation) * RangeScale;
				if (newSize <= 50)
					Stars[i].SetDrawScale(newSize);
				else if (Stars[i].DrawScale != 1)
					Stars[i].SetDrawScale(50);
			}
		}
	}
	
	// �����������
	function bool Zoom()
	{
		local int i;
		local float scale, unScale;
		scale = 1.1;
		unscale = 262000 / scale;
		for (i = 0; i < MaxStars; i++)
		{
			if (Stars[i] != None)
			{
				if (VSize(Stars[i].Location) > unScale)
				{
					Stars[i].SetLocation((Stars[i].Location / max(max(abs(Stars[i].Location.x), abs(Stars[i].Location.y)), abs(Stars[i].Location.z))) * 262000);
				}
				else
					Stars[i].SetLocation(Stars[i].Location * scale);
			}
		}
		Resize();
		GalaxyScale *= 1.1;
		return (GalaxyScale > 8);
	}

Begin:

CheckSize:
	sleep(0.01);
	Resize();
	GoTo('CheckSize');

ZoomInto:
	if (!Zoom())
		GoTo('EndZoom');
	sleep(0.1);
	`log("+ 1 iteration");
	GoTo('ZoomInto');

EndZoom:
	`log("zummed");
	RangeScale = 0.0004;
	Resize();

EndAll:

}

function rotator UnrRot(float pitch, float yaw, float roll)
{
	local float degToRot;
	local rotator rota;
	degToRot = DegToRad * RadToUnrRot;
	rota.Pitch = pitch * degToRot;
	rota.Yaw = yaw * degToRot;
	rota.Roll = roll * degToRot;
	return rota;
}

function Gen(Pawn locPawn, int numStars)
{
	local vector posit;
	local int i;
	if (!bGenerated) {
		GetNavData(MyData, numStars);
		MyPawn = locPawn;
		bGenerated = true;
		MaxStars = numStars;
		for (i = 0; i < MaxStars; i++)
		{
			posit.x = MyData.NavigationData[i * 3] + Location.x;
			posit.y = MyData.NavigationData[i * 3 + 1] + Location.y;
			posit.z = MyData.NavigationData[i * 3 + 2] + Location.z;
			Stars[i] = (Spawn(class'City.ministar', MyPawn,, posit, rot(0, 0, 0)));
		}
	}
	else
		`log("Galaxy already generated!");
}

// ���������� ����� ������� ��������� (������ ������ ���������) (��� ��������)
function RotateGf(float Pitch, float Yaw, float Roll)
{
	// ������� ��������
	local Matr3 rotMat;
	local int i;
	local vector locVec;
	
	// ������� �������� 
	rotMat.m11 = cos(yaw) * cos(roll) - sin(pitch) * sin (yaw) * sin(roll);
	rotMat.m12 = -cos(pitch) * sin(roll);
	rotMat.m13 = sin(yaw) * cos(roll) + sin(pitch) * cos(yaw) * sin(roll);
	rotMat.m21 = cos(yaw) * sin(roll) + sin(pitch) * sin(yaw) * cos(roll);
	rotMat.m22 = cos(pitch) * cos(roll);
	rotMat.m23 = sin(yaw) * sin(roll) - sin(pitch) * cos(yaw) * cos(roll);
	rotMat.m31 = -cos(pitch) * sin(yaw);
	rotMat.m32 = sin(pitch);
	rotMat.m33 = cos(pitch) * cos(yaw);
	
	for (i = 0; i < MaxStars; i++)
	{
		locVec.x = MyData.NavigationData[i * 3];
		locVec.y = MyData.NavigationData[i * 3 + 1];
		locVec.z = MyData.NavigationData[i * 3 + 2];
		
		locVec = (locVec * rotMat) * GalaxyScale;
		
		Stars[i].SetLocation(locVec);
	}
	
	SetRotation(UnrRot(Pitch, Yaw, Roll));
	ScaleG();
}

// ���������� ����� ��������� ��������� (��� ��������)
function MoveGf(optional vector Dest = vect(0, 0, 0))
{
	/*local int i;
	local vector locVec;
	// �����
	local vector Delta;
	Delta = Location - Dest;
	for (i = 0; i < MaxStars; i++)
	{
		locVec = Stars[i].Location - Delta;
		Stars[i].SetLocation(locVec);
	}
	SetLocation(Dest);*/
}

// ���������� ����� ��������� ��������� (� ����������)
function MoveG(optional vector Dest = vect(0, 0, 0))
{

}

// ���������(���������) ������ ��������� �� ����������� �������� (�� ������ ��������� � �����) (� ����������)
function ScaleG(optional float modScale = 1.0)
{
	local int i;
	GalaxyScale *= modScale;
	for (i = 0; i < MaxStars; i++)
	{
		if (VSize(Stars[i].Location) * modScale > 262000)
		{
			Stars[i].SetLocation((Stars[i].Location / VSize(Stars[i].Location)) * 262000);
		}
		else
			Stars[i].SetLocation(Stars[i].Location * modScale);
	}
	// �������� �� MoveG
	MoveGf();
}

function RedrawGalaxy()
{
/*
	// ������� ��������
	local Matr3 rotMat;
	local int i;
	local vector locVec;
	
	// ������� �������� 
	rotMat.m11 = cos(yaw) * cos(roll) - sin(pitch) * sin (yaw) * sin(roll);
	rotMat.m12 = -cos(pitch) * sin(roll);
	rotMat.m13 = sin(yaw) * cos(roll) + sin(pitch) * cos(yaw) * sin(roll);
	rotMat.m21 = cos(yaw) * sin(roll) + sin(pitch) * sin(yaw) * cos(roll);
	rotMat.m22 = cos(pitch) * cos(roll);
	rotMat.m23 = sin(yaw) * sin(roll) - sin(pitch) * cos(yaw) * cos(roll);
	rotMat.m31 = -cos(pitch) * sin(yaw);
	rotMat.m32 = sin(pitch);
	rotMat.m33 = cos(pitch) * cos(yaw);
	
	for (i = 0; i < MaxStars; i++)
	{
		locVec.x = MyData.NavigationData[i * 3];
		locVec.y = MyData.NavigationData[i * 3 + 1];
		locVec.z = MyData.NavigationData[i * 3 + 2];
		
		if (VSize(Stars[i].Location) * GalaxyScale > 262000)
		{
			locVec = (locVec * rotMat) / VSize(Stars[i].Location) * 262000);
		}
		else
			locVec = (locVec * rotMat) * GalaxyScale);
		
		Stars[i].SetLocation(locVec);
		
	}
	
	
	for (i = 0; i < MaxStars; i++)
	{
		if (VSize(Stars[i].Location) * modScale > 262000)
		{
			Stars[i].SetLocation((Stars[i].Location / VSize(Stars[i].Location)) * 262000);
		}
		else
			Stars[i].SetLocation(Stars[i].Location * modScale);
	}
	// �������� �� MoveG
	MoveGf();*/
}

simulated function Destroyed()
{
	local int i;
	if (bGenerated)
		for (i = 0; i < MaxStars; i++)
		{
			Stars[i].Destroy();
		}
	super.Destroyed();
}

function ZoomIn()
{
	GoToState('InMenu', 'ZoomInto');
}

defaultproperties
{
	bGenerated = false
	MaxStars = 0
	RangeScale = 0.0002
	GalaxyScale = 0.1
	Cosmos = false;
}