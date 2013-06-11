/**
 *	Global_DB_Manager
 *
 *	Creation date: 17.04.2013 13:00
 *	Copyright 2013, Gorelov Nikita
 */
class Global_DB_Manager extends DB_Manager;

var string DBName; 				// ������������ ����� ��

var int DB_Id;						// ��� ������� ���������� ��

var ESQLDriver SQLiteDriver;

var ItemTypes_Provider _ItemTypes_Provider;
var ItemClasses_Provider _ItemClasses_Provider;

// ������������ � ��������� ��
function Connect()
{
	if ( mDLLAPI.IO_fileExists(DBName) ) {	`log("Connecting...");
		DB_Id = mDLLAPI.Connect(DBName);
		mDLLAPI.SelectDatabase(DB_Id);
	}
	else CreateDB();
}

// ������� ��
function CreateDB()
{	`log("Creating...");
	DB_Id = mDLLAPI.CreateDataBase();
	mDLLAPI.SelectDatabase(DB_Id);

	mDLLAPI.QueryDatabase("CREATE TABLE  ClassTypes  (Type_ID INTEGER PRIMARY KEY, Type TEXT)");

	mDLLAPI.QueryDatabase("CREATE TABLE  ItemClasses  (Class_ID INTEGER PRIMARY KEY, Name TEXT, Mass REAL, Description TEXT, Type_ID INTEGER )");

	mDLLAPI.QueryDatabase("CREATE TABLE  Items  (Item_ID INTEGER PRIMARY KEY, Count INTEGER DEFAULT (1), Equiped INTEGER DEFAULT (0), Class_ID INTEGER, Container_ID INTEGER )");

	mDLLAPI.QueryDatabase("CREATE TABLE  Containers  (Container_ID INTEGER PRIMARY KEY, Actor_ID INTEGER, Location TEXT)");
}

// ���������� �� �� ������
event Destroyed()
{	`log("Destroyed");
	mDLLAPI.SaveDataBase(DBName);
}

// ��������� �� � �����
function SaveDataBase()
{
	mDLLAPI.SaveDataBase(DBName);
}

// �������� ����� ��� ��������
function InsertType(string Type_ID, string Type)
{
	_ItemTypes_Provider.InsertType( Type_ID, Type);
}


function int GetTypeCount()
{
	return _ItemTypes_Provider.GetTypeCount();
}

// �������� ����� ��� ��������
function InsertClass(string Class_ID, string Type_ID, string Mass, string _Name, string Description)
{
	_ItemClasses_Provider.InsertItemClass(Class_ID, Type_ID, Mass, _Name, Description);
}

// �������� � ������� ������������ ���������� ������ ��� ����������
public function Container_Provider RegisterContainer(int Container_ID)
{
	local Container_Provider newContainer;
	newContainer = Container_Provider( RegisterDataProvider(DB_Id, class'Container_Provider', "Container_"$Container_ID) );
	return newContainer;
}

// �������� � ������� ������������ ���������� ������ ��� ����������
public function PawnInventory_Provider RegisterPawnInventory(int Pawn_ID)
{
	local PawnInventory_Provider newContainer;
	newContainer = PawnInventory_Provider( RegisterDataProvider(DB_Id, class'PawnInventory_Provider', "Pawn_"$Pawn_ID) );
	return newContainer;
}


function PostBeginPlay()
{
	super.PostBeginPlay();
	mDLLAPI.InitDriver(SQLiteDriver);
	Connect();
	_ItemTypes_Provider = ItemTypes_Provider( RegisterDataProvider(DB_Id, class'ItemTypes_Provider', "_ItemTypes_Provider") );
	_ItemClasses_Provider = ItemClasses_Provider( RegisterDataProvider(DB_Id, class'ItemClasses_Provider', "_ItemClasses_Provider") );
}

// �������� ���������� ������ � ��
function int GetTableCount()
{
	return mDLLAPI.GetTableCount();
}

// ��������� ������������� ������� � ��
function bool CheckTable(string TableName)
{
	// Main_Provider = RegisterDataProvider(DB_Id, class'DB_DataProvider', "MainDBDataProvider");
	// Main_Provider.mCommands[0]="select name from sqlite_master where type='table' and name = '" $ TableName $ "';";
	// Main_Provider.Select();
	// if (Main_Provider.GetDataCount() == 0 ){ `log ( "This table do not exists:"@TableName); return false;
	// }
	// else return true;
}

defaultproperties
{
	SQLiteDriver=SQLDrv_SQLite
	DBName = "IW_CaIGS"
}
