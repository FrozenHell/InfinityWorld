/**
 *	BaseGameInfo
 *
 *	Creation date: 23.04.2013 22:59
 *	Copyright 2013, Nikita
 */
class BaseGameInfo extends UTGame;

var Global_DB_Manager GDBM;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	GDBM = Spawn (class'Global_DB_Manager');
	`log ("BaseGameInfo was loaded");
}

event PreExit()
{
	GDBM.SaveDataBase();
}


defaultproperties
{
}
