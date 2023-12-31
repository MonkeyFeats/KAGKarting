// set camera on local player
// this just sets the target, specific camera vars are usually set in StandardControls.as

#define CLIENT_ONLY
#include "Spectator.as"

int deathTime = 0;
Vec2f deathLock;
bool spectatorTeam;
bool wantsCamPos = true;

void onInit(CRules@ this) { Reset(this); }
void onRestart(CRules@ this) { Reset(this); }

void Reset(CRules@ this)
{
	SetTargetPlayer(null);
	CCamera@ camera = getCamera();

	wantsCamPos = true;
}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	CCamera@ camera = getCamera();
	if (camera !is null && player !is null && player is getLocalPlayer())
	{
		camera.setPosition(blob.getPosition());
		camera.setTarget(blob);
		camera.mousecamstyle = 1; // follow
		//camera.targetDistance = 1.5f; // zoom factor
		camera.posLag = 0.5f;
	}
}

//change to spectator cam on team change
void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam)
{
	CCamera@ camera = getCamera();
	CBlob@ playerBlob = player is null ? player.getBlob() : null;

	if (camera !is null && newteam == this.getSpectatorTeamNum() && getLocalPlayer() is player)
	{
		spectatorTeam = true;
		camera.setTarget(null);
		if (playerBlob !is null)
		{
			playerBlob.ClearButtons();
			playerBlob.ClearMenus();

			camera.setPosition(playerBlob.getPosition());
			deathTime = getGameTime();
		}
	}
	else if (getLocalPlayer() is player)
		spectatorTeam = false;

}
		
//Change to spectator cam on death
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	CCamera@ camera = getCamera();
	CBlob@ victimBlob = victim !is null ? victim.getBlob() : null;
	CBlob@ attackerBlob = attacker !is null ? attacker.getBlob() : null;

	//Player died to someone
	if (camera !is null && victim is getLocalPlayer())
	{
		//Player killed themselves
		if (victim is attacker || attacker is null)
		{
			camera.setTarget(null);
			if (victimBlob !is null)
			{
				victimBlob.ClearButtons();
				victimBlob.ClearMenus();

				camera.posLag = 10.0f; // stop jerky jerkyness
				camera.setPosition(victimBlob.getPosition());				
				deathLock = victimBlob.getPosition();
				SetTargetPlayer(null);

			}
			deathTime = getGameTime() + 2 * getTicksASecond();

		}
		else
		{
			if (victimBlob !is null)
			{
				victimBlob.ClearButtons();
				victimBlob.ClearMenus();

			}

			if (attackerBlob !is null)
			{
				SetTargetPlayer(attackerBlob.getPlayer());
				deathLock = victimBlob.getPosition();
			}
			else
			{
				camera.setTarget(null);

			}
			deathTime = getGameTime() + 2 * getTicksASecond();

		}
	}
}

// death effect
void onTick(CRules@ this)
{
	CCamera@ camera = getCamera();
	if (camera is null || getLocalPlayerBlob() !is null || getLocalPlayer() is null)
		return;	

	if (wantsCamPos)
	{
		CBlob@[] slots;
		if ( getBlobsByName("slot", @slots))
		{
			CBlob@ rndslot = slots[XORRandom(slots.length())];
			if (rndslot !is null)
			{
				if ((camera.getPosition() - rndslot.getPosition()).Length() > 48)
				camera.setPosition(rndslot.getPosition());
				else
				wantsCamPos = false;					
			}
		}
	}
}

void onRender(CRules@ this)
{
	//death effect
	CCamera@ camera = getCamera();
	if (camera !is null && getLocalPlayerBlob() is null && getLocalPlayer() !is null)
	{
		const int diffTime = deathTime - getGameTime();
		// death effect
		if (!spectatorTeam && diffTime > 0)
		{
			//lock camera
			camera.setPosition(deathLock);
			//zoom in for a bit
			//const float zoom_target = 2.0f;
			//const float zoom_speed = 5.0f;
			//camera.targetDistance = Maths::Min(zoom_target, camera.targetDistance + zoom_speed * getRenderDeltaTime());
		}
		else
		{
			Spectator(this);
		}
	}

	if (targetPlayer() !is null && getLocalPlayerBlob() is null)
	{
		GUI::SetFont("menu");
		GUI::DrawText("Following " + targetPlayer().getCharacterName() +
		              " (" + targetPlayer().getUsername() + ")",
		              Vec2f(getScreenWidth() / 2 - 90, getScreenHeight() * (0.02f)),
		              Vec2f(getScreenWidth() / 2 + 90, getScreenHeight() * (0.02f) + 30),
		              SColor(0xffffffff), true, true);
	}

	
}
