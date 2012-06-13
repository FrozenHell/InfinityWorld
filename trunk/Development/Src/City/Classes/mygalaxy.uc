class mygalaxy extends Actor
	DLLBind(galaxy);
	
struct MyNavigationStruct
{
	var array<int> NavigationData;
};

var array<actor> stars;
var MyNavigationStruct MyData;
var Pawn MyPawn;
//var actor starmas[50];
var bool generated;
var int maxstars;

// зависимость размера звезды от расстояния
var float rangescale;

dllimport final function GetNavData(out MyNavigationStruct NavData, int nstars);

delegate GetPlayerViewPoint( out vector out_Location, out Rotator out_rotation );

// находимся в режиме вращения камеры
auto state InMenu {
	// изменение размера ближайших звёзд
	function resize() {
		local int i;
		local float newsize;
		local vector ViewLocation; // положение игрока
		local rotator ViewRotation; // поворот игрока
		GetPlayerViewPoint(ViewLocation,ViewRotation);
		for (i = 0; i<maxstars; i++) {
			if (stars[i] != None) {
				newsize = VSize(stars[i].Location-ViewLocation)*rangescale;
				if (newsize <= 50) stars[i].SetDrawScale(newsize);
				else if (stars[i].DrawScale != 1) stars[i].SetDrawScale(50);
			}
		}
	}
	
	// приближение
	function bool zoom() {
		local int i;
		local float scale,unscale;
		scale = 1.1;
		unscale = 262000/scale;
		for (i = 0; i<maxstars; i++) {
			if (stars[i] != None) {
				if (abs(stars[i].Location.x)>unscale || abs(stars[i].Location.y)>unscale || abs(stars[i].Location.z)>unscale) {
					stars[i].SetLocation((stars[i].Location / max(max(abs(stars[i].Location.x),abs(stars[i].Location.y)),abs(stars[i].Location.z)))*262000);
				} else stars[i].SetLocation(stars[i].Location*scale);
			}
		}
		resize();
		SetDrawScale(DrawScale*1.1);
		return (DrawScale < 100);
	}

begin:

checksize:
	sleep(0.01);
	resize();
	goto('checksize');

ZoomInto:
	if (!zoom()) goto('EndZoom');
	sleep(0.1);
	goto('ZoomInto');

EndZoom:
rangescale = 0.0004;
resize();

EndAll:

}

function gen(Pawn locpawn,int nstars) {
	local vector posit;
	local int i;
	if (!generated) {
		GetNavData(MyData,nstars);
		MyPawn = locpawn;
		generated = true;
		maxstars = nstars;
		for (i=0;i<maxstars;i++) {
			posit.x=MyData.NavigationData[i*3]/10+Location.x;
			posit.y=MyData.NavigationData[i*3+1]/10+Location.y;
			posit.z=MyData.NavigationData[i*3+2]/10+Location.z;
			stars[i] = (Spawn(class'City.ministar',MyPawn,,posit,rot(0,0,0)));
		}
	} else `log("Galaxy already generated!");
}

simulated function Destroyed() {
	local int i;
	if (generated)
		for (i=0;i<maxstars;i++) {
			stars[i].destroy();
		}
	super.Destroyed();
}

function ZoomIn() {
	GoToState('InMenu','ZoomInto');
}

defaultproperties
{
	generated = false
	maxstars = 0
	rangescale = 0.0002
}