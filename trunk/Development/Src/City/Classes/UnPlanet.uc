class UnPlanet extends Actor;

var float ex;
var float rad;
var float timeang;
var float mass;
var float radius;

function initialize(int pos, float rS, float massS) { // rS - радиус звезды
	local int type;
	type = Rand(3)+1; // земля, гигант, нептун
	switch (type) {
		case 1:
			mass = FRand()*58742+1000; //1000*10^20-7 масс земли
			radius = (((3*mass)/(4*3.1415*(FRand()*4+3.5)))*1000000000)**0.33333333; // ** - возведение в степень
			break;
		case 2:
			mass = 18987000*(FRand()*12.81+0.19); //0.19-13 масс юпитера
			radius = 71492*(FRand()*0.4+0.8); // 1-1.4
			break;
		case 3:
			mass = (FRand()*9+7)*59742;// 7-16 масс земли
			radius = (FRand()*1+3.5)*6378.1;// примерно 4 радиуса земли
			break;
	}
	rad = (FRand()*0.5+1.8)*(rS/695500)*(pos*pos+8*pos+16)*0.5*(0.045*149597870); // a.e.=149598000km
	ex = FRand()*0.295+0.005;
	timeang = sqrt((rad**3)*5.915/((massS+mass)*1000)); // период обращения в секундах
}

defaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
		StaticMesh=StaticMesh'Houses.Planets.Planet2'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshCompopo)
	bHidden = False
	bCollideActors = True
	bBlockActors = True
	bStatic = False
	bMovable = True
}