#define SERVER_ONLY;
#include "Karts_Structs.as";

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	CBitStream stream;
	stream.write_u16(0xDEAD);
	this.set_CBitStream("trackdata", stream);

	TrackData data;
	this.set("trackdata", @data);
}

void onTick(CRules@ this)
{
	//This aint right

	TrackData@ data;
	this.get("trackdata", @data);

	CMap@ map = getMap();	
	if (map !is null)
	{
		const u8 waypointcount = map.get_u8("waypoint count");
		if (waypointcount > 0 && getNet().isServer())
		{
			CBitStream stream;
			stream.write_u16(0x5ade);
			data.Serialise(stream);				
			this.set_CBitStream("trackdata", stream);
			this.Sync("trackdata", true);

			if (data.WaypointMarkers.size() == 0) // (getGameTime() < 1)
			{	
				data.WaypointMarkers.set_length(waypointcount);	
				Vec2f[] waypointpositions;
				for(int i = 0; i < waypointcount; i++)
        		{
        			waypointpositions.clear();

					if ( map.getMarkers("waypoint_"+i,  waypointpositions ))
					{
						for(int j = 0; j < waypointpositions.size(); j++)
	        			{
	        				data.WaypointMarkers[i].push_back(waypointpositions[j]);
	        			}
					}
				}				
			}
		}
	}
}
