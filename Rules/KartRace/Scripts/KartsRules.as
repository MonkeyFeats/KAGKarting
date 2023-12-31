
//karts gamemode logic script

#define SERVER_ONLY

#include "Karts_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";

string getMapName()
{
	return getFilenameWithoutExtension(getFilenameWithoutPath(getMapInParenthesis()));
}

void Config(KartCore@ this)
{
	CRules@ rules = getRules();
	string gameconfigstr;
	string mapconfigstr;

	if (rules.exists("rulesconfig"))
	{
		gameconfigstr = "../Mods/KAGKarting/Rules/KartRace/kartrace_vars.cfg";
		mapconfigstr = rules.get_string("rulesconfig");
	}

	ConfigFile vars_cfg = ConfigFile(gameconfigstr);
	ConfigFile map_cfg = ConfigFile(mapconfigstr);
	
	this.spawnTime = (getTicksASecond() * vars_cfg.read_s32("spawn_time", 3));

	s32 warmUpTimeSeconds = vars_cfg.read_s32("warmup_time", 10);
	this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);

	this.introduction = map_cfg.read_string("introduction", "");
	rules.set_string("introduction", this.introduction);
	rules.Sync("introduction", true);
	rules.set_u8("TotalLaps", map_cfg.read_u8("laps", 3));
	rules.Sync("TotalLaps", true);
	
	s32 gameDurationSecs = map_cfg.read_s32("game_time", -1);
	if (gameDurationSecs <= 0) { this.gameTicksLeft = 0; rules.set_bool("no timer", true); }
	else { this.gameTicksLeft = (getTicksASecond() * gameDurationSecs); }

	rules.set_u32("game ticks left", this.gameTicksLeft);
	rules.set_u32("game ticks duration", this.gameTicksLeft);
	rules.Sync("game ticks left", true);
	rules.Sync("game ticks duration", true);
}

shared class KartSpawns : RespawnSystem
{
	KartCore@ Karts_core;
	bool force;

	int gamestart;
	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Karts_core = cast < KartCore@ > (core);
	}

	void Update()
	{
		for (uint team_num = 0; team_num < Karts_core.teams.length; ++team_num)
		{
			KartsTeamInfo@ team = cast < KartsTeamInfo@ > (Karts_core.teams[team_num]);

			for (uint i = 0; i < team.spawns.length; i++)
			{
				KartsPlayerInfo@ info = cast < KartsPlayerInfo@ > (team.spawns[i]);

				UpdateSpawnTime(info, i);
				DoSpawnPlayer(info);
			}
		}
	}

	void UpdateSpawnTime(KartsPlayerInfo@ info, int i)
	{
		if (info !is null)
		{
			u8 spawn_property = 255;

			if (info.can_spawn_time > 0)
			{
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250, (info.can_spawn_time / 30)));
			}

			string propname = "karts spawn time " + info.username;

			Karts_core.rules.set_u8(propname, spawn_property);
			Karts_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
		}
	}

	void DoSpawnPlayer(PlayerInfo@ p_info)
	{		
		if (canSpawnPlayer(p_info))
		{
			CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?			

			if (player is null)
			{
				RemovePlayerFromSpawn(p_info);
				return;
			}
			if (player.get_bool("Finished"))
			{
				RemovePlayerFromSpawn(p_info);
				return;
			}
			if (player.getTeamNum() != int(p_info.team))
			{
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer(null);
				blob.server_Die();
			}

			const u8 waypointcount = getMap().get_u8("waypoint count");	
			const u8 TLaps = getRules().get_u8("TotalLaps");
			u8 targetnum = player.get_u8("target waypoint num");
			u8 nextnum = player.get_u8("next waypoint num");

			CBlob@ pickedSlot;
			f32 SpawnAngle;
			Vec2f spawnlocation = getSpawnLocation(p_info, targetnum, nextnum, SpawnAngle, pickedSlot);

			CBlob@ playerBlob = SpawnKarIntoWorld(spawnlocation, p_info);	
			if (playerBlob !is null)
			{	
				if (pickedSlot !is null)
				{
					if (pickedSlot !is null)
					pickedSlot.server_Die();
				}

				playerBlob.setAngleDegrees(SpawnAngle);
				// spawn resources
				p_info.spawnsCount++;				
				RemovePlayerFromSpawn(player);

				if (targetnum == waypointcount) // died before finish line > spawning past it > so give +1 lap
				{
					u8 CurrentLap = playerBlob.get_u8("CurrentLap"); 
					playerBlob.set_u8("CurrentLap", CurrentLap+1);
				}
			}
		}
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		KartsPlayerInfo@ info = cast < KartsPlayerInfo@ > (p_info);	

		if (info is null) { warn("Karts LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		if (force) { return true; }

		return info.can_spawn_time <= 0;
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info, u8 targetwaypoint, u8 nextwaypoint, f32 &out Angle, CBlob@ &out slot)
	{		
		@slot = null;
		KartsPlayerInfo@ k_info = cast < KartsPlayerInfo@ > (p_info);
		if (k_info !is null)
		{
			if (!getRules().isIntermission() && !getRules().isWarmup())
			{
				Vec2f SpawnSpot;
				Vec2f[] spawns;
				CMap@ map = getMap();
				if ( map.getMarkers("waypoint_"+targetwaypoint,  spawns ))
				{					
					Vec2f[] potentials;
					for (uint i = 0; i < spawns.size(); i++)
					{
						Vec2f tilepos = spawns[i];
						Tile t = map.getTile(tilepos);
						if ( (t.type >= 384 && t.type < 388) || (t.type == 560 ) )
						potentials.push_back(tilepos);
					}
					
					SpawnSpot = potentials[ XORRandom(potentials.size()) ];

					Vec2f[] nextpoints;
					if ( map.getMarkers("waypoint_"+(nextwaypoint),  nextpoints ))
					{
						f32 Closest_nextdist = 999999;
						uint Closest_nextpoint = 0;

						for (uint i = 0; i < nextpoints.size(); i++)
						{
							Vec2f tilepos = nextpoints[i];
							Tile t = map.getTile(tilepos);
							if ( (t.type >= 384 && t.type < 388) || (t.type == 560 ) )
							{
								f32 leng = (SpawnSpot-tilepos).Length();
								if (leng < Closest_nextdist)
								{
									Closest_nextpoint = i;
									Closest_nextdist = leng;
								}
							}
						}
						Angle = -(SpawnSpot - nextpoints[Closest_nextpoint]).Angle()-90;
					} 				
				}



				return SpawnSpot;
			}
			else
			{
				CBlob@ pickedSlot = getBlobByNetworkID(k_info.spawn_point);
				if (pickedSlot !is null && pickedSlot.hasTag("slotspawn"))
				{
					@slot = pickedSlot;
					Angle = pickedSlot.getAngleDegrees();
					return pickedSlot.getPosition();
				}
				else
				{	
					@slot = null;
					Angle = k_info.deathAngle;
					return k_info.deathPosition;
				}
			}
		}		

		return Vec2f(16, 16);
	}

	void RemovePlayerFromSpawn(CPlayer@ player)
	{
		RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
	}

	void RemovePlayerFromSpawn(PlayerInfo@ p_info)
	{
		KartsPlayerInfo@ info = cast < KartsPlayerInfo@ > (p_info);

		if (info is null) { warn("Karts LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

		string propname = "karts spawn time " + info.username;

		for (uint i = 0; i < Karts_core.teams.length; i++)
		{
			KartsTeamInfo@ team = cast < KartsTeamInfo@ > (Karts_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				team.spawns.erase(pos);
				break;
			}
		}

		Karts_core.rules.set_u8(propname, 255);  //not respawning
		Karts_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));

		//DONT set this zero - we can re-use it if we didn't actually spawn
		//info.can_spawn_time = 0;
	}

	void AddPlayerToSpawn(CPlayer@ player)
	{
		s32 tickspawndelay = s32(Karts_core.spawnTime);

		KartsPlayerInfo@ info = cast < KartsPlayerInfo@ > (core.getInfoFromPlayer(player));

		if (info is null) { warn("Karts LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		//clamp it so old bad values don't get propagated
		s32 old_spawn_time = Maths::Max(0, Maths::Min(info.can_spawn_time, tickspawndelay));

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

		if (player.getTeamNum() < Karts_core.teams.length)
		{
			KartsTeamInfo@ team = cast < KartsTeamInfo@ > (Karts_core.teams[info.team]);

			info.can_spawn_time = ((old_spawn_time > 30) ? old_spawn_time : tickspawndelay);

			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY! " + info.team + " / " + Karts_core.teams.length);
		}
	}

	bool isSpawning(CPlayer@ player)
	{
		KartsPlayerInfo@ info = cast < KartsPlayerInfo@ > (core.getInfoFromPlayer(player));
		for (uint i = 0; i < Karts_core.teams.length; i++)
		{
			KartsTeamInfo@ team = cast < KartsTeamInfo@ > (Karts_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				return true;
			}
		}
		return false;
	}
};

shared class KartCore : RulesCore
{
	s32 warmUpTime;
	s32 spawnTime;
	s32 gameTicksLeft;	
	string introduction;

	int showIntroductionTime;
	int showIntroductionCounter;

	KartSpawns@ karts_spawns;

	KartCore() {}

	KartCore(CRules@ _rules, RespawnSystem@ _respawns)
	{
		spawnTime = 0;
		super(_rules, _respawns);
	}

	int gametime;
	int gamestart;
	void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
	{
		RulesCore::Setup(_rules, _respawns);
		@karts_spawns = cast < KartSpawns@ > (_respawns);
		rules.SetCurrentState(0); // intermission
		server_CreateBlob("Entities/Meta/ChallengeMusic.cfg");

		showIntroductionTime = 10 * 30;
		showIntroductionCounter = 0;
	}

	//CPlayer@ henry;
	void Update()
	{
		const u32 time = getGameTime();		
		if (rules.isGameOver()) { return; }

		s32 ticksToStart = gamestart + warmUpTime - getGameTime();		
		karts_spawns.force = false;	

		if (ticksToStart > 0 && rules.isWarmup())
		{
			int SecToStart = (ticksToStart / 30) + 1;
			if (SecToStart > 4)
			{
				rules.SetGlobalMessage("Slot Selection Ends In: {SEC}");
				rules.AddGlobalMessageReplacement("SEC", ""+SecToStart);	
			}
			//else if (SecToStart == 4)
			//{
			//	if (henry is null)
			//	@henry = AddBot("Henry");
			//}
			else if (SecToStart == 4)
			{
				rules.SetGlobalMessage("Slot Selection Locked");
				rules.AddGlobalMessageReplacement("SEC", ""+SecToStart);

				CBlob@[] slots;
				if (getBlobsByTag("slotspawn", @slots))
				{
					for (int i = 0; i < slots.length(); i++)
					{
						CBlob@ slot = slots[i];
						if (slot !is null)	
						{
							//CPlayer@ player = getPlayerByUsername("Henry");
							//if(player !is null)
							//{
							//	ChangePlayerTeam(player, 0 );
							//}
							slot.server_Die();
						}									
					}
				}
			}
			else
			{
				rules.SetGlobalMessage("Race Starts In: {SEC}");
				rules.AddGlobalMessageReplacement("SEC", ""+SecToStart);				
			}
			karts_spawns.force = true; // any spawns from here on in are forced
		}
		else if (ticksToStart <= 0 && (rules.isWarmup()))
		{				
			rules.SetCurrentState(GAME);			
		}
		else if (rules.isIntermission())
		{			

			rules.SetGlobalMessage("                    Track: "+rules.get_string("introduction")+"\n\nSelect a starting slot to join the game..");
			gamestart = getGameTime();
			karts_spawns.force = true;

			if (allTeamsHavePlayers())
			{
				rules.SetCurrentState(WARMUP);
			}
		}	
		else if (rules.isMatchRunning())
		{
			//if (time % 30 == 0)
			{
				// update timer
				if (gameTicksLeft > 0)
				{
					gameTicksLeft -= 1;
					if (gameTicksLeft <= 0)
					{
						// end game - time limit
						rules.SetTeamWon(1);
						rules.SetCurrentState(GAME_OVER);
						rules.SetGlobalMessage("Times Up!");
						sv_mapautocycle = true;
						gameTicksLeft = 0;
					}
					rules.set_u32("game ticks left", gameTicksLeft);
					rules.Sync("game ticks left", true);
					if (gameTicksLeft == 0)
					{ return; }

				}

				//if (showIntroductionCounter < showIntroductionTime)
				//{
				//	rules.SetGlobalMessage(rules.get_string("introduction"));
				//	showIntroductionCounter++;
				//}
				//else
				{
					rules.SetGlobalMessage("");
				}
			}
		}
		RulesCore::Update(); //update respawns
	}

	bool allTeamsHavePlayers()
	{
		for (uint i = 0; i < teams.length; i++)
		{
			if (teams[i].players_count < 1)
			{
				return false;
			}
		}

		return true;
	}

	void AddTeam(CTeam@ team)
	{
		KartsTeamInfo t(teams.length, team.getName());
		teams.push_back(t);
	}

	void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
	{
		KartsPlayerInfo p(player.getUsername(), 0, "kar");
		players.push_back(p);
		ChangeTeamPlayerCount(p.team, 1);
		player.set_u8("CurrentLap", 1); //no better place?
	}

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (victim !is null)
		{
			CBlob@ blob = victim.getBlob();
			if (blob !is null)
			{
				KartsPlayerInfo@ info = cast < KartsPlayerInfo@ > (getInfoFromPlayer(victim));
				if (info is null) { return; }
				info.deathAngle = blob.getAngleDegrees();
				info.deathPosition = blob.getPosition();
			}
		}
	}

	bool getPlayerBlobs(CBlob@[]@ playerBlobs)
	{
		for (uint step = 0; step < players.length; ++step)
		{
			CPlayer@ p = getPlayerByUsername(players[step].username);
			if (p is null) continue;

			CBlob@ blob = p.getBlob();
			if (blob !is null)
			{
				playerBlobs.push_back(blob);
			}
		}
		return playerBlobs.size() > 0;
	}
};

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	KartSpawns spawns();
	KartCore core(this, spawns); //delayed setup
	Config(core);
	this.set("core", @core);
	this.SetGlobalMessage("");
}