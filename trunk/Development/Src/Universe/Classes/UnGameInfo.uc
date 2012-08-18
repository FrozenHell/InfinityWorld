class UnGameInfo extends UTDeathmatch;

exec function CreateBot() {
	SpawnBot();
}

defaultproperties
{
	Acronym="UN"	

	MapPrefixes.Empty
	MapPrefixes(0)="UN"

	DefaultMapPrefixes.Empty
	//DefaultMapPrefixes(0)=(Prefix="UN",GameType="Universe.UnGameInfo")
	//DefaultGameType="Universe.UnGameInfo"

	PlayerControllerClass=class'UnPlayerController'
	DefaultPawnClass=class'UnPawn'

	Name="Default__UnGameInfo"
}