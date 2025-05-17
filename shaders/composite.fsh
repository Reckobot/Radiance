#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex8;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	float ambient = AMBIENT;

	color = texture(colortex0, texcoord);
	float depth = texture(depthtex0, texcoord).r;
	float depth1 = texture(depthtex1, texcoord).r;

	if(depth >= 1.0) {
		#ifdef DISTANT_HORIZONS
			depth = texture(dhDepthTex0, texcoord).r;
			depth1 = texture(dhDepthTex1, texcoord).r;
		#endif
	}

	vec4 light = texture(colortex4, texcoord);

	vec3 normal = texture(colortex3, texcoord).rgb;
	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 worldPos = feetPlayerPos+cameraPosition;

	bool pixelate = false;
	if(dot(normal, vec3(ivec3(normal))) > 0.9) {
		pixelate = true;
	}
	if(texture(colortex8, texcoord).rgb != 0.0) {
		pixelate = false;
	}

	bool notBlock = false;
	notBlock = bool(int(texture(colortex8, texcoord).r));
	vec3 shadowScreenPos = viewToShadowScreen(viewPos, pixelate, depth, depth1, normal, false, notBlock);

	float shadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;
	float time = clamp(abs(sunAngle - shadowAngle), 0.0, 1.0);

	if((depth < 1.0) && (depth != depth1)) {
		float shading = dot(normal, worldLightVector);
		if((shading > 0.85) && (depth == texture(depthtex0, texcoord).r)) {
			shading *= shadow;
		}
		shading = pow(shading*1.125, 8.0);
		shading = clamp(shading, 0.0, 1.0);

		vec3 sunLighting = mix(vec3(0.75,0.9,1.0)*ambient, mix(vec3(1.0,0.9,0.75)*1.25, vec3(0.5,0.75,1.0)*4.0, time), shading);
		sunLighting *= clamp(1-(time*1.75), 0.0, 1.0);
		sunLighting *= light.g;
		sunLighting *= 1-(rainStrength/1.25);

		vec3 blockLighting = vec3(1.25, 1.125, 0.75)*light.r*1.25;
		
		color.rgb *= mix(sunLighting, blockLighting, light.r);
	}
}