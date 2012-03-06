class ministar extends Actor;

defaultProperties
{
	 Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
      StaticMesh=StaticMesh'Houses.Stars.MyStar'
			CollideActors = True
      BlockActors = True
      BlockRigidBody = True
   End Object
   Components.add(StaticMeshCompopo)
   bHidden = False
   bCollideActors = True
   bBlockActors = True
   bStatic = False
   bMovable = False
}