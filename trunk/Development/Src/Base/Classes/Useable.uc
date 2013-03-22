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

// доступно ли действие
public function bool GetUseable(optional int actionIndex = 0);

// получить общее количество действий (включая неактивные) над объектом
public function int GetActionsCount();