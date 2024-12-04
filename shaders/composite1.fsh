#version 330 compatibility
#include "/lib/color.glsl"
#include "/lib/settings.glsl"
#include "/lib/rt.glsl"

uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex5;

uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 skyColor;

in vec2 texcoord;

/* RENDERTARGETS: 7 */
layout(location = 0) out vec4 reflection;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

void main() {
	#ifdef SSR
	float depth = texture(depthtex0, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

	//ssr
	reflection.rgb = vec3(0);
	vec3 vnormal = mat3(gbufferModelView) * normal;
	float refl = texture(colortex5, texcoord).g;
	if (refl > 0){
		vec3 reflectRay = reflect(normalize(viewPos), vnormal);
		int steps = SSR_STEPS;
		vec3 sky = ContrastSaturationBrightness(skyColor, 0.25, 2.0, 0.5);

		for (int i = 0; i < steps; i++){
			vec3 rayPos = viewPos + (reflectRay*SSR_DIST*i);
			vec3 rayscreenPos = viewtoscreen(rayPos);
			vec2 raycoord = rayscreenPos.xy;
			vec3 rayogPos = projectAndDivide(gbufferProjectionInverse, (vec3(raycoord, texture(depthtex0, raycoord).r) * 2.0 - 1.0));
			
			vec3 raypbr = texture(colortex5, raycoord).rgb;
			float rayspec = raypbr.r;
			float rayrefl = raypbr.g;

			vec3 newrayPos;
			if ((distance(rayPos, rayogPos) <= 0.5)&&((lessThanEqual(raycoord, vec2(1,1))==true)&&(greaterThanEqual(raycoord, vec2(0,0))==true))){
				newrayPos = rayogPos;
				rayscreenPos = viewtoscreen(newrayPos);
				raycoord = rayscreenPos.xy;
				if (texture(colortex5, raycoord).g == 0){
					vec3 sample = texture(colortex0, raycoord).rgb;
					reflection.rgb += sample.rgb * (refl);
					break;
				}
			}
		}
		if (reflection.rgb == vec3(0)){
			reflection.rgb += sky/10;
		}
		reflection.rgb *= 1;
	}
	#endif
}