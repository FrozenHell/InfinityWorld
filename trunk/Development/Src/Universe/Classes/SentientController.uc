/**
 *	SentientController
 *
 *	Creation date: 19.03.2012 16:33
 *	Copyright 2012, FrozenHell Skyline
 */
class SentientController extends GameAIController;

// ������ �� ������
var Pawn Player;

// �������� ����� ����������
var float WaitAttack;

// ����������, � �������� ����� ������������� �����
var() float AtackRange;

// ������������ ���������� �� ������� ����� ��������� �������
var const float MaxMeleeRange;

// ��� ����� (����� ������)
enum EAtackType
{
	AT_Melee,						// ������ ������� ���
	AT_RunAttack,				// ������ �� ����������� ���������� � �����
	AT_AttackRunAttack,	// ��� -> �������� -> ��� -> .. ���� �� �������� �� ����������� ����������, ����� ������� �����
	AT_AttackRunMelee,		// ��� -> �������� -> ��� -> .. ���� �� �������� � ����, ����� ������� �����
	AT_StandAttack				// ����� ���� �� ����� ������
};

// �������
enum EFraction
{
	Fr_Citizen,  // ���������
	Fr_Traveler, // ��������������
	Fr_Mercenary // ������
};

// ��� ����� �� ���������
var() EAtackType AtackType;

// -----------------����� ���������� ����������---------------------


// ��������� ��������� - ��������� �����
auto State Idle
{

Begin:
	// ��������� ������ ������
	if (Enemy == None)
	{
		Player = SearchPlayer();
		`log(SearchPlayer());
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
	ignores SeePlayer, SeeMonster, TakeDamage, HearNoise;
	
	// ���������� �������� ����� ����������
	function TimerFiring()
	{
		StopShootWeapon(0);
	}
	
Begin:
	MoveTo(Pawn.Location, Enemy, 10, true); // ���������� � ������� ������
	
GivePain:
	// ���� ����������?
	if (Enemy != none)
	{
		if (!Enemy.IsAliveAndWell())
		{
			// ���� ����
			StopShootWeapon(0); // ������ ��������
			GoToState('Idle'); // ��������� � ��������� �����
		}
	}
	else
	{
		// ���� - ������ �� ����, ��� ���-�� ����� �� ���
		StopShootWeapon(0); // ������ ��������
		GoToState('Idle'); // ��������� � ��������� �����
	}
	
	// ��������� � ����������� �� ���������� ���� �����
	switch (AtackType)
	{
		case AT_Melee:
			// ��������� � ����
			MoveToward(Enemy, Enemy, MaxMeleeRange - 50,, true);
			// ���������?
			if (VSize(Pawn.Location - Enemy.Location) < MaxMeleeRange)
			{
				// ������� ����
				ShootWeapon(0);
				// �������� ����� ��������
				SetTimer(1, false, 'TimerFiring'); // 1 - ��������
			}
			break;
		case AT_RunAttack:
			// ������ �� ���������� ����
			MoveToward(Enemy, Enemy, AtackRange - 100,, true);
			// �������� ���������� ��� ��������
			if (VSize(Pawn.Location - Enemy.Location) < AtackRange) // �������� �������� �� ��������� ������
			{
				// ������� ����
				//TakeFocus(Enemy);
				if (CanSee(Enemy))
				{
					ShootWeapon(0);
					// �������� ����� ��������
					StopShootWeapon(0);
					//SetTimer(1, false, 'TimerFiring'); // 1 - ��������
				}
			}
			break;
		case AT_AttackRunAttack:
			// �� ��������
			break;
		case AT_AttackRunMelee:
			// �� ��������
			break;
		case AT_StandAttack:
			// �� ��������
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
	local Pawn PW;
	foreach AllActors(class'Pawn', PW)
	{
		if (PW.IsPlayerPawn())
		{
			return PW;
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
function ShootWeapon(optional byte fireType = 0)
{ // fireType - ��� ����� (��� UnrealTournament ���������� ��� � ���)
	Pawn.StartFire(fireType);
}

// ���������� �����
function StopShootWeapon(optional byte fireType = 0)
{
	Pawn.StopFire(fireType);
}

defaultproperties
{
	AtackRange = 1000
	MaxMeleeRange = 100
	WaitAttack = 1
	AtackType = AT_RunAttack
	Name="AngryBotsController__"
}