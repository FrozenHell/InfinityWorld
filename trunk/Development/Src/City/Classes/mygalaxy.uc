class mygalaxy extends Actor
	DLLBind(galaxy);
	
struct MyNavigationStruct
{
	var array<int> NavigationData;
};

var array<actor> stars;
var Pawn MyPawn;
//var actor starmas[50];
var bool generated;
var int maxstars;

dllimport final function GetNavData(out MyNavigationStruct NavData, int nstars);

delegate GetPlayerViewPoint( out vector out_Location, out Rotator out_rotation );

auto state minimize {
	function mini() {
		local int i;
		local float newsize;
		local vector ViewLocation; // положение игрока
		local rotator ViewRotation; // поворот игрока
		GetPlayerViewPoint(ViewLocation,ViewRotation);
		for (i = 0; i<maxstars; i++) {
			newsize = VSize(stars[i].Location-ViewLocation)*0.001;
			if (newsize <= 1.0) stars[i].SetDrawScale(newsize);
			else if (stars[i].DrawScale != 1) stars[i].SetDrawScale(1.0);
		}
	}

begin:
	sleep(0.05);
	mini();
	goto('begin');

}

function gen(Pawn locpawn,int nstars) {
	local MyNavigationStruct MyData;
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

defaultproperties
{
	generated = false;
	maxstars = 0;
}