class UnPlanet extends ClickableActor;

var float Ex; // эксцентриситет
var float Rad; // параметр орбиты
var float TimeAng;
var float Mass;
var float Radius;

function initialize(int pos, float rS, float massS) // rS - радиус звезды, massS - масса звезды
{
	local int type;
	type = Rand(3)+1; // земля, гигант, нептун
	switch (type)
	{
		case 1:
			Mass = FRand()*58742+1000; //1000*10^20-7 масс земли
			Radius = (((3*Mass)/(4*3.1415*(FRand()*4+3.5)))*1000000000)**0.33333333; // ** - возведение в степень
			break;
		case 2:
			Mass = 18987000*(FRand()*12.81+0.19); //0.19-13 масс юпитера
			Radius = 71492*(FRand()*0.4+0.8); // 1-1.4
			break;
		case 3:
			Mass = (FRand()*9+7)*59742;// 7-16 масс земли
			Radius = (FRand()*1+3.5)*6378.1;// примерно 4 радиуса земли
			break;
	}
	Rad = (FRand()*0.5+1.8)*(rS/695500)*(pos*pos+8*pos+16)*0.5*(0.045*149597870); // a.e.=149598000km
	Ex = FRand()*0.295+0.005;
	timeang = sqrt((Rad**3)*5.915/((massS+Mass)*1000)); // период обращения в секундах
}

defaultProperties
{
	Begin Object Name=StaticMeshComponent
		StaticMesh=StaticMesh'Houses.Planets.Planet1'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshComponent)

	Parent_MatInst = MaterialInstanceConstant'Houses.Planets.Atmosphere1_INST'
	MatID = 0
	NormalMatInstLinearColor = (R=0.242034,G=0.190995,B=0.880435,A=1.000000)
	SelectMatInstLinearColor = (R=24.2034,G=19.0995,B=88.0435,A=1.000000)
}