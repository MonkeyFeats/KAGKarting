//Rules timer!
// Requires "game ticks left" set originally
void onRender(CRules@ this)
{
	if (!this.isMatchRunning()) return;

	GUI::SetFont("hud");
	const u32 gameTicksLeft = this.get_u32("game ticks left");
	const u32 gameTicksDuration = this.get_u32("game ticks duration");
	const u32 gameTicks = gameTicksDuration - gameTicksLeft;
	
	u32 Time = gameTicksLeft / 30;
	u32 Seconds = Time % 60;
	u32 MilliSeconds = gameTicksLeft / 0.5 % 60;
	u32 Minutes = Time / 60;
	drawRulesFont("Time Left: " + 
				((Minutes < 10) ? "0" + Minutes : "" + Minutes) + ":" +
				((Seconds < 10) ? "0" + Seconds : "" + Seconds) + ":" + 
				((MilliSeconds < 10) ? "0" + MilliSeconds : "" + MilliSeconds),
	            SColor(255, 255, 255, 255), Vec2f(24, 8), Vec2f(20, 20), false, false);
	
}
