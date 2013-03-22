/**
 *	Usable
 *
 *	Creation date: 06.09.2012 12:49
 *	Copyright 2013, FHS
 */
interface Useable;

// ��������, ������� ����� ��������� � ��������
struct Action
{
	// ���, ������������ �� HUD
	var() String Name;
	// ������� �� � ������ ������
	var() bool bActive;
};

// �������� ��� ����������� ��������
public function String GetActionName(optional int actionIndex = 0);

// ������� ���������� ��� ������� "������������" �������
public function Use(Pawn uInstigator, optional int actionIndex = 0);

// �������� �� ��������
public function bool GetUseable(optional int actionIndex = 0);

// �������� ����� ���������� �������� (������� ����������) ��� ��������
public function int GetActionsCount();