/**
 *	GFxMovie_LiftButton
 *
 *	Creation date: 03.03.2013 01:09
 *	Copyright 2013, FHS
 */
class GFxMovie_LiftButton extends GFxMovie_TouchScreen;

// меняем состояние лифта для ролика
function SetState(int locState)
{
	local ASValue arg;
	local array<ASValue> args;
	
	// первый аргумент
	arg.Type = AS_Number;
	arg.n = locState * 1.0;
	args.AddItem(arg);
	// вызываем функцию из AS
	Invoke("_root.SetState", args);
}


defaultproperties
{
	MovieInfo=SwfMovie'Houses.Lifts.LiftButton_movie'
	RenderTexture=TextureRenderTarget2D'Houses.Lifts.LiftButton_RT'
}
