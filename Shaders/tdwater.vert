
uniform float screenPosX;
uniform float screenPosY;
uniform float zoomscale;
varying vec4 Texcoord2;

void main(void)
{
  gl_Position = gl_ProjectionMatrix * gl_Vertex;
  gl_TexCoord[0] = gl_MultiTexCoord0;

  float x = screenPosX*(4*zoomscale);
  float y = screenPosY*(4*zoomscale);
  vec4 screenpos = vec4(x, y, 0, 0);

  Texcoord2 =  gl_Vertex + screenpos;
}