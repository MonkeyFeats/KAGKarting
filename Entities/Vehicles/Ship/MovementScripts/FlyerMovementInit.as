// Flyer Movement

#include "FlyerCommon.as"

void onInit(CMovement@ this)
{
	FlyerMoveVars moveVars;
	//walking vars
	moveVars.turnSpeed = 2.6f;
	moveVars.turnSpeedInAir = 2.5f;
	moveVars.turnFactor = 1.0f;

	//thrusting vars
	moveVars.thrustMaxVel = 2.1f;
	moveVars.thrustStart = 0.5f;
	moveVars.thrustMid = 0.55f;
	moveVars.thrustEnd = 0.4f;
	moveVars.thrustFactor = 1.0f;
	moveVars.thrustCount = 0;

	//swimming
	moveVars.swimspeed = 1.2;
	moveVars.swimforce = 30;
	moveVars.swimEdgeScale = 2.0f;
	//the overall scale of movement
	moveVars.overallScale = 1.0f;
	//stopping forces
	moveVars.stoppingForce = 1.10f; //function of mass
	moveVars.stoppingForceAir = 2.00f; //function of mass
	moveVars.stoppingFactor = 1.0;
	//

	this.getBlob().set("moveVars", moveVars);
	this.getBlob().getShape().getVars().waterDragScale = 30.0f;
	this.getBlob().getShape().getConsts().collideWhenAttached = true;
}
