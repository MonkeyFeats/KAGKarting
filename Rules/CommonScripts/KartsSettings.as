
#include "RulesCore.as";
#include "Default/DefaultGUI.as"
#include "Default/DefaultLoaders.as"
#include "PrecacheTextures.as"
#include "EmotesCommon.as"
#include "GameplayEvents.as"

//not server only so that all the players get this
void onInit(CRules@ this)
{
	SetupGameplayEvents(this);
	LoadDefaultMapLoaders();
	LoadDefaultGUI();
	
	sv_gravity = 0.0f;
	particles_gravity.y = 0.0f;

	sv_visiblity_scale = 2.0f;
	cc_halign = 2;
	cc_valign = 2;

	s_effects = false;

	sv_max_localplayers = 1;

	PrecacheTextures();

	//also restart stuff
	onRestart(this);

	Driver@ driver = getDriver();
	if (driver is null) return;

	driver.AddShader("hq2x", 1.0f);
	driver.SetShader("hq2x", true);

	//driver.AddShader("tdwater", 2.0f);
	//driver.SetShader("tdwater", true);
	//driver.SetShaderExtraTexture("tdwater", CFileMatcher("/tdwater.png").getFirst());
	//driver.SetShaderFloat("tdwater", "screenWidth", driver.getScreenWidth());
	//driver.SetShaderFloat("tdwater", "screenHeight", driver.getScreenHeight());
	//driver.ForceStartShaders();	
}

void onRestart(CRules@ this)
{
	SetChatVisible(true);
	//map borders
	CMap@ map = getMap();
	if (map !is null)
	{
		map.SetBorderFadeWidth(8.0f);
		map.SetBorderColourTop(SColor(0xff000000));
		map.SetBorderColourLeft(SColor(0xff000000));
		map.SetBorderColourRight(SColor(0xff000000));
		map.SetBorderColourBottom(SColor(0xff000000));
	}
}

//void onRender(CRules@ this)
//{
//	if (getGameTime() == 0) return;
//	Driver@ driver = getDriver();	
//	if (driver is null) return;
//
//
//
//	const float scalex = getDriver().getResolutionScaleFactor();
//	const float zoom = getCamera().targetDistance * scalex;
//
//	driver.SetShaderFloat("tdwater", "zoomscale", zoom);
//	driver.SetShaderFloat("tdwater", "screenPosX", Maths::Abs(-(getCamera().getPosition().x)/getScreenWidth()));
//	driver.SetShaderFloat("tdwater", "screenPosY", 1.0 + (-(getCamera().getPosition().y)/getScreenHeight()));
//	driver.SetShaderFloat("tdwater", "time", getGameTime());
//}

//chat stuff!

//void onEnterChat(CRules @this)
//{
//	if (getChatChannel() != 0) return; //no dots for team chat
//
//	CBlob@ localblob = getLocalPlayerBlob();
//	if (localblob !is null)
//		set_emote(localblob, Emotes::dots, 100000);
//}
//
//void onExitChat(CRules @this)
//{
//	CBlob@ localblob = getLocalPlayerBlob();
//	if (localblob !is null)
//		set_emote(localblob, Emotes::off);
//}


void onTick(CRules@ this)
{

	//Driver@ driver = getDriver();	
	//if (driver is null) return;

	//if (getGameTime() == 10)
	//driver.ForceStartShaders();

	if (!getNet().isServer())
		return;

	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.Update();
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (!getNet().isServer())
		return;

	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.onPlayerDie(victim, killer, customData);
	}
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	if (!getNet().isServer())
		return;

	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.AddPlayerSpawn(player);
	}
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	if (!getNet().isServer())
		return;

	if (!this.get_bool("managed teams"))
	{
		RulesCore@ core;
		this.get("core", @core);

		if (core !is null)
		{
			core.AddPlayerSpawn(player);
		}
	}
}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!getNet().isServer())
		return;

	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.onSetPlayer(blob, player);
	}
}
