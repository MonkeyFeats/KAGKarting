
void onInit(CSprite@ this)
{	
	//this.getCurrentScript().tickFrequency = 5;
	this.SetZ(10.0f); 

	CSpriteLayer@ basecoat = this.addSpriteLayer( "boatbody", "Boats.png", 16, 24, XORRandom(8), -1);
	if ( basecoat !is null)
	{
		Animation@ anim =  basecoat.addAnimation("default", 0, false);
		anim.AddFrame(1+XORRandom(4));
		basecoat.SetRelativeZ(1.0f);
		basecoat.SetOffset(Vec2f(-0.25f, 0.0f));
		basecoat.ScaleBy(Vec2f(0.75, 0.75));
	}


}

//void onTick(CSprite@ this)
//{	
//	f32 wave = Maths::Sin(getGameTime() / 50.0f)*5;
//
//	CSpriteLayer@ basecoat = this.getSpriteLayer( "boatbody");
//	if (basecoat !is null)
//	{
//		basecoat.SetOffset(Vec2f(wave, -wave)*0.2);
//	}
//}
