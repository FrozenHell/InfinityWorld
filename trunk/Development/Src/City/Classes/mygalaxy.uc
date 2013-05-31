/*
*	Создаём модель галактики для карты галактики.
*	Location галактики - это её фокус (в случае нахождения в космосе, фокус должен быть в центре координат)
* Реальный же центр галактики находится в точке (GalaxyCenter - Location)
*/
class MyGalaxy extends Actor
	DLLBind(galaxy);

struct NaviStruct
{
	var array<int> NaviData;
};

// матрица 3х3
struct Matr3
{
	var float m11, m12, m13, m21, m22, m23, m31, m32, m33;
};

// максимальная координата (на самом деле, чуть меньше максимальной)
const WorldSize = 262000;

// в космосе ли мы находимся
var bool bCosmos; // если false то мы находимся в галографической модели
// звёзды
var array<MiniStar> Stars;
// структура, получаемая из DLL
var NaviStruct MyData;
// игрок (нужно для реализации некоторых стандартных функций)
var protected Pawn MyPawn;
// сгенерирована ли галактика
var bool bGenerated;
// количество звёзд
var int MaxStars;
// масштаб
var float GalaxyScale;
// положение центра галактики относительно фокуса
var vector GalaxyCenter;
// повороты в градусах
var float fPitch, fYaw, fRoll;

// индекс звезды, на которой мы сфокусировались
var int FocusIndex;

// зависимость размера звезды от расстояния
var float RangeScale;

dllimport final function GetNavData(out NaviStruct NavData, int nStars);

delegate GetPlayerViewPoint(out vector out_Location, out rotator out_Rotation);

// умножение вектора на матрицу
final operator(16) vector * (vector A, Matr3 B)
{
	local vector localVector;
	localVector.x = (B.m11 * A.x + B.m21 * A.y + B.m31 * A.z);
	localVector.y = (B.m12 * A.x + B.m22 * A.y + B.m32 * A.z);
	localVector.z = (B.m13 * A.x + B.m23 * A.y + B.m33 * A.z);
	return localVector;
}

// находимся в режиме вращения камеры
auto state InMenu
{
	// изменение размера ближайших звёзд
	function Resize()
	{
		local int i;
		local float newSize;
		local vector viewLocation; // положение игрока
		local rotator viewRotation; // поворот игрока
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

	// приближение
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

	// для отладки
	GoTo('CheckSize');

EndAll:

}

// создать ротатор, основываясь на поворотах в градусах
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

// сгенерировать галактику
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

// установить новый поворот галактики
function RotateG(float pitch, float yaw, float roll)
{
	fPitch = pitch;
	fYaw = yaw;
	fRoll = roll;
	RedrawGalaxy();
}

// установить новое положение галактики
function MoveG(vector Dest)
{
	GalaxyCenter = Dest;
	RedrawGalaxy();
}

// увеличить(уменьшить) размер галактики на определённую величину (из центра координат в сферу)
function ScaleG(float modScale)
{
	GalaxyScale *= modScale;
	RedrawGalaxy();
}

// установить центром модели звезду
function NewFocus(MiniStar localStar)
{
	GalaxyCenter.x = - MyData.NaviData[localStar.Index * 3];
	GalaxyCenter.y = - MyData.NaviData[localStar.Index * 3 + 1];
	GalaxyCenter.z = - MyData.NaviData[localStar.Index * 3 + 2];

	RedrawGalaxy();
}

// полная перерисовка галактики
function RedrawGalaxy()
{
	// матрица вращения
	local Matr3 rotMat;
	local int i;
	local vector locVec;

	// заполнение матрицы вращения
	rotMat.m11 = cos(fYaw) * cos(fRoll) - sin(fPitch) * sin (fYaw) * sin(fRoll);
	rotMat.m12 = -cos(fPitch) * sin(fRoll);
	rotMat.m13 = sin(fYaw) * cos(fRoll) + sin(fPitch) * cos(fYaw) * sin(fRoll);
	rotMat.m21 = cos(fYaw) * sin(fRoll) + sin(fPitch) * sin(fYaw) * cos(fRoll);
	rotMat.m22 = cos(fPitch) * cos(fRoll);
	rotMat.m23 = sin(fYaw) * sin(fRoll) - sin(fPitch) * cos(fYaw) * cos(fRoll);
	rotMat.m31 = -cos(fPitch) * sin(fYaw);
	rotMat.m32 = sin(fPitch);
	rotMat.m33 = cos(fPitch) * cos(fYaw);

	// для каждой звезды
	for (i = 0; i < MaxStars; i++)
	{
		// берём реальные координаты
		locVec.x = MyData.NaviData[i * 3];
		locVec.y = MyData.NaviData[i * 3 + 1];
		locVec.z = MyData.NaviData[i * 3 + 2];

		// двигаем
		locVec += Location + GalaxyCenter;

		// масштабируем
		if (bCosmos) // если мы в космосе, масштабируем из центра координат
		{
			if (VSize(locVec) * GalaxyScale > WorldSize)
			{
				locVec = (locVec / VSize(locVec)) * WorldSize;
			}
			else
				locVec *= GalaxyScale;
		}
		else // если это модель, масштабируем из центра модели
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


		// поворачиваем
		if (Stars[i] != None)
			Stars[i].SetLocation(locVec * rotMat);
	}
}

// уничтожение галактики
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

// приблизить до звезды
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