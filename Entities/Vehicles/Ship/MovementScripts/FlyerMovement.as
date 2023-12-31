// Flyer Movement Walking

#include "FlyerCommon.as"
#include "FireParticle.as"

void onInit(CMovement@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	FlyerMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars))
	{
		return;
	}

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);


	const bool is_client = getNet().isClient();

	CMap@ map = blob.getMap();
	Vec2f vel = blob.getVelocity();
	Vec2f pos = blob.getPosition();
	CShape@ shape = blob.getShape();

	const f32 vellen = shape.vellen;
	const bool onground = blob.isOnGround();

			f32 angle = blob.getAngleDegrees();
			Vec2f force = Vec2f(0, -10);
			f32 torque = 0.25f;
			Vec2f offset = Vec2f(0.0f, 16.0f);

	if (blob.getTickSinceCreated() < 2)
	{
		force.x = 10.5f;
		blob.AddForce(force);
		blob.AddTorque(2000);
	}

	if (is_client && getGameTime() % 3 == 0 && blob.getTickSinceCreated() > 30)
	{
		if(right)
		{
			blob.AddTorque((left) || (right) ? 250 : -250); // Turn right //
		}

		if(left)
		{
			blob.AddTorque((left) || (right) ? -250 : 250); // Turn left //
		}

			if (up)
			{
				if (vel.y > -moveVars.thrustMaxVel || vel.x > -moveVars.thrustMaxVel)
				{

					force.y -= 40.0f; // Thrust amount//
					force.RotateBy(blob.getShape().getAngleDegrees()); // Relative rotation to the craft // 

					offset.RotateBy(angle);
					makeFireParticle(pos + offset + getRandomVelocity(0.0f, 0.0f, 180.0f));
				}
			
					force *= moveVars.thrustFactor * moveVars.overallScale * 10.0f;
					blob.AddForce(force);

			// sound

			if (moveVars.thrustCount == 1 && is_client)
			{
				TileType tile = blob.getMap().getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() + 4.0f)).type;
				if (blob.getMap().isTileGroundStuff(tile))
				{
					blob.getSprite().PlayRandomSound("/EarthJump");
				}
				else
				{
					blob.getSprite().PlayRandomSound("/StoneJump");
				}
			}
		}
	}
	

	

	//walking & stopping



	

	//falling count
	if (!onground && vel.y > 0.1f)
	{
		moveVars.fallCount++;
	}
	else
	{
		moveVars.fallCount = 0;
	}

	CleanUp(this, blob, moveVars);


//some specific helpers


}

//cleanup all vars here - reset clean slate for next frame

void CleanUp(CMovement@ this, CBlob@ blob, FlyerMoveVars@ moveVars)
{
	//reset all the vars here
	moveVars.thrustFactor = 1.0f;
	moveVars.turnFactor = 1.0f;
	moveVars.stoppingFactor = 1.5f;
}

//TODO: fix flags sync and hitting so we dont need this
bool checkForSolidMapBlob(CMap@ map, Vec2f pos)
{
	CBlob@ _tempBlob; CShape@ _tempShape;
	@_tempBlob = map.getBlobAtPosition(pos);
	if (_tempBlob !is null && _tempBlob.isCollidable())
	{
		@_tempShape = _tempBlob.getShape();
		if (_tempShape.isStatic())
		{
			if (_tempBlob.getName() == "wooden_platform")
			{
				f32 angle = _tempBlob.getAngleDegrees();
				if (angle > 180)
					angle -= 360;
				angle = Maths::Abs(angle);
				if (angle < 30 || angle > 150)
				{
					return false;
				}
			}

			return true;
		}
	}

	return false;
}
