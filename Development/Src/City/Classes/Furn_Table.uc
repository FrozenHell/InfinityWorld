/**
 *	Furn_Table
 *
 *	Creation date: 23.03.2013 07:15
 *	Copyright 2013, FHS
 */
class Furn_Table extends Actor;

defaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
		StaticMesh = StaticMesh'Furniture.Test.Table'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshCompopo)
	
	bHidden = False
	bCollideActors = True
	bBlockActors = True
	bStatic = False
	bMovable = False
}