/**
 *	SeqEvent_ScriptSpawn
 *
 *	Creation date: 17.02.2013 12:58
 *	Copyright 2013, FHS
 */
class SeqEvent_RemoteVectorEvent extends SeqEvent_RemoteEvent;

// будуща€ позици€ игрока (определ€етс€ скриптом)
var vector Position;

defaultproperties
{
	VariableLinks(1) = (ExpectedType=class'SeqVar_Vector', LinkDesc="Position", bWriteable=true, PropertyName=Position)
	ObjCategory="Actor"
	ObjName="RemoteVectorEvent"
	EventName=RemoteVectorEvent
	MaxTriggerCount=0
}
