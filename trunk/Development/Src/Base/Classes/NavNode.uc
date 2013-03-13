/**
 *	NavNode
 *
 *	Creation date: 03.11.2012 18:04
 *	Copyright 2012, FHS
 */
class NavNode extends Actor
	placeable;

var float g, h, f;
var() array<NavNode> Links;
var NavNode CameFrom;

function AddRelation(NavNode node)
{
	if (Location.x == 0.0 && Location.y == 0.0 && Location.z == 0.0)
		`warn("Ќода находитс€ в начале координат");

	if (Location == node.Location)
		`warn("Ќоду пытаютс€ св€зать с самой собой или нодой в этой же точке");
	else
	{
		Links.AddItem(node);
	}
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_NavP'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)
	GoodSprite=Sprite

	Begin Object Class=SpriteComponent Name=Sprite2
		Sprite=Texture2D'EditorResources.Bad'
		HiddenGame=true
		HiddenEditor=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		Scale=0.25
	End Object
	Components.Add(Sprite2)
	BadSprite=Sprite2
}
