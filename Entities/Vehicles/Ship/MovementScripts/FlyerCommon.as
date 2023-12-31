// Runner Common

shared class FlyerMoveVars
{
	//walking vars
	f32 turnSpeed;  //target vel
	f32 turnSpeedInAir;
	f32 turnFactor;

	//thrusting vars
	f32 thrustMaxVel;
	f32 thrustStart;
	f32 thrustMid;
	f32 thrustEnd;
	f32 thrustFactor;
	s32 thrustCount; //internal counter
	s32 fallCount; //internal counter only moving down

	//swimming vars
	f32 swimspeed;
	f32 swimforce;
	f32 swimEdgeScale;

	//scale the entire movement
	f32 overallScale;

	//force applied while... stopping
	f32 stoppingForce;
	f32 stoppingForceAir;
	f32 stoppingFactor;
};

namespace Walljump
{
	enum WalljumpSide
	{
		NONE,
		LEFT,
		RIGHT,
		BOTH
	};
}

shared class ShipInfo
{
	s8 charge_time;
	u8 charge_state;

	ShipInfo()
	{
		charge_time = 0;
		charge_state = 0;
	};
}
