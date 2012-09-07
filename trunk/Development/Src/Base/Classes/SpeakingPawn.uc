/**
 *	SpeakingPawn
 *
 *	Creation date: 03.04.2012 18:08
 *	Copyright 2012, FrozenHell Skyline
 *
 *	Паун для тестирования определённых функций, связанных с диалогами
 *	Не используйте его в конечном проекте
 */
class SpeakingPawn extends UTPawn // надо будет наследовать от другого класса
;//	implements(Useable);

// заговорить с пауном
public function Use(Pawn uInstigator)
{
	`log(Name@"был потревожен");
}

defaultproperties
{

}
