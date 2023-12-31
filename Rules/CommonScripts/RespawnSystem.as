
//the respawn system interface, provides some sane default functions
//  but doesn't spawn players on its own (so you can plug your own implementation)

// designed to work in tandem with a rulescore
//  to get playerinfos and whatnot from usernames reliably and to hold team info
//  can be designed to work without one of course.

#include "PlayerInfo"
#include "KarCommon.as";

shared class RespawnSystem
{

	private RulesCore@ core;

	RespawnSystem() { @core = null; }

	void Update() { /* OVERRIDE ME */ }

	void AddPlayerToSpawn(CPlayer@ player)  { /* OVERRIDE ME */ }

	void RemovePlayerFromSpawn(CPlayer@ player) { /* OVERRIDE ME */ }

	void SetCore(RulesCore@ _core) { @core = _core; }

	//the actual spawn functions
	CBlob@ SpawnPlayerIntoWorld(Vec2f at, PlayerInfo@ p_info)
	{
		CPlayer@ player = getPlayerByUsername(p_info.username);

		if (player !is null)
		{
			CBlob @newBlob = server_CreateBlob(p_info.blob_name, p_info.team, at);
			newBlob.server_SetPlayer(player);
			player.server_setTeamNum(p_info.team);
			return newBlob;
		}

		return null;
	}

	//the actual spawn functions
	CBlob@ SpawnKarIntoWorld(Vec2f at, PlayerInfo@ p_info)
	{
		CPlayer@ player = getPlayerByUsername(p_info.username);

		if (player !is null)
		{			
			CBlob @newBlob = server_CreateBlob(p_info.blob_name, p_info.team, at);
			newBlob.server_SetPlayer(player);
			player.server_setTeamNum(p_info.team);
			
			if (!getRules().isMatchRunning()) //one time setup
			{
				player.set_bool("Finished", false);
				KarInfo kar;
				player.set("karInfo", kar);
			}

			KarInfo@ kar;
			if (player.get("karInfo", @kar))
			{
				newBlob.server_setTeamNum(kar.Colour);
				if (newBlob.getSprite() !is null)
				{
					CSpriteLayer@ decal = newBlob.getSprite().getSpriteLayer("decal");
					if (decal !is null)
					{
						decal.ReloadSprite("Kar.png", 16, 24, kar.DecalColour, -1);	
						decal.SetFrameIndex(kar.Decal);
						//decal.setRenderStyle(RenderStyle::additive);
						//decal.SetColor( SColor(255,255,255,0) );
						decal.SetOffset(Vec2f(-0.25f, 0.0f));
						decal.SetRelativeZ(10.0f);
						decal.SetVisible(true);
					}
				}	
			}

			return newBlob;
		}

		return null;
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		/* OVERRIDE ME */
		return true;
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		/* OVERRIDE ME */
		return Vec2f();
	}

	/*
	 * Override so rulescore can re-add when appropriate
	 */
	bool isSpawning(CPlayer@ player)
	{
		return false;
	}


};
