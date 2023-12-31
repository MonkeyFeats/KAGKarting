uniform sampler2D baseMap; 
uniform sampler2D extraMap;
varying vec4 Texcoord2;
uniform float time;
uniform float zoomscale;

//pixellate stuff
uniform float vx_offset;
uniform float screenWidth;
uniform float screenHeight;
uniform float pixel_w = 4.0;
uniform float pixel_h = 4.0;

//wave stuff
uniform vec2 WaveScale = vec2(3.25,3.3);
uniform float TimeScale = 30.0;
uniform float DistanceScale = 0.03;

void main()
{
  vec2 Texcoord = gl_TexCoord[0].xy;
  vec4 sample = texture2D(baseMap, Texcoord);


  if (sample.rgba == 0.0)
  {
    vec2 Texcoord22 = Texcoord2.xy;
    //pixellate stuf     
    float dx = pixel_w*(zoomscale/screenWidth);
    float dy = pixel_h*(zoomscale/screenHeight);
    vec2 pixelcoord = vec2(dx*floor(Texcoord2.x/dx), dy*floor(Texcoord2.y/dy));
    Texcoord22.x = (pixelcoord.x);
    Texcoord22.y = (pixelcoord.y);

    Texcoord22.x /= zoomscale;
    Texcoord22.y /= zoomscale;
    Texcoord22 *= 8; // texture scale

    // wave stuff
    vec2 Wave1;
    Wave1.x = sin((time/TimeScale)+(Texcoord22.x+Texcoord22.y)*WaveScale.x)*DistanceScale,
    Wave1.y = cos((time/TimeScale)+(Texcoord22.x+Texcoord22.y)*WaveScale.y)*DistanceScale;

    vec4 wavesample1 = texture(extraMap, Texcoord22 + Wave1 );
    wavesample1.rgb += (Wave1.x-Wave1.y)*0.2;   

    sample = wavesample1;
  }
  gl_FragColor = sample;
}

