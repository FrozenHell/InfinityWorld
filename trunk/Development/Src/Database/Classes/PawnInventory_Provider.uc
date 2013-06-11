/**
 *	Player_DB_DataProvider
 *
 *	Creation date: 20.04.2013 13:02
 *	Copyright 2013, Nikita Gorelov
 */
class PawnInventory_Provider extends Container_Provider;

function Take(string Class_ID,string Container_ID, string Count)
{
	local array<SBindInfo> lBindInfos; 	// текущий массив параметров
	local SBindInfo lNewBindInfo; 		// текущий редактируемый параметр
	//local array<string> Result;		// массив результата запроса
	//local int lDataCount;				// количество полученных записей из запроса

	lNewBindInfo.BindType 		= 1; // Integer
	lNewBindInfo.BindParam 		= "@Class_ID";
	lNewBindInfo.BindValue 		= Class_ID;
	lBindInfos[lBindInfos.Length] 	= lNewBindInfo;

	lNewBindInfo.BindParam 		= "@Container_ID";
	lNewBindInfo.BindValue 		= Container_ID;
	lBindInfos[lBindInfos.Length] 	= lNewBindInfo;

	lNewBindInfo.BindParam 		= "@Count";
	lNewBindInfo.BindValue 		= Count;
	lBindInfos[lBindInfos.Length] 	= lNewBindInfo;

	BindValues(lBindInfos);

	if ( GetItemCount( Container_ID, Class_ID ) > 0 ) {	 `log("Updating item...");
		UPDATE();
	}
	else {
		INSERT();
	}
}

function Drop(string Class_ID,string Container_ID, string Count)
{
	local array<SBindInfo> lBindInfos; 	// текущий массив параметров
	local SBindInfo lNewBindInfo; 		// текущий редактируемый параметр
	//local array<string> Result;		// массив результата запроса
	//local int lDataCount;				// количество полученных записей из запроса

	lNewBindInfo.BindType 		= 1; // Integer
	lNewBindInfo.BindParam 		= "@Class_ID";
	lNewBindInfo.BindValue 		= Class_ID;
	lBindInfos[lBindInfos.Length] 	= lNewBindInfo;

	lNewBindInfo.BindParam 		= "@Container_ID";
	lNewBindInfo.BindValue 		= Container_ID;
	lBindInfos[lBindInfos.Length] 	= lNewBindInfo;

	//`log ( GetItemCount( Container_ID, Class_ID ) );
	if ( GetItemCount( Container_ID, Class_ID ) > int(Count) ) {

		lNewBindInfo.BindParam 		= "@Count";
		lNewBindInfo.BindValue 		= "-" $ Count;
		lBindInfos[lBindInfos.Length] 	= lNewBindInfo;

		BindValues(lBindInfos);

		UPDATE();
	}
	else {
		BindValues(lBindInfos);

		Delete();	//`log("Deleting item..."); `log ( GetItemCount( Container_ID, Class_ID ) );
	}
}

function int GetItemCount(string Container_ID, string Class_ID)
{
	local int ResultID, Count;

	mDLLAPI.PrepareStatement("Select Count from Items where Class_ID = " $ Class_ID @ "AND Container_ID = " $ Container_ID);
	ResultID = mDLLAPI.ExecuteStatement();
	mDLLAPI.NextResult(ResultID);
	mDLLAPI.GetIntVal(ResultID, "Count", Count);
	return Count;
}

defaultproperties
{
	mCommands(0)="SELECT * FROM Items WHERE Container_ID = @Container_ID;"
	mCommands(1)="UPDATE Items SET Count = Count + @Count WHERE Container_ID = @Container_ID AND Class_ID = @Class_ID;"
	mCommands(2)="INSERT INTO Items (Container_ID, Class_ID,Count) VALUES (@Container_ID, @Class_ID, @Count);"
	mCommands(3)="DELETE FROM Items WHERE Container_ID = @Container_ID AND Class_ID = @Class_ID;"
}
