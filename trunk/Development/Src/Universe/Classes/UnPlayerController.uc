/**
 *	UnPlayerController
 *
 *	Creation date: 03.01.2012 18:08
 *	Copyright 2012, FrozenHell Skyline
 */
class UnPlayerController extends UTPlayerController;

var MyGalaxy Galaxy;
var MyHouse House;
var bool bGalaxyGenerated, bHouseGenerated;

exec function rotator UnrRot(float pitch, float yaw, float roll)
{
	local rotator rota;
	local float degToRot;
	degToRot = DegToRad * RadToUnrRot;
	rota.Pitch = pitch * degToRot;
	rota.Yaw = yaw * degToRot;
	rota.Roll = roll * degToRot;
	return rota;
}

exec function vector Vec(int x, int y, int z)
{
	local vector ve;
	ve.X = x;
	ve.Y = y;
	ve.Z = z;
	return ve;
}

exec function drawgalaxy(optional int numStars = 1000)
{
	if (!bGalaxyGenerated)
	{
		galaxy = Spawn(class'City.mygalaxy', UnPawn(Owner),, vect(500, 0, 1000), rot(0, 0, 0));
		galaxy.GetPlayerViewPoint = GetPlayerViewPoint;
		bGalaxyGenerated = true;
		galaxy.gen(UnPawn(Owner), numStars);
		say("Generated"@numStars@"stars");
	}
}

exec function rotateGalax(float Pitch, float Yaw, float Roll)
{
	//galaxy.RotateGf(Pitch, Yaw, Roll);
}

exec function cleargalaxy()
{
	if (bGalaxyGenerated)
	{
		galaxy.destroy();
		bGalaxyGenerated = false;
	}
}

exec function drawhouse(optional int seed = 0)
{
	if (!bHouseGenerated)
	{
		House = Spawn(class'City.myhouse', UnPawn(Owner),, vect(0, -100, -40),rot(0, 0, 0));
		House.GetPlayerViewPoint = GetPlayerViewPoint;
		House.gen2(UnPawn(Owner), 4, 4, 4, seed + 1);
		bHouseGenerated = true;
	}
}

exec function genmorehouses()
{
	local int i, j;
	local MyHouse how;
	for (i = 0; i < 4; i++)
	{
		for (j = 0; j < 4; j++)
		{
			how = Spawn(class'City.myhouse', UnPawn(Owner),, vec(i * 5000, j * 5000, -40), UnrRot(0, 0, 0));
			how.GetPlayerViewPoint = GetPlayerViewPoint;
			how.gen2(UnPawn(Owner), 5, 5, 10, i + j);
		}
	}
}

exec function clearhouse()
{
	if (bHouseGenerated)
	{
		house.destroy();
		bHouseGenerated = false;
		say("Clearing House");
	}
}

exec function gen_ps()
{
	local PlanetSystem PS1;
	PS1 = Spawn(class'City.PlanetSystem', UnPawn(Owner),, vec(50, 30, 300), UnrRot(0, 0, 0));
	PS1.generate(UnPawn(Owner), 1);
}

// нажали клавишу "Использовать"
exec function use_actor()
{
	local Actor hitActor;
	local vector hitNormal, hitLocation;
	local vector viewLocation;
	local rotator viewRotation;
	// расстояние на котором можем использовать объекты
	local float maxRange;
	maxRange = 100;
	GetPlayerViewPoint(viewLocation, viewRotation);
	HitActor = Trace(hitLocation, hitNormal, viewLocation + maxRange * vector(viewRotation), viewLocation, true);

	// если мы нажали на актёра, который можно использовать
	if (Useable(HitActor) != None)
	{
		// использовать
		Useable(HitActor).Use(Pawn);
	}
}

defaultproperties
{
	Name="Default__UnPlayerController"
	bGalaxyGenerated = false
	bHouseGenerated = false
}
