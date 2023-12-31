
void onInit(CSprite@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;	

	this.SetZ(100.0f); 

	//this.getBlob().server_setTeamNum(4);

	CSpriteLayer@ arm1 = this.addSpriteLayer( "arm1", "Excavator.png", 32, 16, this.getBlob().getTeamNum(), -1);
	if ( arm1 !is null)
	{
		Animation@ anim =  arm1.addAnimation("default", 0, false);
		anim.AddFrame(1);
		arm1.SetRelativeZ(2.0f);
		arm1.SetOffset(Vec2f(2.0f, 0.0f));
	}

	CSpriteLayer@ arm2 = this.addSpriteLayer( "arm2", "Excavator.png", 16, 16, this.getBlob().getTeamNum(), -1);
	if ( arm2 !is null)
	{
		Animation@ anim =  arm2.addAnimation("default", 0, false);
		anim.AddFrame(8);
		arm2.SetRelativeZ(3.0f);
		arm2.SetOffset(Vec2f(-14.0f, 0.0f));
	}	
	CSpriteLayer@ arm3 = this.addSpriteLayer( "arm3", "Excavator.png", 16, 16, this.getBlob().getTeamNum(), -1);
	if ( arm3 !is null)
	{
		Animation@ anim =  arm3.addAnimation("default", 0, false);
		anim.AddFrame(9);
		arm3.SetRelativeZ(2.0f);
		arm3.SetOffset(Vec2f(-28.0f, 0.0f));
	}
}

u8 state = 0;
u8 timer = 45;

void onTick(CSprite@ this)
{
	CSpriteLayer@ arm1 = this.getSpriteLayer( "arm1" );
	CSpriteLayer@ arm2 = this.getSpriteLayer( "arm2" );
	CSpriteLayer@ arm3 = this.getSpriteLayer( "arm3" );
	if (arm1 is null || arm2 is null || arm3 is null) return;

	Vec2f a1off = arm1.getOffset();
	Vec2f a2off = arm2.getOffset();
	Vec2f a3off = arm3.getOffset();

	if (timer > 0)
	{timer --;}
	else
	{timer = 43; state ++;}
		

	switch (state)
	{
		case 0:
		case 2:
		case 4:
		case 6:
		{
			arm2.SetOffset(a2off+Vec2f(0.10, 0));
			arm3.SetOffset(a3off+Vec2f(0.20, 0));

			
		}break;

		case 1:
		case 3:
		case 5:
		{
			arm2.SetOffset(a2off+Vec2f(-0.10, 0));
			arm3.SetOffset(a3off+Vec2f(-0.20, 0));
		}break;

		case 7: break;

		case 8:
		case 9:
		{	
			arm1.RotateBy(-2, -a1off);
			arm2.RotateBy(-2, -a2off);
			arm3.RotateBy(-2, -a3off);

		}break;

		case 10: break;


		case 11:
		{
			arm2.SetOffset(a2off+Vec2f(0, 0.2));
			arm3.SetOffset(a3off+Vec2f(0, 0.3));

			
		}break;

		case 12:
		{
			arm2.SetOffset(a2off+Vec2f(0, -0.2));
			arm3.SetOffset(a3off+Vec2f(0, -0.3));
		}break;

		case 13:
		case 14:
		{	
			arm1.RotateBy(2, -a1off);
			arm2.RotateBy(2, -a2off);
			arm3.RotateBy(2, -a3off);

		}break;

		case 15:
		{
			if (timer == 0)
			{
				state = 0;
			}
		}break;
	}

	
}