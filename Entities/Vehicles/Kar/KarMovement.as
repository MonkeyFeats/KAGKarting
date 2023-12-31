// Kar Movement
#include "KarCommon.as";

/*
const string test_name = "visualizer.png";
const string test_name2 = "visu2.png";

u16[] Square_IDs = {1,0,3,1,3,2};
Vertex[] circle = 
{
	Vertex(-64,-64,  0.0, 0,0),
	Vertex( 64,-64,  0.0, 1,0),
	Vertex( 64, 64,  0.0, 1,1),
	Vertex(-64, 64,  0.0, 0,1)
};

void onInit(CBlob@ this)
{
	//Setup();
	Render::addBlobScript(Render::layer_posthud, this, "KarMovement.as", "render");
}

float wheelang = 0;	

Vertex[] floor = 
{
	Vertex(-64,-15,  0.0, 0,0),
	Vertex( 64,-15,  0.0, 1,0),
	Vertex( 64, 15,  0.0, 1,1),
	Vertex(-64, 15,  0.0, 0,1)
};

void render(CBlob@ this, int id)
{	
	KarEngine@ engine;
	if (!this.get("moveVars", @engine))
	{ return; }

	Render::SetAlphaBlend(true);
	Render::SetZBuffer(true, true);
	Render::ClearZ();
	Render::SetTransformScreenspace();

	wheelang += engine.AxleRear.RollingVel*.03;

	float[] model;
	Matrix::MakeIdentity(model);
	Matrix::SetTranslation(model, 512, 512, 128);
	Matrix::SetRotationDegrees(model, 0 , 0 , wheelang);
	Render::SetModelTransform(model);
	Render::RawQuads(test_name, circle);

	floor[0].u += (-engine.LocalVelocity.y*0.0003);
	floor[1].u += (-engine.LocalVelocity.y*0.0003); 
	floor[2].u += (-engine.LocalVelocity.y*0.0003); 
	floor[3].u += (-engine.LocalVelocity.y*0.0003);  

	Matrix::MakeIdentity(model);
	Matrix::SetTranslation(model, 512, 590, 128);
	//Matrix::SetRotationDegrees(model, 0 , 0 , wheelang);
	Render::SetModelTransform(model);

	Render::RawQuads(test_name2, floor);
}

*/

void onInit(CMovement@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;	

	KarEngine engine;
	@engine.AxleFront = KarAxle( 2.15, -3.5, this.getBlob().getAngleDegrees());
	@engine.AxleRear =  KarAxle( 2.15,  3.5, this.getBlob().getAngleDegrees());

	engine.EngineRPM = 750;
	engine.CurrentGear = 0;
	engine.GearState = GearStates::Neuteral;
	engine.AngularVelocity = 0;	

	//engine.CGHeight = 0.55f;
	engine.Mass = this.getBlob().getMass();
	engine.BrakePower = 12000; // footbrake stopping power
	engine.EBrakePower = 55000; // handbrake stopping power
	engine.LongWeightTransfer = 0.6f; //scale of mass that can be shifted
	engine.LatWeightTransfer = 0.6f; //scale of mass that can be shifted
	engine.CornerStiffnessFront = 12.0f; //lateral tire friction multiplier front wheels
	engine.CornerStiffnessRear = 14.0f;  //lateral tire friction multiplier back wheels
	engine.MaxSteerAngle = 33.0f; // max angle(degrees) the steering wheels can be, relative to the car
	engine.SteerPower = 0.23f; // power steering scale : how fast we lerp from current steer angle to wanted (max)steerangle 
	engine.AngularFricFeedbackScale = 1.0f; // friction scalar applied to angular torque. ie. how much the car will try to make its angle perpendicular to its velocity angle

	// Left wheels to right wheels distance 
	engine.TrackWidth = (Maths::Abs(engine.AxleRear.LeftWheel.Origin.x) + Maths::Abs(engine.AxleRear.RightWheel.Origin.x));
	// Front axle to back axle distance
	engine.WheelBase = (Maths::Abs(engine.AxleFront.Origin.y) + Maths::Abs(engine.AxleRear.Origin.y));	

	int[] eCurve = { 10, 150, 260, 370, 450, 520, 600, 450, 360, 150, 10, 1 }; // horsepower at each x1000 rpm
	engine.TorqueCurve = eCurve;	
	float[] gRatios = { 4.2f, 3.1f, 2.2f, 1.4f, 1.2f, 0.95f, 0.8f}; engine.EffectiveGearRatio =  2.8f;
	//float[] gRatios = { 12.47f, 8.99f, 6.67f, 4.64f, 3.625f, 2.9f, 2.32f}; //pre multiplied by effective-gear/final-drive ratio, saves doing it on tick
	engine.GearRatios = gRatios;

	//engine.PeakRPM = 6000;
	//engine.OptimalShiftUpRPM = gRatios[CurrentGear]/gRatios[CurrentGear+1])*engine.PeakRPM;
	//engine.OptimalShiftDownRPM = gRatios[CurrentGear]/gRatios[CurrentGear-1])*engine.PeakRPM;

	this.getBlob().set("moveVars", engine);

	EngineUpdate(this.getBlob(), engine, 0, 0, 0); //update its numbers once to prevent sanic boost

}

bool wasNuetral = true;
void onTick(CMovement@ this)
{	
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	KarEngine@ engine;
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

	if (is_client) //needed?
	{		
		if (up && !down) 
		{
			if ( -engine.LocalVelocity.y < -30.0f) {engine.Throttle = Maths::Lerp(engine.Throttle, 0, 0.1); Brake = 1; }
			else 
			{ if (engine.Throttle < 1) engine.Throttle += 0.1; engine.GearState = GearStates::Forwards;}
		} 
		else if (!up && down)// && !up) 
		{
			if ( -engine.LocalVelocity.y > 30.0f) { engine.Throttle = Maths::Lerp(engine.Throttle, 0, 0.1); Brake = 1; }
			else 
			{ if (engine.Throttle > -1) engine.Throttle -= 0.1;  engine.GearState = GearStates::Reverse;}
		}
		else
		{
			//engine.GearState = GearStates::Neuteral;
			engine.Throttle = 0;	
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
			if (engine.Throttle > 0)
			{
				engine.EngineRPM += Pi2 * (engine.getGearRatio()*2); 
			}
			else if (engine.EngineRPM > 150)
			{
				engine.EngineRPM -= Pi2 * (engine.getGearRatio()*2);
			}
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

	}

	CSprite@ sprite = blob.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("untitled.ogg");

		sprite.SetEmitSoundPaused(false);
		sprite.SetEmitSoundVolume(0.50f+Maths::Abs((engine.Throttle/50)));
		sprite.SetEmitSoundSpeed(0.2f + (engine.EngineRPM/8000));	
		//sprite.getVars().sound_emit_pitch = 0.1f + (engine.EngineRPM/2000);
	}	
}

void EngineUpdate(CBlob@ blob, KarEngine@ engine, float Brake, float EBrake, float steerInput)
{		
	Vec2f Pos = blob.getPosition();
	f32 HeadingAngle = blob.getAngleDegrees();
	engine.AngularVelocity = blob.getAngularVelocity();	

	engine.Velocity = blob.getVelocity()*SpeedFactor;
	float AbsoluteVelocity = engine.Velocity.Length();	
	Vec2f localvelvec = engine.Velocity;
	engine.LocalVelocity = localvelvec.RotateBy(-HeadingAngle);	

	engine.KMPH = Maths::Lerp(engine.KMPH, Maths::Abs(-engine.LocalVelocity.y), 0.4);
	if (AbsoluteVelocity < 1.0 && engine.Throttle == 0) 
	{
		engine.KMPH = 0;
		engine.Velocity = Vec2f_zero;
		engine.LocalVelocity = Vec2f_zero;
		blob.setVelocity(Vec2f_zero);
		engine.AxleFront.SlipAngle = 0;
		engine.AxleRear.SlipAngle =  0;
		//blob.setAngularVelocity(0);
		return;
	}

	if (Brake == 1)
	{
		engine.AxleFront.RollingVel *=  0.95;
		engine.AxleRear.RollingVel *=  0.95;
	}
	else if (EBrake == 1)
	{
		engine.AxleFront.RollingVel *= 0.15;
		engine.AxleRear.RollingVel *= 0.15;
	}
	//else
	//{
	//	engine.AxleFront.RollingVel = (Maths::Abs(-engine.LocalVelocity.y)/Maths::Pi)/engine.AxleRear.WheelRadius;
	//	//engine.AxleRear.RollingVel = Maths::Lerp(engine.AxleRear.RollingVel, (engine.KMPH/3.6)/engine.AxleRear.WheelRadius, 0.2); //radians per second
	//}

	//engine.EngineRPM = Maths::Lerp(engine.EngineRPM, engine.Throttle * (Maths::Abs(engine.AxleRear.RollingVel) / PiSec * engine.getGearRatio()), 0.5f);
	engine.EngineRPM = Maths::Lerp(engine.EngineRPM, Maths::Abs(engine.AxleRear.RollingVel) / (Pi2/60) * engine.getGearRatio(), 0.35f);

	if (engine.GearState == GearStates::Reverse)
	{
		engine.EngineRPM = Maths::Min(engine.EngineRPM, 8000);
	}

	// gears //
	if (engine.EngineRPM > 6100 && engine.CurrentGear != 5 && engine.ClutchTimer == 0 && Maths::Abs(engine.SteerAngle) < 33)
 	{ 			
 		engine.CurrentGear += 1; 
 		engine.ClutchTimer = 15;
 		//Sound::Play("engine2backfire.ogg", Pos);
 	}	
 	else if (engine.EngineRPM < 3200 && engine.CurrentGear > 0 && engine.ClutchTimer == 0)
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
	engine.SteerAngle = SignedVelY*steerInput*engine.MaxSteerAngle;
	if (Maths::Abs(engine.SteerAngle) < 0.01) engine.SteerAngle = 0;

	// steer wheel angle
	engine.AxleFront.RightWheel.HeadingAngle = HeadingAngle+engine.SteerAngle;
	engine.AxleFront.LeftWheel.HeadingAngle = HeadingAngle+engine.SteerAngle;		
	engine.AxleRear.RightWheel.HeadingAngle = HeadingAngle;
	engine.AxleRear.LeftWheel.HeadingAngle = HeadingAngle;

	// Weight transfer
	const float transferX = Maths::Clamp(engine.LocalVelocity.x/120, -engine.LatWeightTransfer, engine.LatWeightTransfer);
	const float transferY = Maths::Clamp(-engine.LocalVelocity.y/120, -engine.LongWeightTransfer, engine.LongWeightTransfer);

	// Weight on each tire
	engine.AxleFront.LeftWheel.ActiveWeight =  Maths::Max(Vec2f((0.5-transferX), 0.5-transferY).Length()*engine.Mass/4, 0);
	engine.AxleFront.RightWheel.ActiveWeight = Maths::Max(Vec2f((0.5+transferX), 0.5-transferY).Length()*engine.Mass/4, 0);
	engine.AxleRear.LeftWheel.ActiveWeight =   Maths::Max(Vec2f((0.5-transferX), 0.5+transferY).Length()*engine.Mass/4, 0)+5;
	engine.AxleRear.RightWheel.ActiveWeight =  Maths::Max(Vec2f((0.5+transferX), 0.5+transferY).Length()*engine.Mass/4, 0)+5;

	// Calculate weight center of four tires
	if (AbsoluteVelocity > 1.0f) {

		engine.CenterOfGravity = ((engine.AxleFront.LeftWheel.LocalPosition) * (engine.AxleFront.LeftWheel.ActiveWeight) +
					  			  (engine.AxleFront.RightWheel.LocalPosition) * (engine.AxleFront.RightWheel.ActiveWeight) +
				      			  (engine.AxleRear.LeftWheel.LocalPosition) * (engine.AxleRear.LeftWheel.ActiveWeight) +
					  			  (engine.AxleRear.RightWheel.LocalPosition) * (engine.AxleRear.RightWheel.ActiveWeight)) / engine.Mass;
	}	
	else 
	{
		engine.CenterOfGravity = Vec2f_zero;
	}
	//blob.getShape().SetCenterOfMassOffset(engine.CenterOfGravity);	
	
	//const float activeBrake = 1.0-(EBrake ? 1 : (Brake ? 1 : 0));
	float activeBrake = 1.0 - (Brake * EBrake);
	float activeTorque = (engine.Throttle * engine.GetTorque() * engine.getGearRatio());//In Newtons

	// engine torque converted to wheel torque (rear wheel drive), Nm
	engine.DriveTorque = Maths::Lerp(engine.DriveTorque, activeTorque, 0.9); //(EBrake ? 0.8 : (Brake ? 0.05 : 0.1))
	if (Maths::Abs(engine.DriveTorque) < 1 ) engine.DriveTorque = 0;

	float FrontAxleAngularVel = (-engine.AxleFront.Origin.y)*engine.AngularVelocity;
	float RearAxleAngularVel = (engine.AxleRear.Origin.y)*engine.AngularVelocity;
	
	// Slip angle, lateral tyre slip
	engine.AxleFront.SlipAngle = (Maths::ATan2(engine.LocalVelocity.x-FrontAxleAngularVel, Maths::Abs(engine.LocalVelocity.y))*RADtoDEG - engine.SteerAngle);
	engine.AxleRear.SlipAngle =  (Maths::ATan2(engine.LocalVelocity.x-RearAxleAngularVel, Maths::Abs(engine.LocalVelocity.y))*RADtoDEG);
	if (Maths::Abs(engine.LocalVelocity.y) < 0.1) {engine.AxleFront.SlipAngle = 0; engine.AxleRear.SlipAngle = 0;}

	float rcp_lat_velocity = (1.0 / Maths::Max(Maths::Abs(engine.LocalVelocity.x), 1.0));
	float rcp_long_velocity = (1.0 / Maths::Max(Maths::Abs(engine.LocalVelocity.y), 1.0));
	float long_slipRatiof = (engine.AxleFront.RollingVel - -engine.LocalVelocity.y) * rcp_long_velocity;
	float long_slipRatior = (engine.AxleRear.RollingVel - -engine.LocalVelocity.y) * rcp_long_velocity;

	AxleUpdate(blob, engine, engine.AxleFront, Pos, -HeadingAngle, AbsoluteVelocity, long_slipRatiof, false);	
	AxleUpdate(blob, engine, engine.AxleRear, Pos, -HeadingAngle, AbsoluteVelocity, long_slipRatior, true);
	
	// Speed is too low to turn
	if (engine.KMPH < 0.001f && Maths::Abs(engine.DriveTorque) < 0.0001 ) { engine.AngularForce = 0; }

	f32 angularAcceleration = (engine.SteerAngle*(1.5+Maths::Abs(-engine.LocalVelocity.y/25)));		
	engine.AngularForce = Maths::Lerp(engine.AngularForce, angularAcceleration, 0.8);	
	//engine.AngularForce = Maths::Lerp(engine.AngularForce, 0, 0.02+ (0.01+(AbsoluteVelocity/1000)));
	//if (Maths::Abs(engine.AngularForce) < 0.01) engine.AngularForce = 0.0;

	blob.AddTorque(engine.AngularForce - blob.getAngularVelocity());

	//float dragForceX = 0.15 * engine.LocalVelocity.x * Maths::Abs(engine.LocalVelocity.x);
	//float dragForceY = 0.15 * -engine.LocalVelocity.y * Maths::Abs(engine.LocalVelocity.y);
	//blob.AddForce(Vec2f(dragForceX, dragForceY).RotateBy(HeadingAngle)*0.01);
}

void AxleUpdate(CBlob@ blob, KarEngine@ engine, KarAxle@ axle, Vec2f karPos, float karAngle, float karAbsVel, float slipRatio, bool isDriveAxle)
{
	Vec2f OriginRotated = axle.Origin;
	OriginRotated.RotateBy(-karAngle);
	axle.LocalPosition = OriginRotated;

	float RollResistance = 0.0025f;
	axle.RollingVel = (-engine.LocalVelocity.y*(1.0 - RollResistance)) + (isDriveAxle ? engine.DriveTorque/WheelRadius/engine.Mass : 0);
	if (Maths::Abs(axle.RollingVel) < 0.01) axle.RollingVel = 0;

	axle.FrictionForce = axle.LeftWheel.FrictionForce + axle.RightWheel.FrictionForce; 

	WheelUpdate(blob, axle.LeftWheel, karPos, karAngle, karAbsVel, axle.SlipAngle, slipRatio);
	WheelUpdate(blob, axle.RightWheel, karPos, karAngle, karAbsVel, axle.SlipAngle, slipRatio);
}

void WheelUpdate(CBlob@ blob, KarWheel@ wheel, Vec2f karPos, float karAngle, float karAbsVel, float slipAngle, float slipRatio)
{
	Vec2f OriginRotated = wheel.Origin;
	OriginRotated.RotateBy(-karAngle);
	wheel.LocalPosition = OriginRotated;

	const uint16 tileType = getMap().getTile(karPos+wheel.LocalPosition).type;
	u8 GroundType = getGroundType(tileType);

	wheel.FrictionForce.x =  pacejka_lat(wheel.ActiveWeight*Gravity, (slipAngle/90), GroundType);
	wheel.FrictionForce.y =  pacejka_long(wheel.ActiveWeight*Gravity, slipRatio, GroundType); 

	Vec2f RRWForces = wheel.FrictionForce; 
	RRWForces.RotateBy(blob.getAngleDegrees());
	if (wheel.FrictionForce.Length() > 1)	
	blob.AddForceAtPosition(RRWForces*0.01, blob.getPosition()+wheel.LocalPosition);	

	// Skidmarks
	wheel.SkidActive = false;
	if (Maths::Abs(slipRatio) > 0.8)// || Maths::Abs(slipAngle) > (45)) 
	{		
		wheel.SkidActive = true;
	}		

	if (wheel.SkidActive)
	{
		switch (GroundType)
		{			
			case 0: //water
			{			
				CParticle@ p = ParticlePixel(karPos+wheel.LocalPosition, Vec2f_zero, SColor(0xff371f0e), true, 30);
				//if (getGameTime() % 12 == 0)
				//blob.getSprite().PlayRandomSound("/Wet", 0.4+(karAbsVel/20), 0.5+(karAbsVel/15));
				break;
			}
			case 1: //rubber/road
			{
				CParticle@ p = ParticlePixel(karPos+wheel.LocalPosition, Vec2f_zero, color_black, true, 30);
				if (getGameTime() % 5 == 0)
				makeSmokeParticle(karPos+wheel.LocalPosition);
				float ff = Maths::Abs(wheel.FrictionForce.x/7000);
				if (getGameTime() % 2 == 0)
				Sound::Play("CarSkidding2.ogg", karPos+wheel.LocalPosition, 0.15+(karAbsVel/250), 0.55+(karAbsVel/180));
				break;
			}
			case 2: //grass
			{			
				CParticle@ p = ParticlePixel(karPos+wheel.LocalPosition, Vec2f_zero, SColor(0xff371f0e), true, 30);
				CParticle@ p2 = ParticlePixel(karPos+wheel.LocalPosition, Vec2f(0,3).RotateBy(karAngle), SColor(0xff371f0e), true, 10);
				if (p2 !is null)
				{
					p2.damping = 0.88;
				}
				if (getGameTime() % 12 == 0)
				blob.getSprite().PlayRandomSound("/Dirty", 0.15+(karAbsVel/250), 0.5+(karAbsVel/180));
				break;
			}
		}							
	}
}

// simplified version of pacejka (longitudal), pacejka is a formula used on real world cars to calculate traction forces on tires
float pacejka_long(float Fz, float slip, u8 GroundType = 1)
{
	//    Stiffness | Shape | Peak | Curvature
	float 	 b,         c,      d,      e;

	switch (GroundType)
	{
		case 0: { b = 0.0;  c = 1.0; d = 1.0; e = 0.0; break; } //Water
		case 1: { b = 10.0; c = 1.9; d = 1.0; e = 0.97; break; } //Dry tarmac
		case 2: { b = 12.0; c = 2.3; d = 0.8; e = 1.0; break; } //Wet tarmac
		case 3: { b = 5.0;  c = 2.0; d = 0.3; e = 1.0; break; } //Snow
		case 4: { b = 4.0;  c = 2.0; d = 0.1; e = 1.0; break; } //Ice
	}	
	return (Fz * d) * Maths::Sin(c * Maths::ATan(b * slip - e * (b*slip - Maths::ATan(b*slip))));
}
// simplified version of pacejka (lateral)
float pacejka_lat(float Fz, float slip, u8 GroundType = 1)
{
	//    Stiffness | Shape | Peak | Curvature
	float 	 b,         c,      d,      e;

	switch (GroundType)
	{
		case 0: { b = 0.0; c = 1.0; d = 1.0; e = 0.0; break; } //Water		
		case 1: { b = 20.0; c = 1.1; d = 1.3; e = 0.1; break; } //Dry tarmac
		case 2: { b = 12;  c = 2.3; d = 0.8; e = 1.0; break; } //Wet tarmac		
		case 3: { b = 5.0; c = 2.0; d = 0.3; e = 1.0; break; } //Snow			
		case 4: { b = 4.0; c = 2.0; d = 0.1; e = 1.0; break; } //Ice		
	}	

	return (Fz * d) * Maths::Sin(c * Maths::ATan(b * slip - e * (b*slip - Maths::ATan(b*slip))));
}