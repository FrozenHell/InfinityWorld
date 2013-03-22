/**
 *	SeqEvent_UseUsableActor
 *
 *	Creation date: 13.02.2013 1:14
 *	Copyright 2013, FHS
 */
class SeqEvent_UseUsableActor extends SequenceEvent;

// Kismet_ID обробатываемого объекта
var() int UsableActor_ID;

// действие объекта
var() int UsableActor_ActionId;

defaultproperties
{
	ObjName = "Use UsabeActor"
	ObjCategory = "Other"
	MaxTriggerCount = 0
	UsableActor_ActionId = 0
}
