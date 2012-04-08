/**
 *	UnPlayerController
 *
 *	Creation date: 03.01.2012 18:08
 *	Copyright 2012, FrozenHell Skyline
 */
class UnPlayerController extends UTPlayerController;

var mygalaxy galaxy;
var myhouse house;
var bool generated,generatedh;

exec function rotator UnrRot(float Pitch,float Yaw,float Roll) {
	local rotator Rota;
	local float DegToRot;
	DegToRot = DegToRad*RadToUnrRot;
	Rota.Pitch = Pitch*DegToRot;
	Rota.Yaw = Yaw*DegToRot;
	Rota.Roll = Roll*DegToRot;
	return Rota;
}

exec function vector vec(int x,int y,int z) {
	local vector ve;
	ve.x=x;
	ve.y=y;
	ve.z=z;
	return ve;
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
		house = Spawn(class'City.myhouse',UnPawn(Owner),,vect(0,-100,-40),rot(0,0,0));
		house.GetPlayerViewPoint = GetPlayerViewPoint;
		house.gen2(UnPawn(Owner),4,4,4,seed+1);
		`log("finish");
		generatedh = true;
	}
}

exec function genmorehouses() {
	local int i,j;
	local myhouse how;
	for (i=0;i<4;i++) {
		for (j=0;j<4;j++) {
			how = Spawn(class'City.myhouse',UnPawn(Owner),,vec(i*5000,j*5000,-40),UnrRot(0,0,0));
			how.GetPlayerViewPoint = GetPlayerViewPoint;
			how.gen2(UnPawn(Owner),5,5,10,i+j);
		}
	}
}

exec function clearhouse() {
	if (generatedh) {
		house.destroy();
		generatedh = false;
		say("Clearing House");
	}
}

// нажали клавишу "Использовать"
exec function use_actor() {
	local Actor HitActor;
	local vector HitNormal, HitLocation;
	local vector ViewLocation;
	local rotator ViewRotation;
	GetPlayerViewPoint( ViewLocation, ViewRotation );
	HitActor = Trace(HitLocation, HitNormal, ViewLocation + 100 * vector(ViewRotation), ViewLocation, true);
	if (HitActor!=None) {
		if (HitActor.IsA('UsableActor')) {
			UsableActor(HitActor).Use(Pawn);
		} else if (HitActor.IsA('SpeakingPawn')) {
			SpeakingPawn(HitActor).Talk(Pawn);
		}
	}
}

defaultproperties
{
	Name="Default__UnPlayerController"
	generated = false
	generatedh = false
}
