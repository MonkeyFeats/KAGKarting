#define SERVER_ONLY
#include "KarCommon.as";

void onInit(CBrain@ this)
{
	InitBrain(this);
}

void InitBrain(CBrain@ this)
{
	CBlob @blob = this.getBlob();

	this.getCurrentScript().removeIfTag = "dead";

	if (!blob.exists("difficulty"))
	{
		blob.set_s32("difficulty", 15); // max
	}
}

void onTick(CBrain@ this)
{
	if (!getRules().isMatchRunning())
	return;

	CBlob @blob = this.getBlob();
	KarInfo@ kar;
	if (!blob.getPlayer().get("karInfo", @kar))
	{
		return;
	}

	CMap@ map = getMap();
	const u8 waypointcount = map.get_u8("waypoint count");
	
	Vec2f mypos = blob.getPosition();
	u8 targetnum = kar.TargetWaypointNum;
	Vec2f nextpoint = kar.NextWayPosition;
	Vec2f targetpoint = kar.TargetWayPosition;
	Vec2f lastpoint = kar.LastWayPosition;
	f32 angle = blob.getAngleDegrees();

	Vec2f[] waypoints;
	Vec2f[] nextwaypoints;	

	f32 angleOffset = 270.0f;	
	f32 targetangle1 = (targetpoint - mypos).getAngle();
	f32 targetangle2 = (nextpoint - mypos).getAngle();


	f32 targetangle3 = ((-angle-targetangle2)+90);
	f32 targetangle4 = ((-angle-targetangle1)+90);
	while (targetangle3 < -180)
	{
		targetangle3+=360;
	}
	while (targetangle4 < -180)
	{
		targetangle4+=360;
	}

	blob.setKeyPressed(key_left, false);
	blob.setKeyPressed(key_right, false);
	blob.setKeyPressed(key_action3, false);

	//if (targetangle3 > 10 || targetangle3 < -10)
	//{
	//	//if (getGameTime() % 3 == 0)
	//	blob.setKeyPressed(key_up, false);
	//	//blob.setKeyPressed(key_action3, true);
	//}

	if ( blob.getVelocity().Length()*40 > (nextpoint - mypos).Length() )
	blob.setKeyPressed(key_up, false);
	else
	blob.setKeyPressed(key_up, true);

	if (targetangle3 > 3 || targetangle4 > 35)
	{
		blob.setKeyPressed(key_right, true); 		
	}
	else if (targetangle3 < -3 || targetangle4 < - 35)
	{
		blob.setKeyPressed(key_left, true);
	}

	if (Maths::Abs(targetangle3) > 35)
	{
		blob.setKeyPressed(key_action3, true);
	}
}