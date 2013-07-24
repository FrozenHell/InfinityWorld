/**
 *	IW_Provider
 *	Провайдер данных для общих нужд
 *	Creation date: 28.04.2013 13:09
 *	Copyright 2013, Nikita
 */
class IW_Provider extends DB_DataProvider;

var int ClassesCount;

// возврат количества классов предметов в БД и установка значения переменной ClassesCount
function int GetClassesCount()
{
	local int ResultID, Count;

	mDLLAPI.PrepareStatement("SELECT count(*) as Count FROM ItemClasses");
	ResultID = mDLLAPI.ExecuteStatement();
	mDLLAPI.NextResult(ResultID);
	mDLLAPI.GetIntVal(ResultID, "Count", Count);
	ClassesCount = Count;
	return Count;
}

function int CheckClassExistence(string Class_ID)
{
	local int ResultID, ID;

	mDLLAPI.PrepareStatement("SELECT Class_ID as Count FROM ItemClasses where Class_ID =" $ Class_ID);
	ResultID = mDLLAPI.ExecuteStatement();
	mDLLAPI.NextResult(ResultID);
	mDLLAPI.GetIntVal(ResultID, "Count", ID);
	if (ID != -1)
		return ID;
	else
		return -1;
}

defaultproperties
{
}
