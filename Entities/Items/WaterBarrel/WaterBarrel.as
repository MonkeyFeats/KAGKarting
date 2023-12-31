#include "Splash.as";

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	Splash(this, 2, 2, 0);
}