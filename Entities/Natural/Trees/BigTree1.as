// tree logic
Random@ map_random = Random();

void onInit( CSprite@ this )
{
	this.SetZ(550.0f);
	CBlob@ blob = this.getBlob();
	blob.getShape().SetStatic( true );
	
	u8 count = 5+map_random.NextRanged(3);

	for (uint i = 0; i < count; i++)
	{
		CSpriteLayer@ leaves = this.addSpriteLayer( "leaves", this.getFilename(), 32, 32, blob.getTeamNum(), 0);
		if (leaves !is null)
		{
			u8 rnd = XORRandom(6);
			Animation@ anim = leaves.addAnimation("default", 8+(rnd), true);
			{
				int[] frames = {3,4,5,6,7,8,7,6,5,4};
				anim.AddFrames(frames);
			}
			leaves.SetFacingLeft(XORRandom(2) == 0);
			leaves.SetRelativeZ(1+i);
			leaves.SetOffset(blob.isFacingLeft() ?  Vec2f(0.0f+(rnd/2),10.0f+(rnd/1.5)) :  Vec2f(0.0f+(rnd/2),-10.0f-(rnd/1.5)));
			leaves.SetVisible(true);
			leaves.RotateBy((i*(360/count)),blob.isFacingLeft() ?  Vec2f(0.0f+(rnd/1.5),-10.0f-(rnd/1.5)) :  Vec2f(0.0f+(rnd/1.5),10.0f+(rnd/1.5)));

		}
	}
}
