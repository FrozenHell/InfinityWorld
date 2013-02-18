class MyTestActor extends Actor;

auto state Autostate
{
Begin:
	`log("I'm live!!");
}

defaultProperties
{
	 Begin Object Class=StaticMeshComponent Name=StaticMeshCompopo
      StaticMesh=StaticMesh'Houses.Test1.polopotolok'
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