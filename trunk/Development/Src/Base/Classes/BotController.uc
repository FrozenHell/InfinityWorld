class BotController extends AIController;

var vector LastEnemyPos;
var vector TargetLocation;
var Pawn Enemy1;

var UTWeap_RocketLauncher RL;

var array <NavNode> _OpenSet;
var array <NavNode> _ClosedSet;

var NavNode _NavNode;

/*
*	event PostBeginPlay()
*	{
*		super.PostBeginPlay();
*	}
*/

State Runner
{
ignores SeePlayer, HearNoise;
BEGIN:
	if (_NavNode == None)
	{
		`log("Пути не существует");
		goto('END');
	}

	`log("Бот: бегу за врагом!");

RUN:
	if (_NavNode.CameFrom != none)
	{
		MoveTo(_NavNode.Location, Enemy1, 10);
		_NavNode = _NavNode.CameFrom;
		goto('RUN');
	}
	MoveTo(_NavNode.Location, Enemy1, 10);

END:
	GotoState('Wait');
}

state Run
{
ignores SeePlayer, HearNoise;
BEGIN:
	`log("Бот: игрок очень близко, бегу напрямик!");
	if (Enemy1 != None)
		MoveTo(Enemy1.Location,Enemy1,150);
	else
		MoveTo(LastEnemyPos,Enemy1,150);
	GotoState('Wait');
}

auto state Wait
{
BEGIN:
	`log("жду");
}

state Fire
{
ignores SeePlayer, HearNoise;
BEGIN:
	//MoveToward(Pawn,Enemy1,1);
	Pawn.StartFire(0);
	sleep(RL.GetFireInterval(0));
	Pawn.Stopfire(0);
	Enemy1 = none;
	//if (Enemy1 == none) Goto ('END');
	//Goto ('BEGIN');
END:
	//Pawn.Stopfire(0);
}

// бот видит игрока
event SeePlayer(Pawn Seen)
{
	Enemy1 = Seen;
	`log("Бот: вижу врага!");
	GoToPoint(Enemy1.Location);
}

// бот слышит шум
event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	LastEnemyPos = NoiseMaker.Location;
	//Enemy1 = none; // на всякий
	`log("Бот: слышу врага!");
	GoToPoint(LastEnemyPos);
	// полностью перезаписываем стандартное, иначе раскоментировать следующую строку
	// Super.HearNoise(Loudness, NoiseMaker, NoiseType);
}

// бот получает повреждения
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Enemy1 = EventInstigator.Pawn;
	GoToPoint(Enemy1.Location);
	// полностью перезаписываем стандартное, иначе раскоментировать следующую строку
	// Super.TakeDamage(DamageAmount, EventInstigator, HitLocation,иMomentum, DamageType, HitInfo, DamageCauser);
}

// бежать к точке
function GoToPoint(vector endPoind)
{
	local NavNode locNode, StartNode, TargetNode;
	local float minRange1, minRange2;

	minRange1 = 100000.0;
	minRange2 = 100000.0;

	foreach AllActors(class'NavNode', locNode)
	{
		if (VSize(Pawn.Location - locNode.Location) < minRange1)
		{
			minRange1 = VSize(Pawn.Location - locNode.Location);
			StartNode = locNode;
		}

		if (VSize(endPoind - locNode.Location) < minRange2)
		{
			minRange2 = VSize(endPoind - locNode.Location);
			TargetNode = locNode;
		}
	}

	//if (StartNode != TargetNode && VSize(Pawn.Location - endPoind) > VSize(Pawn.Location - StartNode.Location))
	//{
		_NavNode = CreatePath(StartNode, TargetNode);
		GotoState('Runner');
	//}
	//else
	//	GotoState('Run');
}

// создать путь из нод для путешествия
function NavNode CreatePath(NavNode END_POINT, NavNode START_POINT)
{
    local NavNode Current;
	local float tentative_g_score, min_f;
	local bool isClosed, isOpen;
	local int j, k;

	ToOpenSet(START_POINT, END_POINT);

	min_f = 100000.0;
	while (_OpenSet.Length > 0)
    {
        min_f = 1000000.0;
		For (j=0; j<_OpenSet.Length;j++)
			if (_OpenSet[j].f<= min_f)
            {
				min_f = _OpenSet[j].f;
                Current = _OpenSet[j];
            }

		if (Current == END_POINT)
			break;

		_ClosedSet[_ClosedSet.Length] = Current;

        For (j = 0; j < _OpenSet.Length; j++)
			if (_OpenSet[j] == Current)
            {
				_OpenSet.RemoveItem(_OpenSet[j]);
                break;
            }

		for (j = 0; j < Current.Links.Length; j++)
		{
			isClosed = false;
			for (k=0;k<_ClosedSet.Length;k++)
				if (_ClosedSet[k] == Current.Links[j])
				{
					isClosed = true;
					break;
				}
			if (isClosed) continue;

			tentative_g_score = (Current.g + VSize(Current.Location - Current.Links[j].Location));

			isOpen = false;
			for (k=0;k<_OpenSet.Length;k++)
				if (_OpenSet[k] == Current.Links[j])
				{
					isOpen = true;
					if (tentative_g_score < _OpenSet[k].g )
					{
						_OpenSet[k].g = tentative_g_score;
						_OpenSet[k].h = VSize( _OpenSet[k].Location -  END_POINT.Location);
						_OpenSet[k].f =  _OpenSet[k].g +  _OpenSet[k].h;
					}
					else break;
				}

			if (isOpen == false)
			{
				Current.Links[j].CameFrom = Current;
				Current.Links[j].g = tentative_g_score;
				Current.Links[j].h = VSize(Current.Links[j].Location - END_POINT.Location);
				Current.Links[j].f = Current.Links[j].g +Current.Links[j].h;
				_OpenSet[_OpenSet.Length] = Current.Links[j];
			}
		}
	}
	return Current;
}

function ToOpenSet(NavNode first, NavNode last)
{
	first.g = 0.0;
	first.h = VSize(first.Location - last.Location);
	first.f = first.h;
	_OpenSet[_OpenSet.Length] = first;
}

defaultproperties
{

}