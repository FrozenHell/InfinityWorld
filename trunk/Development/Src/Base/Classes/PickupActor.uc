/**
 *	PickupActor
 *
 *	Creation date: 11.04.2013 20:09
 *	Copyright 2013, FHS
 */
class PickupActor extends UsableActor;

var() String PickupName;

// ���������� �������� ��������, ����� "����� �������"
public function String GetActionName(optional int actionIndex = 0)
{
	return Actions[actionIndex].Name@PickupName;
}

public function Use(Pawn uInstigator, optional int actionIndex = 0)
{
	
}

defaultproperties
{
	Actions[0] = (Name = "�����", bActive = true)
	PickupName = "�������"
}
