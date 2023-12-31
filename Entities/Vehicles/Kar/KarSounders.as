#include "KarCommon.as";
void onTick(CSprite@ this)
{	
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	KarBody@ engine;
	if (!blob.get("moveVars", @engine))
	{ return; }	
	
	this.SetEmitSound("engine2.ogg");
	this.SetEmitSoundPaused(false);
	this.SetEmitSoundVolume(0.15f);
	this.SetEmitSoundSpeed(0.3f + (engine.EngineRPM/7000));	
	//this.getVars().sound_emit_pitch = 0.5f + (engine.EngineRPM/6000);	
}