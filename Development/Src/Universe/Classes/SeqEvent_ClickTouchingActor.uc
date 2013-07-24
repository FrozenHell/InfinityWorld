/**
 *	SeqEvent_ClickTouchingActor
 *
 *	Creation date: 25.11.2012 19:24
 *	Copyright 2012, WhyNot
 */
class SeqEvent_ClickTouchingActor extends SequenceEvent;

// Kismet_ID обробатываемого объекта
var() int ClickableActor_ID;

defaultproperties
{
	ObjName = "Click Menu Item"
	ObjCategory = "Other"
	MaxTriggerCount = 0
}
