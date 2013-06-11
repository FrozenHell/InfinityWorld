/**
 *	Item_DataProvider
 *	Класс, предназначенный для обработки и ввода в базу информации о классах предметов, которые есть в игре.
 *	Creation date: 19.04.2013 15:31
 *	Copyright 2013, Nikita Gorelov
 */
class ItemClasses_Provider extends IW_Provider;

// Определение наличия класса предмета в БД в таблиице ClassTypes
public function InsertItemClass( string Class_ID, string Type_ID, string Mass, string _Name, string Description)
{
	local array<SBindInfo> lBindInfos; 	// текущий массив параметров
	local SBindInfo lNewBindInfo; 		// текущий редактируемый параметр
	//local array<string> Result;		// массив результата запроса
	//local int lDataCount;				// количество полученных записей из запроса

	lNewBindInfo.BindType 		= 1; // Integer
	lNewBindInfo.BindParam 		= "@Class_ID";
	lNewBindInfo.BindValue 		= Class_ID;
	lBindInfos[lBindInfos.Length] 	= lNewBindInfo;
	BindValues(lBindInfos);

	Select();

	if ( GetDataCount() != 1) {
		lNewBindInfo.BindType 		= 1;
		lNewBindInfo.BindParam 		= "@Type_ID";
		lNewBindInfo.BindValue 		= Type_ID;
		lBindInfos[lBindInfos.Length] 	= lNewBindInfo;
		BindValues(lBindInfos);
		lNewBindInfo.BindType 		= 3;
		lNewBindInfo.BindParam 		= "@Name";
		lNewBindInfo.BindValue 		= _Name;
		lBindInfos[lBindInfos.Length] 	= lNewBindInfo;
		BindValues(lBindInfos);
		lNewBindInfo.BindType 		= 3;
		lNewBindInfo.BindParam 		= "@Description";
		lNewBindInfo.BindValue 		= Description;
		lBindInfos[lBindInfos.Length] 	= lNewBindInfo;
		BindValues(lBindInfos);
		lNewBindInfo.BindType 		= 2;
		lNewBindInfo.BindParam 		= "@Mass";
		lNewBindInfo.BindValue 		= Mass;
		lBindInfos[lBindInfos.Length] 	= lNewBindInfo;
		BindValues(lBindInfos);
		Insert();	//`log("Inserting...");
	}

	//`log("Current" @ GetDataCount() );
}

defaultproperties
{
	mCommands(0)="SELECT * FROM ItemClasses WHERE Class_ID = @Class_ID;"
	mCommands(2)="INSERT INTO ItemClasses (Class_ID, Name, Mass, Description, Type_ID) VALUES (@Class_ID, @Name, @Mass, @Description, @Type_ID);"
}
