/**
 *	TouchScreen
 *
 *	Creation date: 02.03.2013 15:55
 *	Copyright 2013, FHS
 *
 *	��������� �����
 */
class TouchScreen extends UsableActor
	Placeable;

var GFxMovie_TouchScreen GFxMovie;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	GFxMovie = new Class'Base.GFxMovie_TouchScreen';
	GFxMovie.initialize();
}

function SetCursorPosition(vector globPosition)
{
	local vector localPosition;
	// ��������� ������ � ��������� ������� ���������
	localPosition = globPosition - Location;
	localPosition = localPosition << Rotation;
	
	// ������������� ������
	GFxMovie.MoveCursor((100+localPosition.x) * 2.5, (100-localPosition.z) * 2.5);
}

// ������ �� ���������� �����
function UnFocus()
{
	GFxMovie.UnFocus();
}

// �������������� Use
public function Use(Pawn uInstigator)
{
	GFxMovie.Tap();
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		StaticMesh=StaticMesh'TouchScreen.TouchMesh'
	End Object
	
	ActionName = "���������"
}
