#version 120
#extension GL_EXT_gpu_shader4 : enable

/*
const int colortex0Format = RGB8;
const int colortex1Format = R11F_G11F_B10F;

*/




/*--------------------------------*/

varying vec2 texcoord;



uniform sampler2D depthtex0;
uniform sampler2D colortex1;
uniform sampler2D noisetex;
uniform mat4 gbufferProjectionInverse;
uniform float frameTimeCounter;
const float PI = 3.14159265359;
float fastAcos(float inX)
{
	const float PI = 3.14159265359;
	const float C0 = 1.56467;
	const float C1 = -0.155972;

    float x = abs(inX);
    float res = C1 * x + C0;
    res *= sqrt(1.0f - x);

    return (inX >= 0) ? res : PI - res;
}
#include "skyATM.glsl"



vec3 ACESFilm( vec3 x )
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
	vec3 r = (x*(a*x+b))/(x*(c*x+d)+e);

    return pow(r,vec3(1./2.233333333));
}



float cdist(vec2 coord) {
	vec2 vec = abs(coord*2.0-1.0);
	float d = max(vec.x,vec.y);
	return 1.0 - d*d;
}





vec3 decode (vec2 enc)
{
    vec2 fenc = enc*4-2;
    float f = dot(fenc,fenc);
    float g = sqrt(1-f/4.0);
    vec3 n;
    n.xy = fenc*g;
    n.z = 1-f/2;
    return n;
}
float nrand( vec2 n )
{
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}
float BlueNoise(){
	vec2 nTC = mod(floor(gl_FragCoord.xy),32.);
	return fract(texelFetch2D(noisetex,ivec2(nTC),0).x);


}


vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
vec3 toScreenSpace(vec3 p) {
    vec3 p3 = p * 2. - 1.;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}
float triangWhiteNoise( vec2 n )
{
	//uses white noise for color dithering : gives a somewhat more "filmic" look when noise is visible
	float t = fract( frameTimeCounter );
	float rnd = nrand( n + 0.07*t );

    float center = rnd*2.0-1.0;
    rnd = center*inversesqrt(abs(center));
    rnd = max(-1.0,rnd);
    return rnd-sign(center);
}
vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}
vec2 nvec2(vec4 pos) {
    return pos.xy/pos.w;
}
float nvec1(vec4 pos) {
    return pos.z/pos.w;
}
vec4 nvec4(vec3 pos) {
    return vec4(pos.xyz, 1.0);
}

vec3 fpDither(vec3 color,float dither){
	const vec3 mantissaBits = vec3(6.,6.,5.);
	vec3 exponent = floor(log2(color));
	return color + dither*exp2(-mantissaBits)*exp2(exponent);
}
float bayer2(vec2 a){
	a = floor(a);
    return fract(dot(a,vec2(0.5,a.y*0.75)));
}
#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))
#define bayer32(a)  (bayer16(.5*(a))*.25+bayer2(a))
#define bayer64(a)  (bayer32(.5*(a))*.25+bayer2(a))
#define bayer128(a) fract(bayer64(.5*(a))*.25+bayer2(a)+tempSample)

//spiral sampling (numbers tweaked for 9 samples)
vec2 tapLocation(int sampleNumber, float spinAngle,int nb, float nbRot,float r0)
{
    float alpha = (float(sampleNumber*1.0f + r0) * (1.0 / (nb)));
    float angle = alpha * (nbRot * 6.28) + spinAngle;

    float ssR = alpha;
    float sin_v, cos_v;

	sin_v = sin(angle);
	cos_v = cos(angle);

    return vec2(cos_v, sin_v)*ssR;
}

#define Nether_Saturation 0.75 //[0.0 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#include "color_functions.glsl"

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
void main() {
	vec3 color = texture2D(colortex1,texcoord).xyz/100.;
	float Depth = texture2D(depthtex0, texcoord).x;




	vec3 fragpos = toScreenSpace(vec3(texcoord,Depth));
	vec3 screenVec = normalize(fragpos.xyz);

		vec3 fogC = getFogColor(screenVec,dot(screenVec,vec3(0.)));
        color = saturation(color.rgb, Nether_Saturation);


/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(ACESFilm(color)+triangWhiteNoise(texcoord)*exp2(-8.),1.);

}
