/**
 *	Container_Provider
 *	Класс поддержки взаимодействия экземпляра класса ContainerActor с БД
 *	Creation date: 22.04.2013 18:48
 *	Copyright 2013, Nikita Gorelov
 */
class Container_Provider extends IW_Provider;

var int CountRandomRange;

function PostBeginPlay()
{

}

function SelectRandomClass()
{

}

// заполнить контейнер случайными предметами
function FillRandom(string Container_ID)
{
	local int RandomID, RandomCount;//, ResultID;
	//local array<string> CurrentRecord;

	local array<SBindInfo> lBindInfos;
	local SBindInfo lNewBindInfo;

	//local string ClassName;

	GetClassesCount();// узнаем количество существующих классов

	RandomCount = Rand(3)+1; // сколько предметов будет в контейнере

	// определяем свойтва параметра запроса


	// получаем из запроса наименование класса предмета
	while ( RandomCount > 0 ) {
		RandomID  = Rand(ClassesCount);

		// получить имя класса
		/* mDLLAPI.PrepareStatement("Select Name from ItemClasses where rowid = " $ RandomID );
		ResultID = mDLLAPI.ExecuteStatement();
		mDLLAPI.NextResult(ResultID);
		mDLLAPI.GetStringVal(ResultID, "Name", ClassName); */

		lNewBindInfo.BindType 		= 1; // Integer

		lNewBindInfo.BindParam 		= "@Class_ID";
		lNewBindInfo.BindValue 		= string(RandomID);
		lBindInfos[0] 	= lNewBindInfo;
		BindValues(lBindInfos);

		lNewBindInfo.BindParam 		= "@Container_ID";
		lNewBindInfo.BindValue 		= Container_ID;
		lBindInfos[1] 	= lNewBindInfo;
		BindValues(lBindInfos);

		lNewBindInfo.BindParam 		= "@Count";
		lNewBindInfo.BindValue 		= string( Rand(CountRandomRange) +1);
		lBindInfos[2] 	= lNewBindInfo;
		BindValues(lBindInfos);

		INSERT();

		--RandomCount;
	}
}

function bool IsEmpty(string Container_ID)
{
	local int ResultID, Count;
	mDLLAPI.PrepareStatement("Select count(*) as Count from Items where Container_ID = " $ Container_ID );
	ResultID = mDLLAPI.ExecuteStatement();
	mDLLAPI.NextResult(ResultID);
	mDLLAPI.GetIntVal(ResultID, "Count", Count);

	if ( Count > 0) return true;
	else return false;
}


defaultproperties
{
	CountRandomRange = 3

	mCommands(0)="SELECT * FROM ItemClasses where Class_ID =@Class_ID;"
	mCommands(2)="INSERT INTO Items (Container_ID,Class_ID, Count) VALUES (@Container_ID,@Class_ID, @Count);"
}
