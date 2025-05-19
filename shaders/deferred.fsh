#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor1;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	float ambient = AMBIENT;

	color = texture(colortex0, texcoord);
	float depth = texture(depthtex0, texcoord).r;
	float depth1 = texture(depthtex1, texcoord).r;
	mat4 projectionInverse = gbufferProjectionInverse;

	if(depth >= 1.0) {
		#ifdef DISTANT_HORIZONS
			depth = texture(dhDepthTex0, texcoord).r;
			depth1 = texture(dhDepthTex1, texcoord).r;
			projectionInverse = dhProjectionInverse;
		#endif
	}

	vec4 light = texture(colortex4, texcoord);

	vec3 normal = texture(colortex3, texcoord).rgb;
	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(projectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 worldPos = feetPlayerPos+cameraPosition;

	bool pixelate = false;
	if(dot(normal, vec3(ivec3(normal))) > 0.9) {
		pixelate = true;
	}
	if(texture(colortex8, texcoord).rgb != vec3(0.0)) {
		pixelate = false;
	}

	bool notBlock = false;
	notBlock = bool(int(texture(colortex8, texcoord).r));
	vec3 shadowScreenPos = viewToShadowScreen(viewPos, pixelate, depth, depth1, normal, false, notBlock, texcoord);

	float shadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec3 sunVector = normalize(sunPosition);

	bool isDayTime = false;

	if(shadowAngle == sunAngle) {
		isDayTime = true;
	}

	float time;
	if(isDayTime) {
		time = 1-(abs(shadowAngle - 0.25)*4);
	} else {
		time = 1-(abs(shadowAngle - 0.75)*4);
	}
	time *= 8.0;
	time = clamp(time, 0.0, 1.0);

	if(depth < 1) {
		float shading = clamp(dot(normal, worldLightVector), 0.0, 1.0);
		shading = pow(shading*1.25, 8.0);

		if((shading > 0)&&(depth != texture(dhDepthTex0, texcoord).r)) {
			shading *= shadow;
		}
		shading = clamp(shading, 0.0, 1.0);

		vec3 sunLight = vec3(1.0,0.9,0.75)*1.25;
		vec3 moonLight = vec3(0.5,0.75,1.0)*0.75;
		vec3 ambientLight = vec3(0.5,0.75,1.0) * ambient * 2.0;

		vec3 lightMix = mix(moonLight, sunLight, time);

		vec3 sunLighting = mix(ambientLight, lightMix, clamp(shading+(time/4), 0.0, 1.0));

		sunLighting *= clamp(light.g, 0.0, 1.0);
		sunLighting *= 1-(rainStrength/1.25);

		if(!isDayTime) {
			sunLighting *= clamp(time, 0.25, 1.0);
		}

		vec3 blockLighting = vec3(1.25, 1.125, 0.75)*light.r*1.25;
		
		color.rgb *= mix(sunLighting, blockLighting, light.r);
	}
}