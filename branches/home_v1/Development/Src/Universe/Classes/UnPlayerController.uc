class UnPlayerController extends UTPlayerController;

var mygalaxy galaxy;
var myhouse house;
var bool generated,generatedh;

exec function rotator UnrRot(float Pitch,float Roll,float Yaw) {
	local rotator Rota;
	local float DegToRot;
	DegToRot = DegToRad*RadToUnrRot;
	Rota.Pitch = Pitch*DegToRot;
	Rota.Roll = Roll*DegToRot;
	Rota.Yaw = Yaw*DegToRot;
	return Rota;
}

exec function drawgalaxy(optional int numst = 1000) {
	if (!generated) {
		galaxy = Spawn(class'City.mygalaxy',UnPawn(Owner),,vect(500,0,2000),rot(0,0,0));
		generated = true;
		say("Generated"@numst@"stars");
	}
	galaxy.gen(UnPawn(Owner),numst);
}

exec function cleargalaxy() {
	if (generated) {
		galaxy.destroy();
		generated = false;
		say("Clearing Galaxy");
	}
}

exec function drawhouse(optional int seed = 0) {
	if (!generatedh) {
		`log("start");
		house = Spawn(class'City.myhouse',UnPawn(Owner),,vect(0,-100,-40),UnrRot(0,0,0));
		house.GetPlayerViewPoint = GetPlayerViewPoint;
		house.gen2(UnPawn(Owner),4,4,4,seed+1);
		`log("finish");
		generatedh = true;
	}
}

exec function cosin() {
	`log(cos(PI));
}

exec function clearhouse() {
	if (generatedh) {
		house.destroy();
		generatedh = false;
		say("Clearing House");
	}
}

defaultproperties
{
        Name="Default__UnPlayerController"
	generated = false
	generatedh = false
}
