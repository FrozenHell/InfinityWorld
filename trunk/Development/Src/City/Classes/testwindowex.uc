class testwindowex extends housepart;

defaultProperties
{
	 Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
      StaticMesh=StaticMesh'Houses.Test1.windowex'
			CollideActors = True
      BlockActors = True
      BlockRigidBody = True
   End Object
   Components.add(StaticMeshCompopo)
}