#include "RulesCore.as"
#include "KartsCommon.as"
#include "KarCommon.as"

string endGameText = "You Finished";
bool myPlayerGotToTheEnd = false;
int finishedCount = 0;
int preEndGameTime = 0;

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
	this.addCommandID("player finish");
	this.addCommandID("race finish");

	AddColorToken("$WHITE$", SColor(255, 255, 255, 255));
	AddColorToken("$DARKGREY$", SColor(255, 135, 135, 135));
	AddColorToken("$LITGREEN$", SColor(255, 150, 255, 150));
	AddColorToken("$GOLD$", SColor(255, 234, 177, 39));
	AddColorToken("$SILVER$", SColor(255, 219, 232, 240));
	AddColorToken("$BRONZE$", SColor(255, 203, 113, 74));
}

void Reset(CRules@ this)
{
	this.set_s32("restart_rules_after_game_time", 30 * 16.0f);
	thisRaceTimes.clear();
	newTimeSpots.clear();
	finishedCount = 0;
	preEndGameTime = 0;
}

void onInit(CMap@ this)
{
	CRules@ rules = getRules();
	SetIntroduction(rules, "Race");

	this.set_u8("waypoint count", 0);
	
	if (getNet().isServer())
	{		
		// make stats file
		Stats_MakeFile(rules, "Race");
		ConfigFile stats;
		if (!stats.loadFile("../Cache/" + g_statsFile))
		{
			Stats_CreateFile(stats);
			stats.saveFile(g_statsFile);
			Stats_setupRecordTimesArray(stats);
		}
		else
		{
			Stats_setupRecordTimesArray(stats);
		}
	}
	AddRulesScript(rules);
}

void Reset(CMap@ this)
{
	this.set_u8("waypoint count", 0);
}

f32[] PlayerRaceDists;

void onTick(CRules@ this)
{	
	CMap@ map = getMap();
	RulesCore@ core;
	this.get("core", @core);
	if (core is null) return;

 	// setup waypoints
	if (map.get_u8("waypoint count") == 0)
	{
		u8 count = 0;
		for (uint i = 0; i < 155; ++i)
		{
			Vec2f[] waypoints;
			if (map.getMarkers("waypoint_"+i, waypoints ))
			{	 count++;	 }
			else break;	
		}
		map.set_u8("waypoint count", count);
	}

	// handling player placement in the race
	PlayerRaceDists.clear();
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p !is null && p.getTeamNum() == 0)
		{
			KarInfo@ kar;
			if (!p.get("karInfo", @kar)) return;
			f32 dist = kar.DistanceToEnd;
			//print(""+dist+" " +p.getUsername());
			PlayerRaceDists.push_back(dist);			
		}
	}
	PlayerRaceDists.sortAsc();

	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p !is null && p.getTeamNum() == 0)
		{
			KarInfo@ kar;
			if (!p.get("karInfo", @kar)) return;
			f32 dist = kar.DistanceToEnd;
			kar.Placement = 1+PlayerRaceDists.find(dist);
		}
	}

	
	if (getNet().isServer())
	{
		//printf("finishedCount " + thisRaceTimes.size() );
		if (thisRaceTimes.size() == core.teams[0].players_count && (!this.isIntermission() && !this.isWarmup())) // all players
		{	
			preEndGameTime++;				
		}	

		if (preEndGameTime == 60)
		{
			
			CBitStream params;
			getRules().SendCommand(getRules().getCommandID("race finish"), params);

			this.SetTeamWon(0);
			this.SetCurrentState(GAME_OVER);
			sv_mapautocycle = true;
		}

		if (this.isGameOver())
		{
			// sync stats to players
			if (!syncedStats)
			{
				ConfigFile stats;
				string MatchOutput;
				string RecordsOutput;
				if (stats.loadFile("../Cache/" + g_statsFile))
				{
					MatchOutput += Stats_Output_RoundTimes(stats);
					RecordsOutput += Stats_Output_RecordsTimes(stats);
					Stats_Send(this, MatchOutput, RecordsOutput);
				}
				syncedStats = true;
			}

			return;
		}
	}
}

void onRender(CRules@ this)
{	
	if (this.isGameOver())
	{
		Stats_Draw(this);
	}
}
