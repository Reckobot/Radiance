#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

/* DRAWBUFFERS:1 */

varying vec3 sunVec;
varying vec3 upVec;

varying vec3 sky1;
varying vec3 sky2;
const int 		noiseTextureResolution  = 32;

varying vec3 nsunlight;
varying float SdotU;
varying float sunInt;
varying float moonInt;

uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform int worldTime;
uniform int heldItemId;
uniform int heldBlockLightValue;
uniform float rainStrength;
uniform float wetness;
uniform ivec2 eyeBrightnessSmooth;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform sampler2D noisetex;
	float tmult = mix(min(abs(worldTime-6000.0)/6000.0,1.0),2.4,rainStrength)*0.48+0.52;
const int FOGMODE_LINEAR = 9729;
const int FOGMODE_EXP = 2048;
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

#include "projUtil.glsl"
#include "skyATM.glsl"
vec3 fpDither(vec3 color,float dither){
	const vec3 mantissaBits = vec3(6.,6.,5.);
	vec3 exponent = floor(log2(color));
	return color + dither*exp2(-mantissaBits)*exp2(exponent);
}
float nrand( vec2 n )
{
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
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

void main() {
	vec3 fragpos = toScreenSpaceVector(vec3(gl_FragCoord.xy/vec2(viewWidth,viewHeight),1.));
	fragpos = mat3(gbufferModelViewInverse) * fragpos;


	vec3 fColor = getSkyColor(fragpos,sunInt,moonInt,fragpos.y) ;


	gl_FragData[0] = vec4(fpDither(fColor*100.,triangWhiteNoise(gl_FragCoord.xy/vec2(viewWidth,viewHeight))),1.0);

}