/**
 *	Coin
 *
 *	Creation date: 16.04.2013 15:24
 *	Copyright 2013, Nikita
 */
class Coin extends BaseMoney;

function PostBeginPlay()
{
	super.PostBeginPlay(); 		
}

defaultproperties
{	
	Class_ID = 8	
	Mass = 0.0
	Description = "Sweet little bird - exellent coin in this place"
	
	Begin Object Class=SpriteComponent Name=MySprite
		Sprite=Texture2D'EditorResources.Ambientcreatures'
		HiddenGame = false
	End Object
	Components.Add(MySprite)
	
}
