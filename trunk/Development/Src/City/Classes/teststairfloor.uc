class teststairfloor extends housepart;

defaultProperties
{
	 Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
      StaticMesh=StaticMesh'Houses.Test1.stairfloor'
			CollideActors = True
      BlockActors = True
      BlockRigidBody = True
   End Object
   Components.add(StaticMeshCompopo)
}