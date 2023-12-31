
void onInit(CRules@ this)
{
	this.addCommandID("pick spawn");
}

void onTick(CRules@ this)
{
	if (!this.isIntermission() && !this.isWarmup())
	return;

	CPlayer@ p = getLocalPlayer();
	if (p is null) { return; }	
	if (p.getTeamNum() != this.getSpectatorTeamNum()) return;

	const u16 localID = p.getNetworkID();
	Vec2f mousepos = getControls().getMouseWorldPos();
	CBitStream params;

	CBlob@[] slots;
	if (getBlobsByTag("slotspawn", @slots))
	{
		for(int i = 0; i < slots.length(); i++)
		{
			CBlob@ slot = slots[i];
			if (slot !is null)
			{
				Vec2f pos = slot.getPosition();
				CSprite@ sprite = slot.getSprite();	
				
				bool mouseonslot = (mousepos - pos).getLength() < 4.0f;

				if (mouseonslot)
				{
					sprite.setRenderStyle(RenderStyle::normal);

					if ( getControls().isKeyJustPressed( KEY_LBUTTON ))
					{
						params.ResetBitIndex();
						params.write_netid(localID);
						params.write_netid(slot.getNetworkID());
						this.SendCommand(this.getCommandID("pick spawn"), params);					
					}
				}
				else
				{
					sprite.setRenderStyle(RenderStyle::additive);
				}
			}		
		}  
	}	 
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("pick spawn"))
	{
		ReadPickCmd(this, params);
	}
}

void ReadPickCmd(CRules@ this, CBitStream @params)
{
	CPlayer@ player = getPlayerByNetworkId(params.read_netid());
	const u16 pick = params.read_netid();
	if (player is getLocalPlayer())
	{
		player.client_ChangeTeam(0);
		player.client_RequestSpawn(pick);
	}
}