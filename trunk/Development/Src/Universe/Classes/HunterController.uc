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

defaultproperties
{

}
