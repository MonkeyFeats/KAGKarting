
void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";

	this.getShape().SetRotationsAllowed(true);
	this.getShape().getVars().onground = true;	
}
void onTick(CBlob@ this)
{	
	const bool is_client = getNet().isClient();

	if (is_client) //needed?
	{
		const bool left		= this.isKeyPressed(key_left);
		const bool right	= this.isKeyPressed(key_right);
		const bool up		= this.isKeyPressed(key_up);
		const bool down		= this.isKeyPressed(key_down);
		const bool use		= this.isKeyPressed(key_use);
		//const bool spacebar	= blob.isKeyPressed(key_action3); // has problems for obvious no reason

		float Throttle = 0;
		float Brake = 0;
		float EBrake = 0;	
		float Steer = 0;

		if (up && !down) 
		{
			Throttle = 4;
		} 
		else if (down) 
		{
			Throttle = -4; 
		}
		else 
		{
			Throttle = 0;
		}

		if(!left && right) { Steer = 1;} //brake = 1?
		else if(left && !right)	{ Steer = -1;}
		else {Steer = 0;}			

		this.setAngularVelocity(Steer);

		this.AddForce(Vec2f(0, -Throttle).RotateBy(this.getAngleDegrees()));
		//if (engine.KMPH > 120 && blob.isMyPlayer() )
		//ShakeScreen((engine.KMPH-120)*0.2, 10, blob.getPosition());
	}	

	//CSprite@ sprite = blob.getSprite();
	//if (sprite !is null)
	//{
	//	sprite.SetEmitSound("engine2.ogg");
	//	sprite.SetEmitSoundPaused(false);
	//	sprite.SetEmitSoundVolume(0.15f);
	//	sprite.SetEmitSoundSpeed(0.3f + (engine.EngineRPM/7000));	
	//	//sprite.getVars().sound_emit_pitch = 0.5f + (engine.EngineRPM/6000);
	//}	
}
