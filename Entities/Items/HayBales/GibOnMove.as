void onTick(CBlob@ this)
{
	Vec2f vel = this.getVelocity();
	Vec2f pos = this.getPosition();
	if (vel.Length() > 0.5f)
	{
		this.server_Die();
	}
}
void onDie(CBlob@ this)
{
	const string image = this.getSprite().getFilename();
	const Vec2f position = this.getPosition();
	const u8 team = this.getTeamNum();

	ParticleAnimated(image, position, Vec2f(0, 0), 0.0f, 1.0f, 4, 0.0f, true);
}
/*
	for(u8 i = 0; i < 3; i++)
	{		
		makeGibParticle(
		image,                              // file name
		position,                           // position
		getRandomVelocity(90, 2, 360),      // velocity
		1,                                  // column
		1,                                  // row
		Vec2f(8, 8),                        // frame size
		1.0f,                               // scale?
		0,                                  // ?
		"",                                 // sound
		team);                              // team number
	}
}