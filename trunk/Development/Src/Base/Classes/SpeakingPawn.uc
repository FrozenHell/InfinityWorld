/**
 *	SpeakingPawn
 *
 *	Creation date: 03.04.2012 18:08
 *	Copyright 2013, FrozenHell Skyline
 */
class SpeakingPawn extends UTPawn // ���� ����� ����������� �� ������� ������
	implements(Useable);

// ����, ������������ �� HUD ("������� F �����"@ActionName)
var() String ActionName;

// �������� �� ������ ��� �������������
var bool bUseable;

// ������� �������� ActionName
public function String GetActionName()
{
	return ActionName;
}

// ���������� � ������
public function Use(Pawn uInstigator)
{
	`log(Name@"��� ����������");
}

public function bool GetUseable()
{
	return bUseable;
}

defaultproperties
{
	ActionName="��������"
	bUseable = true
}
