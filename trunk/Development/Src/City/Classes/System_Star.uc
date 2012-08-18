class System_Star extends ClickableActor;

// разиус звезды
var float Rad;
var float Mass;
var float Temp;

function initialize()
{
	local int type;
	type = Rand(3)+1; // в будущем надо сделать правильное распределение рандома

	switch (type) { // тип
		// белые карлики
		case 1: // белые карлики (3-10% от всех)
			Mass = (FRand()*1.4)*19891000; // баг (минимальное значение - ноль)
			Rad = (FRand()*1.6+0.4)*695500;
			Temp = FRand()*5000+20000;
			break;
		// главная последовательность
		case 2: // B - бело-голубые карлики
			Mass = (FRand()*1.2)*19891000; // баг (минимальное значение - ноль)
			Rad = (FRand()*1.6+0.4)*695500;
			Temp = FRand()*6000+17000;
			break;
		case 3: // A - белые звёзды
			Mass = (FRand()*1.8)*19891000; // баг (минимальное значение - ноль)
			Rad = (FRand()*1.6+0.4)*695500;
			Temp = FRand()*3000+10000;
			break;
		case 4: // F - жёлто-белые карлики
			
			break;
		case 5: // G - жёлтые карлики
			
			break;
		case 6: // K - оранжевые карлики
			
			break;
		case 7: // M - красные карлики
			
			break;
		// субгиганты
		case 8: // B - бело-голубые субгиганты
			
			break;
		case 9: // A - белые субгиганты
			
			break;
		case 10: // F - жёлто-белые субгиганты
			
			break;
		case 11: // G - жёлтые субгиганты
			
			break;
		case 12: // K - оранжевые субгиганты
			
			break;
		// гиганты
		case 13: // B - бело-голубые гиганты
			
			break;
		case 14: // A - белые гиганты
			
			break;
		case 15: // F - жёлто-белые гиганты
			
			break;
		case 16: // G - жёлтые гиганты
			
			break;
		case 17: // K - оранжевые гиганты
			
			break;
		case 18: // M - красные гиганты
			
			break;
		default:
			// исключительное событие
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