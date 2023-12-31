
#include "FlyerCommon.as"
#include "Hitters.as";
#include "FallDamage.as";

void onInit(CBlob@ this)
{
	ShipInfo ship;
	this.set("shipInfo", @ship);

	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 240, 255));
	this.set_f32("map dmg modifier", 400.0f);
	this.set_f32("map_bomberman_width", 24.0f);
	this.set_f32("explosive_radius", 64.0f);
	this.set_f32("explosive_damage", 10.0f);

	this.set_bool("map_damage_raycast", true);
	this.set_f32("gib health", -3.0f);
	this.Tag("player");

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	this.getShape().SetRotationsAllowed(true);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	CSprite@ sprite = this.getSprite();

	sprite.SetZ( 200.0f );
	sprite.SetEmitSound("IntThrust.ogg");

	// add sprite layers
	{
		CSpriteLayer@ lleg = sprite.addSpriteLayer("lleg", "Ship.png", 16, 16);
		if (lleg !is null)
		{
			lleg.addAnimation("default", 0, false);
			int[] frames = { 4 };
			lleg.animation.AddFrames(frames);
			lleg.SetRelativeZ(1.0f);
			lleg.SetOffset(Vec2f(20.0f, 14.0f));
		}
			CSpriteLayer@ rleg = sprite.addSpriteLayer("rleg", "Ship.png", 16, 16);
		if (rleg !is null)
		{
			rleg.addAnimation("default", 0, false);
			int[] frames = { 5 };
			rleg.animation.AddFrames(frames);
			rleg.SetRelativeZ(1.0f);
			rleg.SetOffset(Vec2f(-20.0f, 14.0f));
		}
			CSpriteLayer@ thruster = sprite.addSpriteLayer("thruster", "Ship.png", 32, 16);
		if (thruster !is null)
		{
			thruster.addAnimation("default", 0, false);
			int[] frames = { 12};
			thruster.animation.AddFrames(frames);
			thruster.SetRelativeZ(1.0f);
			thruster.SetOffset(Vec2f(0.0f, 15.0f));
		}

	}
}
void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16, 16));
	}
}


void onTick(CBlob@ this)
{	
	if (this.hasAttached() || this.getTickSinceCreated() < 30)
	{
		if (this.getHealth() > 1.0f)
		{

			ShipInfo@ ship;
			if (!this.get("shipInfo", @ship))
			{
				return;
			}

	
			FlyerMoveVars@ moveVars;
			if (!this.get("moveVars", @moveVars))
			{
				return;
			}
		}
	}
}




void onInit(CSprite@ this)
{
	this.SetZ(100.0f);
	this.getCurrentScript().tickFrequency = 5;
}

void onGib(CSprite@ this)
{

	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0f;
	const u8 team = blob.getTeamNum();
	CParticle@ Body     = makeGibParticle("Mods/Lander/Entities/Characters/Ship/ShipGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm      = makeGibParticle("Mods/Lander/Entities/Characters/Ship/ShipGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("Mods/Lander/Entities/Characters/Ship/ShipGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("Mods/Lander/Entities/Characters/Ship/ShipGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}

