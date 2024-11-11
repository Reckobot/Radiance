#version 120
#extension GL_EXT_gpu_shader4 : enable
flat varying vec3 ambientUp;

uniform sampler2D colortex4;

uniform float sunIntensity;
uniform float sunElevation;
uniform float skyIntensity;
uniform float skyIntensityNight;
uniform float rainStrength;

uniform vec2 texelSize;

uniform vec3 sunColor;
uniform vec3 sunPosition;
uniform vec3 nsunColor;

uniform mat4 gbufferModelViewInverse;

vec3 sunVec = normalize(mat3(gbufferModelViewInverse) *sunPosition);

#include "lib/sky_gradient.glsl"

vec3 coneSample(vec2 Xi)
{
	float r = sqrt(1.0f - Xi.x*Xi.y);
    float phi = 2 * 3.14159265359 * Xi.y;

    return normalize(vec3(cos(phi) * r, sin(phi) * r, Xi.x)).xzy;
}
vec3 cosineHemisphereSample(vec2 Xi)
{
    float r = sqrt(Xi.x);
    float theta = 2.0 * 3.14159265359 * Xi.y;

    float x = r * cos(theta);
    float y = r * sin(theta);

    return vec3(x, y, sqrt(clamp(1.0 - Xi.x,0.,1.)));
}
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

	gl_Position = ftransform()*0.5+0.5;
	gl_Position.xy = gl_Position.xy*vec2(18.+258,258.)*texelSize;
	gl_Position.xy = gl_Position.xy*2.-1.0;

	ambientUp = vec3(0.);



	//integrate sky light
	for (int i = 0; i < 5; i++) {
		for (int j = 0; j < 5; j++) {
			vec2 ij = vec2(i,j)/5.*0.9+0.05;
			vec3 pos = cosineHemisphereSample(ij);


			ambientUp += getSkyColorLut(pos.xyz,sunVec,pos.y,colortex4)/25.;
	}
	}
	//fake bounced light
	ambientUp += sunColor*skyIntensity*(0.05+sunElevation*sunElevation)*0.15 + vec3(0.18,0.2,0.3)/10.*skyIntensityNight*(0.05+sunElevation*sunElevation)*0.1;

}
