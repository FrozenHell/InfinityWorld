class messages extends object
	dllbind(Messages);
	
struct Message1 {
	var string Title;
	var string Text;
};

dllimport final function int ShowOKMessage(const out Message1 Mess);
dllimport final function int ShowYESNOMessage(const out Message1 Mess);
dllimport final function int ShowYESNOCANCELMessage(const out Message1 Mess);
dllimport final function int ShowABORTRETRYIGNOREMessage(const out Message1 Mess);

function int MessBoxOK(string title, String text) { // MB_OK
	local Message1 mess;
	mess.Title = title;
	mess.Text = text;
	return ShowOKMessage(mess);
}

function int MessBoxYESNO(string Title,String Text) { // MB_YESNO
	local Message1 mess;
	mess.Title = title;
	mess.Text = text;
	return ShowYESNOMessage(mess);
}

function int MessBoxYESNOCANCEL(string Title,String Text) { // MB_YESNOCANCEL
	local Message1 mess;
	mess.Title = title;
	mess.Text = text;
	return ShowYESNOCANCELMessage(mess);
}

function int MessBoxABORTRETRYIGNORE(string Title,String Text) { // MB_YESNOCANCEL
	local Message1 mess;
	mess.Title = title;
	mess.Text = text;
	return ShowABORTRETRYIGNOREMessage(mess);
}

defaultproperties
{

}