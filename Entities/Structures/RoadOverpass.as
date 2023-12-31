
void onInit(CSprite@ this)
{
	this.SetZ(-5000); //background

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ front = this.addSpriteLayer("front layer", "RoadOverpass.png" , 96, 112, 0, 0);

	if (front !is null)
	{
		Animation@ anim = front.addAnimation("default", 0, false);
		anim.AddFrame(0);
		front.SetRelativeZ(1000);
	}
}

CBlob@ underBlob = null;
void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (getNet().isServer() && isStatic && !this.isAttached())
	{
		CBlob@ blob = server_CreateBlob("roadunderpass", this.getTeamNum(), this.getPosition());
		if (blob !is null)
		{
			blob.setAngleDegrees(this.getAngleDegrees());
			blob.server_AttachTo(this, "UNDER");
			@underBlob = blob;
		}
	}
}

void onDie(CBlob@ this)
{
	AttachmentPoint @ap = this.getAttachments().getAttachmentPointByName("UNDER");
	if (ap.getOccupied() !is null)
	{
		if (getNet().isServer())
		{
			ap.getOccupied().server_Die();
		}
	}
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (blob.getName() == "kar" && blob.hasTag("underpassing"))
		{			
			CSpriteLayer@ front = this.getSprite().getSpriteLayer("front layer");
			if (front !is null)
			{				
				bool visible = front.isVisible();

				CPlayer@ p = getLocalPlayer();
				if (p !is null)
				{
					CBlob@ local = p.getBlob();
					if (local !is null)
					{
						print("enter");
						front.SetVisible(false);
					}
				}
			}
		}
	}
}

void onEndCollision(CBlob@ this, CBlob@ blob)
{
	if (blob !is null)
	{
		if (blob.getName() == "kar")
		{
			CSpriteLayer@ front = this.getSprite().getSpriteLayer("front layer");
			if (front !is null)
			{	
				CPlayer@ p = getLocalPlayer();
				if (p !is null)
				{
					CBlob@ local = p.getBlob();
					if (local !is null)
					{
						print("exit");
						front.SetVisible(true);
					}
				}
			}
		}
	}
}
/*
void onRender(CSprite@ this)
{

	Vec2f tl, br;
	this.getBlob().getShape().getBoundingRect(tl, br);	
	CBlob@[] overlapping;	
	getMap().getBlobsInBox(tl, br, @overlapping);
	for (uint i = 0; i < overlapping.length; i++)
	{
		CBlob@ o_blob = overlapping[i];
		if (o_blob !is null && o_blob.getName() == "kar")
		{
			//this.setRenderStyle(RenderStyle::additive);
			//o_blob.getSprite().setRenderStyle(RenderStyle::additive);
			o_blob.RenderForHUD(RenderStyle::shadow);
			//CSpriteLayer@ decal = this.getSpriteLayer("decal"); //need to reload for the colour to change
			//if (decal !is null)
			//{					
			//	decal.setRenderStyle(RenderStyle::additive);
			//}
		}
	}
}

//void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
//{	
//	this.getSprite().SetFrameIndex(1);
//	this.AddForce(blob.getVelocity()*(3+XORRandom(8)) + Vec2f(XORRandom(3),XORRandom(3)));
//	this.setAngularVelocity((-10.0f + XORRandom(200)*0.1f ));
//	blob.AddForce(-blob.getVelocity()*20);
//	this.getSprite().PlaySound("/TrafficConeHit.ogg", 0.2+blob.getVelocity().Length()/5, 0.5+blob.getVelocity().Length()/5);
//}