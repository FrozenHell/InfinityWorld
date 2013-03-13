/**
 *	HunterController
 *
 *	Creation date: 17.02.2013 12:33
 *	Copyright 2013, FHS
 */
class HunterController extends BotController;

// бот видит игрока
event SeePlayer(Pawn Seen)
{
	// ничего не делаем
}

// бот слышит шум
event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	// ничего не делаем
}

// бот получает повреждения
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// ничего не делаем
}

function StopPlayerHunt()
{
	local UnPlayerController playerContr;
	
	foreach AllActors(class'UnPlayerController', playerContr)
	{
		playerContr.BotPrayWin();
	}
}
/*
auto state PrayWalk
{
Begin:
	// бежим к высокой точке
	GoToPoint(vect(0, 0, 10000));
}

state Wait
{
BEGIN:
	// дошли до финиша, говорим об этом
	StopPlayerHunt();
}*/

defaultproperties
{

}
