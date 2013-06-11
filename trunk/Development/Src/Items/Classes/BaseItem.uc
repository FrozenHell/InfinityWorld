/**
 *	BaseItem
 *	Данные класс описывает образец предмета, который можно брать в инвертарь или оставлять
	в игровом пространстве. Приводятся поля класса, а также методы взаимодействия с экземпляром класса (предметом).
 *	Creation date: 18.04.2013 10:15
 *	Copyright 2013, Gorelov Nikita
 */
class BaseItem extends PickupActor;

// Типы преметоы
enum ITEM_TYPES
{
	SIMPLE,		// простой предмет
	MONEY,		// валюта
	AMMO,		// патроны
	WEAPON,		// оружие
	ARMOR,		// броня
	QUEST,		// квестовые предмет
	SPECIAL		// что-то исключительное
};

var ITEM_TYPES 	Item_type; // указывается определенные тип данного предмета

var int 			Class_ID;		// код класса предмета
var int			Actor_ID;		// код созданного экземпляра предмета
var float 			Mass;		// вес единицы предмета
var float 			Count;		// количество предметов в одном экземпляре класса
var string 		Description; 	// короткое описание предмета
var int 			Type_ID;		// текущий тип предмета


function PostBeginPlay()
{
	local array<string> SplitName;
	local string Delimiter;
	
	super.PostBeginPlay(); 
	
	Type_ID = Item_type; 	
	
	Delimiter = "_";
	SplitName = SplitString(string(self.Name),Delimiter);
	Actor_ID = int(SplitName[1]);  
	
	// ввести в базу данных весь список типов предметов
	//SetTimer( 3.0,,'InsertAllItemTypes');
	//SetTimer( 4.0,,'CheckClass');
}

public function Use(Pawn uInstigator, optional int actionIndex = 0)
{			
	//if (UnPlayerController(uInstigator.Controller) !=none)		
	//	UnPlayerController(uInstigator.Controller).Inventory.TakeItem(self);
	CheckClass();
	if ( RPGPlayerController(uInstigator.Controller) != none ) {
	// -------------------------------------------------------------- Пусть Inventory.Take возвращает true или false
	RPGPlayerController(uInstigator.Controller).Inventory.Take( string (Class_ID), string(0), string(Count) );
	Destroy();	
	}
}

public function InsertAllItemTypes()
{
	local int _EnumCount, i;
	_EnumCount = ITEM_TYPES.EnumCount;
	
	//`log("Types inserting...");
	for (i = 0; i < _EnumCount; ++i)
	{
		BaseGameInfo(WorldInfo.Game).GDBM.InsertType( string(i), string( GetEnum(enum'ITEM_TYPES', i) ) );
	}
	//BaseGameInfo(WorldInfo.Game).GDBM.SaveDataBase();	
}

public function CheckClass()
{
	BaseGameInfo(WorldInfo.Game).GDBM.InsertClass (string(Class_ID), string(Type_ID), string(Mass), string(self.Class), Description);
}

defaultproperties
{
	Class_ID = 0	
	Mass = 1.0
	Count = 1
	Description="Base class for any items"
	Item_type = SIMPLE	
	
	Actions[0] = (Name = "использовать", bActive = true)

	
	//Components.Remove(StaticMeshComponent0)	
}
