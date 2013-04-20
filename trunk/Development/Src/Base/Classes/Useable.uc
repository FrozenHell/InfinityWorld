/**
 *	Usable
 *
 *	Creation date: 06.09.2012 12:49
 *	Copyright 2013, FHS
 */
interface Useable;

// действие, которое можно совершить с объектом
struct Action
{
	// имя, отображаемое на HUD
	var() String Name;
	// активно ли в данный момент
	var() bool bActive;
};

// получить имя конкретного действия
public function String GetActionName(optional int actionIndex = 0);

// функция вызывается при нажатии "Использовать" игроком
public function Use(Pawn uInstigator, optional int actionIndex = 0);

// ----------------------------------------------------
// первое действие
public function FirstAction(Pawn uInstigator);

// первое дополнительное действие
public function AdditionalAction1(Pawn uInstigator);

// второе дополнительное действие
public function AdditionalAction2(Pawn uInstigator);

// третье дополнительное действие
public function AdditionalAction3(Pawn uInstigator);

// четвёртое дополнительное действие
public function AdditionalAction4(Pawn uInstigator);
// ----------------------------------------------------

// доступно ли действие
public function bool bGetUsable(optional int actionIndex = 0);

// получить общее количество действий (включая неактивные) над объектом
public function int GetActionsCount();