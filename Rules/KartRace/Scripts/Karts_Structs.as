
#include "Rules/CommonScripts/BaseTeamInfo.as";
#include "Rules/CommonScripts/PlayerInfo.as";

shared class KartsPlayerInfo : PlayerInfo
{	
	u32 can_spawn_time;
	u16 spawn_point;
	bool suicide;
	f32 deathAngle;
	Vec2f deathPosition;
	bool finished;

	KartsPlayerInfo() { Setup("", 0, ""); }
	KartsPlayerInfo(string _name, u8 _team, string _default_config) { Setup(_name, _team, _default_config); }

	void Setup(string _name, u8 _team, string _default_config)
	{
		PlayerInfo::Setup(_name, _team, _default_config);		
		can_spawn_time = 0;
		spawn_point = 0;
		suicide = false;
		finished = false;
	}

	bool opEquals(const KartsPlayerInfo &in other) const
	{
		return this is other;
	}
};

shared class KartsTeamInfo : BaseTeamInfo
{
	u32 endgame_start;
	PlayerInfo@[] spawns;

	KartsTeamInfo() { super(); }

	KartsTeamInfo(u8 _index, string _name)
	{
		super(_index, _name);
	}
	void Reset()
	{
		BaseTeamInfo::Reset();
		//respawns.clear();
		endgame_start = 0;
	}
};

shared class TrackData
{    
    Vec2f[][] WaypointMarkers;

    TrackData(){}
    TrackData(CBitStream@ bt) { Unserialise(bt); }

	void Serialise(CBitStream@ bt)
	{	
		u8 wcount = WaypointMarkers.length;		
		bt.write_u8(wcount);
		for(u8 i = 0; i < wcount; i++)
        {
			u8 wlength = WaypointMarkers[i].length;		
			bt.write_u8(wlength);
			for(u8 j = 0; j < wlength; j++)
	        {
	            bt.write_Vec2f(WaypointMarkers[i][j]);
	        }        
	    }
	}
	void Unserialise(CBitStream@ bt)
	{	
		WaypointMarkers.clear();
		u8 wcount = 0;
		if(!bt.saferead_u8(wcount)) return;
		for(u8 i = 0; i < wcount; i++) 
		{							
			u8 wlength = 0;			
			if(!bt.saferead_u8(wlength)) return;
			Vec2f[] temp;
			for(u8 j = 0; j < wlength; j++) 
			{
				Vec2f p;
			 	if(!bt.saferead_Vec2f(p)) return;
			 	temp.push_back(p);
			}	
			WaypointMarkers.push_back(temp);
		}	
	}    
};