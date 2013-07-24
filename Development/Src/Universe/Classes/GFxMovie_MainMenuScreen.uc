/**
 *	GFxMovie_MainMenuScreen
 *
 *	Creation date: 03.03.2013 17:26
 *	Copyright 2013, FHS
 */
class GFxMovie_MainMenuScreen extends GFxMovie_TouchScreen;

delegate NewLevelChanged(int newLevel);

function EventReturnLevel(int newLevel)
{
	`log("New level number is"@newLevel);
	NewLevelChanged(newLevel);
}

defaultproperties
{
	MovieInfo=SwfMovie'MainMenu.Room.MainMenuScreen_movie'
	RenderTexture=TextureRenderTarget2D'MainMenu.Room.MainMenuScreen_RT'
}
