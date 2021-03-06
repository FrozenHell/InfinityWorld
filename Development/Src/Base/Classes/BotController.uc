class BotController extends AIController;

// ��������������� ���������� �������������
enum AltBool
{
    Zero, One
};

// ��������� ���������
enum States
{
    Expecting,  // �����������
    Warning,    // ���������������
    Attacking,  // �����
    Defending,  // ������
    Escaping    // �������
};
var States CurrentState;    //������� ���������

// ���������� ��������
var float Health;                           // �������� 
var float HealthCriticalForDefence;         // ����� �������� ��� �������� � ������
var float HealthCriticalForFlight;          // ����� �������� ��� �������� � �������

var byte bHDl;                         // �������� ���� ����. ������ ������
var byte bHDh;                         // �������� ���� ����. ������ ������
var byte bHFl;                         // �������� ���� ����. ������ �������    
var byte bHFh;                         // �������� ���� ����. ������ �������    

// ���������� ���������������      
var byte  bEnemyIsFounded;                              // ���� ���������   
var float EnemyIsFoundedStartTime;                      // ����� �������     
var float EnemyIsFoundedTimeInterval;                   // ������������ ��������� �����     
var float EnemyIsFoundedCriticalTimeInterval;           // ����. ����� ������������ ��������� ����� ��� �����    
var float EnemyIsFoundedCriticalTimeIntervalForWarning; // ����. ����� ������������ ��������� ����� ��� �������     

var byte bEFh;  // ������������ ��������� ����� ���� ����. ������ �����  
var byte bEFl;  // ������������ ��������� ����� ���� ����. ������ �����  
var byte bEFWh; // ������������ ��������� ����� ���� ����. ������ �������  
var byte bEFWl; // ������������ ��������� ����� ���� ����. ������ �������  

var float SilentEnvironmentTimeInterval;            // ������������ "�����" ����������
var float SilentEnvironmentCriticalTimeInterval;    // ����. ����� ������������ "�����" ����������      

var byte bSEh;                         // ������������ "�����" ���������� ���� ����. ������     
var byte bSEl;                         // ������������ "�����" ���������� ���� ����. ������    

var float NoiseAlarmDistance;       // ��������� ���������� ��������� ������ 

//var array<> AlarmSounds           // ������ ��������� ������
var float tForgetNA;                // ������� ������� ����� �������� �������� �������
var byte bHearingNoises;            // ��� ������� ��������� ����

var byte bHearingShoots;            // ��������� ���������� ��������� 
var float ShootsAbsenceAfterFight;  // ������������ ���������� ���������
var float ShootsAbsenceCriticalIntreval;
var float bSAh;
var float bSAl;

var byte bNoHearingShoots;          // �� ���� ������ ���������

var byte bHearedNA;                 // ��� ������� ����������� ��� 

var byte bEnemyIsDown;              // ���� ��������

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* ��� ���������� ��������� */

var array <byte> EnteringValues;    // �������� �������� 

const COUNT_OF_STATES = 5;          // ���������� ��������� ���������

struct VectorOfWeights              // ���� ��� �������� ��������
{
    var float Weights[19];
};

struct ArrayOfWeights               // �������-������� ��� ���� �������� ���������
{
    var VectorOfWeights _VectorOfWeights [COUNT_OF_STATES]; 
};

var ArrayOfWeights _ArrayOfWeights[COUNT_OF_STATES]; // ���������� �������

var float Soma[COUNT_OF_STATES];    // ���������


var vector LastEnemyPos;
var vector TargetLocation;
var Pawn Enemy1;

var UTWeap_RocketLauncher RL;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* ���������� ����� */

var array <NavNode> _OpenSet;
var array <NavNode> _ClosedSet;

var NavNode _NavNode;

var vector vHitLocation, vHitNormal;

///////////////////////////////////////////////////////////////////////////////////////////////////////////

var Pawn SomePawn; // ���������� � �����-���� Pawn'�
var Pawn NavigationPawn;

var vector Enemy_LastLocation;
var rotator Enemy_LastRotation;
var vector Enemy_FocalPoint;

var rotator PawnRotation;  // ��������� Pawn'� �� �������� � ��������� ���������������
var vector PawnLocation;   // ������� Pawn'� �� �������� � ��������� ���������������
var vector PawnFocalPoint;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

var float Amnesium;         // ����� ��������� ��������� ��������
var float Amnesium_limit;   // ����� ������� ���������

////////////////////////////////////////////////////////////////////////////////////////////////////////////

var float FiringDistance;
var float DefendingDistance;
var float EscapingDistance;

var bool FiringWhileMove;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

var NavNode TNodeCameFrom;
var NavNode NextNode;
var bool bDestinationIsReachable;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
*	event PostBeginPlay()
*	{
*		super.PostBeginPlay();
*	}
*/

// ������� ����� � ����������
function ClearArrays() 
{
    local int i,j,k;
    
    for ( i = 0; i < COUNT_OF_STATES; i++)
    for ( j = 0; j < COUNT_OF_STATES; j++)
    for ( k = 0; k < 19; k++)
    {
        _ArrayOfWeights[i]._VectorOfWeights[j].Weights[k] = 0;
        Soma[i] = 0;
    }
}

// ���������� �������� ������� ��-���������
function SetDefaultEnteringValues()
{
    local byte i;
    for ( i = 0; i < EnteringValues.length; i++ )
    EnteringValues[i] = default.EnteringValues[i];
}

// ������������ �����
function SetWeights() 
{
    //___________________________________________________
    //��� ��������� SEEKING //////////////////////////
    
    //SEEKING 
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[0] = 1;      //Seeking
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[1] = 0;     //Warning
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[2] = 0;      //Attacking
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[3] = 0;      //Defending
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[4] = 0;      //Escaping
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[5] = 0;      //bHDl
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[6] = 0;      //bHDh
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[7] = 0;      //bHFl
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[8] = 0;      //bHFh
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[9] = 0;      //bEFl
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[10] = 0;     //bEFh
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[11] = 0;     //bEFWl
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[12] = 0;     //bEFWh
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[13] = 0;     //bSEl
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[14] = 0;     //bSEh
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[15] = 0;     //bNoise
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[16] = 0;     //bSeeEnemy
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[17] = 0;     //bNoShoots
    _ArrayOfWeights[0]._VectorOfWeights[0].Weights[18] = 0;     //bEnemyDown
    
    //WARNING 
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[0] = 0;      //Seeking
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[1] = 0;      //Warning
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[2] = 0;      //Attacking
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[3] = 0;      //Defending
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[4] = 0;      //Escaping
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[5] = 0;      //bHDl
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[6] = 0;      //bHDh
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[7] = 0;      //bHFl
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[8] = 0;      //bHFh
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[9] = 0;      //bEFl
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[10] = 0;     //bEFh
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[11] = 0;     //bEFWl
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[12] = 2;     //bEFWh
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[13] = 0;     //bSEl
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[14] = 0;     //bSEh
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[15] = 2;     //bNoise
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[16] = 0;     //bSeeEnemy
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[17] = 0;     //bNoShoots
    _ArrayOfWeights[0]._VectorOfWeights[1].Weights[18] = 0;     //bEnemyDown
    
    //Attacking 
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[0] = 0;      //Seeking
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[1] = 0;      //Warning
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[2] = 0;      //Attacking
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[3] = 0;      //Defending
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[4] = 0;      //Escaping
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[5] = 0;      //bHDl
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[6] = 0;      //bHDh
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[7] = 0;      //bHFl
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[8] = 0;      //bHFh
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[9] = 0;      //bEFl
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[10] = 5;     //bEFh
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[11] = 0;     //bEFWl
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[12] = 0;     //bEFWh
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[13] = 0;     //bSEl
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[14] = 0;     //bSEh
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[15] = 0;     //bNoise
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[16] = 0;     //bSeeEnemy
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[17] = 0;     //bNoShoots
    _ArrayOfWeights[0]._VectorOfWeights[2].Weights[18] = 0;     //bEnemyDown
    
    //Defending 
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[0] = 0;      //Seeking
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[1] = 0;      //Warning
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[2] = 0;      //Attacking
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[3] = 0;     //Defending
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[4] = 0;      //Escaping
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[5] = 0;      //bHDl
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[6] = 0;      //bHDh
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[7] = 0;      //bHFl
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[8] = 0;      //bHFh
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[9] = 0;      //bEFl
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[10] = 0;     //bEFh
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[11] = 0;     //bEFWl
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[12] = 0;     //bEFWh
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[13] = 0;     //bSEl
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[14] = 0;     //bSEh
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[15] = 0;     //bNoise
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[17] = 0;     //bNoShoots
    _ArrayOfWeights[0]._VectorOfWeights[3].Weights[18] = 0;     //bEnemyDown
    
    //Escaping 
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[0] = 0;      //Seeking
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[1] = 0;      //Warning
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[2] = 0;      //Attacking
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[3] = 0;      //Defending
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[4] = 0;      //Escaping
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[5] = 0;      //bHDl
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[6] = 0;      //bHDh
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[7] = 0;      //bHFl
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[8] = 0;      //bHFh
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[9] = 0;      //bEFl
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[10] = 0;     //bEFh
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[11] = 0;     //bEFWl
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[12] = 0;     //bEFWh
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[13] = 0;     //bSEl
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[14] = 0;     //bSEh
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[15] = 0;     //bNoise
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[16] = 0;     //bSeeEnemy
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[17] = 0;     //bNoShoots
    _ArrayOfWeights[0]._VectorOfWeights[4].Weights[18] = 0;     //bEnemyDown
    
    //___________________________________________________
    //��� ��������� WARNING //////////////////////////
    
    //SEEKING 
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[1] = 0;     //Warning
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[3] = 0;     //Defending
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[14] = 3;    //bSEh
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[1]._VectorOfWeights[0].Weights[18] = 0;    //bEnemyDown
    
    // WARNING 
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[1] = 1;     //Warning
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[3] = 0;     //Defending
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[1]._VectorOfWeights[1].Weights[18] = 0;    //bEnemyDown
    
    //Attacking 
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[1] = 0;     //Warning
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[3] = 0;     //Defending
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[16] = 5;    //bSeeEnemy
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[1]._VectorOfWeights[2].Weights[18] = 0;    //bEnemyDown
    
    //Defending 
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[1] = 0;     //Warning
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[3] = 0;     //Defending
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[1]._VectorOfWeights[3].Weights[18] = 0;    //bEnemyDown
    
    //Escaping 
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[1] = 0;     //Warning
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[3] = 0;     //Defending
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[1]._VectorOfWeights[4].Weights[18] = 0;    //bEnemyDown  
    
    //___________________________________________________
    //��� ��������� ATTACKING //////////////////////////
    
    //SEEKING 
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[1] = 0;     //Warning
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[3] = 0;     //Defending
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[2]._VectorOfWeights[0].Weights[18] = 3;    //bEnemyDown
    
    //WARNING 
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[1] = 0;     //Warning
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[3] = 0;     //Defending
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[2]._VectorOfWeights[1].Weights[18] = 0;    //bEnemyDown
    
    //Attacking 
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[1] = 0;     //Warning
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[2] = 1;     //Attacking
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[3] = 0;     //Defending
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[2]._VectorOfWeights[2].Weights[18] = 0;    //bEnemyDown
    
    //Defending 
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[1] = 0;     //Warning
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[3] = 0;     //Defending
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[5] = 2;     //bHDl
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[2]._VectorOfWeights[3].Weights[18] = 0;    //bEnemyDown
    
    //Escaping 
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[1] = 0;     //Warning
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[3] = 0;     //Defending
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[2]._VectorOfWeights[4].Weights[18] = 0;    //bEnemyDown
    
    //___________________________________________________
    //��� ��������� DEFENDING //////////////////////////
    
    //SEEKING 
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[1] = 0;     //Warning
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[3] = 0;     //Defending
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[3]._VectorOfWeights[0].Weights[18] = 6;    //bEnemyDown
    
    //WARNING 
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[1] = 0;     //Warning
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[3] = 0;     //Defending
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[3]._VectorOfWeights[1].Weights[18] = 0;    //bEnemyDown
    
    //Attacking 
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[1] = 0;     //Warning
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[3] = 0;     //Defending
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[6] = 5;     //bHDh
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[16] = 0;     //bSeeEnemy
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[3]._VectorOfWeights[2].Weights[18] = 0;    //bEnemyDown
    
    //Defending 
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[1] = 0;     //Warning
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[3] = 3;      //Defending
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[3]._VectorOfWeights[3].Weights[18] = 0;    //bEnemyDown
    
    //Escaping 
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[1] = 0;     //Warning
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[3] = 0;     //Defending
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[7] = 2;      //bHFl
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[17] = 2;     //bNoShoots
    _ArrayOfWeights[3]._VectorOfWeights[4].Weights[18] = 0;    //bEnemyDown  
    
    //___________________________________________________
    //��� ��������� ESCAPING //////////////////////////
    
    //SEEKING 
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[1] = 0;     //Warning
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[3] = 0;     //Defending
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[4]._VectorOfWeights[0].Weights[18] = 0;    //bEnemyDown
    
    //WARNING 
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[1] = 0;     //Warning
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[3] = 0;     //Defending
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[4]._VectorOfWeights[1].Weights[18] = 0;    //bEnemyDown
    
    //Attacking 
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[1] = 0;     //Warning
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[3] = 0;     //Defending
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[4]._VectorOfWeights[2].Weights[18] = 0;    //bEnemyDown
    
    //Defending 
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[1] = 0;     //Warning
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[3] = 0;     //Defending
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[4] = 0;     //Escaping
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[8] = 2;     //bHFh
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[4]._VectorOfWeights[3].Weights[18] = 0;    //bEnemyDown
    
    //Escaping 
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[0] = 0;     //Seeking
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[1] = 0;     //Warning
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[2] = 0;     //Attacking
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[3] = 0;     //Defending
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[4] = 1;     //Escaping
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[5] = 0;     //bHDl
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[6] = 0;     //bHDh
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[7] = 0;     //bHFl
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[8] = 0;     //bHFh
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[9] = 0;     //bEFl
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[10] = 0;    //bEFh
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[11] = 0;    //bEFWl
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[12] = 0;    //bEFWh
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[13] = 0;    //bSEl
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[14] = 0;    //bSEh
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[15] = 0;    //bNoise
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[16] = 0;    //bSeeEnemy
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[17] = 0;    //bNoShoots
    _ArrayOfWeights[4]._VectorOfWeights[4].Weights[18] = 0;    //bEnemyDown     
    
    `log("---------------------!!!!!!!!!!!!!--------------");
}

// �������� ����� ���������
function byte GetNumberOfState() 
{
    local int i;
    for (i=0; i < COUNT_OF_STATES; i++)
    if (EnteringValues[i]==1)
    return i;
}

// ���������� ���������
function SetNumberOfState(int _Number) 
{
    local int i, Number;
    Number = _Number;
    for (i =  0; i < COUNT_OF_STATES; i++)
    if (i ==  Number)
    EnteringValues[i] = 1;
    else
    EnteringValues[i] = 0;
    
}

// �������� �������� ���������
function ChangeBehaviour(int _Number) 
{
    SetNumberOfState(_Number);
    
    switch(GetNumberOfState())
    {
        case 0:
        CurrentState = States.Expecting;
        GotoState('Expecting');
        break;
        
        case 1:
        CurrentState = States.Warning;
        GotoState('Warning');
        break;
        
        case 2:
        CurrentState = States.Attacking;
        GotoState('Attacking');
        break;
        
        case 3:
        CurrentState = States.Defending;
        GotoState('Defending');
        break;
        
        case 4:
        CurrentState = States.Escaping;
        GotoState('Escaping');
        break;
    }
}

// ��������� ������ �������� ��������
function FillEnetringValues() 
{
    EnteringValues[5]=bHDl; 
    EnteringValues[6]=bHDh; 
    EnteringValues[7]=bHFl; 
    EnteringValues[8]=bHFh; 
    EnteringValues[9]=bEFl; 
    EnteringValues[10]=bEFh; 
    EnteringValues[11]=bEFWl;
    EnteringValues[12]=bEFWh;
    EnteringValues[13]=bSEl;
    EnteringValues[14]=bSEh;
    EnteringValues[15]=bHearingNoises; 
    EnteringValues[16]=bEnemyIsFounded; 
    EnteringValues[17]=bNoHearingShoots; 
    EnteringValues[18]=bEnemyisDown; 
}

// ���������� ����� ���������
// � ����������� ������� � ����� ���������
function bool SolveBehaviour() 
{
    local int i,j,max,Number, NumberOfState;
    
    max = 0;
    
    FillEnetringValues();
    
    for (j = 0; j < COUNT_OF_STATES; j++)
    Soma[j] =0 ;
    
    NumberOfState = GetNumberOfState();
    
    for (i = 0; i < 19; i++) // ����������� �������� ��������
    for (j = 0; j < COUNT_OF_STATES; j++) // ����������� ������� ���������
    Soma[j] += EnteringValues[i]* _ArrayOfWeights[NumberOfState]._VectorOfWeights[j].Weights[i];
    
    for (j = 0; j < COUNT_OF_STATES; j++) 
    {
        //`log(Soma[j]);
        if (Soma[j]>=max) 
        {
            max = Soma[j]; 
            Number=j; 
        }
    }
    
    if (GetNumberOfState() != Number)   // ���� ������� ����� ��������� �� ����� ����������
    {
        `log(Number);
        ChangeBehaviour(Number);        // ������ ���������
        `log("New state is" @ CurrentState);
        return true;                    // � ���������� ������������� ����� ��������� ���������.
    }
    else return false;                  // ����� - ���������� �����.
}

simulated event postbeginplay()
{	
    CurrentState = States.Expecting;
    SetWeights();
}

// Enemy ����� ��� ���� ������, ���� ���� ���������� ����������� (�����).
// ������� �����������, ����� LineOfSightTo() ����� ���������� false
event EnemyNotVisible()
{
    `log("I don't see Enemy"); 
}  

// ������������ ���� � ���������������� �������� ��������� ��� �����������
function vector GetNextDestinationPoint(optional vector FinalDest, optional bool bFullRecalculation = false)
{
	local NavNode NN;	
	
	if (bFullRecalculation == true)	// ���� ��������� ������ ������ ����,
	{	`log("Full recalculation");
		TNodeCameFrom = none;
		bDestinationIsReachable = false;	// �� ������������� �� ���������, ��� ����� ���������� �� ���������.		
		GoToPoint(FinalDest); 		// �������� ��������� ������������ ����.		
	}	
	
	if ( CheckTheWay(FinalDest) == true  )	// E��� ���������, ��� ���� �� �����,
	{	`log("Final destination is reachable"@_NavNode@CheckTheWay(FinalDest));		
		bDestinationIsReachable = true;	// ����� ���������, ���  �� ������ ���������� ����� ����� ��� �����
		if (  FinalDest != vect(0,0,0) ) 
			return FinalDest;		// � ��������� �������� ����������		
		else
			return Pawn.Location;		// ��� ���������� ������������ Pawn'� � �������� �������.
	}	
	else						// ���� ���� ��� ���������, ��� ���� ������ ��������, �����
	{	`log("Using NavNode");	
		TNodeCameFrom = _NavNode;
		NN = _NavNode;				// ���������� ������� ����.
		_NavNode = _NavNode.CameFrom;	// �������� ������� ���� ���������.
		if (NN != none)
			return NN.Location;				// ���������� ���������� �������� ����.	
		else
		{
			bDestinationIsReachable = true;
			return Pawn.Location;
		}
	}
}

// �������� ���� � ���������� �� ����
//	�� ����������� ����������� ��������.
function bool CheckTheWay( vector FinalDestination )
{
	local NavNode NN;	// ���������� ���� ��� ������������ ���������� ��������� �����
	local float 	LengthOfStraightWay, LengthOfWay;	// ����� ����� �������� � �� �����	
	
	if ( _NavNode == none )
		return true;
		
	LengthOfWay 			= 0.0 + VSize ( Pawn.Location - _NavNode.Location ) + VSize ( FinalDestination - _NavNode.Location );
	LengthOfStraightWay 	= 0.0;	
	
	NN = _NavNode;
	if (_NavNode != none)
		do
		{
			LengthOfWay += NN.f;
			NN = NN.CameFrom;
		}
		until (NN == none);	
	
	LengthOfStraightWay = VSize (Pawn.Location - FinalDestination);	
	
	if ( Trace ( vHitLocation, vHitNormal, FinalDestination, Pawn.Location,true ) == none && LengthOfStraightWay < LengthOfWay)
	{	`log("The straight way is better");
		return true;
	}
	else
	{	`log("The node's way is better");
		return false;
	}
}


// �������� ����������� ������� ��� �����
function vector GetFiringPos(vector AimLoc)
{
	local float x;	
	local Actor _Actor;
	local NavNode locNode, TargetNode;
	
	// ������� ������ � ��������� ������������, ����������� ����� Pawn'�� � AimLoc
	_Actor = Trace (  vHitLocation,  vHitNormal, AimLoc + Normal(Pawn.Location - AimLoc) * FiringDistance , AimLoc, true);
	if (_Actor != none)
		`log (_Actor@_Actor.Location@vHitLocation );
	
	// ���� Pawn ���������� ������������ AimLoc ������ FiringDistance
	// u ���� �������� ����������� �� ���� ����������	
	if ( VSize( Pawn.Location - AimLoc ) != FiringDistance && IsZero(vHitLocation) )
		return AimLoc + Normal(Pawn.Location - AimLoc) * FiringDistance;	// ���������� ���������� ������� ��� �����
	else
	{	`log("The wall is very close");
		x = 1000.0;
		foreach OverlappingActors(class'NavNode', locNode, 1000.0, AimLoc,false)	// �������� � ������ ����� � ������� SearchR 
		{		
			//`log ( Abs (VSize(AimLoc - locNode.Location) - FiringDistance) );
			if ( Abs (VSize(AimLoc - locNode.Location) - FiringDistance) < x 
				&& 
			Trace (  vHitLocation,  vHitNormal, locNode.Location, AimLoc, true ) == none )		
			{	// ���� ��������� ����� AimLoc'�� � ����� ������ ����������� ���������, ��
				x = Abs (VSize(AimLoc - locNode.Location) - FiringDistance);		// ���������� ������� ���������	
				TargetNode = locNode; //`log ("TargetNode"@TargetNode);
			}	
			
		}
		//x = VSize (AimLoc - vHitLocation) - 50;		
		//return AimLoc + Normal(Pawn.Location - AimLoc) * x;		
		
		return TargetNode.Location;
	}
	
}

// �������, ������������ ���������� ������� ��� �������
// ��������! ������������ ������ ���������� ������-���� ����,
// �,�, ������������� ������������ ������ � GetNextDestinationPoint
function vector GetDefendingPoint()
{
	local NavNode 	locNode; 		// ���������� ���� ��� ������������ ���������� ��������� �����

	if ( Enemy != none)
	{	
	foreach AllActors(class'NavNode', locNode)						// �������� � ������ �����.	
		if ( DefendingDistance - VSize (Enemy.Location - locNode.Location) < 100 && Trace (  vHitLocation,  vHitNormal, locNode.Location, Enemy.Location,true ) == none )
			break;	
	
	if ( locNode == none ) 
		foreach AllActors(class'NavNode', locNode)						// �������� � ������ �����.	
			if ( DefendingDistance - VSize (Enemy.Location - locNode.Location) < 100 )
				break;
	
	if ( locNode == none ) 
		foreach AllActors(class'NavNode', locNode)						// �������� � ������ �����.	
			if ( DefendingDistance - VSize (Enemy.Location - locNode.Location) < DefendingDistance )
				break;	
		
	`log("Defending node"@locNode);	
	if ( locNode != none )
		return locNode.Location;	
	else 
		return Enemy.Location + Normal(Pawn.Location - Enemy.Location) * DefendingDistance;
	}
}

function vector GetEscapingPoint()
{
	local NavNode 	locNode; 		// ���������� ���� ��� ������������ ���������� ��������� �����

	if ( Enemy != none)
	{
	
	foreach AllActors(class'NavNode', locNode)						// �������� � ������ �����.	
		if ( VSize (Enemy.Location - locNode.Location) > EscapingDistance && Trace (  vHitLocation,  vHitNormal, locNode.Location, Enemy.Location,true ) != none )
			break;	
	
	if ( locNode == none ) 
	foreach AllActors(class'NavNode', locNode)						// �������� � ������ �����.	
		if ( VSize (Enemy.Location - locNode.Location) > EscapingDistance / 2 && Trace (  vHitLocation,  vHitNormal, locNode.Location, Enemy.Location,true ) != none )
			break;	
	
	if ( locNode == none ) 
	foreach AllActors(class'NavNode', locNode)						// �������� � ������ �����.	
		if ( VSize (Enemy.Location - locNode.Location) > EscapingDistance )
			break;	
	
	`log("Escaping node"@locNode);
	
	if ( locNode != none )
		return locNode.Location;	
	else 
		return Enemy.Location + Normal(Pawn.Location - Enemy.Location) * EscapingDistance;
		
	}
}


/*
// ��� ����� ������
event SeePlayer(Pawn Seen)
{
	Enemy1 = Seen;
	`log("���: ���� �����!");
	GoToPoint(Enemy1.Location);
}

// ��� ������ ���
event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	LastEnemyPos = NoiseMaker.Location;
	//Enemy1 = none; // �� ������
	`log("���: ����� �����!");
	GoToPoint(LastEnemyPos);
	// ��������� �������������� �����������, ����� ���������������� ��������� ������
	// Super.HearNoise(Loudness, NoiseMaker, NoiseType);
}

// ��� �������� �����������
event TakeDamage(int DamageAmount, Controller EventInstigator, vector vHitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Enemy1 = EventInstigator.Pawn;
	GoToPoint(Enemy1.Location);
	// ��������� �������������� �����������, ����� ���������������� ��������� ������
	// Super.TakeDamage(DamageAmount, EventInstigator, vHitLocation,�Momentum, DamageType, HitInfo, DamageCauser);
}
*/

// ����������� ����
function GoToPoint(vector endPoint, optional actor _actor = none)
{
	local NavNode 	locNode, 		// ���������� ���� ��� ������������ ���������� ��������� �����
					StartNode, 	// ������ ���� � ����
					TargetNode;	// �������� ����
					
	local float 	Range; 		// ���������� ����� ��������� ����� � ������������� Pawn'�
	
	Range = 1000.0;
	foreach OverlappingActors(class'NavNode', locNode, 1000.0, Pawn.Location,false)	// �������� � ������ ����� � ������� SearchR 	
		if (VSize(Pawn.Location - locNode.Location) < Range && Trace (  vHitLocation,  vHitNormal, locNode.Location, Pawn.Location, true ) == none )		// ���� ��������� ����� Pawn'�� � ����� ������ ����������� ���������, ��
		{
			Range = VSize(Pawn.Location - locNode.Location);		// ���������� ������� ���������
			StartNode = locNode;								// � ���������� ���� ����.			
		}		
	
	Range = 1000.0;
	foreach OverlappingActors(class'NavNode', locNode, 1000.0, endPoint,false)	// �������� � ������ ����� � ������� SearchR 
		if (VSize(endPoint - locNode.Location) < Range && Trace (  vHitLocation,  vHitNormal, locNode.Location, endPoint, true ) == none )	
		{
			Range = VSize(endPoint - locNode.Location);
			TargetNode = locNode;			
		}		
	//`log ("GoToPoint"@StartNode@TargetNode);
	
	if (StartNode == none || TargetNode == none)
	{	`log("Node not found"@StartNode@TargetNode);
		_NavNode = None;	// �� ���������� ������ ����
		return;
	}	
	if (VSize(Pawn.Location - endPoint) <= VSize(Pawn.Location - StartNode.Location) && Trace (  vHitLocation,  vHitNormal, endPoint, Pawn.Location, true ) == none ) // ���� ���� �� Pawn'� � endPoind'� ������, ��� ��  Pawn'� � ����		
	{	`log("Straight is better");
		_NavNode = None;	// �� ���������� ������ ����
	}
	else
	{	`log("Calculating path...");
		_NavNode = CreatePath(StartNode, TargetNode);	// ����� ���-���� ���������� ������������ ������������� ����
	}
}

// ������� ���� �� ��� ��� �����������
function NavNode CreatePath(NavNode END_POINT, NavNode START_POINT)
{
    local NavNode Current, locNode;
	local float tentative_g_score, min_f;
	local bool isClosed, isOpen;
	local int j, k;
	
	_OpenSet.Remove(0,_OpenSet.Length);
	_ClosedSet.Remove(0,_ClosedSet.Length);
	foreach AllActors(class'NavNode', locNode)						// �������� � ������ �����.	
		locNode.CameFrom = none;	

	ToOpenSet(START_POINT, END_POINT);

	//min_f = 100000.0;
	while (_OpenSet.Length > 0)					// ���� � �������� ������ ����� ���� ������������� ����:
    {
        min_f = _OpenSet[ _OpenSet.Length-1 ].f + 1;					
		For (j=0; j<_OpenSet.Length;j++)			// 1. ������� ����������� ����
			if (_OpenSet[j].f < min_f)
            {
				min_f = _OpenSet[j].f;
                Current = _OpenSet[j];					
            }

		if (Current == END_POINT)
			break;

		_ClosedSet[_ClosedSet.Length] = Current;	// � ��������� ��� � �������� ������

        For (j = 0; j < _OpenSet.Length; j++)
			if (_OpenSet[j] == Current)
            {
				_OpenSet.RemoveItem(_OpenSet[j]);
                break;
            }

		for (j = 0; j < Current.Links.Length; j++)	// 2. ��������� ��� �������� ���� ���� ����
		{
			isClosed = false;
			for (k=0;k<_ClosedSet.Length;k++)
				if (_ClosedSet[k] == Current.Links[j])
				{
					isClosed = true;
					break;
				}
			if (isClosed) continue;

			tentative_g_score = (Current.g + VSize(Current.Location - Current.Links[j].Location));

			isOpen = false;
			for (k=0;k<_OpenSet.Length;k++)
				if (_OpenSet[k] == Current.Links[j])
				{
					isOpen = true;
					if (tentative_g_score < _OpenSet[k].g )
					{
						_OpenSet[k].CameFrom = Current;
						_OpenSet[k].g = tentative_g_score;
						_OpenSet[k].h = VSize( _OpenSet[k].Location -  END_POINT.Location);
						_OpenSet[k].f =  _OpenSet[k].g +  _OpenSet[k].h;
					}
					else break;
				}

			if (isOpen == false)	// 3. ������ �������� ���� � �������� ������, ���� ��� ��� ���.
			{
				Current.Links[j].CameFrom = Current;
				Current.Links[j].g = tentative_g_score;
				Current.Links[j].h = VSize(Current.Links[j].Location - END_POINT.Location);
				Current.Links[j].f = Current.Links[j].g +Current.Links[j].h;
				_OpenSet[_OpenSet.Length] = Current.Links[j];
			}
		}
	}
	return Current;
}

function ToOpenSet(NavNode first, NavNode last)
{
	first.g = 0.0;
	first.h = VSize(first.Location - last.Location);
	first.f = first.h;
	_OpenSet[_OpenSet.Length] = first;
}

/*�������� �����������
	����������� �������� ���� ������� �������� ��� ����� ��������� �����������
	� ����� ��������� ����� ��������� SolveBehaviour */
function CheckValues()
{
	//EXPECTING
	if ( CurrentState == States.Expecting)
	{
		if (EnemyIsFoundedTimeInterval >= EnemyIsFoundedCriticalTimeIntervalForWarning)
		{ 	`log("I am ready for warning!");		
			bEFWh = 1; bEFWl = 0;
		}
		else
		{
			bEFWh = 0; bEFWl = 1;
		}
			
		if (EnemyIsFoundedTimeInterval >= EnemyIsFoundedCriticalTimeInterval)
		{	`log("I am ready for attacking!");		
			bEFh = 1; bEFl = 0;		   
		}
		else
		{
			bEFh = 0; bEFl = 1;		   
		}
	}
 
	//WARNING
	if ( CurrentState == States.Warning)
	{
		if (bEnemyIsFounded == 1)
			`log("I am ready for attacking!");
		
		if (SilentEnvironmentTimeInterval >= SilentEnvironmentCriticalTimeInterval)
		{	`log("I am ready for expecting!");
			bSEh = 1; bSEl = 0;
		}
		else
		{
			bSEh = 0; bSEl = 1;
		}
	}
	
	//ATTACKING
	if ( CurrentState == States.Attacking)
	{
		if ( Enemy == none )
		{	`log("I am ready for expecting!");
			bEnemyIsDown = 1;
		}
		else
			bEnemyIsDown = 0;
		
		if (Pawn.Health <  (Pawn.default.Health / 2) )
		{	`log("I am ready for defending!");
			bHDl = 1; bHDh = 0;
		}
		else
		{
			bHDl = 0; bHDh = 1;
		}
	}

	//DEFENDING
	if ( CurrentState == States.Defending)
	{
		if ( Enemy == none )
		{	`log("I am ready for expecting!");
			bEnemyIsDown = 1;
		}
		else
		{
			bEnemyIsDown = 0;
		}
			
		if (Pawn.Health >  (Pawn.default.Health / 2) )
		{	`log("I am ready for attacking!");
			bHDl = 0; bHDh = 1;
		}
		else
		{
			bHDl = 1; bHDh = 0;
		}
			
		if (Pawn.Health < (Pawn.default.Health / 4) )
		{    
			bHFl = 1; bHFh = 0; 
		}        
		else
		{
			bHFl = 0; bHFh = 1; 
		}
			
		if ( ShootsAbsenceAfterFight >= ShootsAbsenceCriticalIntreval )
		{	
			bSAh = 1; bSAl = 0; bNoHearingShoots = 1; 
		}
		else
		{
			bSAh = 0; bSAl = 1; bNoHearingShoots = 0; 
		}
			
		if (bSAh == 1 && bHFl == 1)
			`log("I am ready for escaping!"); 
	}

	// ESCAPING
	if ( CurrentState == States.Escaping )
	{
		if ( Enemy == none )
		{	//`log("I am ready for expecting!");
			bEnemyIsDown = 1;
		}
		else
		{
			bEnemyIsDown = 0;
		}	
        
		if (Pawn.Health >  (Pawn.default.Health / 4) )
		{	//`log("I am ready for defending!");
			bHFl = 0; bHFh = 1;
		}	
		else
		{
			bHFl = 1; bHFh = 0;
		}	
	}
	
	SolveBehaviour();
}

// �������� ��������� � ��������� �����������
auto state Expecting
{ 
    function SetLimits()     // ��������� ��������� ��������
    {
        EnemyIsFoundedCriticalTimeIntervalForWarning = 0.1;
        EnemyIsFoundedCriticalTimeInterval = 0.5;
        Amnesium_limit = 2.0;
    }
    
	function ResetValues() // ��������� �������� � ��������
    {
        Enemy = none;
        SomePawn = none;
        Amnesium = 0.0;
        
        EnemyIsFoundedStartTime = 0.0;
        EnemyIsFoundedTimeInterval = 0.0;
        bEnemyIsFounded = 0;
        
        bEFWh   = 0; bEFWl  = 1;
        bEFh    = 0; bEFl   = 1;
    }
    
    function BeginState (Name PreviousStateName)    // ������������� ���������
    {
        SetLimits();
        ResetValues();
        `log("I am in expecting state");
    }
    
    event SeePlayer (Pawn Seen) // �����-���� ����� � ������ ������
    {
		if (Enemy != Seen && Trace (  vHitLocation,  vHitNormal, Seen.Location, Pawn.Location, true )  == Seen)	// ���� ���������� ��� �� ��������� ����� Pawn'�
			Enemy = Seen;                          	// �� ���������� ���.		
		
		if ( Enemy != none )	// ������, ���� ���� ������� � ������, �����		
		{
			SomePawn = Enemy;                           	// �������� ����� � ��������� ������,
			Enemy_LastLocation = Enemy.Location;              	// � ��� ������������,
			Enemy_LastRotation = Enemy.Rotation;            	// � ��� ���������� ��������.
			Enemy_FocalPoint = Enemy.Controller.GetFocalPoint();	// � ����������� ������� ���.
		}
		if (bEnemyIsFounded != 1)                               // ���� ���� ����������� ����� ��� �� �������
		{
			EnemyIsFoundedStartTime = WorldInfo.TimeSeconds;    // ���������� ����� �������,
			bEnemyIsFounded = 1;                                // �������� ���� �����������
		}
		EnemyIsFoundedTimeInterval                              // � ��������� ����� ��������� ����� ���������
		= WorldInfo.TimeSeconds - EnemyIsFoundedStartTime;      // ����� ������ ������� � ������� ��������

    }
    
    event Tick (float DeltaTime)
    {
        If ( Enemy != none && CanSee(Enemy) && LineOfSightTo(Enemy))    // ���� ���� ���� � �� ���������, ��
        {
            Amnesium = 0;                                         	// �������� ������� ���������
            CheckValues();                                             // ������������� �������� �������
            if ( bEFh != 1)        				                  	// � ���� ����� ����������� �� ���������, �����
				Enemy = none;                                        // �������� ����� �����
        }
        else 
        if ( bEnemyIsFounded == 1 )                                	// ����� ���� ���� ��� �������
        {
            if ( Amnesium < Amnesium_limit || bEFh != 1 )             		// ���� ��� ����� ��������� �� ���������, ��
				Amnesium += DeltaTime;                                    // ��������� ������������ ���������� �����
            if ( Amnesium >= Amnesium_limit )                           	// � ���� ������������ ��������� ���� ������
            {               
                CheckValues();                                       	// �� ������ �������� ������������� �������                
                ResetValues();                                         // �� �������� � �� �������
            }
        }
    }
    
    function EndState (Name NextStateName) // ����� �� ���������
    {
        PawnLocation = Pawn.Location;
        PawnRotation = Pawn.Rotation;
        PawnFocalPoint = GetFocalPoint();
    }
}

// �������� ��������� � ��������� ����������������
state Warning
{
    
    function ResetValues() // ��������� �������� � ��������
    {
        SilentEnvironmentTimeInterval = 0.0;
        bSEh = 0; bSEl = 1;
        bEnemyIsFounded = 0;
    }
    
    function BeginState (Name PreviousStateName) // ������������� ���������
    {
        ResetValues();
        `log("I am in warning state");        
        //SpeakingPawn(Pawn).PlayWarningSound();
    }
    
    event SeePlayer(Pawn Seen)
    {
        if (Enemy != Seen || Enemy == none)
        Enemy = Seen;
        bEnemyIsFounded = 1;
        CheckValues();
    }
    
    function Rotate() // �������� Pawn'� �� 90 ��������
    {
        local rotator NewRotation;
        
        NewRotation = Pawn.GetViewRotation();
        NewRotation.Yaw += 65535 / 4;
        pawn.LockDesiredRotation(False);
        pawn.SetDesiredRotation(NewRotation, false , false , 2.0f, false);
        Pawn.LockDesiredRotation(True, false);
    }
    
    event Tick(float DeltaTime)
    {
        SilentEnvironmentTimeInterval += DeltaTime;
    }
    
    function EndState (Name NextStateName)
    {
        pawn.LockDesiredRotation(False);
    }
    
    Begin:
    
    SetFocalPoint(Enemy_LastLocation);                      // Pawn ���������� ������ � ������� ��������� ������� �������� �����.    	
	MoveTo( GetNextDestinationPoint(Enemy_LastLocation, true) );  			//  Pawn ������������ ������� � ������� ���������� �����
			
			while ( bDestinationIsReachable != true )										// ���� ���� ������� �� ���������� �����, 				
				MoveTo( GetNextDestinationPoint(Enemy_LastLocation) );	// �� ����� ����������� � ��������� �������,				
				MoveTo(Enemy_LastLocation);		
    SetFocalPoint(Enemy_FocalPoint);                        // Pawn ���������� ���� ������ � ����������� ������� ������������ �����.    
    
    Inspection: // Pawn �������������.
    Rotate();
    FinishRotation();
    sleep (Rand(2)-FRand());
    
    End:
    if (SilentEnvironmentTimeInterval >= SilentEnvironmentCriticalTimeInterval)
    {		
        //SpeakingPawn(Pawn).PlayExpectingSample();
		pawn.LockDesiredRotation(False);
        MoveTo(PawnLocation);
        SetFocalPoint(PawnFocalPoint);
        CheckValues();
    }
    else Goto('Inspection');
}

// �������� ��������� � ��������� �����
State Attacking
{
    function ResetValues()
    {
        bEnemyIsDown = 0;
        bHDl = 0; bHDh = 1;
    }
    
    function BeginState (Name PreviousStatename)
    {
        ResetValues();
        `log("I am in attacking state");
       `log(Enemy);
	   SpeakingPawn(Pawn).PlayAttackingSound();
        
        //pawn.LockDesiredRotation(False);
    }
    
    event SeePlayer(Pawn Seen)
    {
        Enemy = Seen;
    }
    
    event EnemyNotVisible()
    {
        `log ("I lost him!");
        //Enemy = none;
    }
    
    event Tick(float DeltaTime)
    {
        CheckValues();
		
		if ( Trace (  vHitLocation,  vHitNormal, Enemy.Location, Pawn.Location,true ) == Enemy )
		if ( vector(Pawn.GetViewRotation()) dot Normal(Enemy.Location - Pawn.Location) > 0.75 )
		{
			Pawn.StartFire(0);   	// ����������			
			Pawn.StopFire(0);	// ���������� ��������
		}
    }
    
    function EndState (Name NextStateName)
    {
        
    }
    
Begin:
    if (Enemy != none)
    {   `log("1----------------------------------------------------------------------------------------------");     
		
        IF	// ���� ���� ������� ������ ��� ��� �� ����� ������ �����������,
			( VSize (Enemy.Location - Pawn.Location) > FiringDistance + 50 || Trace (  vHitLocation,  vHitNormal, Enemy.Location, Pawn.Location, true )  != Enemy )	// �����				
        {	`log("2");     				
			MoveTo( GetNextDestinationPoint( GetFiringPos(Enemy.Location), true), Enemy); //  ����������� ������� �����������.				
			while ( bDestinationIsReachable != true )							// ���� ���� ������� �� ���������� �����, 
			{	`log("3");     			
				MoveTo( GetNextDestinationPoint( GetFiringPos(Enemy.Location) ), Enemy);	// ��  ������������ � ��������� �������				
			}
			`log("4-----------------------------------------------------------------------------------------");     
			if ( Trace (  vHitLocation,  vHitNormal, Enemy.Location, Pawn.Location,true ) == Enemy ) // ���� ������ ���� �����, �����
				MOVETO ( GetFiringPos(Enemy.Location) , Enemy);			
			else 
				GoTo('Begin');
		}
        else
		{	`log("5");     		
			MoveToward(Enemy, Enemy, FiringDistance );	// ������ �������� � ��� �������	
			
			goto('End');
		}
    } 
    else goto('Middle');
    
Middle:    
    
End:	
    if (Enemy!=none)
		goto('Begin');
    else 
    {
        //SpeakingPawn(Pawn).PlayExpectingSample();
        MoveTo(PawnLocation);
        SetFocalPoint(PawnFocalPoint);
        CheckValues();
    }
}


// �������� ��������� � ��������� ������
State Defending
{   
    
    function ResetValues() // ��������� �������� � ��������
    {
        bHDl = 1; bHDh = 0;
        bHFl = 0; bHFh = 1;
		bSAh = 0; bSAl = 1;
        bEnemyIsDown = 0;
		bNoHearingShoots = 0;
    }
    
    function BeginState (Name PreviousStateName) // ������������� ���������
    {
        `log("I am in defending state");
        ResetValues();
    }
    
    event SeePlayer(Pawn Seen)
    {
        Enemy = Seen;
    }
    
    event Tick (float DeltaTime)
    {
		local float Angle;
		
		Angle = vector(Enemy.GetViewRotation()) dot Normal(Pawn.Location - Enemy.Location);		
		
		if ( Enemy != none )		
			if ( Enemy.Weapon.IsFiring() && Angle > 0.80 )
				ShootsAbsenceAfterFight = 0.0;
			else
				ShootsAbsenceAfterFight += DeltaTime;
				
		`log("Shoots absence"@ShootsAbsenceAfterFight);
			
	
        CheckValues();
    }
    
    event EnemyNotVisible()
    {
        Enemy = none;
    }
    
    function EndState (Name NextStateName) // ������������� ���������
    {
        StopLatentExecution();

    }
  
    Begin:    
    
    HoldingDistance:
   if (Enemy != none)
    {   `log("1");     
        if ( VSize ( Pawn.Location - Enemy.Location ) < DefendingDistance - 50)  					// ���� ���� ������� ������
        {	`log("2");     				
			MoveTo( GetNextDestinationPoint( GetDefendingPoint(), true) );  			//  Pawn ������������ ������� � �����
			
			while ( bDestinationIsReachable != true )										// ���� ���� ������� �� ���������� �����, 
			{	`log("3");     			
				MoveTo( GetNextDestinationPoint(), Enemy );	// �� ����� ����������� � ��������� �������,			
			}
			`log("4");     
			if ( Trace (  vHitLocation,  vHitNormal, Enemy.Location, Pawn.Location,true ) == Enemy )
				MoveTo( Enemy.Location + Normal(Pawn.Location - Enemy.Location) * DefendingDistance, Enemy);
			else 
				GoTo('Begin');
			
			GoTo('Begin');     
		}
        else
		{	`log("5");     		
			//MoveTo( Enemy.Location + Normal(Pawn.Location - Enemy.Location) * DefendingDistance, Enemy);	// ������ �������� � ��� �������			
			MoveTo(Pawn.Location, Enemy);	// ������ �������� � ��� �������			
			Pawn.StartFire(0);                                             // ����������			
			Pawn.StopFire(0);
			Sleep( FRand() * 3 );
        
			goto('End');
		}
    } 
    else goto('Middle');
    
Middle:    
    
    End:
    if (Enemy == none)
    {
        //SpeakingPawn(Pawn).PlayExpectingSample();
        MoveTo(PawnLocation);
        SetFocalPoint(PawnFocalPoint);
        CheckValues();
    }
    else  GoTo('Begin');
}

// �������� ��������� � ��������� �������
State Escaping
{
    function ResetValues() // ��������� �������� � ��������
    {
        bHFl = 1; bHFh = 0;
        bEnemyIsDown = 0;
    }
    
    function BeginState (Name PreviousStateName) // ������������� ���������
    {
        `log("I am in escaping state");
        ResetValues();
    }
    
    event SeePlayer(Pawn Seen)
    {
        Enemy = Seen;
    }
    
    event Tick (float DeltaTime)
    {
        CheckValues();
    }
    
    event EnemyNotVisible()
    {
        //Enemy = none;
		//StopLatentExecution();
    }
    
    function EndState (Name NextStateName) // ������������� ���������
    {
        StopLatentExecution();
    }
    
    Begin:
    
    
    HoldingDistance:
   if (Enemy != none)
    {   `log("1");     
        if ( VSize ( Pawn.Location - Enemy.Location ) < EscapingDistance - 50)  					// ���� ���� ������� ������
        {	`log("2");     				
			MoveTo( GetNextDestinationPoint( GetEscapingPoint(), true ) );  			//  Pawn ������������ ������� � �����
			
			while ( bDestinationIsReachable != true )										// ���� ���� ������� �� ���������� �����, 
			{	`log("3");     			
				MoveTo( GetNextDestinationPoint( Enemy.Location ), Enemy );	// �� ����� ����������� � ��������� �������,			
			}
			`log("4"@Enemy.Location);     
			if ( Trace (  vHitLocation,  vHitNormal, Enemy.Location, Pawn.Location,true ) == Enemy )
				MoveTo(Enemy.Location, Enemy, EscapingDistance);
			else 
				GoTo('Begin');
			
			GoTo('Begin');     
		}
        else
		{	`log("5");     		
			sleep (1.0);
			/* MoveToward(Enemy , Enemy, DefendingDistance);                                       // ������ �������� � ��� �������			
			Pawn.StartFire(0);                                              // ����������
			Pawn.StopFire(0); */
        
			goto('End');
		}
    } 
    else goto('Middle');
    
Middle:    
    
    End:
    if (Enemy == none)
    {
        //SpeakingPawn(Pawn).PlayExpectingSample();
        MoveTo(PawnLocation);
        SetFocalPoint(PawnFocalPoint);
        CheckValues();
    }
    else  GoTo('Begin');
}

defaultproperties
{
    bDestinationIsReachable = false;
    
	EnemyIsFoundedCriticalTimeIntervalForWarning = 0.1
	
	EnemyIsFoundedCriticalTimeInterval = 0.5
	
    SilentEnvironmentCriticalTimeInterval = 5.0
	
	ShootsAbsenceCriticalIntreval = 10.0
    
    FiringDistance = 500.0
    
    DefendingDistance = 800.0
    
    EscapingDistance = 2000.0
    
    //___________________________________________
    // ��������� ������ �������� ��������
    EnteringValues[0]=1
    EnteringValues[1]=0
    EnteringValues[2]=0
    EnteringValues[3]=0
    EnteringValues[4]=0
    
    EnteringValues[5]=0 //bHDl
    EnteringValues[6]=1 //bHDh - ������� ��������� �������� ��-��������� � �����
    EnteringValues[7]=0 //bHFl
    EnteringValues[8]=1 //bHFh - ������� ��������� �������� ��-��������� � �����
    EnteringValues[9]=1 //bEFl
    EnteringValues[10]=0 //bEFh
    EnteringValues[11]=1 //bEFWl
    EnteringValues[12]=0 //bEFWh
    EnteringValues[13]=0 //bSEl
    EnteringValues[14]=1 //bSEh - ����� ����������
    EnteringValues[15]=0 //bHearingNoises
    EnteringValues[16]=0 //bEnemyIsFounded
    EnteringValues[17]=1 //bNoHearingShoots - �� ������ ���������
    EnteringValues[18]=0 //bEnemyisDown
    //___________________________________________
    
    
    
}