/**
 *	Local_DB_Manager
 *
 *	Creation date: 19.04.2013 12:24
 *	Copyright 2013, Nikita Gorelov
 */
class Local_DB_Manager extends DB_Manager;

var string DBName; 				// Наименование файла БД

var int DB_Id;						// Код текущей кэшируемой БД

var ESQLDriver SQLiteDriver;

var Items_DB_DataProvider ClassTypeProvider, ItemClassProvider, ItemProvider, ContainerProvider;	// Основной провайдер  для разных нужд
var Items_DB_DataProvider PlayerInventoryProvider;

function PostBeginPlay()
{
	super.PostBeginPlay();
	mDLLAPI.InitDriver(SQLiteDriver); // mSQLDriver=SQLDrv_SQLite
	DB_Id = mDLLAPI.Connect(DBName);
	mDLLAPI.SelectDataBase(DB_Id);
	//mProvider = Items_DB_DataProvider(RegisterDataProvider(DB_Id, class'Items_DB_DataProvider', "mProvider"));

}

function ExecutePickup(Pawn Pickuper)
{
	//PlayerInventoryProvider = Items_DB_DataProvider(RegisterDataProvider(DB_Id, class'Items_DB_DataProvider', "PlayerInventoryProvider"));

}


// Переобъявление метода из родительского класса.
// Добавлен второй параметр в выходе функции Spawn и вызов функции CheckItem.
function DB_DataProvider RegisterDataProvider(int aDbIdx, class<DB_DataProvider> aDataProviderClass, string aDataProviderName)
{
	local DB_DataProvider newProvider;

	newProvider = Spawn(aDataProviderClass,self);

	if (newProvider == none) return none;

	newProvider.mName = aDataProviderName;
	newProvider.mDBId = aDbIdx;
	newProvider.mDLLAPI = getDLLAPI();newProvider.InitCommands();

	mDataProviders[mDataProviders.Length] = newProvider;

	//if ( Item_DataProvider(newProvider) != none )
	//Items_DB_DataProvider(newProvider).CheckItem();

	return newProvider;
}

defaultproperties
{
	SQLiteDriver = SQLDrv_SQLite
	DBName = "IW_CaIGS"
}
