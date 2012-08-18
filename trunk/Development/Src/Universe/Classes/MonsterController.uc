/**
 *	MonsterController
 *
 *	Creation date: 19.03.2012 16:33
 *	Copyright 2012, FrozenHell Skyline
 */
class MonsterController extends GameAIController;

// ������ �� ������
var Pawn Player;

// �������� ����� ����������
var float WaitAttack;

// ����������, � �������� ����� ������������� �����
var() float AtackRange;

// ������������ ���������� �� ������� ����� ��������� �������
var const float MaxMeleeRange;

// ��� ����� (�������� ��� ������)
enum EBotAtackType
{
	BAT_Melee,						// ������ ������� ���
	BAT_RunAttack,				// ������ �� ����������� ���������� � �����
	BAT_AttackRunAttack,	// ��� -> �������� -> ��� -> .. ���� �� �������� �� ����������� ����������, ����� ������� �����
	BAT_AttackRunMelee,		// ��� -> �������� -> ��� -> .. ���� �� �������� � ����, ����� ������� �����
	BAT_StandAttack				// ����� ���� �� ����� ������
};

// �������������
var	float Aggressiveness;

var() EBotAtackType AtackType;

// -----------------����� ���������� ����������---------------------


// ��������� ��������� - ��������� �����
auto State Idle
{

Begin:
	// ��������� ������ ������
	if (Enemy == None)
	{
		Player = SearchPlayer();
		SetEnemy(Player);
		StartEnemyAtack();
	}
	else if (Enemy == SearchPlayer())
	{
		StartEnemyAtack();
	}
	Sleep(5);
	GoTo 'Begin';
}

// ��������� �����
State Atack
{
	ignores SeePlayer,SeeMonster,TakeDamage,HearNoise;
	
	// ���������� �������� ����� ����������
	function TimerFiring()
	{
		StopShootWeapon(0);
	}
	
Begin:
	MoveTo(Pawn.Location, Enemy, 10, true); // ���������� � ������� ������
	
GivePain:
	// ���� ����������?
	if (Enemy!=none)
	{
		if (!Enemy.IsAliveAndWell())
		{
			// ���� ����
			StopShootWeapon(0); // ������ ��������
			GotoState('Idle'); // ��������� � ��������� �����
		}
	} else {
		// ���� - ������ �� ����, ��� ���-�� ����� �� ���
		StopShootWeapon(0); // ������ ��������
		GotoState('Idle'); // ��������� � ��������� �����
	}
	
	// ��������� � ����������� �� ���������� ���� �����
	switch (AtackType)
	{
		case BAT_Melee:
			// ��������� � ����
			MoveToward(Enemy, Enemy, MaxMeleeRange-50,, true);
			// ���������?
			if (VSize(Pawn.Location - Enemy.Location)<MaxMeleeRange)
			{
				// ������� ����
				ShootWeapon(0);
				// �������� ����� ��������
				SetTimer(1,false,'TimerFiring'); // 1 - ��������
			}
			break;
		case BAT_RunAttack:
			// ������ �� ���������� ����
			MoveToward(Enemy, Enemy, AtackRange-100,, true);
			// �������� ���������� ��� ��������
			if (VSize(Pawn.Location - Enemy.Location)<AtackRange)
			{ // �������� �������� �� ��������� ������
				// ������� ����
				TakeFocus(Enemy);
				ShootWeapon(0);
				// �������� ����� ��������
				StopShootWeapon(0);
				//SetTimer(1,false,'TimerFiring'); // 1 - ��������
			}
			break;
		case BAT_AttackRunAttack:
			
			break;
		case BAT_AttackRunMelee:
			
			break;
		case BAT_StandAttack:
			
			break;
	}
	sleep(WaitAttack);
	Goto 'GivePain';
}

// ------------------����� ���������----------------------


// ������������� �����������
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

// ��� ������ ���
event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	//StartEnemyAtack();
}

// ��� ����� ������
event SeePlayer(Pawn seen)
{
	// ���� ����� - ����
	if (seen == Enemy)
	{
		StartEnemyAtack();
	}
}

// ����� ������
function Pawn SearchPlayer()
{
	local Pawn localPawn;
	foreach AllActors(class'Pawn', localPawn)
	{
		if (localPawn.IsPlayerPawn())
		{
			return localPawn;
		}
	}
	return None; // ����� �� ������
}

// ���������� ���� �����
function SetEnemy(Pawn P)
{
	if (Enemy == None || Enemy != P)
	{
		Enemy = P;
	}
}

// ������������
function TakeFocus(Pawn P)
{
	Pawn.SetViewRotation(rotator(P.Location - Pawn.Location));
}

// ����� �����
function StartEnemyAtack()
{
	//`log(name@"StartAtack()");
	// ���������
	GoToState('Atack');
}

// ����������� �����
function StopEnemyAtack()
{
	GoToState('Idle');
}

// ���������� �� ������ (��� ������� ������� ����)
function ShootWeapon(optional byte FireType = 0) // FireType - ��� ����� (��� UnrealTournament ���������� ��� � ���)
{
	Pawn.StartFire(FireType);
}

// ���������� �����
function StopShootWeapon(optional byte FireType = 0)
{
	Pawn.StopFire(FireType);
}

defaultproperties
{
	AtackRange = 1000
	MaxMeleeRange = 100
	WaitAttack = 1
	AtackType = BAT_Melee
	Name="AngryBotsController__"
}