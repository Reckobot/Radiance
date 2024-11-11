#version 120
const float	sunPathRotation	= -40.;	//[0. -5. -10. -15. -20. -25. -30. -35. -40. -45. -50. -55. -60. -70. -80. -90.]
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec3 sunVec;
varying vec3 upVec;

varying vec3 sky1;
varying vec3 sky2;
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
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 cameraPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
#include "ToD.glsl"

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

	//correct celestial rotation, ported to glsl by builderboy
	const float sunRotation = radians(sunPathRotation); 
	const vec2 sunData = vec2(cos(sunRotation), -sin(sunRotation)); 

	float ang = fract(worldTime / 24000.0 - 0.25);
	ang = (ang + (cos(ang * 3.14159265358979) * -0.5 + 0.5 - ang) / 3.0) * 6.28318530717959;

	upVec = vec3(0.,1.,0.);
	sunVec = normalize(vec3(-sin(ang), cos(ang) * sunData) * 100.0);
	SdotU = dot(sunVec,upVec);

	sunInt = max(exp(SdotU)-0.95,0.);
	moonInt = clamp(exp(-SdotU)-0.95,0.,0.5);
	vec3 sunlight = mix(normalize(vec3(0.58597,0.23,0.01)),normalize(vec3(0.58597,0.58,0.58)),pow(clamp(SdotU*1.2-0.1,0.,0.75),0.7));
	
	const vec3 moonlight = vec3(0.5, 0.9, 1.4) * 0.0032;
		
	float cosS = SdotU;
	float mcosS = max(cosS,0.0);

	const vec3 moonlight2 = pow(normalize(moonlight),vec3(3.0))*length(moonlight)+moonlight;

	vec3 sunlight04 = pow(sunlight,vec3(1.0/2.2));
	float skyMult = max(SdotU*0.1+0.1,0.0)/0.2*(1.0-rainStrength*0.6)*0.7;
	nsunlight = normalize(pow(mix(sunlight04,5.*sunlight04*(1.0-rainStrength*0.95)+vec3(0.3,0.3,0.35),rainStrength),vec3(2.2)))*0.6*skyMult;

	vec3 sky_color = vec3(0.13, 0.4, 0.95);
	sky_color = normalize(mix(sky_color,2.*sunlight04*(1.0-rainStrength*0.95)+vec3(0.3,0.3,0.3)*length(sunlight04),rainStrength)); //normalize colors in order to don't change luminance

	sky1 = sky_color*0.6*skyMult;
	sky2 = mix(sky_color,mix(nsunlight,sky_color,rainStrength*0.9),1.0-max(mcosS-0.2,0.0)*0.5)*0.6*skyMult;

	gl_Position = ftransform();


}
