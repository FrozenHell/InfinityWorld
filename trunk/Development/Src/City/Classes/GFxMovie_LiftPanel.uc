/**
 *	GFxMovie_LiftPanel
 *
 *	Creation date: 20.03.2013 16:29
 *	Copyright 2013, FHS
 */
class GFxMovie_LiftPanel extends GFxMovie_TouchScreen;

delegate ControlPanelAddFloor(int newFloor);

function InitPanel(int buldingHeight)
{
	local ASValue arg;
	local array<ASValue> args;
	
	// первый аргумент
	arg.Type = AS_Number;
	arg.n = buldingHeight * 1.0;
	args.AddItem(arg);
	// вызываем функцию из AS
	Invoke("_root.InitPanel", args);
}

function EventReturnFloor(int newFloor)
{
	ControlPanelAddFloor(newFloor);
}

defaultproperties
{
	MovieInfo=SwfMovie'Houses.Lifts.LiftPanelMovie'
	RenderTexture=TextureRenderTarget2D'Houses.Lifts.LiftPanel_RT'
}
