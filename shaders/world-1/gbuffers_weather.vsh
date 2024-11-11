#version 120
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;
varying vec4 lmtexcoord;


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
uniform float frameTimeCounter;

const float PI48 = 150.796447372;
float pi2wt = PI48*frameTimeCounter;


vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {

    float magnitude = sin(dot(vec4(pi2wt*fm, pos.x, pos.z, pos.y),vec4(0.5))) * mm + ma;
	vec3 d012 = sin(pi2wt*vec3(f0,f1,f2)*3.0);
	vec3 ret = sin(pi2wt*vec3(f3,f4,f5) + vec3(d012.x + d012.y,d012.y + d012.z,d012.z + d012.x) - pos) * magnitude;
	
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0054, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.07, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}					
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	

	vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
		vec3 worldpos = position.xyz + cameraPosition;
		bool istopv = worldpos.y > cameraPosition.y+5.0;
	if (!istopv) position.xz += vec2(3.0,1.0)+sin(frameTimeCounter)*sin(frameTimeCounter)*sin(frameTimeCounter)*vec2(2.1,0.6);
	position.xz -= (vec2(3.0,1.0)+sin(frameTimeCounter)*sin(frameTimeCounter)*sin(frameTimeCounter)*vec2(2.1,0.6))*0.5;
	gl_Position = gl_ProjectionMatrix * gbufferModelView * position;	
	
	lmtexcoord.xy = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	color = gl_Color;

	
	//gl_Position = ftransform();
	



}