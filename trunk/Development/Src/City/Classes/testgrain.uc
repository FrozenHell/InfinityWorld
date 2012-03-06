class testgrain extends housepart;

defaultProperties
{
	 Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
      StaticMesh=StaticMesh'Houses.Test1.grain'
			CollideActors = True
      BlockActors = True
      BlockRigidBody = True
   End Object
   Components.add(StaticMeshCompopo)
}