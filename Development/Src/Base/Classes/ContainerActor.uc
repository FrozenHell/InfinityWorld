/**
 *	ContainerActor
 *
 *	Creation date: 23.04.2013 18:21
 *	Copyright 2013, Nikita Gorelov
 */
class ContainerActor extends UsableActor;

var Container_Provider ConPro;

public function Use(Pawn uInstigator, optional int actionIndex = 0)
{
	if ( ConPro == none)
		ConPro = BaseGameInfo(WorldInfo.Game).GDBM.RegisterContainer( int(GetActorID()) );

		if (ConPro.IsEmpty( GetActorID() ) == true)
		ConPro.FillRandom( GetActorID() );

}

simulated event PostBeginPlay()
{
	super.postbeginplay();

	//DB_ID = BaseGameInfo(WorldInfo.Game).GDBM.DB_ID;
	//ConPro = Container_Provider( BaseGameInfo(WorldInfo.Game).GDBM.RegisterDataProvider(DB_ID, class'Container_Provider', string (self.Name)) );

	//ConPro.CheckContainer();
}

defaultproperties
{
}
