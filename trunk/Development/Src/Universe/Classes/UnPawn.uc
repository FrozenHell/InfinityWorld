class UnPawn extends UTPawn;

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	// отключаем прыжок на двойное нажатие направления
}

defaultproperties
{
	Begin Object Name=WPawnSkeletalMeshComponent
		bOwnerNoSee=false
	End Object
	Name="Default__UnPawn"

	// персонаж по умолчанию ходит
	GroundSpeed = 440.0

	// высокая скорость полёта для отладки
	AirSpeed = 1000.0

	// отключаем двойной прыжок
	MaxMultiJump = 0
}