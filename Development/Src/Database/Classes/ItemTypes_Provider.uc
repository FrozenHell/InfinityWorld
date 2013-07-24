/**
 *	Types_DB_DataProvider
 *	�����, ��������������� ��� ��������� � ����� � ���� ������������ ����� ���������
 *	Creation date: 20.04.2013 13:04
 *	Copyright 2013, Nikita
 */
class ItemTypes_Provider extends IW_Provider;

// ����������� ������� ���� �������� � �� � �������� ClassTypes
public function InsertType( string Type_ID, string Type)
{
	local array<SBindInfo> lBindInfos; 	// ������� ������ ����������
	local SBindInfo lNewBindInfo; 		// ������� ������������� ��������
	//local array<string> Result;		// ������ ���������� �������
	//local int lDataCount;				// ���������� ���������� ������� �� �������

	lNewBindInfo.BindType 		= 1; // Integer
	lNewBindInfo.BindParam 		= "@Type_ID";
	lNewBindInfo.BindValue 		= Type_ID;
	lBindInfos[lBindInfos.Length] 	= lNewBindInfo;
	BindValues(lBindInfos);

	Select();

	if ( GetDataCount() != 1) {
		lNewBindInfo.BindType 		= 3;
		lNewBindInfo.BindParam 		= "@Type";
		lNewBindInfo.BindValue 		= Type;
		lBindInfos[lBindInfos.Length] 	= lNewBindInfo;
		BindValues(lBindInfos);
		Insert();	//`log("Inserting...");
	}

	//`log("Current" @ GetDataCount() );
}

public function int GetTypeCount()
{
	local int ResultID, Count;

	mDLLAPI.PrepareStatement("Select count(*) as Count from ClassTypes;");
	ResultID = mDLLAPI.ExecuteStatement();
	mDLLAPI.NextResult(ResultID);
	mDLLAPI.GetIntVal(ResultID, "Count", Count);
	return Count;



}
defaultproperties
{
	mCommands(0)="SELECT * FROM ClassTypes WHERE Type_ID = @Type_ID;"
	mCommands(2)="INSERT INTO ClassTypes (Type_ID, Type) VALUES (@Type_ID, @Type);"
}
