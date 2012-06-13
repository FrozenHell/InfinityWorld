class PlanetSystem extends Actor;

// массив планет
var array<UnPlanet> mass;

// звезда (или связанные звёзды)
var System_Star star;

// время
var float obstime;

var bool bHaveAtmosphere;

state drawing {

Begin:
	redrawall();
	obstime+=0.001;
	Sleep(0.01);
	GoTo('Begin');
}

function generate(Pawn locpawn,int seed) {
	local int i;
	local actor locstar;
	locstar = Spawn(class'City.System_Star',locpawn,,Location);
	star = System_Star(locstar);
	star.initialize();
	star.SetDrawScale(star.rad/5000);
	for (i = 0;i<4;i++) {
		mass[i] = genplanet(locpawn,seed+i,i);
	}
	gotostate('drawing');
}

function UnPlanet genplanet(Pawn locpawn,int seed,int posit) {
	local actor locPlanet;
	locPlanet = Spawn(class'City.UnPlanet',locpawn,,Location);
	UnPlanet(locPlanet).initialize(posit,star.Rad,star.Mass);
	redraw(UnPlanet(locPlanet));
	locPlanet.SetDrawScale(UnPlanet(locPlanet).radius/7000);
	return UnPlanet(locPlanet);
}

function redrawall() {
	local int i;
	for (i = 0;i<4;i++) {
		redraw(mass[i]);
	}
}

function redraw(UnPlanet locPlanet) {
	local float rad,ex,f,ro,timeang;
	local vector locpos;
	rad = locPlanet.rad;
	timeang = locPlanet.timeang;
	ex = locPlanet.ex;
	f = obstime*1000*2*3.1415/timeang;
	ro=rad/(1-ex*cos(f));
	locpos.x=(((2*ex*rad)/(1-ex*ex))-(ro*cos(f)));
	locpos.y=(ro*sin(f));
	locpos/=7000;
	locPlanet.SetLocation(Location+locpos);
}

defaultProperties
{
	obstime = 10000000.0
}