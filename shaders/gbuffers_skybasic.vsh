#version 120
#extension GL_EXT_gpu_shader4 : enable
const float	sunPathRotation	= -40.;	//[0. -5. -10. -15. -20. -25. -30. -35. -40. -45. -50. -55. -60. -70. -80. -90.]
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

flat varying vec4 sunVec;

uniform int worldTime;
uniform float rainStrength;

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

	sunVec.xyz = normalize(vec3(-sin(ang), cos(ang) * sunData));
	float pi = 3.14159265359;
	float angSun= -(( pi * 0.5128205128205128 - acos(sunVec.y*1.065-0.065))/1.5);
	float angMoon= -(( pi * 0.5128205128205128 - acos(-sunVec.y*1.065-0.065))/1.5);
	float angSky= -(( pi * 0.5128205128205128 - acos(sunVec.y*0.95+0.05))/1.5);
	float angSkyNight= -(( pi * 0.5128205128205128 -acos(-sunVec.y*0.95+0.05))/1.5);

	float fading = clamp(sunVec.y + 0.095, 0.0, 0.08)/0.08;
	float sunIntensity=max(0.,1.0-exp(angSun));
	float skyIntensity=max(0.,1.0-exp(angSky))*pow(fading, 5.0)*(1.0-rainStrength*0.4);
	float	moonIntensity=max(0.,1.0-exp(angMoon));
	fading = clamp(-sunVec.y + 0.095, 0.0, 0.08)/0.08;
	float skyIntensityNight=max(0.,1.0-exp(angSkyNight))*pow(fading, 5.0)*(1.0-rainStrength*0.4);

	float avgEyeIntensity = ((sunIntensity*120.+moonIntensity*4.)+skyIntensity*230.+skyIntensityNight*4.);
	sunVec.w = 1.8/log2(max(avgEyeIntensity*0.16+1.0,1.13))*0.3;
	gl_Position = ftransform();

}
