class BotController extends AIController;

// вспомогательный логический перечислитель
enum AltBool
{
    Zero, One
};

// состояния поведения
enum States
{
    Expecting,  // спокойствие
    Warning,    // настороженность
    Attacking,  // атака
    Defending,  // защита
    Escaping    // бегство
};
var States CurrentState;    //текущее состояние

// ПОКАЗАТЕЛИ ЗДОРОВЬЯ
var float Health;                           // Здоровье 
var float HealthCriticalForDefence;         // Порог здоровья для перехода к защите
var float HealthCriticalForFlight;          // Порог здоровья для перехода к бегству

var byte bHDl;                         // здоровье ниже крит. порога защиты
var byte bHDh;                         // здоровье выше крит. порога защиты
var byte bHFl;                         // здоровье ниже крит. порога бегства    
var byte bHFh;                         // здоровте выше крит. порога бегства    

// ПОКАЗАТЕЛИ НАСТОРОЖЕННОСТИ      
var byte  bEnemyIsFounded;                              // враг обнаружен   
var float EnemyIsFoundedStartTime;                      // точка отсчета     
var float EnemyIsFoundedTimeInterval;                   // длительность видимости врага     
var float EnemyIsFoundedCriticalTimeInterval;           // крит. порог длительности видимости врага для атаки    
var float EnemyIsFoundedCriticalTimeIntervalForWarning; // крит. порог длительности видимости врага для тревоги     

var byte bEFh;  // длительность видимости врага выше крит. порога атаки  
var byte bEFl;  // длительность видимости врага ниже крит. порога атаки  
var byte bEFWh; // длительность видимости врага выше крит. порога тревоги  
var byte bEFWl; // длительность видимости врага ниже крит. порога тревоги  

var float SilentEnvironmentTimeInterval;            // длительность "тихой" обстановки
var float SilentEnvironmentCriticalTimeInterval;    // крит. порог длительности "тихой" обстановки      

var byte bSEh;                         // длительность "тихой" обстановки выше крит. порога     
var byte bSEl;                         // длительность "тихой" обстановки ниже крит. порога    

var float NoiseAlarmDistance;       // дистанция восприятия тревожных звуков 

//var array<> AlarmSounds           // массив тревожных звуков
var float tForgetNA;                // отрезок времени после которого проходит тревога
var byte bHearingNoises;            // был услушан тревожный звук

var byte bHearingShoots;            // дистанция восприятия выстрелов 
var float ShootsAbsenceAfterFight;  // длительность отсутствия выстрелов
var float ShootsAbsenceCriticalIntreval;
var float bSAh;
var float bSAl;

var byte bNoHearingShoots;          // не было слышно выстрелов

var byte bHearedNA;                 // был услышан посторонний шум 

var byte bEnemyIsDown;              // враг повержен

////////////////////////////////////////////////////////////////////////////////////////////////////////////

/* КУБ ВЫЧИСЛЕНИЯ СОСТОЯНИЙ */

var array <byte> EnteringValues;    // входящие значения 

const COUNT_OF_STATES = 5;          // количество состояний поведения

struct VectorOfWeights              // веса для входящих значений
{
    var float Weights[19];
};

struct ArrayOfWeights               // векторы-акценты для всех учтенных состояний
{
    var VectorOfWeights _VectorOfWeights [COUNT_OF_STATES]; 
};

var ArrayOfWeights _ArrayOfWeights[COUNT_OF_STATES]; // трехмерная матрица

var float Soma[COUNT_OF_STATES];    // сумматоры


var vector LastEnemyPos;
var vector TargetLocation;
var Pawn Enemy1;

var UTWeap_RocketLauncher RL;

var array <NavNode> _OpenSet;
var array <NavNode> _ClosedSet;

var NavNode _NavNode;

var vector HitLocation, HitNormal;

///////////////////////////////////////////////////////////////////////////////////////////////////////////

var Pawn SomePawn; // информация о каком-либо Pawn'е
var Pawn NavigationPawn;

var vector Enemy_LastLocation;
var rotator Enemy_LastRotation;
var vector Enemy_FocalPoint;

var rotator PawnRotation;  // положение Pawn'а до перехода в состояние настороженности
var vector PawnLocation;   // позиция Pawn'а до перехода в состояние настороженности
var vector PawnFocalPoint;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

var float Amnesium;         // время забывания тревожных сигналов
var float Amnesium_limit;   // порог времени забывания

////////////////////////////////////////////////////////////////////////////////////////////////////////////

var float FiringDistance;
var float DefendingDistance;
var float EscapingDistance;

var bool FiringWhileMove;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

var NavNode TNodeCameFrom;
var NavNode NextNode;
var bool bDestinationIsReached;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
*	event PostBeginPlay()
*	{
*		super.PostBeginPlay();
*	}
*/

// очистка весов и сумматоров
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

// установить входящие значеня по-умолчанию
function SetDefaultEnteringValues()
{
    local byte i;
    for ( i = 0; i < EnteringValues.length; i++ )
    EnteringValues[i] = default.EnteringValues[i];
}

// формирование весов
function SetWeights() 
{
    //___________________________________________________
    //ДЛЯ СОСТОЯНИЯ SEEKING //////////////////////////
    
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
    //ДЛЯ СОСТОЯНИЯ WARNING //////////////////////////
    
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
    //ДЛЯ СОСТОЯНИЯ ATTACKING //////////////////////////
    
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
    //ДЛЯ СОСТОЯНИЯ DEFENDING //////////////////////////
    
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
    //ДЛЯ СОСТОЯНИЯ ESCAPING //////////////////////////
    
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

// получить номер состояния
function byte GetNumberOfState() 
{
    local int i;
    for (i=0; i < COUNT_OF_STATES; i++)
    if (EnteringValues[i]==1)
    return i;
}

// установить состояние
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

// поменять текущиее состояние
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

// заполнить вектор входящих значений
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

// определить новое состояние
// и осуществить переход в новое состояние
function bool SolveBehaviour() 
{
    local int i,j,max,Number, NumberOfState;
    
    max = 0;
    
    FillEnetringValues();
    
    for (j = 0; j < COUNT_OF_STATES; j++)
    Soma[j] =0 ;
    
    NumberOfState = GetNumberOfState();
    
    for (i = 0; i < 19; i++) // перечисляем входящие значения
    for (j = 0; j < COUNT_OF_STATES; j++) // перечисляем нейроны состояний
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
    
    if (GetNumberOfState() != Number)   // если текущий номер состояния не равен следующему
    {
        `log(Number);
        ChangeBehaviour(Number);        // меняем состояние
        `log("New state is" @ CurrentState);
        return true;                    // и вовзращаем подтверждение факта изменения состояния.
    }
    else return false;                  // Иначе - возвращаем отказ.
}

simulated event postbeginplay()
{
    CurrentState = States.Expecting;
    SetWeights();
}

// Enemy будет вне поля зрения, если есть физическое препятствие (стена).
// Событие срабатывает, когда LineOfSightTo() будет возвращать false
event EnemyNotVisible()
{
    `log("I don't see Enemy"); 
}  

// формирование пути и последовательное указание координат для перемещения
function vector GetNextDestinationPoint(vector CurrentLocation,optional vector FinalDestination, optional bool bFullRecalculation = false)
{
	local NavNode NN;	
	
	
	if (bFullRecalculation == true)					// Если требуетсмя полный пересчет пути,
	{
		bDestinationIsReached = false;					// то устанавливаем по умолчанию, что пункт назначения не достигнут
		TNodeCameFrom = none;					// и ещё не известен предыдущий узел перемещения.
		
		GoToPoint(FinalDestination); 					// Вызываем процедуру формирования пути.
		
		if (CurrentState != States.Defending && CurrentState != States.Escaping)
		if ( _NavNode != none && CheckTheWay(_NavNode) == true )	// Проверяем, можно ли все же пойти напрямик?
		{										// И если это так, то
			bDestinationIsReached = true;				// сообщаем об этом
			return Pawn.Location;					// и возвращаем расположение Pawn'в в качестве затычки
		}
	}		
	
	if (_NavNode == none)						// Если после просчета пути или просто так оказалось, что путь не нужен,
	{			
		bDestinationIsReached = true;					// тогда указываем, что пункта назначения можно достигнуть без узлов
		return Pawn.Location;						// и возвращаем в качестве затычки для функции расположение самого Pawn'а
	}	
    else										// Иначе		
	{
		NN = _NavNode;
		_NavNode = _NavNode.CameFrom;
		return NN.Location;	
	}
	
}

// Проверка пути и расстояния до цели
//	на возможность перемещения напрямик.
function bool CheckTheWay( NavNode CheckedNavNode )
{
	local NavNode NN;	// Переменная узла для перечисления некоторого множества узлов
	local float 	LengthOfWay, LengthOfStraightWay;		// длины путей напрмик и по узлам
				LengthOfWay 			= 0.0 + VSize ( Pawn.Location - _NavNode.Location ) + VSize ( Enemy.Location - _NavNode.Location );
				LengthOfStraightWay 	= 0.0;	
	
	NN = CheckedNavNode;
		if (_NavNode != none)
			do
			{
				LengthOfWay += NN.f;
				NN = NN.CameFrom;
			}
			until (NN == none);	
	
	LengthOfStraightWay = VSize (Pawn.Location - Enemy.Location);	
	
	if ( Trace (  HitLocation,  HitNormal, Enemy.Location, Pawn.Location,true ) == Enemy && LengthOfStraightWay < LengthOfWay )
		return true;
	else 
		return false;
}

// Функция, возвращающая координаты позиции для обороны
// ВНИМАНИЕ! ВОЗВРАЩАЕТСЯ ТОЛЬКО КООРДИНАТА КАКОГО-ЛИБО УЗЛА,
// Т,Е, РЕКОМЕНДУЕТСЯ ИСПОЛЬЗОВАТЬ ВМЕСТЕ С GetNextDestinationPoint
function vector GetDefendingPoint()
{
	local NavNode 	locNode; 		// Переменная узла для перечисления некоторого множества узлов

	if ( Enemy != none)
	{	
	foreach AllActors(class'NavNode', locNode)						// Работаем с каждым узлом.	
		if ( 1000 - VSize (Enemy.Location - locNode.Location) < 100 && Trace (  HitLocation,  HitNormal, locNode.Location, Enemy.Location,true ) == none )
			break;	
	
	if ( locNode == none ) 
		foreach AllActors(class'NavNode', locNode)						// Работаем с каждым узлом.	
			if ( VSize (Enemy.Location - locNode.Location) > 1000 && Trace (  HitLocation,  HitNormal, locNode.Location, Enemy.Location,true ) == none)
				break;
	
	if ( locNode == none ) 
		foreach AllActors(class'NavNode', locNode)						// Работаем с каждым узлом.	
			if ( 1000 - VSize (Enemy.Location - locNode.Location) < 100 )
				break;
	
	if ( locNode == none ) 
		foreach AllActors(class'NavNode', locNode)						// Работаем с каждым узлом.	
			if ( 1000 - VSize (Enemy.Location - locNode.Location) > 1000 )
				break;				
	}
		
	//`log("Defending node"@locNode);
	
	if ( locNode != none )
		return locNode.Location;	
	else 
		return Enemy.Location + Normal(Pawn.Location - Enemy.Location) * DefendingDistance;
}

function vector GetEscapingPoint()
{
	local NavNode 	locNode; 		// Переменная узла для перечисления некоторого множества узлов

	if ( Enemy != none)
	{
	
	foreach AllActors(class'NavNode', locNode)						// Работаем с каждым узлом.	
		if ( VSize (Enemy.Location - locNode.Location) > 2000 && Trace (  HitLocation,  HitNormal, locNode.Location, Enemy.Location,true ) != none )
			break;	
	
	foreach AllActors(class'NavNode', locNode)						// Работаем с каждым узлом.	
		if ( VSize (Enemy.Location - locNode.Location) > 1000 && Trace (  HitLocation,  HitNormal, locNode.Location, Enemy.Location,true ) != none )
			break;	
	}
	
	foreach AllActors(class'NavNode', locNode)						// Работаем с каждым узлом.	
		if ( VSize (Enemy.Location - locNode.Location) > 2000 )
			break;	
	
	`log("Escaping node"@locNode);
	
	if ( locNode != none )
		return locNode.Location;	
	else 
		return Enemy.Location + Normal(Pawn.Location - Enemy.Location) * EscapingDistance;
}


/*
// бот видит игрока
event SeePlayer(Pawn Seen)
{
	Enemy1 = Seen;
	`log("Бот: вижу врага!");
	GoToPoint(Enemy1.Location);
}

// бот слышит шум
event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	LastEnemyPos = NoiseMaker.Location;
	//Enemy1 = none; // на всякий
	`log("Бот: слышу врага!");
	GoToPoint(LastEnemyPos);
	// полностью перезаписываем стандартное, иначе раскоментировать следующую строку
	// Super.HearNoise(Loudness, NoiseMaker, NoiseType);
}

// бот получает повреждения
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Enemy1 = EventInstigator.Pawn;
	GoToPoint(Enemy1.Location);
	// полностью перезаписываем стандартное, иначе раскоментировать следующую строку
	// Super.TakeDamage(DamageAmount, EventInstigator, HitLocation,иMomentum, DamageType, HitInfo, DamageCauser);
}
*/
// бежать к точке
function GoToPoint(vector endPoint, optional actor _actor = none)
{
	local NavNode 	locNode, 		// Переменная узла для перечисления некоторого множества узлов
					StartNode, 	// Первый узел в пути
					TargetNode;	// Конечный узел
					
	local float 	minRange1, 		// расстояние между ближайшим узлом и расположением Pawn'а
				minRange2;		// расстояние между ближайшим узлом и endPoind'ом
	
	minRange1 = 1000000.0;
	minRange2 = 1000000.0;

	foreach AllActors(class'NavNode', locNode)						// Работаем с каждым узлом.
	{ 
		if (VSize(Pawn.Location - locNode.Location) < minRange1  )		// Если дистанция между Pawn'ом и узлом меньше минимальной дистанции, то
		if ( Trace (  HitLocation,  HitNormal, locNode.Location, Pawn.Location, true ) == none )
		{
			minRange1 = VSize(Pawn.Location - locNode.Location);		// запоминаем меньшую дистанцию
			StartNode = locNode;								// и запоминаем этот узел.			
		}

		if (VSize(endPoint - locNode.Location) < minRange2 )			// то же самое по отношению к endPoind'у
		if ( Trace (  HitLocation,  HitNormal, locNode.Location, endPoint, true ) == none )
		{
			minRange2 = VSize(endPoint - locNode.Location);
			TargetNode = locNode;			
		}
	}	
	
	if (VSize(Pawn.Location - endPoint) <= VSize(Pawn.Location - StartNode.Location) ) // Если путь от Pawn'а к endPoind'у короче, чем от  Pawn'а к узлу
		_NavNode = None;	// то возвращаем пустой узел
	else
		_NavNode = CreatePath(StartNode, TargetNode);	// иначе все-таки возвращаем определенный навигационный узел
}

// создать путь из нод для путешествия
function NavNode CreatePath(NavNode END_POINT, NavNode START_POINT)
{
    local NavNode Current, locNode;
	local float tentative_g_score, min_f;
	local bool isClosed, isOpen;
	local int j, k;
	
	_OpenSet.Remove(0,_OpenSet.Length);
	_ClosedSet.Remove(0,_ClosedSet.Length);
	foreach AllActors(class'NavNode', locNode)						// Работаем с каждым узлом.	
		locNode.CameFrom = none;	

	ToOpenSet(START_POINT, END_POINT);

	//min_f = 100000.0;
	while (_OpenSet.Length > 0)					// Пока в открытом списке узлов есть непроверенные узлы:
    {
        min_f = _OpenSet[ _OpenSet.Length-1 ].f + 1;					
		For (j=0; j<_OpenSet.Length;j++)			// 1. Находим оптимальный узел
			if (_OpenSet[j].f < min_f)
            {
				min_f = _OpenSet[j].f;
                Current = _OpenSet[j];					
            }

		if (Current == END_POINT)
			break;

		_ClosedSet[_ClosedSet.Length] = Current;	// и переносим его в закрытый список

        For (j = 0; j < _OpenSet.Length; j++)
			if (_OpenSet[j] == Current)
            {
				_OpenSet.RemoveItem(_OpenSet[j]);
                break;
            }

		for (j = 0; j < Current.Links.Length; j++)	// 2. Проверяем все соседние узлы того узла
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

			if (isOpen == false)	// 3. Вносим соседний узел в открытый список, если его нет там.
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


// ОПИСАНИЕ ПОВЕДЕНИЯ В СОСТОЯНИИ СПОКОЙСТВИЯ
auto state Expecting
{ 
    function SetLimits()     // установка пороговых значений
    {
        EnemyIsFoundedCriticalTimeIntervalForWarning = 0.0;
        EnemyIsFoundedCriticalTimeInterval = 0.5;
        Amnesium_limit = 2.0;
    }
    
    
    function CheckValues()  // проверка сигналов
    {
        if (EnemyIsFoundedTimeInterval >= EnemyIsFoundedCriticalTimeIntervalForWarning)
        {
            `log("I am ready for warning!");
            //Pawn.DoJump(true);
            bEFWh = 1; bEFWl = 0;
        }
        
        if (EnemyIsFoundedTimeInterval >= EnemyIsFoundedCriticalTimeInterval)
        {
            `log("I am ready for attacking!");
            bEFh = 1; bEFl = 0;
            Enemy = SomePawn;
            SolveBehaviour();
        }
    }
    
    function ResetValues() // обнуление сигналов и значений
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
    
    function BeginState (Name PreviousStateName)    // инициализация состояния
    {
        SetLimits();
        ResetValues();
        `log("I am in expecting state");
    }
    
    event SeePlayer (Pawn Seen) // игрок-враг виден в данный момент
    {
		if (Enemy == none || Enemy != Seen)       // если Контроллер ещё не запоминал этого Pawn'а
		Enemy = Seen;                                           // то запоминаем его.
		
		if (Enemy != none)                                      // Теперь, если враг отмечен в пямаяти,
		{
			SomePawn = Enemy;                           // копируем образ в резервную память,
			Enemy_LastLocation = Enemy.Location;                // и его расположение,
			Enemy_LastRotation = Enemy.Rotation;                // и его ориентацию отдельно.
			Enemy_FocalPoint = Enemy.Controller.GetFocalPoint();// И направление взгляда ещё.
		}
		if (bEnemyIsFounded != 1)                               // Если факт обнаружения врага ещё не отмечен
		{
			EnemyIsFoundedStartTime = WorldInfo.TimeSeconds;    // запоминаем время отсчета,
			bEnemyIsFounded = 1;                                // отмечаем факт обнаружения
		}
		EnemyIsFoundedTimeInterval                              // и вычисляем время видимости врага разностью
		= WorldInfo.TimeSeconds - EnemyIsFoundedStartTime;      // между точкой отсчета и текущим временем

    }
    
    event Tick (float DeltaTime)
    {
        If ( Enemy != none && CanSee(Enemy) && LineOfSightTo(Enemy))    // если враг есть и он обнаружен, то
        {
            Amnesium = 0;                                               // обнуляем счетчик забывания
            CheckValues();                                              // перепроверяем счетчики времени
            if ( bEFh == 1)  SolveBehaviour();                          // и определяем новое состояние (если есть повод).
            else Enemy = none;                                          // Иначе обнуляем образ врага
        }
        else 
        if ( bEnemyIsFounded == 1 )                                     // иначе если враг БЫЛ замечен
        {
            if ( Amnesium < Amnesium_limit || bEFh != 1 )               // Если ещё порог забывания не достигнут, то
            Amnesium += DeltaTime;                                      // учитываем длительность отсутствия врага
            if ( Amnesium >= Amnesium_limit )                           // и если длительность забывания выше порога
            {
                `log(EnemyIsFoundedTimeInterval);
                `log("lol");
                CheckValues();                                          // на всякий пожарный перепроверяем сигналы
                if (!SolveBehaviour())                                  // и если после проверки поведение не меняется
                ResetValues();                                          // всё обнуляем и всё сначала
            }
        }
    }
    
    function EndState (Name NextStateName) // выход из состояния
    {
        PawnLocation = Pawn.Location;
        PawnRotation = Pawn.Rotation;
        PawnFocalPoint = GetFocalPoint();
    }
}

// ОПИСАНИЕ ПОВЕДЕНИЯ В СОСТОЯНИИ ПОДОЗРИТЕЛЬНОСТИ
state Warning
{
    
    function CheckValues() // проверка сигналов
    {
        if (bEnemyIsFounded == 1)
        {
            `log("I am ready for attacking!");
            SolveBehaviour();
        }
        
        if (SilentEnvironmentTimeInterval >= SilentEnvironmentCriticalTimeInterval)
        {
            `log("I am ready for expecting!");
            bSEh = 1; bSEl = 0;
            SolveBehaviour();
        }
    }
    
    function ResetValues() // обнуление сигналов и значений
    {
        SilentEnvironmentTimeInterval = 0.0;
        bSEh = 0; bSEl = 1;
        bEnemyIsFounded = 0;
    }
    
    function BeginState (Name PreviousStateName) // Инициализация состояния
    {
        ResetValues();
        `log("I am in warning state");
        `log(Enemy);
        //SpeakingPawn(Pawn).PlayWarningSound();
    }
    
    event SeePlayer(Pawn Seen)
    {
        if (Enemy != Seen || Enemy == none)
        Enemy = Seen;
        bEnemyIsFounded = 1;
        CheckValues();
    }
    
    function Rotate() // вращение Pawn'а на 90 градусов
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
    
    SetFocalPoint(Enemy_LastLocation);                      // Pawn устремляет взгляд в сторону последней позиции видимого врага.
    MoveTo( GetNextDestinationPoint(Pawn.Location,Enemy_LastLocation) );  // Затем Pawn перемещается к этой позиции.
    If (bDestinationIsReached == false) GoTo('Begin');     // Если путь состоит из нескольких узлов, то снова перемещение в следующей позиции,
    else bDestinationIsReached = false;                     // а иначе - ничего.
    
    `log("Focal"@Enemy_FocalPoint);
    SetFocalPoint(Enemy_FocalPoint);                        // Pawn устремляет свой взгляд в направлении вектора передвижения врага.
    
    
    Inspection: // Pawn осматривается.
    Rotate();
    FinishRotation();
    sleep (Rand(2)-FRand());
    
    End:
    if (SilentEnvironmentTimeInterval >= SilentEnvironmentCriticalTimeInterval)
    {
        //SpeakingPawn(Pawn).PlayExpectingSample();
        MoveTo(PawnLocation);
        SetFocalPoint(PawnFocalPoint);
        CheckValues();
    }
    else Goto('Inspection');
}

// ОПИСАНИЕ ПОВЕДЕНИЯ В СОСТОЯНИИ АТАКИ
State Attacking
{
    function ResetValues()
    {
        bEnemyIsDown = 0;
        bHDl = 0; bHDh = 1;
    }
    
    function CheckValues()
    {
        
        if ( Enemy == none )
        {
            `log("I am ready for expecting!");
            bEnemyIsDown = 1;
            SolveBehaviour();
        }
        
        if (Pawn.Health <  (Pawn.default.Health / 2) )
        {
            `log("I am ready for defending!");
            bHDl = 1; bHDh = 0;
            SolveBehaviour();
        }
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
    }
    
    function EndState (Name NextStateName)
    {
        
    }
    
Begin:
    if (Enemy != none)
    {   `log("1" @ Trace (  HitLocation,  HitNormal, Enemy.Location, Pawn.Location, true )  != Enemy);     
        if ( VSize (Enemy.Location - Pawn.Location) > FiringDistance + 50 || Trace (  HitLocation,  HitNormal, Enemy.Location, Pawn.Location, true )  != Enemy )  					// если враг слишком далеко или его не видно сквозь препядствие
        {	`log("2");     				
			MoveTo( GetNextDestinationPoint(Pawn.Location,Enemy.Location, true) );  			//  Pawn перемещается поближе к врагу
			
			while ( bDestinationIsReached != true )										// Если путь состоит из нескольких узлов, 
			{	`log("3");     			
				MoveTo( GetNextDestinationPoint(Pawn.Location,Enemy.Location, false), Enemy );	// то снова перемещение в следующей позиции,			
			}
			`log("4"@Enemy.Location);     
			if ( Trace (  HitLocation,  HitNormal, Enemy.Location, Pawn.Location,true ) == Enemy )
				MoveTo(Enemy.Location, Enemy, FiringDistance);
			else 
				GoTo('Begin');
			
			GoTo('Begin');     
		}
        else
		{	`log("5");     		
			MoveToward(Enemy, Enemy, FiringDistance );                                       // просто смотреть в его сторону			
			Pawn.StartFire(0);                                              // выстрелить
			Pawn.StopFire(0);
        
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


// ОПИСАНИЕ ПОВЕДЕНИЯ В СОСТОЯНИИ ЗАЩИТЫ
State Defending
{
    function CheckValues() // проверка сигналов
    {
        if ( Enemy == none )
        {
            `log("I am ready for expecting!");
            bEnemyIsDown = 1;
            
        }
        
        if (Pawn.Health >  (Pawn.default.Health / 2) )
        {
            `log("I am ready for attacking!");
            bHDl = 0; bHDh = 1;
            
        }
        
        if (Pawn.Health < (Pawn.default.Health / 4) )
        {    bHFl = 1; bHFh = 0; }
        
		
		if ( ShootsAbsenceAfterFight >= ShootsAbsenceCriticalIntreval )
		{	bSAh = 1; bSAl = 0; bNoHearingShoots = 1; }
		
		if (bSAh == 1 && bHFl == 1)
			`log("I am ready for escaping!");
        
        SolveBehaviour();
        
        
    }
    
    function ResetValues() // обнуление сигналов и значений
    {
        bHDl = 1; bHDh = 0;
        bHFl = 0; bHFh = 1;
		bSAh = 0; bSAl = 1;
        bEnemyIsDown = 0;
		bNoHearingShoots = 0;
    }
    
    function BeginState (Name PreviousStateName) // Инициализация состояния
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
		local vector Vector1, Vector2;
		
		Vector1 = Normal(Pawn.Location-Enemy.Location);
		Vector2 = Enemy.GetPawnViewLocation();
		
		`log ("Cos"@Vector1 dot Vector2 );
		
		if ( Enemy != none )		
			if ( Enemy.Weapon.IsFiring == true && Vector1 dot Vector2 > 0.75 )
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
    
    function EndState (Name NextStateName) // Инициализация состояния
    {
        StopLatentExecution();

    }
    /*  if ( VSize ( Pawn.Location - Enemy.Location ) < DefendingDistance)
			MoveToward( Enemy , Enemy , DefendingDistance );
        else 
			if ( VSize ( Pawn.Location - Enemy.Location ) < DefendingDistance)
				if (Enemy != none)
					MoveTo ( Enemy.Location + Normal(Pawn.Location - Enemy.Location) * DefendingDistance , Enemy);
				else GoTo('End'); */
    Begin:
    
    
    HoldingDistance:
   if (Enemy != none)
    {   `log("1");     
        if ( VSize ( Pawn.Location - Enemy.Location ) + 50 < DefendingDistance)  					// если враг слишком близко
        {	`log("2");     				
			MoveTo( GetNextDestinationPoint(Pawn.Location, GetDefendingPoint(), true) );  			//  Pawn перемещается поближе к врагу
			
			while ( bDestinationIsReached != true )										// Если путь состоит из нескольких узлов, 
			{	`log("3");     			
				MoveTo( GetNextDestinationPoint(Pawn.Location,Enemy.Location, false), Enemy );	// то снова перемещение в следующей позиции,			
			}
			`log("4"@Enemy.Location);     
			if ( Trace (  HitLocation,  HitNormal, Enemy.Location, Pawn.Location,true ) == Enemy )
				MoveTo( Enemy.Location + Normal(Pawn.Location - Enemy.Location) * DefendingDistance, Enemy);
			else 
				GoTo('Begin');
			
			GoTo('Begin');     
		}
        else
		{	`log("5");     		
			MoveTo( Enemy.Location + Normal(Pawn.Location - Enemy.Location) * DefendingDistance, Enemy);	// просто смотреть в его сторону			
			Pawn.StartFire(0);                                              // выстрелить
			Pawn.StopFire(0);
        
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

// ОПИСАНИЕ ПОВЕДЕНИЯ В СОСТОЯНИИ БЕГСТВА
State Escaping
{
    function CheckValues() // проверка сигналов
    {
        if ( Enemy == none )
        {
            `log("I am ready for expecting!");
            bEnemyIsDown = 1;
            
        }
        
        if (Pawn.Health >  (Pawn.default.Health / 4) )
        {
            `log("I am ready for defending!");
            bHFl = 0; bHFh = 1;
        }
        
        SolveBehaviour();
        
        
    }
    
    function ResetValues() // обнуление сигналов и значений
    {
        bHFl = 1; bHFh = 0;
        bEnemyIsDown = 0;
    }
    
    function BeginState (Name PreviousStateName) // Инициализация состояния
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
        Enemy = none;
    }
    
    function EndState (Name NextStateName) // Инициализация состояния
    {
        StopLatentExecution();
    }
    
    Begin:
    
    
    HoldingDistance:
   if (Enemy != none)
    {   `log("1");     
        if ( VSize ( Pawn.Location - Enemy.Location ) - 50 < EscapingDistance)  					// если враг слишком близко
        {	`log("2");     				
			MoveTo( GetNextDestinationPoint(Pawn.Location, GetEscapingPoint(), true) );  			//  Pawn перемещается поближе к врагу
			
			while ( bDestinationIsReached != true )										// Если путь состоит из нескольких узлов, 
			{	`log("3");     			
				MoveTo( GetNextDestinationPoint(Pawn.Location,Enemy.Location, false), Enemy );	// то снова перемещение в следующей позиции,			
			}
			`log("4"@Enemy.Location);     
			if ( Trace (  HitLocation,  HitNormal, Enemy.Location, Pawn.Location,true ) == Enemy )
				MoveTo(Enemy.Location, Enemy, EscapingDistance);
			else 
				GoTo('Begin');
			
			GoTo('Begin');     
		}
        else
		{	`log("5");     		
			/* MoveToward(Enemy , Enemy, DefendingDistance);                                       // просто смотреть в его сторону			
			Pawn.StartFire(0);                                              // выстрелить
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
    bDestinationIsReached = false;
    
    // Warning starting values
    
    SilentEnvironmentCriticalTimeInterval = 5.0
	
	ShootsAbsenceCriticalIntreval = 5.0
    
    FiringDistance = 500.0
    
    DefendingDistance = 800.0
    
    EscapingDistance = 2000.0
    
    //___________________________________________
    // СТАРТОВЫЙ ВЕКТОР ВХОДЯЩИХ ЗНАЧЕНИЙ
    EnteringValues[0]=1
    EnteringValues[1]=0
    EnteringValues[2]=0
    EnteringValues[3]=0
    EnteringValues[4]=0
    
    EnteringValues[5]=0 //bHDl
    EnteringValues[6]=1 //bHDh - текущее состояние здоровья по-умолчанию в норме
    EnteringValues[7]=0 //bHFl
    EnteringValues[8]=1 //bHFh - текущее состояние здоровья по-умолчанию в норме
    EnteringValues[9]=1 //bEFl
    EnteringValues[10]=0 //bEFh
    EnteringValues[11]=1 //bEFWl
    EnteringValues[12]=0 //bEFWh
    EnteringValues[13]=0 //bSEl
    EnteringValues[14]=1 //bSEh - тихая обстановка
    EnteringValues[15]=0 //bHearingNoises
    EnteringValues[16]=0 //bEnemyIsFounded
    EnteringValues[17]=1 //bNoHearingShoots - не слышно выстрелов
    EnteringValues[18]=0 //bEnemyisDown
    //___________________________________________
    
    
    
}