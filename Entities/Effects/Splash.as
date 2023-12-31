//simple water splash just for effect

void Splash(CBlob@ this, const uint splash_halfwidth, const uint splash_halfheight, const f32 splash_offset)
{
	CMap@ map = this.getMap();
	Sound::Play("SplashFast.ogg", this.getPosition(), 1.0f);

	if (map !is null)
	{
		Vec2f pos = this.getPosition() +
		            Vec2f(this.isFacingLeft() ?
		                  -splash_halfwidth * map.tilesize*splash_offset :
		                  splash_halfwidth * map.tilesize * splash_offset,
		                  0);

		for (int x_step = -splash_halfwidth - 2; x_step < splash_halfwidth + 2; ++x_step)
		{
			for (int y_step = -splash_halfheight - 2; y_step < splash_halfheight + 2; ++y_step)
			{
				Vec2f wpos = pos + Vec2f(x_step * map.tilesize, y_step * map.tilesize);
				Vec2f outpos;

				//make a splash!
				bool random_fact = ((x_step + y_step + getGameTime() + 125678) % 7 > 3);

				if (x_step >= -splash_halfwidth && x_step < splash_halfwidth &&
				        y_step >= -splash_halfheight && y_step < splash_halfheight &&
				        (random_fact || y_step == 0 || x_step == 0))
				{
					map.SplashEffect(wpos, -this.getVelocity()/2, 4.0f);
				}
			}
		}
	}
}
