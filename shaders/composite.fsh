#version 330 compatibility
#include "/lib/distort.glsl"
#include "/lib/color.glsl"
#include "/lib/dh.glsl"
#include "/lib/settings.glsl"
#include "/lib/tonemap.glsl"
#include "/lib/rt.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex5;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D colortex11;
uniform sampler2D colortex13;
uniform float viewWidth;
uniform float viewHeight;
uniform int biome_precipitation;
uniform float frameTime;
uniform float rainStrength;

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowtex2;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform vec3 playerLookVector;
uniform vec3 skyColor;
uniform float far;
uniform vec3 cameraPosition;
uniform int renderStage;

in vec2 texcoord;
in vec3 viewnormal;

const float bias = SHADOWRES*0.00000075;

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

	return shadowColor.rgb*2;
}

vec4 getNoise(vec2 coord){
  	ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight)); // exact pixel coordinate onscreen
  	ivec2 noiseCoord = screenCoord % 64; // wrap to range of noiseTextureResolution
  	return texelFetch(noisetex, noiseCoord, 0);
}

vec3 getSoftShadow(vec4 shadowClipPos){
	const float range = SHADOWSOFTNESS;
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
      		offsetShadowClipPos.z -= bias;
      		offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
      		vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
      		vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
      		shadowAccum += getShadow(shadowScreenPos);
      		samples++;
    	}
  	}

  	return shadowAccum / float(samples);
}

/* RENDERTARGETS: 0,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 litparts;

const float sunPathRotation = SUNROTATION;

void main() {	
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;
	
	vec2 lightmap = texture(colortex1, texcoord).rg;
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

	vec3 blocklight = lightmap.r * blocklightColor;
	vec3 skylight = lightmap.g * skylightColor;
	vec3 ambient = ambientColor * AMBIENT;

	color = texture(colortex0, texcoord);
	vec4 nonTerrain = texture(colortex11, texcoord);
	vec4 translucent = texture(colortex13, texcoord);
	bool isterrain = true;
	if ((nonTerrain != vec4(0))&&(translucent == vec4(0))){
		color = nonTerrain;
		isterrain = false;
		ambient = vec3(2) * 0.25 - 0.25;
	}else if ((nonTerrain != vec4(0))){
		color = mix(nonTerrain, translucent, 0.75);
		isterrain = false;
		ambient = ambientColor * 0.25 - 0.25;
	}
	color = vec4(pow(color.rgb, vec3(2.2)), 1);

	float depth = texture(depthtex0, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 camPos = projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0));
	vec3 worldPos = (gbufferModelViewInverse * vec4(viewPos, 1)).xyz + cameraPosition;
	vec3 worldcamPos = (gbufferModelViewInverse * vec4(camPos, 1)).xyz + cameraPosition;
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	vec3 shadow;
	#ifdef HQSHADOWS
	shadow = getSoftShadow(shadowClipPos);
	#endif
	#ifndef HQSHADOWS
		shadowClipPos.z -= bias; // bias
		shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz); // distortion
		vec3 shadowNDCPos = shadowClipPos.xyz / shadowClipPos.w;
		vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
		shadow = getShadow(shadowScreenPos);
	#endif
	vec3 sunlight;
	if (texture(colortex13, texcoord) != vec4(0)){
		sunlight = (sunlightColor * clamp(dot(worldLightVector, normal), 0.2, 0.5) * lightmap.g);
	}else{
		sunlight = (sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 0.5) * lightmap.g)*shadow;
	}

	float shininess = 32;
	float specmult = 3;
	#if MATERIAL == 3
		if (isterrain == true){
			shininess = texture(colortex5, texcoord).r*128;
			specmult = texture(colortex5, texcoord).r*16;
		}
	#endif
	vec3 lightDir = worldLightVector;
	vec3 viewDir = mat3(gbufferModelViewInverse) * -normalize(projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0) * 2.0 - 1.0));
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float spec = pow(max(dot(normal, halfwayDir), 0.5), shininess)*specmult;
	
	sunlight = (sunlight + (sunlight*spec)) * SUNBRIGHTNESS;
	float skyBrightness = (rgb2hsv(skyColor.rgb)).z;
	float lightness = skyBrightness;
	sunlight *= lightness;
	ambient *= lightness;

	litparts = vec4(shadow, 1);

	if(depth >= 1.0){
		color = texture(colortex0, texcoord);
		if (lightness < 0.15){
			lightness = 0.15;
		}
		color.rgb *= lightness*2.75;
	}else{
		color.rgb *= blocklight + ambient + sunlight;
	}
}