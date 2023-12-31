#include "KarCommon.as";

const string iconsFilename = "Speedometer.png";

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

int PlayerCount;

void onRender(CSprite@ this)
{	
	CBlob@ blob = this.getBlob();	
	CPlayer@ player = blob.getPlayer();
	if (blob is null || player is null || !blob.isMyPlayer() ) return;

	KarInfo@ kar; if (!player.get("karInfo", @kar)) { return; }
	KarEngine@ moveVars; if (!blob.get("moveVars", @moveVars)) {return;}

	const f32 HUD_X = getScreenWidth();
	const f32 HUD_Y = getScreenHeight();
	// Speedometer //3
	Vec2f offset = Vec2f(HUD_X/2, 38);
	Vec2f speedoframesize = Vec2f(192, 192);
	Vec2f center = offset + Vec2f(speedoframesize.x/2, HUD_Y-speedoframesize.y/2);
	GUI::DrawIcon(iconsFilename, 0, Vec2f(192, 192), center+-speedoframesize/2, 0.5f);

	// Needle
	Vec2f needlepoint = Vec2f(center.x-68, center.y+38).RotateBy(moveVars.KMPH, center);
	GUI::DrawLine2D( center, needlepoint, SColor(255,255,0,0));

	// RPMguage //	
	Vec2f rpmneedlepoint = Vec2f(center.x-28, center.y+45).RotateBy(moveVars.EngineRPM/(360/8), center+Vec2f(0,45));
	GUI::DrawLine2D( center+Vec2f(0,45), rpmneedlepoint, SColor(255,255,0,0));

	string gearstring = ""+(moveVars.CurrentGear+1);
	switch (moveVars.GearState)
	{
		case -1: {gearstring = "R"; break;}
		case 0: {gearstring = "N"; break;}
		default: {gearstring = ""+(moveVars.CurrentGear+1);}
	}
	// Gear	//	
	GUI::DrawTextCentered("G: "+ gearstring, center+Vec2f(0,25), color_white);

	// Placement & Laps
	u8 TotalLaps = getRules().get_u8("TotalLaps");
	u8 currentLap = kar.CurrentLap;
	u8 currentway = kar.TargetWaypointNum;
	u8 lastway = kar.LastWaypointNum;		
	int Placement = kar.Placement;

	if (getGameTime() % 300 == 0)
	{
		CBlob@[] players;
		getBlobsByTag("player", @players);
		PlayerCount = players.length;
	}

	GUI::SetFont("segoesc");

	string PlacementString = "Pos: "+Placement+" / "+PlayerCount;
	GUI::DrawText(getTranslatedString(PlacementString), Vec2f(20,52), color_white);

	string LapString = "Lap: "+currentLap+" / "+TotalLaps;
	GUI::DrawText(getTranslatedString(LapString), Vec2f(20,20), color_white);

	//GUI::DrawText("Score = " + kar.DriftScore	, Vec2f(getScreenWidth()-512, 148), color_white);
	//GUI::DrawText("Drift = " + kar.CurrentDrift		, Vec2f(getScreenWidth()-512, 164), color_white);
	//GUI::DrawText("Combo = " + kar.DriftCombo	, Vec2f(getScreenWidth()-512, 180), color_white);

	// debuggy //
	////////////

	//if (g_debug == 2) 
	{
		GUI::SetFont("hud");
		Vec2f pos = blob.getInterpolatedPosition();
		//Vec2f targetPos = kar.TargetWayPosition;

		//f32 angle = blob.getAngleDegrees();
		//f32 angleOffset = 270.0f;
		//f32 targetangle = (targetPos - pos).getAngle();
		//f32 angletotarget = (angle + targetangle + angleOffset) % 360;	

		
		//Vec2f lv = moveVars.VelocityForce;			
		//GUI::DrawArrow( pos, (pos + lv), SColor(255,0,0,255) );
	//	GUI::DrawArrow( pos, kar.NextWayPosition, SColor(255,0,0,255) );
	//	GUI::DrawArrow( pos, kar.TargetWayPosition, SColor(255,0,255,0) );
	//	GUI::DrawArrow( pos, kar.LastWayPosition, 	SColor(255,255,0,0) );	
	//	GUI::DrawText("TargetWaypointNum = " + currentway	, Vec2f(getScreenWidth()-512, 148), color_white);
	//	GUI::DrawText("LastWaypointNum = "   + lastway		, Vec2f(getScreenWidth()-512, 164), color_white);
	//  GUI::DrawText("CurrentLap = " 	 	 + currentLap	, Vec2f(getScreenWidth()-512, 180), color_white);

		//return;

		GUI::DrawLine(pos+moveVars.AxleFront.LeftWheel.LocalPosition, pos+moveVars.AxleFront.RightWheel.LocalPosition, SColor(255,255,0,0)); 
		GUI::DrawLine(pos+moveVars.AxleRear.LeftWheel.LocalPosition, pos+moveVars.AxleRear.RightWheel.LocalPosition, SColor(255,255,0,0)); 
		GUI::DrawLine(pos+moveVars.AxleFront.LocalPosition, pos+moveVars.AxleRear.LocalPosition, SColor(255,255,0,0)); 

		Vec2f weightedpos = getDriver().getScreenPosFromWorldPos(pos+moveVars.CenterOfGravity); 
		GUI::DrawRectangle(weightedpos+Vec2f(-4,-4), weightedpos+Vec2f(4,4), SColor(255,255,0,0));

	   	int i = 10;
	    GUI::DrawText("Speed: " + moveVars.KMPH, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText("RPM: " + moveVars.EngineRPM, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText("Gear: " + (moveVars.CurrentGear + 1), Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "Gear State: " + moveVars.GearState, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText("LocalAcceleration: " + moveVars.LocalAcceleration, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "LocalVelocity: " + moveVars.LocalVelocity, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "Velocity: " + moveVars.Velocity, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "SteerAngle: " + moveVars.SteerAngle, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "AngularVelocity: " + moveVars.AngularVelocity, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "CenterOfGravity: " + moveVars.CenterOfGravity, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "HeadingAngle: " + moveVars.HeadingAngle, Vec2f(32, 16*i), color_white); i++;

	    GUI::DrawText( "TireFL Weight: " + moveVars.AxleFront.LeftWheel.ActiveWeight, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "TireFR Weight: " + moveVars.AxleFront.RightWheel.ActiveWeight, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "TireRL Weight: " + moveVars.AxleRear.LeftWheel.ActiveWeight, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "TireRR Weight: " + moveVars.AxleRear.RightWheel.ActiveWeight, Vec2f(32, 16*i), color_white); i++;

	    GUI::DrawText( "TireFL Friction: " + moveVars.AxleFront.LeftWheel.FrictionForce, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "TireFR Friction: " + moveVars.AxleFront.RightWheel.FrictionForce, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "TireRL Friction: " + moveVars.AxleRear.LeftWheel.FrictionForce, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "TireRR Friction: " + moveVars.AxleRear.RightWheel.FrictionForce, Vec2f(32, 16*i), color_white); i++;


	    GUI::DrawText( "AxleF SlipAngle: " + moveVars.AxleFront.SlipAngle, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "AxleR SlipAngle: " + moveVars.AxleRear.SlipAngle, Vec2f(32, 16*i), color_white); i++;

	    GUI::DrawText( "Rolling Vel F: " + moveVars.AxleFront.RollingVel, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "Rolling Vel R: " + moveVars.AxleRear.RollingVel, Vec2f(32, 16*i), color_white); i++;
	    GUI::DrawText( "AxleR Torque: " + moveVars.DriveTorque, Vec2f(32, 16*i), color_white); i++;
	    i++;
	    GUI::DrawText( "rrw ffy: " + moveVars.AxleRear.RightWheel.FrictionForce.y, Vec2f(32, 16*i), color_white); i++;

	   float dtor = ( moveVars.DriveTorque*0.01);
	   GUI::DrawRectangle(Vec2f(254, 16*i), Vec2f(256+moveVars.KMPH, (16*i)+16), SColor(255,255,0,0));
	   GUI::DrawRectangle(Vec2f(254 , 16*i), Vec2f(256, (16*i)+16), color_white);
	   GUI::DrawRectangle(Vec2f(254 +(moveVars.AxleRear.RollingVel), 16*i), Vec2f(256+(moveVars.AxleRear.RollingVel), (16*i)+16), SColor(255,0,0,255));
	   GUI::DrawRectangle(Vec2f(254 +(moveVars.DriveTorque*WheelRadius/360), 16*i), Vec2f(256+(moveVars.DriveTorque*WheelRadius/360), (16*i)+16), SColor(255,255,120,255));
	   GUI::DrawRectangle(Vec2f(254 +(moveVars.AxleFront.RollingVel), 16*i), Vec2f(256+(moveVars.AxleFront.RollingVel), (16*i)+16), SColor(255,0,255,0)); i++;

	   Vec2f start = Vec2f(100, 200);
	   Vec2f end = Vec2f(200, 200);
	   GUI::DrawLine2D(start,end, color_white);

	   for (uint j = 0; j <= 10; j++)
	   {
	   		float Torque = (moveVars.TorqueCurve[j]* moveVars.getGearRatio() * 0.8)/100;
	   		float Torque2 = (moveVars.TorqueCurve[j+1]* moveVars.getGearRatio() * 0.8)/100;
	   		GUI::DrawLine2D(Vec2f(start.x + (j*10), start.y-Torque),Vec2f(start.x + ((j+1)*10), start.y-Torque2), SColor(255,0,255,0));

	   		GUI::DrawLine2D(Vec2f(start.x + (j*10), start.y-10), Vec2f(start.x + (j*10), start.y), color_white);
	   }

	   //Vec2f frontslip(0, -6); frontslip.RotateBy(moveVars.AxleFront.SlipAngle + blob.getAngleDegrees());
	   //Vec2f rearslip(0, -6); rearslip.RotateBy(moveVars.AxleRear.SlipAngle + blob.getAngleDegrees());

	   //GUI::DrawLine( pos+moveVars.AxleFront.LocalPosition, pos+moveVars.AxleFront.LocalPosition+frontslip, SColor(255,0,255,255) );
	   //GUI::DrawLine( pos+moveVars.AxleRear.LocalPosition, pos+moveVars.AxleRear.LocalPosition+rearslip, SColor(255,0,255,255) );

	   //GUI::DrawLine( pos+moveVars.AxleFront.LeftWheel.LocalPosition, pos+moveVars.AxleFront.LeftWheel.LocalPosition+(moveVars.AxleFront.LeftWheel.FrictionForce/300).RotateBy(moveVars.AxleFront.LeftWheel.HeadingAngle), SColor(255,0,255,255) );
	   //GUI::DrawLine( pos+moveVars.AxleFront.RightWheel.LocalPosition, pos+moveVars.AxleFront.RightWheel.LocalPosition+(moveVars.AxleFront.RightWheel.FrictionForce/300).RotateBy(moveVars.AxleFront.RightWheel.HeadingAngle), SColor(255,0,255,255) );
	   //GUI::DrawLine( pos+moveVars.AxleRear.LeftWheel.LocalPosition, pos+moveVars.AxleRear.LeftWheel.LocalPosition+(moveVars.AxleRear.LeftWheel.FrictionForce/300).RotateBy(moveVars.AxleRear.LeftWheel.HeadingAngle), SColor(255,0,255,255) );
	   //GUI::DrawLine( pos+moveVars.AxleRear.RightWheel.LocalPosition, pos+moveVars.AxleRear.RightWheel.LocalPosition+(moveVars.AxleRear.RightWheel.FrictionForce/300).RotateBy(moveVars.AxleRear.RightWheel.HeadingAngle), SColor(255,0,255,255) );
	}
}