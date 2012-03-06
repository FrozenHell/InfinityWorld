class myhouse extends Actor
	DLLBind(house);

struct cell {
	var actor north,east,west,south,northex,eastex,westex,southex,pol,roof,grain;
};

var int UtoR,Utor2,UtoR3;

var Actor MyPawn;
var cell cell1;
var int length,width,height,lenw,widw,heiw;
var rotator angle;
var vector center;

var array<cell> mass;

dllimport final function GetNavData(out MyNavigationStruct NavData, int len, int wid, int hei, int seed);

simulated event PostBeginPlay() {
	Super.PostBeginPlay();
	UtoR = 90*DegToRad*RadToUnrRot;
	UtoR2 = 180*DegToRad*RadToUnrRot;
	UtoR3 = 270*DegToRad*RadToUnrRot;
}

simulated function Destroyed() {
	cell1.north.destroy();
	cell1.east.destroy();
	cell1.south.destroy();
	cell1.west.destroy();
	cell1.pol.destroy();
	super.Destroyed();
}

private function int isbit(int a,int b) { // возвращает 1 или 0 - бит числа "а" в позиции "b"
	return((a>>b)%2);
}

/*private function rotator UnrRot(float Pitch,float Roll,float Yaw) {
	local rotator Rota;
	local float DegToRot;
	DegToRot = DegToRad*RadToUnrRot;
	Rota.Pitch = Pitch*DegToRot;
	Rota.Roll = Roll*DegToRot;
	Rota.Yaw = Yaw*DegToRot;
	return Rota;
}*/

private function rotator QwatRot(float QYaw) { // очень часто выполняемая функция
	local rotator Rota;
	//Rota.Pitch = 0; // обнуления не нужны
	//Rota.Roll = 0;
	Rota.Yaw = angle.Yaw +(QYaw==0?0:QYaw==1?UtoR:QYaw==2?Utor2:Utor3); //QYaw*90*DegToRad*RadToUnrRot;
	return Rota;
}

private function cell drawcell(int celll,const out vector posit,int wzpos,int wxpos,int wypos,bool st) {
	local cell yachejka;
	yachejka.north=drawHPart(IsBit(celll,7)*2+IsBit(celll,6),3,posit);
	yachejka.east=drawHPart(IsBit(celll,5)*2+IsBit(celll,4),0,posit);
	yachejka.south=drawHPart(IsBit(celll,3)*2+IsBit(celll,2),1,posit);
	yachejka.west=drawHPart(IsBit(celll,1)*2+IsBit(celll,0),2,posit);
	if (!st) yachejka.pol=Spawn(class'City.testfloor',MyPawn,,posit,angle);
	else yachejka.pol=Spawn(class'City.teststair',MyPawn,,posit,angle);
	if (wxpos == 1) yachejka.northex=drawHOutPart(IsBit(celll,7)*2+IsBit(celll,6),3,posit);
	else if (wxpos == 2) yachejka.southex=drawHOutPart(IsBit(celll,3)*2+IsBit(celll,2),1,posit);
	if (wypos == 1) yachejka.eastex=drawHOutPart(IsBit(celll,5)*2+IsBit(celll,4),0,posit);
	else if (wypos == 2) yachejka.westex=drawHOutPart(IsBit(celll,1)*2+IsBit(celll,0),2,posit);
	
	// пол первого этажа лестницы
	if ((wzpos==1)&&(st)) yachejka.roof=Spawn(class'City.teststairfloor',MyPawn,,posit,angle);

	if (wzpos==2) { // если последний этаж
		if (!st) yachejka.roof=Spawn(class'City.testroof',MyPawn,,posit,angle);
		else yachejka.roof=Spawn(class'City.testroofstair',MyPawn,,posit,angle);
		if (wxpos == 1) { // операторы "{" и "}" тут необходимы
			if (wypos == 1) yachejka.grain = Spawn(class'City.testroofang',MyPawn,,posit,qwatrot(3));// верхний левый угол
			else if (wypos == 2) yachejka.grain = Spawn(class'City.testroofang',MyPawn,,posit,qwatrot(2));// нижний левый угол
			else yachejka.grain = Spawn(class'City.testroofgrain',MyPawn,,posit,qwatrot(3)); // лево - середина
		} else if (wxpos == 2) {
			if (wypos == 1) yachejka.grain = Spawn(class'City.testroofang',MyPawn,,posit,qwatrot(0));// верхний правый угол
			else if (wypos == 2) yachejka.grain = Spawn(class'City.testroofang',MyPawn,,posit,qwatrot(1));// нижний правый угол
			else yachejka.grain = Spawn(class'City.testroofgrain',MyPawn,,posit,qwatrot(1)); // право - середина
		} else if (wypos == 1) yachejka.grain = Spawn(class'City.testroofgrain',MyPawn,,posit,qwatrot(0)); // верх - середина
		else if (wypos == 2) yachejka.grain = Spawn(class'City.testroofgrain',MyPawn,,posit,qwatrot(2)); // низ - середина
	} else if (wxpos == 1) { // если не последний этаж
		if (wypos == 1) yachejka.grain = Spawn(class'City.testgrain',MyPawn,,posit,qwatrot(3));// верхний левый угол
		else if (wypos == 2) yachejka.grain = Spawn(class'City.testgrain',MyPawn,,posit,qwatrot(2));// нижний левый угол
	} else if (wxpos == 2) {
		if (wypos == 1) yachejka.grain = Spawn(class'City.testgrain',MyPawn,,posit,qwatrot(0));// верхний правый угол
		else if (wypos == 2) yachejka.grain = Spawn(class'City.testgrain',MyPawn,,posit,qwatrot(1));// нижний правый угол
	}
	return yachejka;
}

function gen(Pawn locpawn,optional int len = 10,optional int wid = 10,optional int hei = 10,optional int seed = 0) {
	local MyNavigationStruct MyData;
	local int i,j,k,wxpos,wypos,wzpos;
	local vector pos;
	local float asin, acos;
	length = len; width = wid; height = hei;
	GetNavData(MyData,length,width,height,seed);
	MyPawn = locpawn;
	angle.Yaw = Rotation.Yaw;
	asin = sin(Rotation.Yaw/RadToUnrRot);
	acos = cos(Rotation.Yaw/RadToUnrRot);
	for (k=0;k<height;k++)
		for (j=0;j<width;j++)
			for (i=0;i<length;i++) {
				pos.x=Location.x+lenw*i*acos-widw*j*asin;
				pos.y=Location.y+lenw*i*asin+widw*j*acos;
				pos.z=Location.z+heiw*k;
				wxpos = i==0?1:i==length-1?2:0;
				wypos = j==0?1:j==width-1?2:0;
				wzpos = k==0?1:k==height-1?2:0;
				cell1 = drawcell(MyData.NavigationData[4+i+j*length+k*length*width],pos,wzpos,wxpos,wypos,(i==MyData.NavigationData[0]&&j==MyData.NavigationData[1])||(i==MyData.NavigationData[2]&&j==MyData.NavigationData[3]));
				// последний параметр в предыдущей строке определяет: находится ли в ячейке лестница
			}
}

function gen2(Pawn locpawn,optional int len = 10,optional int wid = 10,optional int hei = 10,optional int seed = 0) {
	local MyNavigationStruct MyData;
	local int i,j,k,wxpos,wypos,wzpos;
	local vector pos;
	local float asin, acos;
	length = len; width = wid; height = hei;
	GetNavData(MyData,length,width,height,seed);
	MyPawn = locpawn;
	center.x = ((length-1)*lenw/2);
	center.y = ((width-1)*widw/2);
	angle.Yaw = Rotation.Yaw;
	asin = sin(Rotation.Yaw/RadToUnrRot);
	acos = cos(Rotation.Yaw/RadToUnrRot);
	for (k=0;k<height;k++)
		for (j=0;j<width;j++)
			for (i=0;i<length;i++) {
				pos.x=Location.x+(lenw*i-center.x)*acos-(widw*j-center.y)*asin;
				pos.y=Location.y+(lenw*i-center.x)*asin+(widw*j-center.y)*acos;
				pos.z=Location.z+heiw*k;
				wxpos = i==0?1:i==length-1?2:0;
				wypos = j==0?1:j==width-1?2:0;
				wzpos = k==0?1:k==height-1?2:0;
				cell1 = drawcell(MyData.NavigationData[4+i+j*length+k*length*width],pos,wzpos,wxpos,wypos,(i==MyData.NavigationData[0]&&j==MyData.NavigationData[1])||(i==MyData.NavigationData[2]&&j==MyData.NavigationData[3]));
				// последний параметр в предыдущей строке определяет: находится ли в ячейке лестница
			}
}

function invis() {
	//mass[0].north.bHidden=true;
}

private function actor drawHPart(int type,int ang,const out vector posit) { // передавать вектор "по ссылке", а не "по значению", const говорит о том, что вектор не будет меняться в этой функции
	local actor mypExem;
	switch (type) {
		case 0:
			mypExem = Spawn(class'City.testwindow',MyPawn,,posit,qwatrot(ang));
			break;
		case 1:
			mypExem = Spawn(class'City.testwall',MyPawn,,posit,qwatrot(ang));
			break;
		case 2:
			mypExem = Spawn(class'City.testdoor',MyPawn,,posit,qwatrot(ang));
			break;
		case 3:
			mypExem = Spawn(class'City.testspace',MyPawn,,posit,qwatrot(ang));
			break;
		default:
			break;
	}
	return mypExem;
}

private function actor drawHOutPart(int type,int ang,const out vector posit) { // передавать вектор "по ссылке", а не "по значению", const говорит о том, что вектор не будет меняться в этой функции
	local actor mypExem;
	switch (type) {
		case 0:
			mypExem = Spawn(class'City.testwindowex',MyPawn,,posit,qwatrot(ang));
			break;
		case 1:
			mypExem = Spawn(class'City.testwallex',MyPawn,,posit,qwatrot(ang));
			break;
		case 2:
			mypExem = Spawn(class'City.testdoorex',MyPawn,,posit,qwatrot(ang));
			break;
		case 3:
			mypExem = Spawn(class'City.testspaceex',MyPawn,,posit,qwatrot(ang));
			break;
		default:
			break;
	}
	return mypExem;
}

defaultproperties
{
	length = 10
	width = 10
	height = 10
	lenw = 600
	widw = 600
	heiw = 250
}