/**
 *	SeqEvent_ClickTouchingActor
 *
 *	Creation date: 25.11.2012 19:24
 *	Copyright 2012, WhyNot
 */
class SeqEvent_ClickTouchingActor extends SequenceEvent;

var() int Index;

defaultproperties
{
	VariableLinks(0)=(ExpectedType=class'SeqVar_Int', LinkDesc="Index", bWriteable=true, PropertyName=Index)
	ObjName = "Click Menu Item"
	ObjCategory = "Other"
	MaxTriggerCount = 0
}
