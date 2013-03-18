/**
 *	TestTriRoof
 *
 *	Creation date: 09.03.2013 16:17
 *	Copyright 2013, Alekseu
 */
class TestTriRoof extends HousePart;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
		StaticMesh = StaticMesh'Houses.Test1.tricenterroof'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
		End Object
	Components.add(StaticMeshCompopo)
}
