
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{	
	this.getSprite().SetFrameIndex(1);
	this.AddForce(blob.getVelocity()*(3+XORRandom(8)) + Vec2f(XORRandom(3),XORRandom(3)));
	this.setAngularVelocity((-10.0f + XORRandom(200)*0.1f ));
	blob.AddForce(-blob.getVelocity()*20);
	this.getSprite().PlaySound("/TrafficConeHit.ogg", 0.2+blob.getVelocity().Length()/5, 0.5+blob.getVelocity().Length()/5);
}