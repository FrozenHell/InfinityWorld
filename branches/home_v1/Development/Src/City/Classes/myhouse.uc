/*
 FrozenHell Skyline, 2012
*/
class myhouse extends Actor
	DLLBind(house);

struct cell {
	var actor north,east,west,south,lex,wex,pol,roof,grain;
	var bool visible;
	
	structdefaultproperties {
		visible = false;
	}
};

var int UtoR,Utor2,UtoR3;

var float asin, acos;

var MyNavigationStruct MyData,MyData2;
var vector ViewLocation; // ��������� ������
var rotator ViewRotation; // ������� ������
var Actor MyPawn;
var int length,width,height,lenw,widw,heiw;
var int distance; // ���������� �� ������ �� ����
var rotator angle;
var vector center; // ��������������� ���������� ��� ����������� ������ ��������� �����
var int visible; // ���������� ����� 0, ����� ��� ����������, �� ��������� �����(��� �������� ���� ��������� �� ������), 2 - ����� ��� ��������� �������, 1 - ����� ��������� ������ �����

var array<cell> mass;

dllimport final function GetNavData(out MyNavigationStruct NavData, int len, int wid, int hei, int seed);
dllimport final function GetNavData2(out MyNavigationStruct NavData,out MyNavigationStruct NavData2, int len, int wid, int hei, int xpos, int ypos, int zpos);

// ������� ��� ���������� ������� �� ����������������
delegate GetPlayerViewPoint( out vector out_Location, out Rotator out_rotation );

// -------------------------------������--------------------------------
state behind {
	function CheckView() {
		if (distance > 5000) {
			gotostate('far');
		}
	}
	
	Begin:
		GetPlayerViewPoint(ViewLocation, ViewRotation);
		distance = VSize(ViewLocation - Location);
		//`log(distance);
		CheckView();
		Sleep(10.0);
		Goto ('Begin');
}

auto state far {
	function CheckView() {
		if (distance < 5000) {
			generate_house(true);
			gotostate('behind');
		} else reload();
	}
	
	Begin:
		GetPlayerViewPoint(ViewLocation, ViewRotation);
		distance = VSize(ViewLocation - Location);
		//`log("long:"@distance);
		CheckView();
		Sleep(distance*0.001);
		Goto ('Begin');
}
// ----------------------------����� �������-----------------------------

simulated event PostBeginPlay() {
	Super.PostBeginPlay();
	UtoR = 90*DegToRad*RadToUnrRot;
	UtoR2 = 180*DegToRad*RadToUnrRot;
	UtoR3 = 270*DegToRad*RadToUnrRot;
}

function Destroyed() {
	clear();
	super.Destroyed();
}

// ������� ������� ��� ������ ����
function clear() {
	local int i;
	if (visible!=0) {
		for (i=0;i<length*width*height;i++) {
			if (mass[i].visible) {
				mass[i].north.destroy();
				mass[i].east.destroy();
				mass[i].south.destroy();
				mass[i].west.destroy();
				mass[i].pol.destroy();
				// ��������� �������� ���������� �� ��� ���� �����
				if (mass[i].lex!=None) mass[i].lex.destroy();
				if (mass[i].wex!=None) mass[i].wex.destroy();
				if (mass[i].roof!=None) mass[i].roof.destroy();
				if (mass[i].grain!=None) mass[i].grain.destroy();
				mass[i].visible=false;
			}
		}
		visible = 0;
	}
}

private function int isbit(int a,int b) { // ���������� 1 ��� 0 (��� ����� "�" � ������� "b")
	return((a>>b)%2);
}

private function int is2bit(int a,int b) { // ���������� ����� �� 0 �� 4
	return((a>>(b+b))%4);
}

/*exec function rotator UnrRot(float Pitch,float Yaw,float Roll) {
	local rotator Rota;
	local float DegToRot;
	DegToRot = DegToRad*RadToUnrRot;
	Rota.Pitch = Pitch*DegToRot;
	Rota.Yaw = Yaw*DegToRot;
	Rota.Roll = Roll*DegToRot;
	return Rota;
}*/

private function rotator QwatRot(float QYaw) { // ����� ����� ����������� �������
	local rotator Rota;
	//Rota.Pitch = 0; // ��������� �� �����
	Rota.Yaw = angle.Yaw +(QYaw==0?0:QYaw==1?UtoR:QYaw==2?Utor2:Utor3); //QYaw*90*DegToRad*RadToUnrRot;
	//Rota.Roll = 0;
	return Rota;
}

private function cell drawcell(int celll,const out vector posit,int wzpos,int wxpos,int wypos,bool st) {
	local cell yachejka;
	yachejka.north=drawHPart(Is2Bit(celll,3),3,posit);
	yachejka.east=drawHPart(Is2Bit(celll,2),0,posit);
	yachejka.south=drawHPart(Is2Bit(celll,1),1,posit);
	yachejka.west=drawHPart(Is2Bit(celll,0),2,posit);
	if (!st) yachejka.pol=Spawn(class'City.testfloor',MyPawn,,posit,angle);
	else yachejka.pol=Spawn(class'City.teststair',MyPawn,,posit,angle);
	if (wxpos == 1) yachejka.lex=drawHOutPart(IsBit(celll,7)*2+IsBit(celll,6),3,posit);
	else if (wxpos == 2) yachejka.lex=drawHOutPart(IsBit(celll,3)*2+IsBit(celll,2),1,posit);
	if (wypos == 1) yachejka.wex=drawHOutPart(IsBit(celll,5)*2+IsBit(celll,4),0,posit);
	else if (wypos == 2) yachejka.wex=drawHOutPart(IsBit(celll,1)*2+IsBit(celll,0),2,posit);
	
	// ��� ������� ����� ��������
	if ((wzpos==1)&&(st)) yachejka.roof=Spawn(class'City.teststairfloor',MyPawn,,posit,angle);
	
	if (wzpos==2) { // ���� ��������� ����
		if (!st) yachejka.roof=Spawn(class'City.testroof',MyPawn,,posit,angle);
		else yachejka.roof=Spawn(class'City.testroofstair',MyPawn,,posit,angle);
		if (wxpos == 1) { // ��������� "{" � "}" ��� ����������
			if (wypos == 1) yachejka.grain = Spawn(class'City.testroofang',MyPawn,,posit,qwatrot(3));// ������� ����� ����
			else if (wypos == 2) yachejka.grain = Spawn(class'City.testroofang',MyPawn,,posit,qwatrot(2));// ������ ����� ����
			else yachejka.grain = Spawn(class'City.testroofgrain',MyPawn,,posit,qwatrot(3)); // ���� - ��������
		} else if (wxpos == 2) {
			if (wypos == 1) yachejka.grain = Spawn(class'City.testroofang',MyPawn,,posit,qwatrot(0));// ������� ������ ����
			else if (wypos == 2) yachejka.grain = Spawn(class'City.testroofang',MyPawn,,posit,qwatrot(1));// ������ ������ ����
			else yachejka.grain = Spawn(class'City.testroofgrain',MyPawn,,posit,qwatrot(1)); // ����� - ��������
		} else if (wypos == 1) yachejka.grain = Spawn(class'City.testroofgrain',MyPawn,,posit,qwatrot(0)); // ���� - ��������
		else if (wypos == 2) yachejka.grain = Spawn(class'City.testroofgrain',MyPawn,,posit,qwatrot(2)); // ��� - ��������
	} else if (wxpos == 1) { // ���� �� ��������� ����
		if (wypos == 1) yachejka.grain = Spawn(class'City.testgrain',MyPawn,,posit,qwatrot(3));// ������� ����� ����
		else if (wypos == 2) yachejka.grain = Spawn(class'City.testgrain',MyPawn,,posit,qwatrot(2));// ������ ����� ����
	} else if (wxpos == 2) {
		if (wypos == 1) yachejka.grain = Spawn(class'City.testgrain',MyPawn,,posit,qwatrot(0));// ������� ������ ����
		else if (wypos == 2) yachejka.grain = Spawn(class'City.testgrain',MyPawn,,posit,qwatrot(1));// ������ ������ ����
	}
	yachejka.visible = true;
	return yachejka;
}

function gen(Pawn locpawn,optional int len = 10,optional int wid = 10,optional int hei = 10,optional int seed = 0) {
	length = len; width = wid; height = hei;
	GetNavData(MyData,length,width,height,seed);
	MyPawn = locpawn;
	center.x = 0; // ������ �� �����, ������ �������� ����� ���������� ����
	center.y = 0;
	angle.Yaw = Rotation.Yaw;
	asin = sin(Rotation.Yaw/RadToUnrRot);
	acos = cos(Rotation.Yaw/RadToUnrRot);
	initialize();
	generate_house();
}

function gen2(Pawn locpawn,optional int len = 10,optional int wid = 10,optional int hei = 10,optional int seed = 0) {
	length = len; width = wid; height = hei;
	GetNavData(MyData,length,width,height,seed);
	MyPawn = locpawn;
	center.x = ((length-1)*lenw/2); // ������ �� �����, ������ �������� ����� ���������� ����
	center.y = ((width-1)*widw/2);
	angle.Yaw = Rotation.Yaw;
	asin = sin(Rotation.Yaw/RadToUnrRot);
	acos = cos(Rotation.Yaw/RadToUnrRot);
	initialize();
	generate_house();
}

private function generate_house(optional bool full=false) {
	local int i,j,k,wxpos,wypos,wzpos,celll;
	local vector pos; // ������� ������
	local vector nav; // ��������������� ���������� ��� ����������� ��������� ������ � ������������� ����������� ������
	
	// ����� ������� � ������� ������
	GetPlayerViewPoint( ViewLocation, ViewRotation );
	
	nav.x = (ViewLocation.x-Location.x)*acos+(ViewLocation.y-Location.y)*asin;
	nav.y = (Location.x-ViewLocation.x)*asin+(ViewLocation.y-Location.y)*acos;
	nav.z = ViewLocation.z-Location.z;
	GetNavData2(MyData,MyData2,length,width,height,nav.x,nav.y,nav.z);
	
	if (visible<2) {
		for (k=0;k<height;k++)
			for (j=0;j<width;j++)
				for (i=0;i<length;i++) {
				celll = i+j*length+k*length*width;
					pos.x=Location.x+(lenw*i-center.x)*acos-(widw*j-center.y)*asin;
					pos.y=Location.y+(lenw*i-center.x)*asin+(widw*j-center.y)*acos;
					pos.z=Location.z+heiw*k;
					wxpos = i==0?1:i==length-1?2:0; // ������ ��������� � ����, ������ ��� � ������� ����?
					wypos = j==0?1:j==width-1?2:0; // ��� ������ ���
					wzpos = k==0?1:k==height-1?2:0; // ��� ��������� ���
					// ���� ������ ������ ���� ������, � ��� ������
					if ((full || (MyData2.NavigationData[4+celll] == 2)) && !mass[celll].visible)	{
						// ������ �
						mass[celll] = drawcell(MyData.NavigationData[4+celll],pos,wzpos,wxpos,wypos,(i==MyData.NavigationData[0]&&j==MyData.NavigationData[1])||(i==MyData.NavigationData[2]&&j==MyData.NavigationData[3]));
						// ��������� �������� � ���������� ������ ����������: ��������� �� � ������ ��������
					// �����, ���� ������ ������ ���� ������, � ��� ������
					} else if (!(full || (MyData2.NavigationData[celll] == 2)) && mass[celll].visible) {
						// ������� ���������� �����
						mass[celll].north.destroy();
						mass[celll].east.destroy();
						mass[celll].south.destroy();
						mass[celll].west.destroy();
						mass[celll].pol.destroy();
						// ��������� �������� ���������� �� ��� ���� �����
						if (mass[celll].lex!=None) mass[celll].lex.destroy();
						if (mass[celll].wex!=None) mass[celll].wex.destroy();
						if (mass[celll].roof!=None) mass[celll].roof.destroy();
						if (mass[celll].grain!=None) mass[celll].grain.destroy();
						// �������, ��� ������ ������
						mass[celll].visible=false;
					}
				}
	}
	visible = full?2:1;
}

function initialize() {
	local int i,j,k;
	local cell celll; // ��� ���������� ����� �������������, ���� �������� �� ������� ��������� ������
	// ������, ����� ��������� �� ������
	for (k=0;k<height;k++)
		for (j=0;j<width;j++)
			for (i=0;i<length;i++)
				mass[i+j*length+k*length*width] = celll;
}

private function actor drawHPart(int type,int ang,const out vector posit) { // ���������� ������ "�� ������", � �� "�� ��������", const ������� � ���, ��� ������ �� ����� �������� � ���� �������
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

private function actor drawHOutPart(int type,int ang,const out vector posit) { // ���������� ������ "�� ������", � �� "�� ��������", const ������� � ���, ��� ������ �� ����� �������� � ���� �������
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

function reload() {
	generate_house();
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