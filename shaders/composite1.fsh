#version 330 compatibility
#extension GL_ARB_shader_storage_buffer_object : enable
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;

layout(std430, binding = 0) buffer frameData {
    float godRayMult;
};

in vec2 texcoord;

/* RENDERTARGETS: 0,5,6 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 godrayBuffer;
layout(location = 2) out vec4 fogBuffer;

void main() {
	color = texture(colortex0, texcoord);

	float depth = texture(depthtex0, texcoord).r;
	float depth1 = texture(depthtex1, texcoord).r;
	vec3 light = texture(colortex4, texcoord).rgb;
	vec3 normal = texture(colortex3, texcoord).rgb;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

	vec3 camNDCPos = vec3(texcoord.xy, 0.0) * 2.0 - 1.0;
	vec3 camviewPos = projectAndDivide(gbufferProjectionInverse, camNDCPos);

	vec3 centercamNDCPos = vec3(vec2(0.5, 0.5), 0.0) * 2.0 - 1.0;
	vec3 centercamviewPos = projectAndDivide(gbufferProjectionInverse, centercamNDCPos);
	centercamviewPos.y += 0.5;

	vec3 camShadowScreen = viewToShadowScreen(centercamviewPos, false, depth, depth1, normal, true);
	vec3 camLook = normalize(camviewPos);

	float lookModifier = dot(playerLookVector, mat3(gbufferModelViewInverse) * normalize(sunPosition))-0.5;
	lookModifier = clamp(lookModifier*8, 1.0, 10.0);

	#ifdef GODRAYS
	float godray = 0.0;
	int stepCount = 32;
	
	if(depth < 1) {
		if(texture(colortex2, texcoord).rgb != vec3(1.0)) {
			for(int i = 0; i < stepCount; i++) {
				vec3 ray = camNDCPos + (camLook*i/2*IGN(texcoord, frameCounter, vec2(viewWidth, viewHeight)));
				bool pixelate = false;
				vec3 rayShadowScreen = viewToShadowScreen(ray, pixelate, depth, depth1, normal, true);

				if(ray.z > viewPos.z) {
					godray += step(rayShadowScreen.z, texture(shadowtex0, rayShadowScreen.xy).r)/(stepCount);
				}
			}

			float modifier = clamp(step(camShadowScreen.z, texture(shadowtex0, camShadowScreen.xy).r), 0.0, 1.0);
			modifier = 1-modifier;

			if(isEyeInWater == 0) {
				godRayMult += ((modifier-0.5)*2.0)*((frameTime*0.00025)*GODRAY_TRANSITION);
				godRayMult = clamp(godRayMult, 0.125, 1.0);

				godrayBuffer = vec4(clamp((godray*godRayMult*lookModifier), 0.0, 0.5));
			} else {
				godRayMult += ((modifier-0.5)*2.0)*((frameTime*0.00025)*GODRAY_TRANSITION);
				godRayMult = clamp(godRayMult, 0.125, 1.0);

				godrayBuffer = vec4(clamp((godray*godRayMult*8), 0.0, 0.75));
			}
		} else {
			godrayBuffer = vec4(clamp(godRayMult*lookModifier, 0.0, 0.5));
		}
	} else {
		godrayBuffer = vec4(clamp(godRayMult*lookModifier, 0.0, 0.5));
	}
	#endif

	float dist = length(viewPos) / far;
	if(texture(colortex2, texcoord).rgb == vec3(1.0)) {
		dist /= 3;
	}
	float fogFactor = exp(-4 * (0.85 - dist));

	if(depth < 1.0) {
		fogBuffer = vec4(texture(colortex1, texcoord).rgb, clamp(fogFactor, 0.0, 1.0));
	}

	if(depth1 >= 1.0 && isEyeInWater == 1) {
		color.rgb = pow(skyColor, vec3(1.0))*0.85;
	}
}