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

exec function message (String caption, String text, optional int type = 0) {
	local messages mess;
	local int a;
	mess = new class'Base.Messages';
	switch (type) {
		case 0:
			a = mess.MessBoxOK(caption,text);
			break;
		case 1:
			a = mess.MessBoxYESNO(caption,text);
			break;
		case 2:
			a = mess.MessBoxYESNOCANCEL(caption,text);
			break;
		case 3:
			a = mess.MessBoxABORTRETRYIGNORE(caption,text);
			break;
		default:
			break;
	}
	switch (a) {
		case 1:
			say("Ok");
			break;
		case 2:
			say("Cancel");
			break;
		case 3:
			say("Abort");
			break;
		case 4:
			say("Retry");
			break;
		case 5:
			say("Ignore");
			break;
		case 6:
			say("Yes");
			break;
		case 7:
			say("No");
			break;
		default:
			say("Message return code"@a);
			break;
	}
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

function vector newvect(int x,int y, int z) {
	local vector vec;
	vec.x=x;
	vec.y=y;
	vec.z=z;
	return vec;
}

exec function drawhouse(optional int seed = 0,optional float angle=0,optional int posx = 0) {
	`log("start");
	house = Spawn(class'City.myhouse',UnPawn(Owner),,newvect(posx*100,0,-40),UnrRot(0,0,angle));
	house.gen(UnPawn(Owner),4,4,4,seed+1);
	`log("finish");
}

exec function drawhouse2(optional int seed = 0,optional float angle=0,optional int posx = 0) {
	`log("start");
	house = Spawn(class'City.myhouse',UnPawn(Owner),,newvect(posx*100,0,-40),UnrRot(0,0,angle));
	house.gen2(UnPawn(Owner),4,4,4,seed+1);
	`log("finish");
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
