class ministar extends ClickableActor;

defaultProperties
{
	Begin Object Name=StaticMeshComponent
		StaticMesh=StaticMesh'Houses.Stars.MyStar'
		CollideActors = True
		BlockActors = True
		BlockRigidBody = True
	End Object
	Components.add(StaticMeshComponent)
	
	Parent_MatInst = MaterialInstanceConstant'Houses.Stars.Starmat_INST'
	MatID = 0
	NormalMatInstLinearColor =  (R=0.700000,G=0.700000,B=0.700000,A=1.000000)
	SelectMatInstLinearColor =  (R=1.615900,G=0.043331,B=0.067746,A=1.000000)
}