Random map_random(3253251239);
#include "LoadMapUtils.as";

namespace CMap
{	
	void SetupMap( CMap@ map, int width, int height )
	{
		map.CreateTileMap( width, height, 8.0f, "world.png" );
		map.CreateSky( SColor(0, 0, 0, 0) );
		map.topBorder = map.bottomBorder = map.rightBorder = map.leftBorder = true;
	} 

	enum Tiles
	{		
		water = 0,

		road = 384,
		roadtograss = 400,
		roadtograss_1 = 401,
		roadtograss_2 = 402,
		roadtograss_3 = 403,
		roadtograss_4 = 404,
		roadtograss_5 = 405,
		roadtograss_6 = 406,
		roadtograss_7 = 407,

		roadtosand = 416,
		roadtosand_1 = 417,
		roadtosand_2 = 418,
		roadtosand_3 = 419,
		roadtosand_4 = 420,
		roadtosand_5 = 421,
		roadtosand_6 = 422,
		roadtosand_7 = 423,

		roadtodirt = 432,
		roadtodirt_1 = 433,
		roadtodirt_2 = 434,
		roadtodirt_3 = 435,
		roadtodirt_4 = 436,
		roadtodirt_5 = 437,
		roadtodirt_6 = 438,
		roadtodirt_7 = 439,

		roadtowater = 464,
		roadtowater_1 = 465,
		roadtowater_2 = 466,
		roadtowater_3 = 467,
		roadtowater_4 = 468,
		roadtowater_5 = 469,
		roadtowater_6 = 470,
		roadtowater_7 = 471,

		grass = 388,
		grasstosand = 408,
		grasstosand_1 = 409,
		grasstosand_2 = 410,
		grasstosand_3 = 411,
		grasstosand_4 = 412,
		grasstosand_5 = 413,
		grasstosand_6 = 414,
		grasstosand_7 = 415,

		grasstodirt = 424,
		grasstodirt_1 = 425,
		grasstodirt_2 = 426,
		grasstodirt_3 = 427,
		grasstodirt_4 = 426,
		grasstodirt_5 = 429,
		grasstodirt_6 = 430,
		grasstodirt_7 = 431,

		grasstowater = 448,
		grasstowater_1 = 449,
		grasstowater_2 = 450,
		grasstowater_3 = 451,
		grasstowater_4 = 452,
		grasstowater_5 = 453,
		grasstowater_6 = 454,
		grasstowater_7 = 455,

		sand = 392,
		sandtodirt = 440,
		sandtodirt_1 = 441,
		sandtodirt_2 = 442,
		sandtodirt_3 = 443,
		sandtodirt_4 = 444,
		sandtodirt_5 = 445,
		sandtodirt_6 = 446,
		sandtodirt_7 = 447,

		sandtowater = 456,
		sandtowater_1 = 457,
		sandtowater_2 = 458,
		sandtowater_3 = 459,
		sandtowater_4 = 460,
		sandtowater_5 = 461,
		sandtowater_6 = 462,
		sandtowater_7 = 463,

		dirt = 396,
		dirttowater = 472,
		dirttowater_1 = 473,
		dirttowater_2 = 474,
		dirttowater_3 = 475,
		dirttowater_4 = 476,
		dirttowater_5 = 477,
		dirttowater_6 = 478,
		dirttowater_7 = 479,

		checkers = 560,
		checkers_1 = 561,
		checkers_2 = 562,
		checkers_3 = 563,

		rumbler_1 = 544,
		rumbler = 545,
		rumbler_2 = 546,
		rumbler_3 = 547,

		rumblertograss = 480,
		rumblertograss_1 = 481,
		rumblertograss_2 = 482,
		rumblertograss_3 = 483,
		rumblertograss_4 = 484,
		rumblertograss_5 = 485,
		rumblertograss_6 = 486,
		rumblertograss_7 = 487,
		rumblertograss_8 = 488,
		rumblertograss_9 = 489,
		rumblertograss_10 = 490,
		rumblertograss_11 = 491,
		rumblertograss_12 = 492,
		rumblertograss_13 = 493,
		rumblertograss_14 = 494,
		rumblertograss_15 = 496,

		rumblertoroad = 496,
		rumblertoroad_1 = 497,
		rumblertoroad_2 = 498,
		rumblertoroad_3 = 499,
		rumblertoroad_4 = 500,
		rumblertoroad_5 = 501,
		rumblertoroad_6 = 502,
		rumblertoroad_7 = 503,
		rumblertoroad_8 = 504,
		rumblertoroad_9 = 505,
		rumblertoroad_10 = 506,
		rumblertoroad_11 = 507,
		rumblertoroad_12 = 508,
		rumblertoroad_13 = 510,
		rumblertoroad_14 = 511,
		rumblertoroad_15 = 512,

		rumblertosand = 513,
		rumblertosand_1 = 514,
		rumblertosand_2 = 515,
		rumblertosand_3 = 516,
		rumblertosand_4 = 517,
		rumblertosand_5 = 518,
		rumblertosand_6 = 519,
		rumblertosand_7 = 520,
		rumblertosand_8 = 521,
		rumblertosand_9 = 522,
		rumblertosand_10 = 523,
		rumblertosand_11 = 524,
		rumblertosand_12 = 525,
		rumblertosand_13 = 526,
		rumblertosand_14 = 527,
		rumblertosand_15 = 528,

		rumblertodirt = 529,
		rumblertodirt_1 = 530,
		rumblertodirt_2 = 531,
		rumblertodirt_3 = 532,
		rumblertodirt_4 = 533,
		rumblertodirt_5 = 534,
		rumblertodirt_6 = 535,
		rumblertodirt_7 = 536,
		rumblertodirt_8 = 537,
		rumblertodirt_9 = 538,
		rumblertodirt_10 = 539,
		rumblertodirt_11 = 540,
		rumblertodirt_12 = 541,
		rumblertodirt_13 = 542,
		rumblertodirt_14 = 543,
		rumblertodirt_15 = 544,

		fence_gate = 564,
		fence_corner = 548,
		fence_grass = 549,
		fence_sand = 550,
		fence_dirt = 551,
		fence_water = 552,
		crop_red = 553,
		crop_green = 556,
		crop_empty = 565,
		crop_empty_grassy = 567,
		crop_empty_water = 568,
		crop_blue = 569,
		crop_yellow = 572,

		woodlogs = 576,
		woodlogs_1 = 577,
		woodbrick = 578,

		woodpath_1 = 579,
		woodpath_2 = 580,
		woodpath_3 = 581,
		woodpath_4 = 582,
		woodpath_5 = 583,
		woodpath_corner_1 = 584,
		woodpath_corner_2 = 585,
		woodpath_corner_3 = 586,
		woodpath_corner_4 = 587,				

		flowers_1 = 588,
		flowers_2 = 589,
		flowers_3 = 590,
		flowers_4 = 591,

		dirtwall = 592,
		dirtwall_1 = 593,
		dirtwall_2 = 594,
		dirtwall_3 = 595,
		dirtwall_4 = 596,
		dirtwall_5 = 597,	

		fence_corner_sand = 598,		
		fence_corner_dirtwall = 599,
		fence_end_grass = 600,
		fence_end_sand = 601,
		fence_end_dirt = 602,

		logpath_full = 603,

		flowers_5 = 604,
		flowers_6 = 605,
		flowers_7 = 606,
		flowers_8 = 607,

		stonewall = 608,
		stonewall_1 = 609,
		stonewall_2 = 610,
		stonewall_3 = 611,
		stonewall_4 = 612,

		stonepath_1 = 613,
		stonepath_2 = 614,
		stonepath_3 = 615,
		stonepath_4 = 616,
		stonepath_5 = 617,

		stonething_1 = 618,
		stonething_2 = 619,

		rooftile_1 = 620,
		rooftile_2 = 621,

		mudtrack_1 = 622,
		mudtrack_2 = 623,

		traintracks_1 = 624,
		traintracks_2 = 625,
		traintracks_3 = 626,
		traintracks_4 = 627,
		traintracks_5 = 628,

		extabrick_1 = 629,
		extabrick_2 = 630,
		extabrick_3 = 631,
		extabrick_4 = 632,
		extabrick_5 = 633,
		extabrick_6 = 634,
		extabrick_7 = 635,
		extabrick_8 = 636,

		cobblestone_1 = 637,
		cobblestone_2 = 638,
		cobblestone_3 = 639,

		roof1_1 = 640,
		roof1_2 = 641,
		roof1_3 = 642,
		roof1_4 = 643,
		roof1_5 = 644,
		roof1_6 = 645,
		roof1_7 = 646,
		roof1_8 = 647,
		roof1_9 = 648,
		roof1_10 = 649,
		roof1_11 = 650,
		roof1_12 = 651,
		roof1_13 = 652,
		roof1_14 = 653,
		roof1_15 = 654,
		roof1_16 = 655,

		roof2_1 = 656,
		roof2_2 = 657,
		roof2_3 = 658,
		roof2_4 = 659,
		roof2_5 = 660,
		roof2_6 = 661,
		roof2_7 = 662,
		roof2_8 = 663,
		roof2_9 = 664,
		roof2_10 = 665,
		roof2_11 = 666,
		roof2_12 = 667,
		roof2_13 = 668,
		roof2_14 = 669,
		roof2_15 = 670,
		roof2_16 = 671,

		roof3_1 = 672,
		roof3_2 = 673,
		roof3_3 = 674,
		roof3_4 = 675,
		roof3_5 = 676,
		roof3_6 = 677,
		roof3_7 = 678,
		roof3_8 = 679,
		roof3_9 = 680,
		roof3_10 = 681,
		roof3_11 = 682,
		roof3_12 = 683,
		roof3_13 = 684,
		roof3_14 = 685,
		roof3_15 = 686,
		roof3_16 = 687,

		roof4_1 = 688,
		roof4_2 = 689,
		roof4_3 = 690,
		roof4_4 = 691,
		roof4_5 = 692,
		roof4_6 = 693,
		roof4_7 = 694,
		roof4_8 = 695,
		roof4_9 = 696,
		roof4_10 = 697,
		roof4_11 = 698,
		roof4_12 = 699,
		roof4_13 = 700,
		roof4_14 = 701,
		roof4_15 = 702,
		roof4_16 = 703,

		roof5_1 = 704,
		roof5_2 = 705,
		roof5_3 = 706,
		roof5_4 = 707,
		roof5_5 = 708,
		roof5_6 = 709,
		roof5_7 = 710,
		roof5_8 = 711,
		roof5_9 = 712,
		roof5_10 = 713,
		roof5_11 = 714,
		roof5_12 = 715,
		roof5_13 = 716,
		roof5_14 = 717,
		roof5_15 = 718,
		roof5_16 = 719,

		roof6_1 = 720,
		roof6_2 = 721,
		roof6_3 = 722,
		roof6_4 = 723,
		roof6_5 = 724,
		roof6_6 = 725,
		roof6_7 = 726,
		roof6_8 = 727,
		roof6_9 = 728,
		roof6_10 = 729,
		roof6_11 = 730,
		roof6_12 = 731,
		roof6_13 = 732,
		roof6_14 = 733,
		roof6_15 = 734,
		roof6_16 = 735,

		stonefence_1 = 736,
		stonefence_2 = 737,
		stonefence_3 = 738,
		stonefence_4 = 739,
		stonefence_5 = 740,
		stonefence_6 = 741,
		stonefence_7 = 742,

		bushes = 752,
		bushestograss = 760,
		bushestosand = 768,
		bushestodirt = 776
	};

	void handlePixel( CMap@ map, CFileImage@ image, SColor pixel, int offset, Vec2f pixelPos)
	{	
		u8 Alpha = pixel.getAlpha(); // blob angle
		u8 Red = pixel.getRed(); // tile angle
		u8 Green = pixel.getGreen(); // tile type
		u8 Blue = pixel.getBlue(); // blob type

		s32 tile = Green;

		bool Backgrounded = true;

		if(tile > 0) tile += 383;
		if(Red >=  128) tile += 255;

		map.SetTile(offset, tile);

		switch (tile)
		{			
			//solid and on top of blobs
			case woodlogs :
			case woodlogs_1 :
			case woodbrick :			
			case dirtwall :
			case dirtwall_1 :
			case dirtwall_2 :
			case dirtwall_5 :
			case stonewall :
			case stonewall_1 :
			case stonewall_2 :			
			case stonething_1 :
			case stonething_2 :
			case rooftile_1 :
			case rooftile_2 :
			case extabrick_1 :
			case extabrick_2 :
			case extabrick_3 :
			case extabrick_4 :
			case extabrick_5 :
			case extabrick_6 :
			case extabrick_7 :
			case extabrick_8 :
			case roof1_1 :
			case roof1_2 :
			case roof1_3 :
			case roof1_4 :
			case roof1_5 :
			case roof1_6 :
			case roof1_7 :
			case roof1_8 :
			case roof1_9 :
			case roof1_10 :
			case roof1_11 :
			case roof1_12 :
			case roof1_13 :
			case roof1_14 :
			case roof1_15 :
			case roof1_16 :
			case roof2_1 :
			case roof2_2 :
			case roof2_3 :
			case roof2_4 :
			case roof2_5 :
			case roof2_6 :
			case roof2_7 :
			case roof2_8 :
			case roof2_9 :
			case roof2_10 :
			case roof2_11 :
			case roof2_12 :
			case roof2_13 :
			case roof2_14 :
			case roof2_15 :
			case roof2_16 :
			case roof3_1 :
			case roof3_2 :
			case roof3_3 :
			case roof3_4 :
			case roof3_5 :
			case roof3_6 :
			case roof3_7 :
			case roof3_8 :
			case roof3_9 :
			case roof3_10 :
			case roof3_11 :
			case roof3_12 :
			case roof3_13 :
			case roof3_14 :
			case roof3_15 :
			case roof3_16 :
			case roof4_1 :
			case roof4_2 :
			case roof4_3 :
			case roof4_4 :
			case roof4_5 :
			case roof4_6 :
			case roof4_7 :
			case roof4_8 :
			case roof4_9 :
			case roof4_10 :
			case roof4_11 :
			case roof4_12 :
			case roof4_13 :
			case roof4_14 :
			case roof4_15 :
			case roof4_16 :
			case roof5_1 :
			case roof5_2 :
			case roof5_3 :
			case roof5_4 :
			case roof5_5 :
			case roof5_6 :
			case roof5_7 :
			case roof5_8 :
			case roof5_9 :
			case roof5_10 :
			case roof5_11 :
			case roof5_12 :
			case roof5_13 :
			case roof5_14 :
			case roof5_15 :
			case roof5_16 :
			case roof6_1 :
			case roof6_2 :
			case roof6_3 :
			case roof6_4 :
			case roof6_5 :
			case roof6_6 :
			case roof6_7 :
			case roof6_8 :
			case roof6_9 :
			case roof6_10 :
			case roof6_11 :
			case roof6_12 :
			case roof6_13 :
			case roof6_14 :
			case roof6_15 :
			case roof6_16 :
			{map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION); Backgrounded = false;} break;

			//solid and below blobs
			case CMap::fence_gate :
			case CMap::fence_corner :
			case CMap::fence_grass :
			case CMap::fence_sand :
			case CMap::fence_dirt :
			case CMap::fence_water :
			case stonefence_1 :
			case stonefence_2 :
			case stonefence_3 :
			case stonefence_4 :
			case stonefence_5 :
			case stonefence_6 :
			case stonefence_7 :
			case dirtwall_3 :
			case stonewall_3 : 
			{ map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION ); Backgrounded = true;} break;

			//non-solid and below
			//case dirtwall_4 :
			//case stonewall_4 :
			//{Backgrounded = true;} break;
		}

		if (Blue > 0 && Blue != 255)
		spawnBlobFromBlue(Alpha, Blue, offset, map);
		
		uint flags = 0;

		if(Red & 1 > 0) flags = flags | Tile::MIRROR;
		if(Red & 2 > 0) flags = flags | Tile::FLIP;
		if(Red & 4 > 0) flags = flags | Tile::ROTATE;

		map.AddTileFlag(offset, flags);
		map.AddTileFlag(offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);

		if (Backgrounded)
		{
			map.AddTileFlag(offset, Tile::BACKGROUND);
		}
		else
		{
			map.RemoveTileFlag(offset, Tile::BACKGROUND);
		}
	}
}

void spawnBlobFromBlue(u8 alpha, u8 blue, int offset, CMap@ map)
{
	int teamnum = ((alpha-10)/24);
	u16 ang = ((alpha-(teamnum*24))-10)*15;		

	//if (blue-1 >= blobNames.length()-1)
	if (blue >= 100)
	{
		AddMarker( map, offset, "waypoint_"+(blue-100));
	}
	else
	{
		string name = blobNames[blue-1];

		bool Staticate = true;
		bool MapCollide = false;

		CBlob@ blob = spawnBlob( map, name, offset, 0, false);		
		if (blob !is null)
		{
			Vec2f shapeOffset;
			switch ( blue-1 )
			{
				case 0 : 
				case 1 : 
				case 2 : 
				case 3 : 
				case 4 : 
				case 5 : 
				case 6 : 
				case 7 : { shapeOffset = Vec2f( 0, 4); blob.getSprite().SetZ(-10.0);} break;

				case 8 : 
				case 9 : 
				case 10 : 
				case 11 : 
				case 12 : 
				case 13 : 
				case 14 : 
				case 15 : { shapeOffset = Vec2f( 0, 1.5); blob.getSprite().SetZ(-10.0f);} break;

				case 16 : //hay bales
				case 17 : 
				case 57 : {Staticate = false; MapCollide = true;} break;
				
				case 18: //trees
				case 19:
				case 20:
				case 21:  
				case 35: //plane
				{ blob.getSprite().SetZ(500.0f); } break;
				
				case 51 : //corners m
				case 54 : { shapeOffset = Vec2f( -4, 4 ); blob.getSprite().SetZ(-15.0f);} break;				
				case 52 : //corners l
				case 55 : { shapeOffset = Vec2f( 2, -2 ); blob.getSprite().SetZ(-16.0f);} break;


				case 59:  
				case 60: //overlappers
				{ blob.getSprite().SetZ(250.0f); } break;

				case 64 : {blob.Tag("slotspawn");} break; //start slots
			}

			blob.getShape().getConsts().mapCollisions = MapCollide;
			//bool facingleft = alpha > 207;
			//if (facingleft) shapeOffset.x = -shapeOffset.x;
			//blob.SetFacingLeft(facingleft);

			blob.getShape().SetOffset(shapeOffset);

			blob.setAngleDegrees(ang);
			blob.server_setTeamNum(teamnum);
			blob.getShape().SetStatic(Staticate);
		}	
	}	
}

const string[] blobNames =
{       
	"dirtwalltiny", //0
	"dirtwallsmall", //1
	"dirtwallmedium", //2
	"dirtwallbig", //3
	"stonewalltiny", //4
	"stonewallsmall", //5
	"stonewallmedium", //6
	"stonewallbig", //7
	"woodfencetiny", //8
	"woodfencesmall", //9
	"woodfencemedium", //10
	"woodfencebig", //11
	"stonefencetiny", //12
	"stonefencesmall", //13
	"stonefencemedium", //14
	"stonefencebig", //15
	"haybale", //16
	"haybalebig", //17
	"palmtree", //18
	"bigtree1", //19
	"bigtree3", //20
	"smalltreetrunk", //21
	"bigtreetrunk", //22
	"boulder1", //23
	"boulder2", //24
	"boulder3", //25
	"boulder4", //26
	"boulder5", //27
	"boulder6", //28
	"boulder7", //29
	"boulder8", //30
	"waterbarrel", //31
	"excavator", //32
	"propkar", //33
	"propboat", //34
	"propplane", //35
	"brickwalltiny", //36
	"brickwallsmall", //37
	"brickwallmedium", //38
	"brickwallbig", //39
	"person", //40
	"crowd_l", //41
	"cone", //42
	"roadoverpass", //43
	"watertowerround", //44
	"watertowersquare", //45
	"finishline_s", //46
	"finishline_m", //47
	"finishline_l", //48
	"finishline_xl", //49
	"dirtcorner_s", //50
	"dirtcorner_m", //51
	"dirtcorner_l", //52
	"stonecorner_s", //53
	"stonecorner_m", //54
	"stonecorner_l", //55
	"waterbarrel_s", //56
	"haybaleround", //57
	"overbarsbase", //58
	"overbarsbar", //59
	"overbarsbar_big", //60
	"crowd_s", //61
	"crowd_m", //62
	"flag_s", //63

	"slot", //64
	"waymarker"
};



