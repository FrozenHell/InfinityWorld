class PlanetSystem extends Actor;

// массив планет
var array<UnPlanet> Mass;

// звезда (или связанные звёзды)
var System_Star Star;

// время
var float FloatTime;

var bool bHaveAtmosphere;

state Drawing
{

Begin:
	redrawall();
	FloatTime += 0.001;
	Sleep(0.01);
	GoTo('Begin');
}

function generate(Pawn localPawn, int seed)
{
	local int i;
	local actor localStar;
	localStar = Spawn(class'City.System_Star', localPawn,, Location);
	Star = System_Star(localStar);
	Star.initialize();
	Star.SetDrawScale(Star.Rad / 5000);
	for (i = 0; i < 4; i++)
	{
		Mass[i] = genplanet(localPawn, seed + i, i);
	}
	gotostate('Drawing');
}

function UnPlanet genplanet(Pawn localPawn,int seed,int posit) {
	local actor locPlanet;
	locPlanet = Spawn(class'City.UnPlanet',localPawn,,Location);
	UnPlanet(locPlanet).initialize(posit,Star.Rad,Star.Mass);
	redraw(UnPlanet(locPlanet));
	locPlanet.SetDrawScale(UnPlanet(locPlanet).radius/7000);
	return UnPlanet(locPlanet);
}

function redrawall() {
	local int i;
	for (i = 0;i<4;i++) {
		redraw(Mass[i]);
	}
}

function redraw(UnPlanet locPlanet) {
	local float rad,ex,f,ro,timeang;
	local vector locpos;
	rad = locPlanet.rad;
	timeang = locPlanet.timeang;
	ex = locPlanet.ex;
	f = FloatTime*1000*2*3.1415/timeang;
	ro=rad/(1-ex*cos(f));
	locpos.x=(((2*ex*rad)/(1-ex*ex))-(ro*cos(f)));
	locpos.y=(ro*sin(f));
	locpos/=7000;
	locPlanet.SetLocation(Location+locpos);
}

defaultProperties
{
	FloatTime = 10000000.0
}