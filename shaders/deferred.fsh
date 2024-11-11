#version 120
#extension GL_EXT_gpu_shader4 : enable
flat varying vec3 ambientUp;
const bool 	shadowHardwareFiltering0 = true;
/*
const int colortex0Format = RGB8;
const int colortex1Format = R11F_G11F_B10F;
const int colortex4Format = R11F_G11F_B10F;
*/
//no need to clear the buffers, saves a few fps
const bool colortex0Clear = false;
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = false;
const bool colortex4Clear = false;


#define MIN_LIGHT_AMOUNT 1.0 //[0.0 0.5 1.0 1.5 2.0 3.0 4.0 5.0]
#define TORCH_AMOUNT 10.0 //[0.0 0.5 0.75 1. 1.2 1.4 1.6 1.8 2.0]
#define TORCH_R 1.0 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define TORCH_G 0.42 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.42 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define TORCH_B 0.11 //[0.0 0.05 0.1 0.11 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

#define Ambient 0.75 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5]

#define SKY_BRIGHTNESS_DAY 1.0 //[0.0 0.5 0.75 1.0 1.2 1.4 1.6 1.8 2.0]
#define SKY_BRIGHTNESS_NIGHT 1.0 //[0.0 0.5 0.75 1.0 1.2 1.4 1.6 1.8 2.0]
#define fsign(a)  (clamp((a)*1e35,0.,1.)*2.-1.)

uniform vec3 nsunColor;
uniform float rainStrength;
uniform float skyIntensity;
uniform float skyIntensityNight;
uniform float sunIntensity;
uniform float moonIntensity;

float facos(float inX)
{
	const float PI = 3.14159265359;
	const float C0 = 1.56467;
	const float C1 = -0.155972;

    float x = abs(inX);
    float res = C1 * x + C0;
    res *= sqrt(1.0f - x);

    return (inX >= 0) ? res : PI - res;
}

void main() {
/* DRAWBUFFERS:4 */
//Custom lightmap LUT (16*16)
gl_FragData[0] = vec4(0.0);
if (gl_FragCoord.x < 17. && gl_FragCoord.y < 17.){
  float skyLut = floor(gl_FragCoord.y)/15.;
  float sky_lightmap = pow(skyLut,2.23);
  float torchLut = floor(gl_FragCoord.x)/15.;
  torchLut *= torchLut;
  float torch_lightmap = ((torchLut*torchLut)*(torchLut*torchLut))*(torchLut*20.)+torchLut*2.;
	float avgEyeIntensity = ((sunIntensity*120.+moonIntensity*4.)+skyIntensity*230.+skyIntensityNight*4.)*sky_lightmap;
	float exposure =  0.18/log2(max(avgEyeIntensity*0.16+1.0,1.13))*0.25;
  vec3 ambient = (ambientUp*sky_lightmap*log2(1.13+sky_lightmap*1.5)+torch_lightmap*0.11*vec3(TORCH_R,TORCH_G,TORCH_B)*TORCH_AMOUNT)*exposure * vec3(1.0,0.96,0.96)+MIN_LIGHT_AMOUNT*0.001*vec3(0.75,1.0,1.25);
  ambient *= Ambient;
  gl_FragData[0] = vec4(ambient*10.,1.0);
}
//Custom sky gradient LUT (256*256)
const float pi = 3.141592653589793238462643383279502884197169;

if (gl_FragCoord.x > 18. && gl_FragCoord.y > 1.){
  float cosY = clamp(floor(gl_FragCoord.x - 18.0)/256.*2.0-1.0,-1.0+1e-5,1.0-1e-5);
  cosY = pow(abs(cosY),1/3.0)*fsign(cosY);
  float mCosT = clamp(floor(gl_FragCoord.y-1.0)/256.,0.0,1.0);
  float Y = facos(cosY);
  const float a = -0.8;
  const float b = -0.1;
  const float c = 3.0;
  const float d = -7.;
  const float e = 0.35;

  //luminance (cie model)
	vec3 daySky = vec3(0.0);
	vec3 moonSky = vec3(0.0);
	// Day
	if (skyIntensity > 0.00001)
	{
	  float L0 = (1.0+a*exp(b/mCosT))*(1.0+c*(exp(d*Y)-exp(d*3.1415/2.))+e*cosY*cosY);
		vec3 skyColor0 = mix(vec3(0.05,0.5,1.)/1.5,vec3(0.4,0.5,0.6)/1.5,rainStrength);
		vec3 normalizedSunColor = nsunColor;

		vec3 skyColor = mix(skyColor0,normalizedSunColor,1.0-pow(1.0+L0,-1.2))*(1.0-rainStrength*0.5);
		daySky = pow(L0,1.0-rainStrength*0.75)*skyIntensity*skyColor*vec3(0.8,0.9,1.)*15.*SKY_BRIGHTNESS_DAY;
	}
	// Night
	if (skyIntensityNight > 0.00001)
	{
		float L0Moon = (1.0+a*exp(b/mCosT))*(1.0+c*(exp(d*(pi-Y))-exp(d*3.1415/2.))+e*cosY*cosY);
		moonSky = pow(L0Moon,1.0-rainStrength*0.75)*skyIntensityNight*vec3(0.08,0.12,0.18)*vec3(0.4)*SKY_BRIGHTNESS_NIGHT;
	}
  gl_FragData[0].rgb = daySky + moonSky;
}

}
