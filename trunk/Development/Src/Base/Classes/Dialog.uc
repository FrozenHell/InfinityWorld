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

const EMPTY_STRING = "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

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

// функция, вызываемая при выборе игроком варианта ответа
function DialogEvent(int option)
{
	if (GetAnswer(Option + 1) != 0)
	{	// если диалог не окончен
		// очищаем окно диалогов
		GFxDialog.ClearDialog();
		// заполняем окно новыми значениями
		FillOptions();
	}
	else
	{
		// закрываем ролик и возвращаем управление игроку
		GFXDialog.Close(false);
		// оповещаем пауна
		DialogClosed();
	}

	`log("Dialog answer is"@Option);
}

function GetDialog(int idFile, int idDlg)
{
	local int i;
	idFileG = idFile;

	// заполняем значения структуры спец-строками
	MyUStr.message = EMPTY_STRING;
	for (i = 0; i < 6; i++)
	{
		MyUStr.answer[i].message = EMPTY_STRING;
	}

	StartDialog(idFile, idDlg, MyUstr);
}

// получаем нужный вариант ответа (1-6) или вопрос (0)
function string GetLine(int line)
{
	if (line == 0)
		return MyUStr.message;
	else
		return MyUStr.answer[line - 1].message;
}

/* 
 * функция, возвращающая номер ответа (0, если ответа нет)
 * так же, загружает из памяти новый диалог, если это необходимо
*/
function int GetAnswer(int idAns)
{
	// нормализуем idAns
	idAns = idAns - 1;

	// если диалог не последний
	if (MyUstr.answer[idAns].parent != 0)
	{
		`log("IdDialog = "$MyUstr.answer[idAns].parent);
		// загружаем в память информацию о новом диалоге из базы
		GetDialog(idFileG, MyUstr.answer[idAns].parent);
		return idAns;
	}
	return 0;
}

//-------------

function StartNewTalk(int questFile, int questID)
{
	// подгружаем в dll нужные переменные
	StartLoadVars();
	
	GFxDialog = new class'Base.GFxMovie_DialogWindow';

	// передаём ссылку на функцию в плеер ролика
	GFxDialog.DialogEvent = DialogEvent;

	// запускаем ролик
	GFxDialog.Start(true);
	GFxDialog.SetFocus(true, true);

	// забираем информацию о диалоге из базы
	GetDialog(questfile, questID);

	// заполняем варианты ответов и запускаем новый диалог
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

	// стартуем новый диалог
	GFxDialog.NewDialog(GetLine(0));
}

DefaultProperties
{
	VarsLoaded = false
}