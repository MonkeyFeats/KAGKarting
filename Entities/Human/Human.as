#include "HumanCommon.as"

int useClickTime = 0;
const int PUNCH_RATE = 15;
const int FIRE_RATE = 40;
const int CONSTRUCT_RATE = 14;
const int CONSTRUCT_VALUE = 5;
const int CONSTRUCT_RANGE = 48;
const f32 BULLET_SPREAD = 0.2f;
const f32 BULLET_SPEED = 9.0f;
const f32 BULLET_RANGE = 350.0f;
const u8 BUILD_MENU_COOLDOWN = 30;
const Vec2f BUILD_MENU_SIZE = Vec2f( 6, 3 );
const Vec2f TOOLS_MENU_SIZE = Vec2f( 1, 3 );
Random _shotspreadrandom(0x11598); //clientside

void onInit( CBlob@ this )
{
	this.Tag("player");	 
	this.addCommandID("get out");
	this.addCommandID("shoot");
	this.addCommandID("construct");
	this.addCommandID("punch");
	this.addCommandID("giveBooty");
	this.addCommandID("releaseOwnership");
	this.addCommandID("swap tool");
	this.set_f32("cam rotation", 0.0f);
	
	this.SetMapEdgeFlags( u8(CBlob::map_collide_up) |
		u8(CBlob::map_collide_down) |
		u8(CBlob::map_collide_sides) );
	
	this.set_u32("menu time", 0);
	this.set_bool( "build menu open", false );
	this.set_string("last buy", "coupling");
	this.set_string("current tool", "pistol");
	this.set_u32("fire time", 0);
	this.set_u32("punch time", 0);
	this.set_u32("groundTouch time", 0);
	this.set_bool( "onGround", true );//for syncing
	this.getShape().getVars().onground = true;
}

void onTick( CBlob@ this )
{
	Move( this );	
}

void Move( CBlob@ this )
{
	CShape@ shape = this.getShape();
	CSprite@ sprite = this.getSprite();
	const bool up = this.isKeyPressed( key_up );
		const bool down = this.isKeyPressed( key_down );
		const bool left = this.isKeyPressed( key_left);
		const bool right = this.isKeyPressed( key_right );	
		const bool punch = this.isKeyPressed( key_action1 );
		const bool shoot = this.isKeyPressed( key_action2 );
		const u32 time = getGameTime();
		const f32 vellen = shape.vellen;

	const bool myPlayer = this.isMyPlayer();
	const f32 camRotation = myPlayer ? getCamera().getRotation() : this.get_f32("cam rotation");
	const bool attached = this.isAttached();
	Vec2f pos = this.getPosition();	
	Vec2f aimpos = this.getAimPos();
	Vec2f forward = aimpos - pos;
		
		// move
		Vec2f moveVel;

		if (up)	{
			moveVel.y -= Human::walkSpeed;
		}
		else if (down)	{
			moveVel.y += Human::walkSpeed;
		}
		
		if (left)	{
			this.setAngularVelocity( -3 );
		}
		else if (right)	{
			this.setAngularVelocity( 3 );
		}
		else
		this.setAngularVelocity( 0 );

			
		this.setVelocity( moveVel.RotateBy(this.getAngleDegrees()) );
		
}

