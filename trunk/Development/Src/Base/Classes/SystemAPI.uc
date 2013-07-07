/*
* Copyright FHS
*/
class SystemAPI extends Object
	dllbind(SystemAPI);

struct Message
{
	var string Title;
	var string Text;
};

struct TimeString
{
	var String TimeStr;
	var String Format;
};

dllimport final function int ShowOKMessage(const out Message Mess);
dllimport final function int ShowYESNOMessage(const out Message Mess);
dllimport final function int ShowYESNOCANCELMessage(const out Message Mess);
dllimport final function int ShowABORTRETRYIGNOREMessage(const out Message Mess);
dllimport final function int GetFormattedTime(out TimeString Time);

/* возвращаемые сообщениями значения
 * соответствуют нажатым кнопкам:
 * 1 - OK
 * 2 - Cancel
 * 3 - Abort
 * 4 - Retry
 * 5 - Ignore
 * 6 - Yes
 * 7 - No
*/
function int MessBoxOK(string title, String text) // MB_OK
{
	local Message mess;
	mess.Title = title;
	mess.Text = text;
	return ShowOKMessage(mess);
}

function int MessBoxYESNO(string Title, String Text) // MB_YESNO
{
	local Message mess;
	mess.Title = title;
	mess.Text = text;
	return ShowYESNOMessage(mess);
}

function int MessBoxYESNOCANCEL(string Title, String Text) // MB_YESNOCANCEL
{
	local Message mess;
	mess.Title = title;
	mess.Text = text;
	return ShowYESNOCANCELMessage(mess);
}

function int MessBoxABORTRETRYIGNORE(string Title, String Text) // MB_YESNOCANCEL
{
	local Message mess;
	mess.Title = title;
	mess.Text = text;
	return ShowABORTRETRYIGNOREMessage(mess);
}

// получить форматированное значение текущего времени
function String GetTimeString(optional String format = "%H:%M %d.%m.%Y")
{
	local TimeString currentTime;
	// инициируем строку достаточной длины
	currentTime.TimeStr = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
	// записываем необходимый формат
	currentTime.Format = format;
	// вызов функции dll
	GetFormattedTime(currentTime);
	// возвращаем время
	return currentTime.TimeStr;
}

defaultproperties
{

}