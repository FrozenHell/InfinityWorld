/**
 *	TestTriFloor
 *
 *	Creation date: 22.02.2013 11:10
 *	Copyright 2013, FHS
 */
class TestTriFloor extends HousePart;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
		StaticMesh = StaticMesh'Houses.Test1.tricenterfloor'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
		End Object
	Components.add(StaticMeshCompopo)
}
