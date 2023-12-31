// Kar Movement
#include "KarCommon.as";

void onInit(CMovement@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;	

	KarBody engine;
	@engine.AxleFront = KarAxle( 2.0, -3.5, this.getBlob().getAngleDegrees());
	@engine.AxleRear =  KarAxle( 2.0,  3.5, this.getBlob().getAngleDegrees());

	engine.EngineRPM = 750;
	engine.CurrentGear = 0;
	engine.GearState = GearStates::Neuteral;
	engine.AngularVelocity = 0;	

	//engine.CGHeight = 0.55f;
	engine.Mass = this.getBlob().getMass();
	engine.BrakePower = 12000; // footbrake stopping power
	engine.EBrakePower = 55000; // handbrake stopping power
	engine.LongWeightTransfer = 1.0f; //scale of mass that can be shifted
	engine.LatWeightTransfer = 1.0f; //scale of mass that can be shifted
	//engine.AirResistance = 0.15f; // air drag, blob shape drag can handle this in cfg
	engine.RollingResistance = 5.5f; // rolling drag, should be approx 30* air drag
	engine.CornerStiffnessFront = 15.0f; //lateral tire friction multiplier front wheels
	engine.CornerStiffnessRear = 13.0f;  //lateral tire friction multiplier back wheels
	engine.MaxSteerAngle = 33.0f; // max angle(degrees) the steering wheels can be, relative to the car
	engine.SteerPower = 0.6f; // power steering scale : how fast we lerp from current steer angle to wanted (max)steerangle 
	engine.AngularFricFeedbackScale = 1.0f; // friction scalar applied to angular torque. ie. how much the car will try to make its angle perpendicular to its velocity angle
	//engine.SpeedTurningStability = 10.0f; // how much harder it is to turn at high speeds

	// Left wheels to right wheels distance 
	engine.TrackWidth = (Maths::Abs(engine.AxleRear.LeftWheel.Origin.x) + Maths::Abs(engine.AxleRear.RightWheel.Origin.x));
	// Front axle to back axle distance
	engine.WheelBase = (Maths::Abs(engine.AxleFront.Origin.y) + Maths::Abs(engine.AxleRear.Origin.y));	

	int[] eCurve = { 100, 210, 325, 440, 570, 600, 640, 610, 450, 100, 10, 1 }; // horsepower at each x1000 rpm
	engine.TorqueCurve = eCurve;	
	float[] gRatios = { 4.8f, 2.8f, 2.3f, 1.7f, 1.3f, 1.0f, 0.9f}; engine.EffectiveGearRatio =  2.9f;
	engine.GearRatios = gRatios;

	//engine.PeakRPM = 6000;
	//engine.OptimalShiftUpRPM = gRatios[CurrentGear]/gRatios[CurrentGear+1])*engine.PeakRPM;
	//engine.OptimalShiftDownRPM = gRatios[CurrentGear]/gRatios[CurrentGear-1])*engine.PeakRPM;

	this.getBlob().set("moveVars", engine);

	EngineUpdate(this.getBlob(), engine, 0, 0, 0); //update its numbers once to prevent sanic boost

}

float Throttle = 0;
bool wasNuetral = true;
void onTick(CMovement@ this)
{	
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	KarBody@ engine;
	if (!blob.get("moveVars", @engine))
	{ return; }

	const bool is_client = getNet().isClient();
	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);
	const bool use		= blob.isKeyPressed(key_use);
		//const bool spacebar	= blob.isKeyPressed(key_action3); // has problems for obvious no reason

	float Brake = 0;
	float EBrake = 0;	
	float Steer = 0;

	//if (is_client) //needed?
	{		
		if (up && !down) 
		{
			if ( -engine.LocalVelocity.y < -2.0f) {Throttle = Maths::Lerp(Throttle, 0, 0.1); Brake = 1; }
			else 
			{ Throttle = Maths::Lerp(Throttle, 1, 0.3); engine.GearState = GearStates::Forwards;}
		} 
		else if (!up && down)// && !up) 
		{
			if ( -engine.LocalVelocity.y > 2.0f) { Throttle = Maths::Lerp(Throttle, 0, 0.1); Brake = 1; }
			else 
			{ Throttle = Maths::Lerp(Throttle, -1, 0.3);  engine.GearState = GearStates::Reverse;}
		}
		else
		{
			engine.GearState = GearStates::Neuteral;	

			Throttle = Maths::Lerp(Throttle, 0, 1);	
		}


		if(!left && right) { Steer = 1;}
		else if(left && !right)	{ Steer = -1;}	

		if(blob.isKeyPressed(key_action3)) { EBrake = 1; }

		if (getRules().isWarmup())		 
		{
			engine.GearState = GearStates::Neuteral;						
			engine.KMPH = 0;			
		}	

		if (engine.GearState == GearStates::Neuteral)
		{
			wasNuetral = true;
			if (Throttle > 0)
			{
				engine.EngineRPM += Pi2 * (engine.getGearRatio()*2 * engine.EffectiveGearRatio); 
			}
			else if (engine.EngineRPM > 150)
			{
				engine.EngineRPM -= Pi2 * (engine.getGearRatio()*2 * engine.EffectiveGearRatio);
			}
		}	
		else
		{
			//if (wasNuetral) //init race boost
			//{
			//	blob.AddForce(Vec2f(0, engine.EngineRPM*0.8).RotateBy(-blob.getAngleDegrees()));
			//	wasNuetral = false;
			//}
	

			blob.getShape().SetCenterOfMassOffset(engine.CenterOfGravity);				
			blob.setAngularVelocity(engine.AngularForce);

			//blob.AddForce(engine.VelocityForce);
			//blob.AddForceAtPosition(engine.VelocityForce, blob.getPosition()+engine.CenterOfGravity);
			//blob.AddForceAtPosition(engine.VelocityForce, blob.getPosition()+engine.AxleRear.LocalPosition);

		}	
			EngineUpdate(blob, engine, Brake, EBrake, Steer);

		while (engine.EngineRPM < 500) 
		{
			engine.EngineRPM += 150+XORRandom(150);
		}
		while (engine.EngineRPM > 7500) 
		{
			engine.EngineRPM -= 150+XORRandom(150);
		}

		//if (engine.KMPH > 120 && blob.isMyPlayer() )
		//ShakeScreen((engine.KMPH-120)*0.2, 10, blob.getPosition());
	}

	CSprite@ sprite = blob.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("untitled.ogg");

		sprite.SetEmitSoundPaused(false);
		sprite.SetEmitSoundVolume(0.50f+Maths::Abs((Throttle/50)));
		sprite.SetEmitSoundSpeed(0.2f + (engine.EngineRPM/8000));	
		//sprite.getVars().sound_emit_pitch = 0.1f + (engine.EngineRPM/2000);
	}	
}

void EngineUpdate(CBlob@ blob, KarBody@ engine, float Brake, float EBrake, float steerInput)
{		
	Vec2f Pos = blob.getPosition();
	f32 HeadingAngle = blob.getAngleDegrees();
	engine.AngularVelocity = blob.getAngularVelocity();	

	engine.Velocity = blob.getVelocity()*SpeedFactor;
	float AbsoluteVelocity = engine.Velocity.Length();	
	Vec2f localvelvec = engine.Velocity;
	engine.LocalVelocity = localvelvec.RotateBy(-HeadingAngle);	

	engine.KMPH = Maths::Lerp(engine.KMPH, Maths::Abs(-engine.LocalVelocity.y), 0.4);

	
	//simple way, doesnt allow for wheelspin :(
	//engine.AxleRear.RollingVel = ((engine.KMPH/3.6)/engine.AxleRear.WheelRadius) * 1.0-(EBrake ? 1.0 : (Brake ? 0.5 : 0.0)); //radians per second
	//print(""+wheelRotRate);



	if (Brake == 1)
	{
		engine.AxleFront.RollingVel *=  0.96; //radians per second
		engine.AxleRear.RollingVel *=  0.96; //radians per second
	}
	else if (EBrake == 1)
	{
		engine.AxleFront.RollingVel *=  0.85; //radians per second
		engine.AxleRear.RollingVel *=  0.85; //radians per second
	}
	else
	{
		engine.AxleFront.RollingVel = (Maths::Abs(-engine.LocalVelocity.y)/Maths::Pi)/engine.AxleRear.WheelRadius;
		//engine.AxleRear.RollingVel = Maths::Lerp(engine.AxleRear.RollingVel, (engine.KMPH/3.6)/engine.AxleRear.WheelRadius, 0.2); //radians per second
	}

	if (Maths::Abs(engine.AxleRear.RollingVel) < 0.1) engine.AxleRear.RollingVel = 0;

	engine.EngineRPM = Maths::Lerp(engine.EngineRPM, Maths::Abs(engine.AxleRear.RollingVel) * engine.getGearRatio() * engine.EffectiveGearRatio * (60 / Pi2), 0.3f);
	//engine.EngineRPM = Maths::Lerp(engine.EngineRPM, engine.KMPH / PiSec * engine.getGearRatio() * engine.EffectiveGearRatio, 0.3f);

	if (engine.GearState == GearStates::Reverse)
	{
		engine.EngineRPM = Maths::Min(engine.EngineRPM, 5000);
	}

	// gears //
	if (engine.EngineRPM > 6200 && engine.CurrentGear != 5 && engine.ClutchTimer == 0 && Maths::Abs(engine.SteerAngle) < 3)
 	{ 			
 		engine.CurrentGear += 1; 
 		engine.ClutchTimer = 15;
 	}	
 	else if (engine.EngineRPM < 3100 && engine.CurrentGear > 0 && engine.ClutchTimer == 0)
 	{
 		engine.CurrentGear -= 1; 
 		engine.ClutchTimer = 15;
 	}

 	if (engine.ClutchTimer > 0) { engine.ClutchTimer--; }

	// Forces
 	int SignedAccelY = -engine.LocalAcceleration > 0 ? 1 : -1;
 	int SignedVelY = -engine.LocalVelocity.y > 0 ? 1 : -1;
 	//int SignedX = engine.LocalAcceleration.x >= 0 ? 1 : -1;

	// Steering direction	
	engine.SteerAngle = Maths::Lerp(engine.SteerAngle, SignedVelY*steerInput*(engine.MaxSteerAngle*(1-(AbsoluteVelocity/250))), engine.SteerPower*(1-(AbsoluteVelocity/250)));
	//if (Maths::Abs(engine.SteerAngle) < 0.001) engine.SteerAngle = 0;

	// steer wheel angle
	engine.AxleFront.RightWheel.HeadingAngle = HeadingAngle+engine.SteerAngle;
	engine.AxleFront.LeftWheel.HeadingAngle = HeadingAngle+engine.SteerAngle;		
	engine.AxleRear.RightWheel.HeadingAngle = HeadingAngle;
	engine.AxleRear.LeftWheel.HeadingAngle = HeadingAngle;

	// Weight transfer
	const float transferX = Maths::Clamp(engine.LocalVelocity.x/120, -1.0,1.0)*engine.LatWeightTransfer;
	const float transferY = Maths::Clamp(-engine.LocalVelocity.y/120, -1.0,1.0)*engine.LongWeightTransfer;

	// Weight on each tire
	engine.AxleFront.LeftWheel.ActiveWeight =  Vec2f(0.5-transferX, 0.5-transferY).Length()*engine.Mass;
	engine.AxleFront.RightWheel.ActiveWeight = Vec2f(0.5+transferX, 0.5-transferY).Length()*engine.Mass;
	engine.AxleRear.LeftWheel.ActiveWeight =   Vec2f(0.5-transferX, 0.5+transferY).Length()*engine.Mass;
	engine.AxleRear.RightWheel.ActiveWeight =  Vec2f(0.5+transferX, 0.5+transferY).Length()*engine.Mass;

	//print(""+
	//	(
	//		engine.AxleFront.LeftWheel.ActiveWeight + engine.AxleFront.RightWheel.ActiveWeight+ engine.AxleRear.LeftWheel.ActiveWeight+ engine.AxleRear.RightWheel.ActiveWeight  )
	//	);

	Vec2f weightOffset = Vec2f(0,1).RotateBy(HeadingAngle);
	if (AbsoluteVelocity > 0.1) 
	{ 
		weightOffset = Vec2f((engine.TrackWidth/2)*transferX, 1+(engine.WheelBase/2)*transferY);  
		engine.CenterOfGravity = weightOffset.RotateBy(HeadingAngle);
	}

	// Slip angle, latitudal tyre slip
	engine.AxleFront.SlipAngle = (Maths::ATan2(engine.LocalVelocity.x - (-engine.WheelBase*engine.AngularVelocity/2), Maths::Abs(engine.LocalVelocity.y))*RADtoDEG) + (SignedVelY* engine.SteerAngle*DEGtoRAD);
	engine.AxleRear.SlipAngle =  (Maths::ATan2(engine.LocalVelocity.x - (engine.WheelBase*engine.AngularVelocity/2), Maths::Abs(engine.LocalVelocity.y))*RADtoDEG);

	const uint16 tileType = getMap().getTile(Pos).type;	
	f32 groundDrag, groundFriction;
	int GroundType;
	getGroundEffects(tileType, groundDrag, groundFriction, GroundType);

	// tire drag
    const float dragForceY = ( (-engine.RollingResistance * groundFriction) * groundDrag  * engine.LocalVelocity.y );
	//const float dragForceX = ((engine.RollingResistance * groundFriction) * groundDrag ) * engine.LocalVelocity.x * engine.LocalVelocity.x;
	//blob.AddForce(Vec2f(dragForceX, dragForceY).RotateBy(HeadingAngle)*0.01);

	// Brake and Torque output	
	//const float activeBrake = 1.0-(EBrake ? 1 : (Brake ? 1 : 0));
	float activeBrake = 1.0 - (Brake * EBrake);
	float activeTorque = (Throttle * engine.GetTorque() * engine.getGearRatio() * engine.EffectiveGearRatio);// Nm, divided by 2 wheels

	// engine torque converted to wheel torque (rear wheel drive), Nm
	engine.DriveTorque = Maths::Lerp(engine.DriveTorque, (activeTorque), 0.2); //(EBrake ? 0.8 : (Brake ? 0.05 : 0.1))
	if (Maths::Abs(engine.DriveTorque) < 1 ) engine.DriveTorque = 0;

	//const float RearSlipRatio =  1.5-(1.0 - (engine.KMPH - Maths::Abs(engine.AxleRear.Torque/1000)) / Maths::Max(engine.KMPH, 1));
	//float SlipRatio = (engine.AxleRear.RollingVel / AbsoluteVelocity) -1;

	//print("sr "+SlipRatio);

	
	//engine.AxleRear.RollingVel += (Throttle * engine.getGearRatio() * engine.EffectiveGearRatio)*engine.AxleRear.WheelRadius; //radians per second
	engine.AxleRear.RollingVel = Maths::Lerp(engine.AxleRear.RollingVel, ((engine.DriveTorque*engine.AxleRear.WheelRadius/Pi2)/30)+(-engine.LocalVelocity.y*0.99), 0.2);

	//SlipRatio = (engine.LocalVelocity.y-engine.AxleRear.RollingVel)/100;

	// tire traction against ground
	// total torque = drive torque + traction torques from both wheels + brake torque
	// angular acceleration = total torque / rear wheel inertia.
	// inertia of a cylinder = Mass * radius2 / 2
	// rear wheel angular velocity += rear wheel angular acceleration * time step

	//float longSlip = Maths::ATan((-engine.LocalVelocity.y) - (engine.AxleRear.RollingVel))*1200;
	//print("long "+longSlip);

	const float TotalTorque = (-engine.AxleRear.FrictionForce.y);
	float MomentOfInertia = (80 * Maths::Pow(engine.AxleRear.WheelRadius, 2)/2)*2;
	float wheelangularaccel = (-TotalTorque) / (MomentOfInertia);

	//print(""+wheelangularaccel);
	// Finalizing forces
	//engine.LocalAcceleration = TotalTorque;
	float rcp_lon_velocity = 0;
	if(Maths::Abs(engine.LocalVelocity.y) >= 1)
	rcp_lon_velocity = (1 / Maths::Abs(engine.LocalVelocity.y));
	float sigma = (engine.AxleRear.RollingVel - -engine.LocalVelocity.y) * rcp_lon_velocity;

	float SlipRatio = Throttle; //longitudal tyre slip
	if (Maths::Abs(-engine.LocalVelocity.y) >= 1)
	SlipRatio = (engine.AxleRear.RollingVel / Maths::Abs(-engine.LocalVelocity.y))-1;

	//print("slip "+SlipRatio);

	//if (rwd)
	{
		engine.AxleFront.LeftWheel.FrictionForce.x = (-engine.CornerStiffnessFront*engine.AxleFront.SlipAngle/90)*engine.AxleFront.LeftWheel.ActiveWeight;
		engine.AxleFront.RightWheel.FrictionForce.x = (-engine.CornerStiffnessFront*engine.AxleFront.SlipAngle/90)*engine.AxleFront.RightWheel.ActiveWeight;
		engine.AxleRear.LeftWheel.FrictionForce.x = (-engine.CornerStiffnessRear*engine.AxleRear.SlipAngle/90)*engine.AxleRear.LeftWheel.ActiveWeight;
		engine.AxleRear.RightWheel.FrictionForce.x = (-engine.CornerStiffnessRear*engine.AxleRear.SlipAngle/90)*engine.AxleRear.RightWheel.ActiveWeight;

		//engine.AxleFront.LeftWheel.FrictionForce.y = engine.AxleFront.RightWheel.FrictionForce.y = dragForceY;

		//if (Maths::Abs(engine.LocalVelocity.y) >= 1)
		{
			//if (Maths::Abs(a) < .5) a=Throttle;
			//if (Maths::Abs(b) < .5) b=Throttle; 
			//print("a "+a + " b" +b);
			engine.AxleRear.LeftWheel.FrictionForce.y =  (pacejka(-engine.AxleFront.LeftWheel.ActiveWeight*Gravity, SlipRatio, groundFriction)/2);
			engine.AxleRear.RightWheel.FrictionForce.y = (pacejka(-engine.AxleFront.RightWheel.ActiveWeight*Gravity, SlipRatio, groundFriction)/2);
		}		
		//else
		//{
		//	engine.AxleRear.LeftWheel.FrictionForce.y =  (-engine.DriveTorque/36);
		//	engine.AxleRear.RightWheel.FrictionForce.y = (-engine.DriveTorque/36);
		//}	
	}
	//else {  }
	//combined weights on axles
	engine.AxleFront.FrictionForce = (engine.AxleFront.LeftWheel.FrictionForce + engine.AxleFront.RightWheel.FrictionForce); 
	engine.AxleRear.FrictionForce = (engine.AxleRear.LeftWheel.FrictionForce + engine.AxleRear.RightWheel.FrictionForce);

	Vec2f RRWForces = engine.AxleRear.RightWheel.FrictionForce; RRWForces.RotateBy(engine.AxleRear.RightWheel.HeadingAngle);
	blob.AddForceAtPosition(RRWForces*0.01, blob.getPosition()+engine.AxleRear.RightWheel.LocalPosition);	

	Vec2f RLWForces = engine.AxleRear.LeftWheel.FrictionForce; RLWForces.RotateBy(engine.AxleRear.LeftWheel.HeadingAngle);
	blob.AddForceAtPosition(RLWForces*0.01, blob.getPosition()+engine.AxleRear.LeftWheel.LocalPosition);	

	Vec2f FRWForces = engine.AxleFront.RightWheel.FrictionForce; FRWForces.RotateBy(engine.AxleFront.RightWheel.HeadingAngle);
	blob.AddForceAtPosition(FRWForces*0.01, blob.getPosition()+engine.AxleFront.RightWheel.LocalPosition);	

	Vec2f FLWForces = engine.AxleFront.LeftWheel.FrictionForce; FLWForces.RotateBy(engine.AxleFront.LeftWheel.HeadingAngle);
	blob.AddForceAtPosition(FLWForces*0.01, blob.getPosition()+engine.AxleFront.LeftWheel.LocalPosition);		

	f32 angularFrictionFeedback = ((engine.AxleFront.FrictionForce.x - engine.AxleRear.FrictionForce.x)/engine.Mass)*engine.AngularFricFeedbackScale;	
	f32 angularAcceleration = (angularFrictionFeedback+engine.SteerAngle) * 0.01;	
	
	engine.AngularForce += angularAcceleration;
	engine.AngularForce = Maths::Lerp(engine.AngularForce, 0, 0.035);

	// Speed is too low to turn
	if (engine.KMPH < 0.1f && Maths::Abs(engine.DriveTorque) < 0.0001 ) { engine.AngularForce = 0; }	

	//print("latfric "+engine.DriveTorque +" ftm "+ FrictionTorqueMax);

		// Skidmarks
	if (Maths::Abs(SlipRatio) > (groundFriction)) 
	{		
		engine.AxleRear.RightWheel.SkidActive = true;
		engine.AxleRear.LeftWheel.SkidActive = true;
	} 
	else 
	{
		engine.AxleRear.RightWheel.SkidActive = false;
		engine.AxleRear.LeftWheel.SkidActive = false;			
	}

	AxleUpdate(blob, engine.AxleFront, -HeadingAngle, Pos, AbsoluteVelocity);
	AxleUpdate(blob, engine.AxleRear, -HeadingAngle, Pos, AbsoluteVelocity);		
}

void AxleUpdate(CBlob@ blob, KarAxle@ axle, float karAngle, Vec2f karpos, float karAbsoluteVelocity)
{
	Vec2f OriginRotated = axle.Origin;
	OriginRotated.RotateBy(-karAngle);
	axle.LocalPosition = OriginRotated;

	WheelUpdate(blob, axle.LeftWheel, karAngle,karpos,karAbsoluteVelocity);
	WheelUpdate(blob, axle.RightWheel, karAngle,karpos,karAbsoluteVelocity);
}	

float pacejka(float downforce, float slip, float groundFriction)
{
	//	Typical values for longitudinal forces
	//		Dry tarmac	Wet tarmac	Snow	Ice
	// b	10			12			5		4 
	// c	1.9			2.3			2		2
	// d	1			0.82		0.3		0.1
	// e	0.97		1			1		1

	//float a = 0.95; // Adherent
	float b = 12.0; 	// Stiffness
	float c = 1.1; 		// Shape
	float d = 2.0; 		// Peak
	float e = 0.96; 	// Curvature

	float F = downforce * d * Maths::Sin(c * Maths::ATan(b * slip - e * (b*slip - Maths::ATan(b*slip))));
	return F;
}

void WheelUpdate(CBlob@ blob, KarWheel@ wheel, float karAngle, Vec2f karpos, float karAbsoluteVelocity)
{	
	Vec2f OriginRotated = wheel.Origin;
	OriginRotated.RotateBy(-karAngle);
	wheel.LocalPosition = OriginRotated;

	uint16 type = getMap().getTile(karpos+wheel.LocalPosition).type;

	const uint16 tileType = getMap().getTile(karpos+wheel.LocalPosition).type;	
	f32 groundDrag, groundFriction;
	int GroundType;
	getGroundEffects(tileType, groundDrag, groundFriction, GroundType);

	//if (karAbsoluteVelocity > 1)
	//{
	//	blob.getSprite().PlayRandomSound("/RumblerHit", 0.6+(karAbsoluteVelocity/20), 0.1+(karAbsoluteVelocity/6));
	//}

	if (wheel.SkidActive)
	{
		switch (GroundType)
		{
			case 0: //rubber/road
			{
				CParticle@ p = ParticlePixel(karpos+wheel.LocalPosition, Vec2f_zero, color_black, true, 30);
				if (getGameTime() % 5 == 0)
				makeSmokeParticle(karpos+wheel.LocalPosition);
				float ff = Maths::Abs(wheel.FrictionForce.x/7000);
				if (getGameTime() % 2 == 0)
				Sound::Play("CarSkidding2.ogg", karpos+wheel.LocalPosition, 0.15+(karAbsoluteVelocity/250), 0.55+(karAbsoluteVelocity/180));
				break;
			}
			case 1: //grass
			{			
				CParticle@ p = ParticlePixel(karpos+wheel.LocalPosition, Vec2f_zero, SColor(0xff371f0e), true, 30);

				CParticle@ p2 = ParticlePixel(karpos+wheel.LocalPosition, Vec2f(0,3).RotateBy(karAngle), SColor(0xff371f0e), true, 10);
				if (p2 !is null)
				{
					p2.damping = 0.88;
				}
				if (getGameTime() % 12 == 0)
				blob.getSprite().PlayRandomSound("/Dirty", 0.15+(karAbsoluteVelocity/250), 0.5+(karAbsoluteVelocity/180));
				break;
			}			
			case 2: //water
			{			
				CParticle@ p = ParticlePixel(karpos+wheel.LocalPosition, Vec2f_zero, SColor(0xff371f0e), true, 30);
				//if (getGameTime() % 12 == 0)
				//blob.getSprite().PlayRandomSound("/Wet", 0.4+(karAbsoluteVelocity/20), 0.5+(karAbsoluteVelocity/15));
				break;
			}
		}							
	}

}