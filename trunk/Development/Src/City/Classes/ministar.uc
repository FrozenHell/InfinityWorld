class MiniStar extends ClickableActor;

defaultProperties
{
	Begin Object Name=StaticMeshComponent
		StaticMesh=StaticMesh'Houses.Stars.MyStar'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.Add(StaticMeshComponent)
	
	Parent_MatInst = MaterialInstanceConstant'Houses.Stars.Starmat_INST'
	MatID = 0
	NormalMatInstLinearColor = (R=1.430000,G=0.900000,B=0.900000,A=1.000000)
	SelectMatInstLinearColor = (R=50.615900,G=40.043331,B=20.067746,A=1.000000)
}