/**
 *	MonsterController
 *
 *	Creation date: 19.03.2012 16:33
 *	Copyright 2012, FrozenHell Skyline
 */
class MonsterController extends GameAIController;

// ссылка на игрока
var Pawn Player;

// задержка между выстрелами
var float WaitAttack;

// расстояние, с которого будет производиться атака
var() float AtackRange;

// максимальное расстояние на котором атака считается ближней
var const float MaxMeleeRange;

// тип атаки (изменить или убрать)
enum BotAtackType {
	ATT_Melee,						// только ближний бой
	ATT_RunAttack,				// подбег на определённой расстояние и атака
	ATT_AttackRunAttack,	// бег -> стрельба -> бег -> .. пока не подбежит на определённое расстояние, затем обычная атака
	ATT_AttackRunMelee,		// бег -> стрельба -> бег -> .. пока не подбежит в упор, затем ближняя атака
	ATT_StandAttack				// атака стоя на месте спауна
};

// агрессивность
var	float Aggressiveness;

var() BotAtackType AtackType;

// -----------------конец объявления переменных---------------------


// начальное состояние - состояние покоя
auto State Idle {

Begin:
	// назначаем врагом игрока
	if (Enemy == None) {
		Player = SearchPlayer();
		SetEnemy(Player);
		StartEnemyAtack();
	} else if (Enemy == SearchPlayer()) {
		StartEnemyAtack();
	}
	Sleep(5);
	GoTo 'Begin';
}

// состояние атаки
State Atack {
	ignores SeePlayer,SeeMonster,TakeDamage,HearNoise;
	
	// отключение стрельбы через интеревалы
	function TimerFiring() {
		StopShootWeapon(0);
	}
	
Begin:
	MoveTo(Pawn.Location, Enemy, 10, true); // посмотреть в сторону игрока
	
GivePain:
	// враг существует?
	if (Enemy!=none) {
		if (!Enemy.IsAliveAndWell())	{
			// враг мёртв
			StopShootWeapon(0); // хватит стрелять
			GotoState('Idle'); // переходим в состояние покоя
		}
	} else {
		// враг - больше не враг, или что-то пошло не так
		StopShootWeapon(0); // хватит стрелять
		GotoState('Idle'); // переходим в состояние покоя
	}
	
	// действуем в зависимости от выбранного типа атаки
	switch (AtackType) {
		case ATT_Melee:
			// подбежать в упор
			MoveToward(Enemy, Enemy, MaxMeleeRange-50,, true);
			// прибежали?
			if (VSize(Pawn.Location - Enemy.Location)<MaxMeleeRange) {
				// нанести удар
				ShootWeapon(0);
				// задержка после выстрела
				SetTimer(1,false,'TimerFiring'); // 1 - задержка
			}
			break;
		case ATT_RunAttack:
			// бежать на расстояние огня
			MoveToward(Enemy, Enemy, AtackRange-100,, true);
			// достигли расстояния для выстрела
			if (VSize(Pawn.Location - Enemy.Location)<AtackRange) { // добавить проверку на видимость игрока
				// нанести удар
				TakeFocus(Enemy);
				ShootWeapon(0);
				// задержка после выстрела
				StopShootWeapon(0);
				//SetTimer(1,false,'TimerFiring'); // 1 - задержка
			}
			break;
		case ATT_AttackRunAttack:
			
			break;
		case ATT_AttackRunMelee:
			
			break;
		case ATT_StandAttack:
			
			break;
	}
	sleep(WaitAttack);
	Goto 'GivePain';
}

// ------------------конец состояний----------------------


// инициализация контроллера
simulated event PostBeginPlay() {
	super.PostBeginPlay();
}

// бот слышит шум
event HearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType ) {
	//StartEnemyAtack();
}

// бот видит игрока
event SeePlayer(Pawn Seen) {
	
	// если игрок - враг
	if (Seen==Enemy)	{
		StartEnemyAtack();
	}
}

// поиск игрока
function Pawn SearchPlayer() {
	local Pawn PW;
	foreach AllActors(class'Pawn',PW) {
		if (PW.IsPlayerPawn()) {
			return PW;
		}
	}
	return None; // игрок не найден
}

// назначение боту врага
function SetEnemy(Pawn P) {
	if (Enemy==None || Enemy!=P) {
		Enemy=P;
	}
}

// прицеливание
function TakeFocus(Pawn P) {
	Pawn.SetViewRotation(rotator(P.Location-Pawn.Location));
}

// старт атаки
function StartEnemyAtack() {
	//`log(name@"StartAtack()");
	// атаковать
	GoToState('Atack');
}

// прекращение атаки
function StopEnemyAtack() {
	GoToState('Idle');
}

// выстрелить из оружия (или ударить ближним боем)
function ShootWeapon(optional byte FireType=0) { // FireType - тип атаки (для UnrealTournament аналогично ЛКМ и ПКМ)
	Pawn.StartFire(FireType);
}

// прекратить огонь
function StopShootWeapon(optional byte FireType=0) {
	Pawn.StopFire(FireType);
}

defaultproperties
{
	AtackRange = 1000
	MaxMeleeRange = 100
	WaitAttack = 1
	AtackType = ATT_Melee
	Name="AngryBotsController__"
}