/**
 *	HunterController
 *
 *	Creation date: 17.02.2013 12:33
 *	Copyright 2013, FHS
 */
class HunterController extends BotController;

// ��� ����� ������
event SeePlayer(Pawn Seen)
{
	// ������ �� ������
}

// ��� ������ ���
event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	// ������ �� ������
}

// ��� �������� �����������
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// ������ �� ������
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
	// ����� � ������� �����
	GoToPoint(vect(0, 0, 10000));
}

state Wait
{
BEGIN:
	// ����� �� ������, ������� �� ����
	StopPlayerHunt();
}*/

defaultproperties
{

}
