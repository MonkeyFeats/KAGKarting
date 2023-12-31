#include "Karts_Structs.as";

void onInit(CRules@ rules)
{
	if (!GUI::isFontLoaded("segoesc"))
	{		
		string segoesc = CFileMatcher("segoesc.ttf").getFirst();
		GUI::LoadFont("segoesc", segoesc, 22, true);
	}
}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

	string propname = "karts spawn time " + p.getUsername();
	if (p.getBlob() is null && this.exists(propname))
	{
		u8 spawn = this.get_u8(propname);

		if (spawn != 255)
		{
			string spawn_message = getTranslatedString("Respawning in: {SEC}").replace("{SEC}", ((spawn > 250) ? getTranslatedString("approximatively never") : ("" + spawn)));

			GUI::SetFont("hud");
			GUI::DrawText(spawn_message , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
		}
	}
}
