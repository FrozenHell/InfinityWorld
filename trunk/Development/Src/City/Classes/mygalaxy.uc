class MyGalaxy extends Actor
	DLLBind(galaxy);
	
struct MyNavigationStruct
{
	var array<int> NavigationData;
};

var array<Actor> Stars;
var MyNavigationStruct MyData;
var Pawn MyPawn;
//var Actor StarMas[50];
var bool bGenerated;
var int MaxStars;

// зависимость размера звезды от расстояния
var float RangeScale;

dllimport final function GetNavData(out MyNavigationStruct NavData, int nStars);

delegate GetPlayerViewPoint( out vector out_Location, out Rotator out_Rotation );

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
	function bool zoom()
	{
		local int i;
		local float scale, unScale;
		scale = 1.1;
		unscale = 262000 / scale;
		for (i = 0; i < MaxStars; i++)
		{
			if (Stars[i] != None)
			{
				if (abs(Stars[i].Location.x) > unScale || abs(Stars[i].Location.y) > unScale || abs(Stars[i].Location.z) > unScale)
				{
					Stars[i].SetLocation((Stars[i].Location / max(max(abs(Stars[i].Location.x), abs(Stars[i].Location.y)), abs(Stars[i].Location.z))) * 262000);
				}
				else
					Stars[i].SetLocation(Stars[i].Location * scale);
			}
		}
		Resize();
		SetDrawScale(DrawScale * 1.1);
		return (DrawScale < 100);
	}

begin:

checksize:
	sleep(0.01);
	Resize();
	GoTo('checksize');

ZoomInto:
	if (!zoom())
		GoTo('EndZoom');
	sleep(0.1);
	GoTo('ZoomInto');

EndZoom:
RangeScale = 0.0004;
Resize();

EndAll:

}

function Gen(Pawn locpawn, int numStars)
{
	local vector posit;
	local int i;
	if (!bGenerated) {
		GetNavData(MyData, numStars);
		MyPawn = locpawn;
		bGenerated = true;
		MaxStars = numStars;
		for (i = 0; i < MaxStars; i++)
		{
			posit.x = MyData.NavigationData[i * 3] / 10 + Location.x;
			posit.y = MyData.NavigationData[i * 3 + 1] / 10 + Location.y;
			posit.z = MyData.NavigationData[i * 3 + 2] / 10 + Location.z;
			Stars[i] = (Spawn(class'City.ministar', MyPawn,, posit, rot(0, 0, 0)));
		}
	}
	else
		`log("Galaxy already generated!");
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
}