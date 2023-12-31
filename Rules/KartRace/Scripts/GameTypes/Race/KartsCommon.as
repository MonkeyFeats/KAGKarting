
string g_statsFile;
bool syncedStats = false;
const string thistime_stats_tag = "karting_thistimestats";
const string alltime_stats_tag = "karting_alltimestats";

// Hook for map loader
void LoadMap()	// this isn't run on client!
{
	KartingCommonLoad();
}

void KartingCommonLoad()
{
	CRules@ rules = getRules();
	if (rules is null)
	{
		error("Something went wrong Rules is null");
	}

	SetConfig(rules);
	LoadMap(getMapInParenthesis());
}

void SetConfig(CRules@ rules)
{
	syncedStats = false;
	rules.set_string("rulesconfig", "test");
	rules.set_string("rulesconfig", CFileMatcher("/" + getMapName() + ".cfg").getFirst());
}

void AddRulesScript(CRules@ rules)
{
	CFileMatcher@ files = CFileMatcher("Karting_Race");
	while (files.iterating())
	{
		const string filename = files.getCurrent();
		if (rules.RemoveScript(filename))
		{
			printf("Removing rules script " + filename);
		}
	}

	printf("Adding rules script: " + getCurrentScriptName());
	rules.AddScript(getCurrentScriptName());
}

void SetIntroduction(CRules@ this, const string &in shortName)
{
	this.set_string("short name", shortName);
	this.set_string(thistime_stats_tag, "");
	this.set_string(alltime_stats_tag, "");
}

//// STATS STUFF

string getMapName()
{
	return getFilenameWithoutExtension(getFilenameWithoutPath(getMapInParenthesis()));
}

void Stats_MakeFile(CRules@ this, const string &in mode)
{
	CRules@ rules = getRules();
	g_statsFile = "Stats_Karting/stats_" + mode + "_" + getMapName() + ".cfg";
	this.set_string("stats file", g_statsFile);
	printf("STATS FILE -> ../Cache/" + g_statsFile);
	this.set_string(thistime_stats_tag, "");
	this.set_string(alltime_stats_tag, "");
}

string[] thisRaceTimes;
string[] recordRaceTimes;
uint[] newTimeSpots;

void Stats_Send(CRules@ this, string &in roundtext, string &in recordstext)
{
	roundtext += "\n\n";
	this.set_string(thistime_stats_tag, roundtext);
	this.Sync(thistime_stats_tag, true);

	recordstext += "\n\n";
	this.set_string(alltime_stats_tag, recordstext);
	this.Sync(alltime_stats_tag, true);
}

u32 Stats_getCurrentTime(CRules@ this)
{
	const u32 gameTicksLeft = this.get_u32("game ticks left");
	const u32 gameTicksDuration = this.get_u32("game ticks duration");
	return gameTicksDuration - gameTicksLeft;
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer() && cmd == this.getCommandID("player finish"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		if (player !is null)
		{
			const string name = player.getUsername();
			const u32 Time = Stats_getCurrentTime(getRules());

			if (thisRaceTimes.find(""+Time+"+"+name) == -1) //pushes it twice otherwise
			{
				thisRaceTimes.push_back(""+Time+"+"+name);
			}

			CBlob@ blob = player.getBlob();
			if (blob !is null)
			{				
				blob.server_Die();
			}
		}
	}
	
	if (getNet().isServer() && cmd == this.getCommandID("race finish"))
	{
		ConfigFile stats;
		if (stats.loadFile("../Cache/" + g_statsFile))
		{	
			for (uint i = 0; i < thisRaceTimes.size(); i++)
			{
				string[]@ thistokens = thisRaceTimes[i].split("+");
				if (thistokens.size() != 2) continue;

				const int thisTime = parseInt(thistokens[0]);
				const string thisName = thistokens[1];

				for (uint j = 0; j < recordRaceTimes.size()-1; j++)
				{
					string[]@ recordtokens = recordRaceTimes[j].split("+");
					if (recordtokens.size() != 2) continue;

					const int recordTime = parseInt(recordtokens[0]);
					const string recordName = recordtokens[1];

					if (thisTime < recordTime)
					{
						recordRaceTimes.insertAt(j, (thisTime+"+"+thisName));	
						newTimeSpots.push_back(j);	
						break;
					} 
				}
			}

			recordRaceTimes.set_length(20);

			string stringus;
			for (uint k = 0; k < recordRaceTimes.size(); k++)
			{
				stringus += recordRaceTimes[k]+"~";
			}

			stats.add_string("fastest times", stringus);
			stats.saveFile(g_statsFile);
		}
	}
}

void AllTime_Stats_Send(CRules@ this, string &in text)
{
	text += "\n\n";
	this.set_string(alltime_stats_tag, text);
	this.Sync(alltime_stats_tag, true);
}

void Stats_CreateFile(ConfigFile@ stats)
{
	string fakearray = "";
	for (uint i = 0; i < 20; i++)
	{
		fakearray+= "999999+N/A~";
	}

	stats.add_string("fastest times", fakearray);
}

void Stats_setupRecordTimesArray(ConfigFile@ stats)
{	
	if (stats.loadFile("../Cache/" + g_statsFile))
	{	
		recordRaceTimes.clear();
		string fakearray = "";

		const string fastestTimes = stats.read_string("fastest times");
		string[]@ tokens = fastestTimes.split("~");

		for (uint i = 0; i < tokens.size()-1; i++)
		{			
			recordRaceTimes.push_back(tokens[i]);
		}
	}
}

string Stats_Output_RoundTimes(ConfigFile@ stats)
{	
	string RaceTimes = "\n\n";
	RaceTimes += "Place |    M:S:MS  |  Name\n$DARKGREY$-----------------------------------------------------------------------$WHITE$\n"; 

	for(uint i = 0; i < thisRaceTimes.size(); i++)
	{
		if (i > 20) break;

		string[]@ tokens = thisRaceTimes[i].split("+");

		u8 oI = i+1;
		string OrdinalIndicator;
		if (oI >= 10 && oI <= 20)
		{
			OrdinalIndicator = oI+"th  |  ";
		} 
		else
		{	
			switch (oI % 10) 
			{
				case 1: OrdinalIndicator = oI+"st:    |  "; break;
				case 2: OrdinalIndicator = oI+"nd:   |  "; break;
				case 3: OrdinalIndicator = oI+"rd:    |  "; break;
				default: OrdinalIndicator = oI+"th:    |  "; break;
			}
		}

		//string coltoken = "";
		//switch (i)
		//{
		//	case 0: coltoken = "$GOLD$"; break;
		//	case 1: coltoken = "$SILVER$"; break;
		//	case 2: coltoken = "$BRONZE$"; break;
		//}

		string[]@ tokens1 = thisRaceTimes[i].split("+");
		if (tokens.size() == 2) 
		{				
			const int Time = parseInt(tokens1[0]);
			string Name = tokens1[1];

			if (Name.length() > 23)
			{
				Name.set_length(21);
				Name += "..";
			}

			s32 Minutes = Time/30 / 60;	
			s32 Seconds = Time/30 % 60;
			s32 MilliSeconds = Time / 0.5 % 60;	

			string line = OrdinalIndicator+(Minutes > 500 ? "":((Minutes < 10 ? "0":"")+Minutes+":"+(Seconds < 10 ? "0":"")+Seconds+":"+(MilliSeconds < 10 ? "0":"")+MilliSeconds+"  |  "))+Name;
			RaceTimes += (i < newTimeSpots.size() ? "$LITGREEN$":"") + line + (i < newTimeSpots.size() ? "$WHITE$":"");

			if (i < 19)
			RaceTimes += "\n$DARKGREY$-----------------------------------------------------------------------$WHITE$\n";	
		}
	}
	for(uint i = 0; i < Maths::Min(20-thisRaceTimes.size(), 20); i++)
	{
		u8 oI = i+1+thisRaceTimes.size();
		string OrdinalIndicator;
		if (oI >= 10 && oI <= 20)
		{
			OrdinalIndicator = oI+"th  |  ";
		} 
		else
		{	
			switch (oI % 10) 
			{
				case 1: OrdinalIndicator = oI+"st:    |  "; break;
				case 2: OrdinalIndicator = oI+"nd:   |  "; break;
				case 3: OrdinalIndicator = oI+"rd:    |  "; break;
				default: OrdinalIndicator = oI+"th:    |  "; break;
			}
		}

		RaceTimes += OrdinalIndicator;

		if (i < 18)
		RaceTimes += "\n$DARKGREY$-----------------------------------------------------------------------$WHITE$\n";	
	}
	return RaceTimes;
}

string Stats_Output_RecordsTimes(ConfigFile@ stats)
{	
	string RecordTimes = "\n\n";

	RecordTimes += "Place |    M:S:MS  |  Name\n$DARKGREY$-----------------------------------------------------------------------$WHITE$\n"; 

	for (uint i = 0; i < recordRaceTimes.size(); i++)
	{	
		u8 oI = i+1;
		string OrdinalIndicator;
		if (oI >= 10 && oI <= 20)
		{
			OrdinalIndicator = oI+"th:  |  ";
		} 
		else
		{	
			switch (oI % 10) 
			{
				case 1: OrdinalIndicator = oI+"st:    |  "; break;
				case 2: OrdinalIndicator = oI+"nd:   |  "; break;
				case 3: OrdinalIndicator = oI+"rd:    |  "; break;
				default: OrdinalIndicator = oI+"th:    |  "; break;
			}
		}

		string[]@ tokens = recordRaceTimes[i].split("+");		

		if (tokens.size() == 2) 
		{				
			const int Time = parseInt(tokens[0]);
			string Name = tokens[1] == "N/A" ? "  " : tokens[1];

			if (Name.length() > 23)
			{
				Name.set_length(21);
				Name += "..";
			}

			s32 Minutes = Time/30 / 60;	
			s32 Seconds = Time/30 % 60;
			s32 MilliSeconds = Time / 0.5 % 60;	

			string line = OrdinalIndicator+(Minutes > 500 ? "":((Minutes < 10 ? "0":"")+Minutes+":"+(Seconds < 10 ? "0":"")+Seconds+":"+(MilliSeconds < 10 ? "0":"")+MilliSeconds+"  |  "))+Name;			

			RecordTimes += (newTimeSpots.find(i) != -1 ? "$LITGREEN$":"") + line + (newTimeSpots.find(i) != -1 ? "$WHITE$":"") + (i < 19 ? "\n$DARKGREY$-----------------------------------------------------------------------$WHITE$\n" : "");		

		}
	}
	return RecordTimes;
}

void Stats_Draw(CRules@ this)
{
	const string roundtext = this.get_string(thistime_stats_tag);
	const string recordstext = this.get_string(alltime_stats_tag);

	if (roundtext.size() > 0 && recordstext.size() > 0)
	{
		GUI::SetFont("menu");

		const f32 MenuMiddle = 440;
		Vec2f Padding(2,16);
		Vec2f TextPadding(16,16);

		Vec2f TopLeft1(MenuMiddle-400.0f, 20.0f);
		Vec2f BottomRight1(MenuMiddle-Padding.x, 700.0f);
		Vec2f TopLeft2(MenuMiddle+Padding.x, 20.0f);
		Vec2f BottomRight2(MenuMiddle+400.0f, 700.0f);

		GUI::DrawFramedPane(TopLeft1, Vec2f(BottomRight1.x, 65));
		GUI::DrawFramedPane(TopLeft2, Vec2f(BottomRight2.x, 65));

		GUI::DrawFramedPane(TopLeft1+Vec2f(0, 35), BottomRight1);
		GUI::DrawFramedPane(TopLeft2+Vec2f(0, 35), BottomRight2);

		//string shortName = this.get_string("short name" ); //gametype
		//GUI::DrawTextCentered( shortName, Vec2f(MenuMiddle,10), color_white);

		const string RaceTimesHeader = " Race Times";
		GUI::DrawTextCentered( RaceTimesHeader, TopLeft1+Vec2f(200-Padding.x,Padding.y*1.3), color_white);
		GUI::DrawText(roundtext, TopLeft1+TextPadding, BottomRight1, color_white,false,false,false);

		//client has problems here even if i am able push them back 
		//for (uint i = 0; i < newTimeSpots.size(); i++)
		//{
		//	Vec2f pos = TopLeft2+Padding+Vec2f(0, (Padding.y*1.35)+((Padding.y*1.35)*newTimeSpots[i]));
		//	GUI::DrawRectangle(pos, pos+Vec2f(400-(Padding.x*5), 16), SColor(40,20,230,20));
		//}

		const string RecordTimesHeader = " Race Record Times";
		GUI::DrawTextCentered( RecordTimesHeader, TopLeft2+Vec2f(200-Padding.x,Padding.y*1.3), color_white);
		GUI::DrawText(recordstext, TopLeft2+TextPadding, BottomRight2, color_white,false,false,false);
	}
}
