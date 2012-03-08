class mygalaxy extends Actor
	DLLBind(galaxy);

struct galaxy {
	var array<actor> stars;
};
	
struct MyNavigationStruct
{
	var array<int> NavigationData;
};

var galaxy Mygal;
var Pawn MyPawn;
var actor starmas[50];
var bool generated;
var int maxstars;

dllimport final function GetNavData(out MyNavigationStruct NavData, int stars);

function gen(Pawn locpawn,int nstars) {
	local MyNavigationStruct MyData;
	local vector posit;
	local int i;
	if (!generated) {
		GetNavData(MyData,nstars);
		MyPawn = locpawn;
		generated = true;
		maxstars = nstars;
		for (i=0;i<nstars;i++) {
			posit.x=MyData.NavigationData[i*3]/10+Location.x;
			posit.y=MyData.NavigationData[i*3+1]/10+Location.y;
			posit.z=MyData.NavigationData[i*3+2]/10+Location.z;
			Mygal.stars[i] = (Spawn(class'City.ministar',MyPawn,,posit,rot(0,0,0)));
		}
	} else `log("Galaxy already generated!");
}

simulated function Destroyed() {
	local int i;
	if (generated)
		for (i=0;i<maxstars;i++) {
			Mygal.stars[i].destroy();
		}
	super.Destroyed();
}

defaultproperties
{
	generated = false;
	maxstars = 0;
}