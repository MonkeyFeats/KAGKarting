#include "KarPNGLoader.as";
#include "KarCommon.as";
#include "KartsCommon.as";
#include "Splash.as";

u16 dieTime;

void onInit(CBlob@ this)
{	
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;	
	this.SetMapEdgeFlags( u8(CBlob::map_collide_up) | u8(CBlob::map_collide_down) | u8(CBlob::map_collide_sides) );		

	this.getShape().SetRotationsAllowed(true);
	//this.getShape().SetGravityScale(0.0f);
	//this.getShape().SetOffset(Vec2f(0,-1.5f));
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	//this.getShape().getConsts().bullet = true;
	this.Tag("player");	

	CSprite@ sprite = this.getSprite();

	if (sprite !is null)
	{
		sprite.SetZ(100.0f); 

		CSpriteLayer@ basecoat = sprite.addSpriteLayer( "carbody", "Kar.png", 16, 24, 0, -1);
		if ( basecoat !is null)
		{
			Animation@ anim =  basecoat.addAnimation("default", 0, false);
			anim.AddFrame(1);
			basecoat.SetRelativeZ(1.0f);
			basecoat.SetOffset(Vec2f(-0.25f, 0.0f));
			basecoat.ScaleBy(Vec2f(0.5, 0.5));
		}

		CSpriteLayer@ decal = sprite.addSpriteLayer( "decal", "Kar.png", 16, 24, 0, -1);
		if (decal !is null)
		{
			Animation@ anim = decal.addAnimation("default", 0, false);
			int[] frames = {2,3,4,5,6,7,8,9,10,11,12,13,14};
			anim.AddFrames(frames);
			decal.SetOffset(Vec2f(-0.25f, 0.0f));
			decal.ScaleBy(Vec2f(0.5, 0.5));
		}				
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (solid)
	{
		Vec2f vel = this.getOldVelocity();
		float velleng = vel.Length();

		if (velleng > 2)
		{
			this.getSprite().PlayRandomSound("/carcrash",velleng/10);
			sparks(point1, velleng);

			if (this.isMyPlayer())
			ShakeScreen(velleng, velleng*2, point1);
		}	
	}
}

void onTick(CBlob@ this)
{
	//const bool is_client = getNet().isClient();
	//const bool is_server = getNet().isServer();
	//CBlob@ localBlob = getLocalPlayerBlob();
	CPlayer@ player = this.getPlayer();
	if (player is null) return;

	if ( this.isMyPlayer() )
	{

	KarEngine@ engine;
	if (!this.get("moveVars", @engine))
	{ return; }

	KarInfo@ kar;
	if (!player.get("karInfo", @kar))
	{ return; }	

		const u8 waypointcount = kar.waypoints.length()-1;	
		const u8 TLaps = getRules().get_u8("TotalLaps");
		u8 targetnum = kar.TargetWaypointNum;
		u8 nextnum = kar.NextWaypointNum;
		u8 lastnum = kar.LastWaypointNum;
		Vec2f nextpoint = kar.NextWayPosition;
		Vec2f targetpoint = kar.TargetWayPosition;
		Vec2f lastpoint = kar.LastWayPosition;

		//if (Maths::Abs(engine.AxleRear.SlipAngle) > 0.1)
		//{			
		//	kar.CurrentDrift += ((this.getVelocity().Length()*3)*Maths::Abs(engine.AxleRear.SlipAngle))/3;
		//	kar.ComboTimer = 15;
		//}
		//else if (kar.ComboTimer > 0)
		//{
		//	kar.ComboTimer--;
		//}
		//else if (kar.ComboTimer == 0)
		//{
		//	kar.DriftScore += kar.CurrentDrift;
		//	kar.CurrentDrift = 0;
		//	kar.DriftCombo = 0;
		//	kar.ComboTimer = -1;
		//}

		if (this.isKeyJustPressed(key_action1))
		this.getSprite().PlaySound("Horn3.ogg");

		if (kar.waypoints.length() == 0) return;	

		CMap@ map = getMap();
		Vec2f pos = this.getPosition();		
		
		f32 waylength = (pos - targetpoint).Length();
		f32 racelength = ((waypointcount+1)*TLaps);
		f32 distancetraveled = (kar.LastWaypointNum+((waypointcount+1)*(kar.CurrentLap-1)));
		kar.DistanceToEnd = racelength - (distancetraveled-waylength*0.0001);
	
		Vec2f p1 = kar.waypoints[targetnum][0];
		float DistToTarget = getDistanceToLine( kar.waypoints[targetnum][0], kar.waypoints[targetnum][kar.waypoints[targetnum].length()-1], pos, p1);
		kar.TargetWayPosition = p1;
		Vec2f p2;
		float DistToNext = getDistanceToLine( kar.waypoints[nextnum][0], kar.waypoints[nextnum][kar.waypoints[nextnum].length()-1], pos, p2);
		kar.NextWayPosition = p2;
		Vec2f p3;
		float DistToLast = getDistanceToLine( kar.waypoints[kar.LastWaypointNum][0], kar.waypoints[kar.LastWaypointNum][kar.waypoints[kar.LastWaypointNum].length()-1], pos, p3);
		kar.LastWayPosition = p3;

		if (DistToNext <= (p1-p2).Length() -1.0f)
		{
			if (!player.get_bool("Finished"))
			{
				if ( (kar.WaypointsPast == waypointcount && kar.TargetWaypointNum == 0) || this.hasTag("givelap") )
				{
					u8 CurrentLap = kar.CurrentLap;			
					if (CurrentLap >= TLaps)
					{
						kar.WaypointsPast = 0;

						player.set_bool("Finished", true);
						colsparks(this.getPosition());
						//myPlayerGotToTheEnd = true;
						Sound::Play("Finish1.ogg");	

						CBitStream params;
						params.write_netid(player.getNetworkID());
						getRules().SendCommand(getRules().getCommandID("player finish"), params);						
					}
					else
					{
						Sound::Play("Lap1.ogg");
						kar.CurrentLap = CurrentLap+1;
						kar.WaypointsPast = 0;
					}
					this.Untag("givelap");
				}
			}

			kar.TargetWaypointNum = (kar.TargetWaypointNum == waypointcount ? 0 : (kar.TargetWaypointNum+1));			

			if (kar.TargetWaypointNum > kar.WaypointsPast)
			kar.WaypointsPast+=1;

			player.set_bool("wrong way", false);
		}
		else if (DistToTarget > (p1-p3).Length()+1.0f)
		{
			kar.TargetWaypointNum = (kar.TargetWaypointNum == 0 ? waypointcount : (kar.TargetWaypointNum-1));
			player.set_bool("wrong way", true);
		}	
		kar.NextWaypointNum = (kar.TargetWaypointNum ==  waypointcount ? 0 : (kar.TargetWaypointNum+1));
		kar.LastWaypointNum = (kar.TargetWaypointNum == 0 ? waypointcount : (kar.TargetWaypointNum-1));			

		player.set_u8("target waypoint num", kar.TargetWaypointNum); //for when they die, rules checks last waypoint num to respawn at.	
		player.set_u8("next waypoint num", kar.NextWaypointNum); //for when they die, rules checks last waypoint num to respawn at.	

	}
}

void onDie(CBlob@ this)
{
	// blob is null by now
	//if ( getMap().getTile(this.getPosition()).type == 0)
	//Splash(this, 2, 2, 0);

	SetScreenFlash( 0, 255, 255, 255 ); // clear red screen bug
}

void sparks(Vec2f at, f32 damage)
{
	int amount = int(damage + XORRandom(5));

	for (int i = 0; i < amount; i++)
	{
		Vec2f vel = getRandomVelocity(0, damage/1.5f, 360.0f);
		CParticle@ p = ParticlePixel(at, vel, SColor(255, 200+ XORRandom(55), 200+ XORRandom(55), 100+XORRandom(155)), true, 15+ XORRandom(45));
		if (p !is null)
		{
			p.Z =1000;
			p.damping =  0.92;
		}
	}
}

void colsparks(Vec2f at)
{
	uint amount = 20+XORRandom(10);

	for (uint i = 0; i < amount; i++)
	{
		Vec2f vel = getRandomVelocity(0, 0.7+(XORRandom(100)*0.01), 360);
		CParticle@ p = ParticlePixel(at, vel, SColor(255, 80+ XORRandom(175), 80+ XORRandom(175), 80+XORRandom(175)), true, 20+XORRandom(60));
		if (p !is null)
		{
			p.Z =1000;
			p.damping =  0.91+(XORRandom(100)*0.001);
		}
	}
}