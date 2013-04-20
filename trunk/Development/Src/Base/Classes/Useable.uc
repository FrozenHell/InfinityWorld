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

// ----------------------------------------------------
// ������ ��������
public function FirstAction(Pawn uInstigator);

// ������ �������������� ��������
public function AdditionalAction1(Pawn uInstigator);

// ������ �������������� ��������
public function AdditionalAction2(Pawn uInstigator);

// ������ �������������� ��������
public function AdditionalAction3(Pawn uInstigator);

// �������� �������������� ��������
public function AdditionalAction4(Pawn uInstigator);
// ----------------------------------------------------

// �������� �� ��������
public function bool bGetUsable(optional int actionIndex = 0);

// �������� ����� ���������� �������� (������� ����������) ��� ��������
public function int GetActionsCount();