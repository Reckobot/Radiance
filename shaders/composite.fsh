#version 330 compatibility
#include /lib/distort.glsl
#include /lib/color.glsl

#define Ambient 0.25 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SunBrightness 1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0]
#define FogDensity 10 //[0 1 2 3 4 5 6 7 8 9 10]
#define HighQualityShadows true //[true false]
#define ShadowSoftness 0.25 //[0.0 0.125 0.25 0.375 0.5 0.625 0.75 0.875 1.0]

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform vec3 playerLookVector;
uniform vec3 skyColor;
uniform float far;

in vec2 texcoord;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

vec3 getShadow(vec3 shadowScreenPos){
	float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);

	if(transparentShadow == 1.0){
		return vec3(1.0);
	}

	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);

	if(opaqueShadow == 0.0){
		return vec3(0.0);
	}

	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);

	return shadowColor.rgb * (1.0 - shadowColor.a);
}

vec4 getNoise(vec2 coord){
  	ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight)); // exact pixel coordinate onscreen
  	ivec2 noiseCoord = screenCoord % 64; // wrap to range of noiseTextureResolution
  	return texelFetch(noisetex, noiseCoord, 0);
}

vec3 getSoftShadow(vec4 shadowClipPos){
	const float range = ShadowSoftness;
	const float increment = 0.5;

	float noise = getNoise(texcoord).r;

	float theta = noise * radians(360.0);
	float cosTheta = cos(theta);
	float sinTheta = sin(theta);

	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

	vec3 shadowAccum = vec3(0.0);
	int samples = 0;

	for(float x = -range; x <= range; x += increment){
		for (float y = -range; y <= range; y+= increment){
			vec2 offset = rotation * vec2(x, y) / shadowMapResolution;
			vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0, 0.0);
      		offsetShadowClipPos.z -= 0.0003;
      		offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
      		vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
      		vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
      		shadowAccum += getShadow(shadowScreenPos);
      		samples++;
    	}
  	}

  	return shadowAccum / float(samples);
}

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

const vec3 blocklightColor = vec3(1,1,1);
const vec3 skylightColor = vec3(1,1,1);
const vec3 sunlightColor = vec3(2,1.5,1);
const vec3 ambientColor = vec3(1,1.5,2);

void main() {

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;
	
	vec2 lightmap = texture(colortex1, texcoord).rg;
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

	vec3 blocklight = lightmap.r * blocklightColor;
	vec3 skylight = lightmap.g * skylightColor;
	vec3 ambient = ambientColor * Ambient;

	color = texture(colortex0, texcoord);

	float depth = texture(depthtex0, texcoord).r;
	if(depth == 1.0){
		return;
	}

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	vec3 shadow;
	if (HighQualityShadows == true){
		shadow = getSoftShadow(shadowClipPos);
	}
	else{
		shadowClipPos.z -= 0.0003; // bias
		shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz); // distortion
		vec3 shadowNDCPos = shadowClipPos.xyz / shadowClipPos.w;
		vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
		shadow = getShadow(shadowScreenPos);
	}
	vec3 sunlight = (sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * lightmap.g)*shadow;

	int shininess = 2;
	vec3 light = shadowLightPosition;
	light.y = -light.y;
	float spec = pow((max(0.0, dot(normalize(viewPos), normalize(reflect(light, normal))))), shininess)*4;
	
	sunlight = (sunlight + (sunlight*spec)) * SunBrightness;
	float skyBrightness = (rgb2hsv(skyColor.rgb)).z;
	float lightness = skyBrightness;
	sunlight *= lightness;
	ambient *= lightness;


	color.rgb *= blocklight + ambient + sunlight;

	//fog
	if (FogDensity > 0){
		float dist = length(viewPos) / far;
		float fogFactor = exp(-FogDensity * (1.0 - dist));
		color.rgb = mix(color.rgb, (vec3(1,1,1)/1.5)*(lightness), clamp(fogFactor, 0.0, 1.0));
	}
}