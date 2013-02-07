/**
 *	NavNode
 *
 *	Creation date: 03.11.2012 18:04
 *	Copyright 2012, WhyNot
 */
class NavNode extends Actor;

var float g, h, f;
var array<NavNode> Links;
var NavNode CameFrom;
var int LinksSize;

function AddRelation(NavNode node)
{
	if (Location.x == 0.0 && Location.y == 0.0 && Location.z == 0.0)
		`warn("Ќода св€зана с собой или нодой в той-же точке!");
	Links[LinksSize] = node;
	LinksSize++;
}

defaultproperties
{
	LinksSize = 0;
}
