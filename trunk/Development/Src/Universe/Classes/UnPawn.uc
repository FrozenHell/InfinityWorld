class UnPawn extends UTPawn;

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	// ��������� ������ �� ������� ������� �����������
}

defaultproperties
{
	Begin Object Name=WPawnSkeletalMeshComponent
		bOwnerNoSee=false
	End Object
	Name="Default__UnPawn"

	// �������� �� ��������� �����
	GroundSpeed = 440.0

	// ������� �������� ����� ��� �������
	AirSpeed = 1000.0

	// ��������� ������� ������
	MaxMultiJump = 0
}