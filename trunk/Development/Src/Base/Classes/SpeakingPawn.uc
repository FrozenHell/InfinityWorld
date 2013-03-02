/**
 *	SpeakingPawn
 *
 *	Creation date: 03.04.2012 18:08
 *	Copyright 2013, FrozenHell Skyline
 */
class SpeakingPawn extends UTPawn // надо будет наследовать от другого класса
	implements(Useable);

// поле, отображаемое на HUD ("Нажмите F чтобы"@ActionName)
var() String ActionName;

// забрать значение ActionName
public function String GetActionName()
{
	return ActionName;
}

// заговорить с пауном
public function Use(Pawn uInstigator)
{
	`log(Name@"был потревожен");
}

defaultproperties
{
	ActionName="говорить"
}
