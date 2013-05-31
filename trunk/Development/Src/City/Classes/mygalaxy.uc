/*
*	������ ������ ��������� ��� ����� ���������.
*	Location ��������� - ��� � ����� (� ������ ���������� � �������, ����� ������ ���� � ������ ���������)
* �������� �� ����� ��������� ��������� � ����� (GalaxyCenter - Location)
*/
class MyGalaxy extends Actor
	DLLBind(galaxy);

struct NaviStruct
{
	var array<int> NaviData;
};

// ������� 3�3
struct Matr3
{
	var float m11, m12, m13, m21, m22, m23, m31, m32, m33;
};

// ������������ ���������� (�� ����� ����, ���� ������ ������������)
const WorldSize = 262000;

// � ������� �� �� ���������
var bool bCosmos; // ���� false �� �� ��������� � ��������������� ������
// �����
var array<MiniStar> Stars;
// ���������, ���������� �� DLL
var NaviStruct MyData;
// ����� (����� ��� ���������� ��������� ����������� �������)
var protected Pawn MyPawn;
// ������������� �� ���������
var bool bGenerated;
// ���������� ����
var int MaxStars;
// �������
var float GalaxyScale;
// ��������� ������ ��������� ������������ ������
var vector GalaxyCenter;
// �������� � ��������
var float fPitch, fYaw, fRoll;

// ������ ������, �� ������� �� ���������������
var int FocusIndex;

// ����������� ������� ������ �� ����������
var float RangeScale;

dllimport final function GetNavData(out NaviStruct NavData, int nStars);

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
		unscale = WorldSize / scale;
		for (i = 0; i < MaxStars; i++)
		{
			if (Stars[i] != None)
			{
				if (VSize(Stars[i].Location) > unScale)
				{
					Stars[i].SetLocation((Stars[i].Location / VSize(Stars[i].Location)) * WorldSize);
				}
				else
					Stars[i].SetLocation(Stars[i].Location * scale);
			}
		}
		Resize();
		GalaxyScale *= 1.1;
		return (GalaxyScale < 10);
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

	// ��� �������
	GoTo('CheckSize');

EndAll:

}

// ������� �������, ����������� �� ��������� � ��������
final function rotator UnrRot(float pitch, float yaw, float roll)
{
	local float degToRot;
	local rotator rota;
	degToRot = DegToRad * RadToUnrRot;
	rota.Pitch = pitch * degToRot;
	rota.Yaw = yaw * degToRot;
	rota.Roll = roll * degToRot;
	return rota;
}

// ������������� ���������
function Gen(Pawn locPawn, int numStars)
{
	local int i;
	if (!bGenerated)
	{
		GetNavData(MyData, numStars);
		MyPawn = locPawn;
		bGenerated = true;
		MaxStars = numStars;
		for (i = 0; i < MaxStars; i++)
		{
			Stars[i] = (Spawn(class'City.ministar', MyPawn,, Location, rot(0, 0, 0)));
			Stars[i].Index = i;
		}
	}
	else
		`log("Galaxy already generated!");

	GalaxyCenter = vect(0, 0, 0);

	RedrawGalaxy();
}

// ���������� ����� ������� ���������
function RotateG(float pitch, float yaw, float roll)
{
	fPitch = pitch;
	fYaw = yaw;
	fRoll = roll;
	RedrawGalaxy();
}

// ���������� ����� ��������� ���������
function MoveG(vector Dest)
{
	GalaxyCenter = Dest;
	RedrawGalaxy();
}

// ���������(���������) ������ ��������� �� ����������� �������� (�� ������ ��������� � �����)
function ScaleG(float modScale)
{
	GalaxyScale *= modScale;
	RedrawGalaxy();
}

// ���������� ������� ������ ������
function NewFocus(MiniStar localStar)
{
	GalaxyCenter.x = - MyData.NaviData[localStar.Index * 3];
	GalaxyCenter.y = - MyData.NaviData[localStar.Index * 3 + 1];
	GalaxyCenter.z = - MyData.NaviData[localStar.Index * 3 + 2];

	RedrawGalaxy();
}

// ������ ����������� ���������
function RedrawGalaxy()
{
	// ������� ��������
	local Matr3 rotMat;
	local int i;
	local vector locVec;

	// ���������� ������� ��������
	rotMat.m11 = cos(fYaw) * cos(fRoll) - sin(fPitch) * sin (fYaw) * sin(fRoll);
	rotMat.m12 = -cos(fPitch) * sin(fRoll);
	rotMat.m13 = sin(fYaw) * cos(fRoll) + sin(fPitch) * cos(fYaw) * sin(fRoll);
	rotMat.m21 = cos(fYaw) * sin(fRoll) + sin(fPitch) * sin(fYaw) * cos(fRoll);
	rotMat.m22 = cos(fPitch) * cos(fRoll);
	rotMat.m23 = sin(fYaw) * sin(fRoll) - sin(fPitch) * cos(fYaw) * cos(fRoll);
	rotMat.m31 = -cos(fPitch) * sin(fYaw);
	rotMat.m32 = sin(fPitch);
	rotMat.m33 = cos(fPitch) * cos(fYaw);

	// ��� ������ ������
	for (i = 0; i < MaxStars; i++)
	{
		// ���� �������� ����������
		locVec.x = MyData.NaviData[i * 3];
		locVec.y = MyData.NaviData[i * 3 + 1];
		locVec.z = MyData.NaviData[i * 3 + 2];

		// �������
		locVec += Location + GalaxyCenter;

		// ������������
		if (bCosmos) // ���� �� � �������, ������������ �� ������ ���������
		{
			if (VSize(locVec) * GalaxyScale > WorldSize)
			{
				locVec = (locVec / VSize(locVec)) * WorldSize;
			}
			else
				locVec *= GalaxyScale;
		}
		else // ���� ��� ������, ������������ �� ������ ������
		{
			if (VSize(locVec) * GalaxyScale > WorldSize)
			{
				if (Stars[i] != None)
				{
					Stars[i].Destroy();
					Stars[i] = None;
				}
			}
			else
			{
				if (Stars[i] == None)
				{
					Stars[i] = (Spawn(class'City.ministar', MyPawn,, locVec, rot(0, 0, 0)));
					Stars[i].Index = i;
				}
				locVec *= GalaxyScale;
			}
		}


		// ������������
		if (Stars[i] != None)
			Stars[i].SetLocation(locVec * rotMat);
	}
}

// ����������� ���������
simulated function Destroyed()
{
	local int i;
	if (bGenerated)
		for (i = 0; i < MaxStars; i++)
		{
			Stars[i].Destroy();
		}
	Super.Destroyed();
}

// ���������� �� ������
function ZoomIn()
{
	RedrawGalaxy();
	GoToState('InMenu', 'ZoomInto');
}

defaultproperties
{
	bGenerated = false
	MaxStars = 0
	RangeScale = 0.0002
	GalaxyScale = 0.1
	bCosmos = false;
	FocusIndex = -1;
}