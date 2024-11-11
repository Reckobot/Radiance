#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/


varying vec4 color;
varying vec2 texcoord;


uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform mat4 gbufferProjectionInverse;
	const vec2[8] offsets = vec2[8](vec2(1./8.,-3./8.),
									vec2(-1.,3.)/8.,
									vec2(5.0,1.)/8.,
									vec2(-3,-5.)/8.,
									vec2(-5.,5.)/8.,
									vec2(-7.,-1.)/8.,
									vec2(3,7.)/8.,
									vec2(7.,-7.)/8.);
vec3 lightColor(in vec2 lmcoord, in vec3 normal,in vec3 fpos, in vec3 sunVec, in vec3 moonVec, in vec3 upVec, in bool mat, in float moonMul){
	float SdotU = dot(sunVec,upVec);
	float sunInt = max(exp(SdotU)-0.95,0.);
	float moonInt = clamp(exp(-SdotU)-0.95,0.,0.5);
	
	vec3 sunlight = mix(normalize(vec3(0.58597,0.23,0.01)),normalize(vec3(0.58597,0.58,0.58)),pow(clamp(SdotU*1.1-0.1,0.,0.75),0.7));
	const vec3 rainC = vec3(0.01,0.01,0.01);
	sunlight = mix(sunlight,rainC*sunlight,rainStrength);



	vec3 moonlight = mix(vec3(1., 1.1, 1.4) * 0.6*0.2,vec3(0.6,0.63,0.7)*0.2,rainStrength);

	float VdotL = dot(fpos,sunVec);


	vec3 dayLight = sunlight*2.8 + exp(VdotL*VdotL*VdotL)*sunlight*4.;
	vec3 nightLight = moonlight*1.8 + exp(-VdotL*VdotL*VdotL)*moonlight*3.*(1.0-rainStrength*0.5);
	
	return dayLight*sunInt + nightLight*moonInt*1.6  ;

}
vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
vec3 toScreenSpace(vec3 p) {
        vec3 p3 = p * 2. - 1.;
        vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
        return fragposition.xyz / fragposition.w;
}
vec3 toScreenSpaceNoDiv(vec3 p) {
        vec3 p3 = p * 2. - 1.;
        vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
        return fragposition.xyz;
}
							
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {



	vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
	gl_Position = ftransform();
	vec3 fragpos = normalize((gbufferProjectionInverse*gl_Position).xyz);
	texcoord = (gl_MultiTexCoord0).xy;

	
	vec3 sunVec = normalize(sunPosition);
	vec3 upVec = normalize(upPosition);



	color = (dot(normal,upVec)*0.25+0.8 + dot(normal,sunVec)*0.25+0.8)*vec4((lightColor(vec2(0.,1.), normal,fragpos, sunVec, -sunVec, upVec, false,1.7))*0.5,0.999);
	color.a = 0.99;
	color.rgb *= (1.0-abs(dot(sunVec,upVec))*0.6)*0.5;
	
}