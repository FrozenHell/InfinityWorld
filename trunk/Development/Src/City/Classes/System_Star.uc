class System_Star extends ClickableActor;

// ������ ������
var float Rad;
var float Mass;
var float Temp;

function initialize()
{
	local int type;
	type = Rand(3)+1; // � ������� ���� ������� ���������� ������������� �������

	switch (type) { // ���
		// ����� �������
		case 1: // ����� ������� (3-10% �� ����)
			Mass = (FRand()*1.4)*19891000; // ��� (����������� �������� - ����)
			Rad = (FRand()*1.6+0.4)*695500;
			Temp = FRand()*5000+20000;
			break;
		// ������� ������������������
		case 2: // B - ����-������� �������
			Mass = (FRand()*1.2)*19891000; // ��� (����������� �������� - ����)
			Rad = (FRand()*1.6+0.4)*695500;
			Temp = FRand()*6000+17000;
			break;
		case 3: // A - ����� �����
			Mass = (FRand()*1.8)*19891000; // ��� (����������� �������� - ����)
			Rad = (FRand()*1.6+0.4)*695500;
			Temp = FRand()*3000+10000;
			break;
		case 4: // F - ����-����� �������
			
			break;
		case 5: // G - ����� �������
			
			break;
		case 6: // K - ��������� �������
			
			break;
		case 7: // M - ������� �������
			
			break;
		// ����������
		case 8: // B - ����-������� ����������
			
			break;
		case 9: // A - ����� ����������
			
			break;
		case 10: // F - ����-����� ����������
			
			break;
		case 11: // G - ����� ����������
			
			break;
		case 12: // K - ��������� ����������
			
			break;
		// �������
		case 13: // B - ����-������� �������
			
			break;
		case 14: // A - ����� �������
			
			break;
		case 15: // F - ����-����� �������
			
			break;
		case 16: // G - ����� �������
			
			break;
		case 17: // K - ��������� �������
			
			break;
		case 18: // M - ������� �������
			
			break;
		default:
			// �������������� �������
			Mass = 666;
			Rad = 666;
			Temp = 666;
			break;
	}
}

defaultProperties
{
	Begin Object Name=StaticMeshComponent
		StaticMesh=StaticMesh'Houses.Stars.MyStar'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	
	Parent_MatInst = MaterialInstanceConstant'Houses.Stars.Starmat_INST'
	MatID = 0
	NormalMatInstLinearColor = (R=1.430000,G=0.900000,B=0.900000,A=1.000000)
	SelectMatInstLinearColor = (R=50.615900,G=40.043331,B=20.067746,A=1.000000)
}