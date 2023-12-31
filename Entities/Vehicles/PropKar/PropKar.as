
void onInit(CBlob@ this)
{	
	CSprite@ sprite = this.getSprite();

	if (sprite !is null)
	{
		sprite.SetZ(100.0f); 

		CSpriteLayer@ basecoat = sprite.addSpriteLayer( "carbody", "Kar.png", 16, 24, XORRandom(8), -1);
		if ( basecoat !is null)
		{
			Animation@ anim =  basecoat.addAnimation("default", 0, false);
			anim.AddFrame(1);
			basecoat.SetOffset(Vec2f(-0.25f, 0.0f));
			basecoat.ScaleBy(Vec2f(0.5, 0.5));
		}

		CSpriteLayer@ decal = sprite.addSpriteLayer( "decal", "Kar.png", 16, 24, XORRandom(8), -1);
		if (decal !is null)
		{
			Animation@ anim = decal.addAnimation("default", 0, false);
			anim.AddFrame(2+XORRandom(12));
			decal.SetRelativeZ(1.0f);
			decal.SetOffset(Vec2f(-0.25f, 0.0f));
			decal.ScaleBy(Vec2f(0.5, 0.5));
		}	
	}
}
