// tree logic
Random@ map_random = Random();

void onInit( CSprite@ this )
{
	this.SetZ(500.0f);
	CBlob@ blob = this.getBlob();
	blob.getShape().SetStatic( true );
	
	int[] frames = {4,5,6,7,6,5};	
	int count = 5+map_random.NextRanged(3);

	for (uint i = 0; i < count; i++)
	{
		this.RemoveSpriteLayer("leaves"+i);
		CSpriteLayer@ leaves = this.addSpriteLayer( "leaves"+i, this.getFilename(), 48, 48, blob.getTeamNum(), 0);
		if (leaves !is null)
		{
			u8 rnd = XORRandom(6);
			Animation@ anim = leaves.addAnimation("default", 8+(rnd), true);
			{
				anim.AddFrames(frames);
			}
			leaves.SetFacingLeft(XORRandom(2) == 0);
			leaves.SetRelativeZ(1+i);
			leaves.SetOffset(blob.isFacingLeft() ?  Vec2f(0.0f+(rnd/2),19.0f+(rnd/1.5)) :  Vec2f(0.0f+(rnd/2),-19.0f-(rnd/1.5)));
			leaves.SetVisible(true);
			leaves.RotateBy((i*(360/count)),blob.isFacingLeft() ?  Vec2f(0.0f+(rnd/2),-19.0f-(rnd/1.5)) :  Vec2f(0.0f+(rnd/2),19.0f+(rnd/1.5)));

		}
/*
		CSpriteLayer@ leaves_shadow = this.addSpriteLayer( "leaves_shadow"+i, this.getFilename(), 48, 48, blob.getTeamNum(), 0);
		if (leaves_shadow !is null)
		{
			u8 rnd = XORRandom(6);
			Animation@ anim = leaves_shadow.addAnimation("default", 8+(rnd), true);
			{
				int[] frames = {4,5,6,7,6,5};
				anim.AddFrames(frames);
			}
			leaves_shadow.SetFacingLeft(XORRandom(2) == 0);
			leaves_shadow.SetRelativeZ(1+i);
			leaves_shadow.SetOffset(blob.isFacingLeft() ?  Vec2f(0.0f+(rnd/2),19.0f+(rnd/1.5)) :  Vec2f(0.0f+(rnd/2),-19.0f-(rnd/1.5)));
			leaves_shadow.SetVisible(true);
			leaves_shadow.RotateBy((i*(360/count)),blob.isFacingLeft() ?  Vec2f(0.0f+(rnd/2),-19.0f-(rnd/1.5)) :  Vec2f(0.0f+(rnd/2),19.0f+(rnd/1.5)));

			leaves_shadow.TranslateBy(Vec2f(24,24));
			leaves_shadow.SetRelativeZ(-1.5);
			leave_shadow.SetAngleDegrees(-blob.getAngleDegrees());
		}*/
	}

}

/*
int count;
void onTick( CSprite@ this )
{
	CBlob@ blob = this.getBlob();

	for (uint i = 0; i < count; i++)
	{
		CSpriteLayer@ leaves_shadow = this.getSpriteLayer( "leaves_shadow"+i);
		if (leaves_shadow !is null)
		{
			leaves_shadow.setRenderStyle(RenderStyle::shadow);
		}
	}	

	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

