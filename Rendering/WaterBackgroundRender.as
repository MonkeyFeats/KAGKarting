
const string back_name = "pixel.png";
const string tex1_name = "FluidMask1.png";
const string tex2_name = "FluidMask5.png";

const int wavelength = 128;
const f32 amplitude = 24.0;
const f32 z = -500.0;
const int framesize = 256;
const int gframesize = 256;

const uint width = (10000);
const uint height = (10000);

void onInit(CRules@ this)
{
	this.set_bool("water markers to find", true);
	this.set_bool("ground markers to find", true);

	int water_id = Render::addScript(Render::layer_background, "WaterBackgroundRender.as", "RenderWater", 0.0f);
	Setup();
}

Vertex[] water_raw_back;
Vertex[] water_raw;
Vertex[] water_raw2;

float[] model;

void Setup()
{
	Matrix::MakeIdentity(model);

	water_raw.clear();
	water_raw2.clear();

	CMap@ map = getMap();

	float w2 = width/2;
	float h2 = height/2;

	water_raw_back.push_back(Vertex(-w2, -h2, 	0, 0, 0, 	SColor(255,10,60,120)));
	water_raw_back.push_back(Vertex( w2, -h2, 	0, 1, 0, 	SColor(255,10,60,120)));
	water_raw_back.push_back(Vertex( w2,  h2,	0, 1, 1,  	SColor(255,10,60,120)));
	water_raw_back.push_back(Vertex(-w2,  h2,	0, 0, 1,  	SColor(255,10,60,120)));
	
	water_raw.push_back(Vertex(-w2, -h2, 	 	1, 0, 0, 									SColor(55,80,200,180)));
	water_raw.push_back(Vertex( w2, -h2, 	 	1, width/framesize, 0, 					    SColor(55,80,200,180)));
	water_raw.push_back(Vertex( w2,  h2,    	1, width/framesize, height/framesize,  		SColor(55,80,200,180)));
	water_raw.push_back(Vertex(-w2,	 h2,    	1, 0, height/framesize,  					SColor(55,80,200,180)));
	
	water_raw2.push_back(Vertex(-w2, -h2, 	 	2, 0, 0, 									SColor(20, 210, 210, 210)));
	water_raw2.push_back(Vertex( w2, -h2, 	 	2, width/framesize, 0, 						SColor(20, 210, 210, 210)));
	water_raw2.push_back(Vertex( w2,  h2, 		2, width/framesize, height/framesize, 		SColor(20, 210, 210, 210)));
	water_raw2.push_back(Vertex(-w2,  h2, 		2, 0, height/framesize, 					SColor(20, 210, 210, 210)));
}


void RenderWater(int id)
{
	float time = getGameTime()*0.1;

	Render::SetAlphaBlend(true);
	Render::RawQuads(back_name, water_raw_back);

	f32 w1 =  -amplitude * Maths::Sin(Maths::Pi*2.0f*((time))/wavelength);
	f32 w2 =  -amplitude * Maths::Cos(Maths::Pi*2.0f*((time))/wavelength);

	Matrix::SetTranslation(model, w1*1.4, -w2*1.4, 0);			
	Render::SetModelTransform(model);
	Render::RawQuads(tex1_name, water_raw);

	Matrix::SetTranslation(model, w1, -w2, 0);			
	Render::SetModelTransform(model);
	Render::RawQuads(tex2_name, water_raw2);
}
