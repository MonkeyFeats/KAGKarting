#include "Karts_Structs.as";

// unused
namespace WeaponType
{
	enum type
	{
		none = 0,
		greenshell,
		redshell,
		banana,
		mushroom
	};
}

namespace GearStates
{
	enum Num
	{
		Reverse = -1,
		Neuteral,
		Forwards
	};
}

// blob stuff
shared class KarInfo
{
	Vec2f[][] waypoints;
	u8 WaypointsPast;
	u8 CurrentLap;
	u8 WaypointLap;	
	u8 TargetWaypointNum;
	u8 NextWaypointNum;
	u8 LastWaypointNum;
	Vec2f TargetWayPosition;
	Vec2f NextWayPosition;
	Vec2f LastWayPosition;
	int Placement;
	u8 Colour;
	u8 Decal;
	u8 DecalColour;

	u32 DriftScore;
	u32 CurrentDrift;
	u16 DriftCombo;
	int ComboTimer;

	f32 DistanceToEnd;

	bool Has_Weapon;
	u8 Weapon_Type;

	KarInfo()
	{

		u32 DriftScore= 0;
		u32 CurrentDrift= 0;
		u16 DriftCombo= 0;
		int ComboTimer= -1;

		CBitStream stream;
		getRules().get_CBitStream("trackdata", stream);

		u16 checkbits;
		if (stream.getBitsUsed() > 0 && stream.saferead_u16(checkbits) && checkbits == 0x5ade)
		{
			waypoints.clear();
			TrackData data(stream);	
			for (u8 i = 0; i < data.WaypointMarkers.length; i++)
			{
				Vec2f[] temp;
				for (u8 j = 0; j < data.WaypointMarkers[i].length; j++)
				{
					Vec2f v = data.WaypointMarkers[i][j];
					temp.push_back(v);	
				}
				waypoints.push_back(temp);
			}
		}

		CurrentLap = 1;
		WaypointsPast = 0;
		NextWaypointNum = 1;
		TargetWaypointNum = 0;	
		LastWaypointNum = waypoints.length()-1;
		TargetWayPosition = Vec2f_zero;
		NextWayPosition = Vec2f_zero;
		LastWayPosition = Vec2f_zero;		
		Placement = 1;
		DistanceToEnd = 0;
		Has_Weapon = false;		
		Weapon_Type = 0;//WeaponType::none;	

		Colour = XORRandom(8);
		Decal = XORRandom(12);
		DecalColour = XORRandom(8);			
	}
};

const f32 DEGtoRAD = 0.01745329252f;//Maths::Pi / 180.0f;
const f32 RADtoDEG   = 180.0f / Maths::Pi;
const f32 Pi2 = 6.28318530718f;//(Maths::Pi * 2.0f);
const f32 PiSec =  0.10471975512f;//(Pi2 / 60.0f);
const f32 KmphToMph = 0.621371f;
const f32 Gravity = -9.81f;
const f32 WheelRadius = 0.33; // meters
const u8 SpeedFactor = 16; //multiplier from kag velocity to irl velocity (eg. velleng of 1.0f = 12(SpeedFactor)kmph  )
const f32 RevolutionsPerMin = 9.549296585513092f; //60 / Pi2;

// SI Units
// Force N (Newton)	= m.kg/s2
// Power W (Watt) = N.m/s = J/s = m2 kg / s3
// 1 mile = 1.6093 km
// 1 ft (foot)	= 0.3048 m
// 1 in (inch)	= 0.0254 m = 2.54 cm
// 1 km/h = 0.2778 m/s
// 1 mph = 1.609 km/h = .447 m/s
// 1 rpm (revolution per minute) = 0.105 rad/s
// 1 G	= 9.8 m/s2 = 32.1 lb/s2
// 1 lb (pound)	= 4.45 N
// 1 lb (pound)	= 0.4536 kg 1) = 1 lb/1G
// 1 lb.ft (foot pounds) = 1.356 N.m
// 1 lb.ft/s (foot pound per second) = 1.356 W
// 1 hp (horsepower) = 550 ft.lb/s = 745.7 W 

// movement stuff
shared class KarEngine
{
	f32 KMPH = 0;
	f32 EngineRPM = 750;
	int GearState = 0;
	int CurrentGear = 0;
	float Throttle = 0;

	KarAxle@ AxleFront;
	KarAxle@ AxleRear;

	float GearRatio = 0;
	float Mass = 0;
	float BrakePower = 0;
	float EBrakePower = 0;
	float LatWeightTransfer = 0;
	float LongWeightTransfer = 0;
	float MaxSteerAngle = 0;
	float CornerStiffnessFront = 0;
	float CornerStiffnessRear = 0;
	float AirResistance = 0;
	float RollingResistance = 0;
	float SteerPower = 0;
	float SteerAngle = 0;
	float AngularFricFeedbackScale = 0;
	//float SpeedTurningStability = 0;
	float WheelBase = 0;
	float TrackWidth = 0;	
	float HeadingAngle = 0; 
	float LocalAcceleration = 0;
	float DriveTorque = 0;
	float AngularVelocity = 0;
	float AngularForce = 0;
	Vec2f LocalVelocity = Vec2f_zero;
	Vec2f Velocity = Vec2f_zero;
	Vec2f VelocityForce = Vec2f_zero;
	Vec2f CenterOfGravity = Vec2f_zero;	

	int[] TorqueCurve;
	f32[] GearRatios;
	f32 getGearRatio() { return GearRatios[CurrentGear]*EffectiveGearRatio; } 
	f32 EffectiveGearRatio = 4.2;
	f32 getGearRatio(int Gear) { return GearRatios[Gear]*EffectiveGearRatio; } 
	f32 ClutchTimer = 0;

	f32 GetTorque()
	{	
		f32 T;
		int RpmRange = Maths::Floor(EngineRPM/1000);	
		switch(RpmRange)
		{
			case 0: { T = Maths::Lerp(TorqueCurve[0], TorqueCurve[1],  EngineRPM / 1000); break;}
			case 1: { T = Maths::Lerp(TorqueCurve[1], TorqueCurve[2], (EngineRPM - 1000) / 1000); break;}
			case 2: { T = Maths::Lerp(TorqueCurve[2], TorqueCurve[3], (EngineRPM - 2000) / 1000); break;}
			case 3: { T = Maths::Lerp(TorqueCurve[3], TorqueCurve[4], (EngineRPM - 3000) / 1000); break;}
			case 4: { T = Maths::Lerp(TorqueCurve[4], TorqueCurve[5], (EngineRPM - 4000) / 1000); break;}
			case 5: { T = Maths::Lerp(TorqueCurve[5], TorqueCurve[6], (EngineRPM - 5000) / 1000); break;}
			case 6: { T = Maths::Lerp(TorqueCurve[6], TorqueCurve[7], (EngineRPM - 6000) / 1000); break;}
			case 7: { T = Maths::Lerp(TorqueCurve[7], TorqueCurve[8], (EngineRPM - 7000) / 1000); break;}
			case 8: { T = Maths::Lerp(TorqueCurve[8], TorqueCurve[9], (EngineRPM - 8000) / 1000); break;}
			case 9: { T = Maths::Lerp(TorqueCurve[9], TorqueCurve[10],(EngineRPM - 9000) / 1000); break;}
			default: warn("rpm out of range in GetTorque() function");
		}
		return T;
	}
};

shared class KarAxle
{
	KarWheel@ LeftWheel;
	KarWheel@ RightWheel;

	Vec2f Origin = Vec2f_zero;
	Vec2f LocalPosition = Vec2f_zero;
	Vec2f FrictionForce = Vec2f_zero;
	float SlipAngle = 0;
	float RollingVel = 0; //wheels angular velocity around the axel

	KarAxle(){}
	KarAxle(float _Wheeloffpos, float _Axleoffpos, float _angle)
	{
		Origin = Vec2f(0,_Axleoffpos);
		LocalPosition = Origin;
		LocalPosition.RotateBy(_angle);
		//RollingCircumference = (WheelRadius*2)*Maths::Pi;	
		@LeftWheel = KarWheel(Vec2f(-_Wheeloffpos,_Axleoffpos), _angle);		
		@RightWheel = KarWheel(Vec2f(_Wheeloffpos,_Axleoffpos), _angle);
	}
};

shared class KarWheel
{
	Vec2f Origin;
	Vec2f LocalPosition;
	Vec2f FrictionForce;
	float HeadingAngle;
	float ActiveWeight;
	float Grip;
	bool SkidActive;	

	KarWheel(){}
	KarWheel(Vec2f _offpos, float _angle)
	{
		Origin = _offpos;
		LocalPosition = _offpos;
		LocalPosition.RotateBy(_angle);
		HeadingAngle = _angle;	
		SkidActive = false;
	}
};

shared void makeSmokeParticle(Vec2f pos)
{
	string texture;
	switch (XORRandom(2))
	{
		case 0: texture = "Entities/Effects/Sprites/SmallSmoke1.png"; break;
		case 1: texture = "Entities/Effects/Sprites/SmallSmoke2.png"; break;
	}
	ParticleAnimated(texture, pos, Vec2f(0, 0), 0.0f, 1.0f, 2, 0.0f, true);
}

shared u8 getGroundType(uint16 &in type)
{
	switch(type)
	{
		case 0: // water
		{
			return 0;
		}	

		//case 544: // rumbler
		//case 545:
		//case 536:
		//case 547:
		//case 496 :
		//case 497 :
		//case 498 :
		//case 499 :
		//case 500 :
		//case 501 :
		//case 502 :
		//case 503 :
		//case 504 :
		//case 505 :
		//case 506 :
		//case 507 :
		//case 508 :
		//case 510 :
		//case 511 :
		//{		
		//	GroundType = 1;	
		//	break;
		//}

		case 388: // grass
		case 389:
		case 390:
		case 391:
		case 392: // sand
		case 393:
		case 394:
		case 395:
		case 396: // dirt
		case 397:
		case 398:
		case 399:
		{
			return 2;
		}
		default : 
		{
			return 1;
		}					
	}
	return 1;
}