class messages extends object
	dllbind(Messages);
	
struct Message1 {
	var string title;
	var string text;
};

dllimport final function int ShowOKMessage(const out Message1 Mess);
dllimport final function int ShowYESNOMessage(const out Message1 Mess);
dllimport final function int ShowYESNOCANCELMessage(const out Message1 Mess);
dllimport final function int ShowABORTRETRYIGNOREMessage(const out Message1 Mess);

function int MessBoxOK(string Title,String Text) { // MB_OK
	local Message1 mess;
	mess.title = Title;
	mess.text = Text;
	return ShowOKMessage(mess);
}

function int MessBoxYESNO(string Title,String Text) { // MB_YESNO
	local Message1 mess;
	mess.title = Title;
	mess.text = Text;
	return ShowYESNOMessage(mess);
}

function int MessBoxYESNOCANCEL(string Title,String Text) { // MB_YESNOCANCEL
	local Message1 mess;
	mess.title = Title;
	mess.text = Text;
	return ShowYESNOCANCELMessage(mess);
}

function int MessBoxABORTRETRYIGNORE(string Title,String Text) { // MB_YESNOCANCEL
	local Message1 mess;
	mess.title = Title;
	mess.text = Text;
	return ShowABORTRETRYIGNOREMessage(mess);
}

defaultproperties
{

}