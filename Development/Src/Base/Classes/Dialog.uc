class Dialog extends Object
	DLLBind(Dialogs);

struct Answer
{
	var String Message;
	var String Func;
	var Int Parent;
};

struct Quest
{
	var Answer Answer[6];
	var String Message;
};

const EMPTY_STRING = "                                                                                                                                                                                                                                                               ";

var int idFileG;
var bool VarsLoaded;
var Quest MyUStr;
var GFxMovie_DialogWindow GFxDialog;

dllimport final function byte StartDialog(int idFile, int idDlg, out quest Dlg);
dllimport final function LoadVars(out String Name1, out String Value);

delegate DialogClosed();

function StartLoadVars()
{
	local String N;
	local String V;
	if (!VarsLoaded)
	{
		N="Name";
		V="Aleksandr";
		LoadVars(N, V);
		N="sex";
		V="male";
		LoadVars(N, V);
		N="Age";
		V="16";
		LoadVars(N, V);
		VarsLoaded = true;
	}
}

// �������, ���������� ��� ������ ������� �������� ������
function DialogEvent(int option)
{
	if (GetAnswer(Option + 1) != 0)
	{	// ���� ������ �� �������
		// ������� ���� ��������
		GFxDialog.ClearDialog();
		// ��������� ���� ������ ����������
		FillOptions();
	}
	else
	{
		// ��������� ����� � ���������� ���������� ������
		GFXDialog.Close(false);
		// ��������� �����
		DialogClosed();
	}

	`log("Dialog answer is"@Option);
}

function GetDialog(int idFile, int idDlg)
{
	local int i;
	idFileG = idFile;
	`log("File="$idFile);
	`log("Dlg="$idDlg);
	// ��������� �������� ��������� ����-��������
	MyUStr.message = EMPTY_STRING;
	for (i = 0; i < 6; i++)
	{
		MyUStr.answer[i].message = EMPTY_STRING;
		MyUStr.answer[i].func = EMPTY_STRING;
	}

	StartDialog(idFile, idDlg, MyUstr);
}

// �������� ������ ������� ������ (1-6) ��� ������ (0)
function string GetLine(int line)
{
	if (line == 0)
		return MyUStr.message;
	else
		return MyUStr.answer[line - 1].message;
}

/* 
 * �������, ������������ ����� ������ (0, ���� ������ ���)
 * ��� ��, ��������� �� ������ ����� ������, ���� ��� ����������
*/
function int GetAnswer(int idAns)
{
	// ����������� idAns
	idAns = idAns - 1;
	`log("StartFunc = "$MyUstr.answer[idans].func);
	FuncDef(MyUstr.answer[idAns].func);

	// ���� ������ �� ���������
	if (MyUstr.answer[idAns].parent != 0)
	{
		`log("IdDialog = "$MyUstr.answer[idAns].parent);
		// ��������� � ������ ���������� � ����� ������� �� ����
		GetDialog(idFileG, MyUstr.answer[idAns].parent);
		return 1;
	}
	return 0;
}

//-------------

function StartNewTalk(int questFile, int questID)
{
	// ���������� � dll ������ ����������
	StartLoadVars();
	
	GFxDialog = new class'Base.GFxMovie_DialogWindow';

	// ������� ������ �� ������� � ����� ������
	GFxDialog.DialogEvent = DialogEvent;

	// ��������� �����
	GFxDialog.Start(true);
	GFxDialog.SetFocus(true, true);

	// �������� ���������� � ������� �� ����
	GetDialog(questfile, questID);

	// ��������� �������� ������� � ��������� ����� ������
	FillOptions();
}

function FillOptions()
{
	local int i;

	for (i = 1; i <= 6; i++)
	{
		if (GetLine(i) != EMPTY_STRING)
		{
			`log("Option"@i@"Loaded");
			GFxDialog.AddOption(GetLine(i));
		}
	}

	// �������� ����� ������
	GFxDialog.NewDialog(GetLine(0));
}

function FuncDef(String Func)
{
	local String NameFunc;
	local array<String> Args;
	local int i;
	NameFunc=Mid(Func,0,InStr(Func,"("));
	`log("Func = "$NameFunc);
	Func=Mid(Func,InStr(Func,"(")+1,Len(Func)-Len(NameFunc)-2);
	Args=SplitString(Func,"','");
	i=0;
	for (i=0;i<Args.Length;i++)
	{
		if (i==0){
			Args[i]=Mid(Args[i],1);
		}
		if (i==Args.Length-1){
			Args[i]=Mid(Args[i],0,Len(Args[i])-1);
		}
		`log("arg"$i$"="$Args[i]);
	}
}

DefaultProperties
{
	VarsLoaded = false
}