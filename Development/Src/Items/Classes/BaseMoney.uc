/**
 *	BaseMoney
 *
 *	Creation date: 19.04.2013 12:42
 *	Copyright 2013, Nikita Gorelov
 */
class BaseMoney extends BaseItem;

function PostBeginPlay()
{
	super.PostBeginPlay(); 		
}

defaultproperties
{
	Class_ID = 1	
	Mass = 0.0
	Description="Base class for money"
	Item_type = MONEY	
	
	//StaticMeshComponent.HiddenGame = true
	
}
