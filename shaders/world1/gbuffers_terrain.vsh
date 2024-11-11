#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

#define WAVY_STUFF		//disable and gain some more fps


#define ENTITY_LEAVES        18.0
#define ENTITY_VINES        106.0
#define ENTITY_TALLGRASS     31.0
#define ENTITY_DANDELION     37.0
#define ENTITY_ROSE          38.0
#define ENTITY_WHEAT         59.0
#define ENTITY_LILYPAD      111.0
#define ENTITY_FIRE          51.0
#define ENTITY_LAVAFLOWING   10.0
#define ENTITY_LAVASTILL     11.0

varying vec4 color;
varying vec2 texcoord;


attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform float rainStrength;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

const float PI48 = 150.796447372;
float pi2wt = PI48*frameTimeCounter;


vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {

    float magnitude = sin(dot(vec4(pi2wt*fm, pos.x, pos.z, pos.y),vec4(0.5))) * mm + ma;
	vec3 d012 = sin(pi2wt*vec3(f0,f1,f2));
	vec3 ret = sin(pi2wt*vec3(f3,f4,f5) + vec3(d012.x + d012.y,d012.y + d012.z,d012.z + d012.x) - pos) * magnitude;
	
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0054, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.07, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}


vec3 toLinear(vec3 sRGB){
return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}
#include "lighting.glsl"	
	const vec2[8] offsets = vec2[8](vec2(1./8.,-3./8.),
									vec2(-1.,3.)/8.,
									vec2(5.0,1.)/8.,
									vec2(-3,-5.)/8.,
									vec2(-5.,5.)/8.,
									vec2(-7.,-1.)/8.,
									vec2(3,7.)/8.,
									vec2(7.,-7.)/8.);
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	vec4 idtest = vec4(ENTITY_TALLGRASS,ENTITY_DANDELION,ENTITY_ROSE,ENTITY_WHEAT)-mc_Entity.x;
	bool wavy1 = idtest.x*idtest.y*idtest.z*idtest.w == 0.0;
	
	vec2 id2 = vec2(161.0,ENTITY_LEAVES)-mc_Entity.x;
	bool wavy2 = id2.x*id2.y == 0.0;
	
	
	idtest = vec4(50.0,62.0,76.0,89.0)-mc_Entity.x;
	bool emissive = idtest.x*idtest.y*idtest.z*idtest.w == 0.0;
	
	idtest = vec4(141.0,142.0,175.0,106.0)-mc_Entity.x;
	
	bool mat = idtest.x*idtest.y*idtest.z*idtest.w == 0.0;
	color = emissive? vec4(1.0) : gl_Color;
	color.rgb = toLinear(color.rgb);
		
	gl_Position = ftransform();
	

	vec4 position = gl_ModelViewMatrix * gl_Vertex;
	position = gbufferModelViewInverse * position;


	
	vec3 sunVec = normalize(sunPosition);
	vec3 upVec = normalize(upPosition);
	texcoord = (gl_MultiTexCoord0).xy;

	vec2 lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
	
	
	
	color.rgb *= lightColor(lmcoord, normal, sunVec, -sunVec, upVec, mat && wavy1,position.y+cameraPosition.y);


}