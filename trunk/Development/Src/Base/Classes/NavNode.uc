/**
 *	NavNode
 *
 *	Creation date: 03.11.2012 18:04
 *	Copyright 2012, WhyNot
 */
class NavNode extends Object;

var double g, h, f;
var int Index;
var vector Pos;
var array<NavNode> Links;
var NavNode CameFrom;
var int LinksSize;

function AddRelation(NavNode node)
{
	if (Pos.x == 0.0 && Pos.y == 0.0 && Pos.z == 0.0)
		`log("error");
	Links[LinksSize] = node;
	LinksSize++;
}

defaultproperties
{
	LinksSize = 0;
}
