/**
 *	LiftRoom
 *
 *	Creation date: 03.03.2013 11:51
 *	Copyright 2013, FHS
 */
class LiftRoom extends HousePart;



defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
		StaticMesh=StaticMesh'Houses.Lifts.LiftRoom'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshCompopo)
	bMovable = True
}
