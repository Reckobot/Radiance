#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;

varying vec3 moonVec;
varying vec3 upVec;
varying vec2 texcoord;

varying float moonVisibility;



uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform int worldTime;
uniform int heldItemId;
uniform int heldBlockLightValue;
uniform float rainStrength;
uniform float wetness;
uniform ivec2 eyeBrightnessSmooth;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 cameraPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;

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

	moonVec = normalize(-sunPosition);
	upVec = normalize(upPosition);

	float MdotU = dot(moonVec,upVec);

	moonVisibility = pow(clamp(MdotU+0.15,0.0,0.15)/0.15,3.0);
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;



	color = gl_Color;
	
	gl_Position = ftransform();
	int frame = int(mod(frameCounter*1.0,8.));

	vec2 offset = offsets[frame];

	vec2 jitter = offset/vec2(viewWidth,viewHeight);

	gl_Position.xy += jitter * gl_Position.w;

}

