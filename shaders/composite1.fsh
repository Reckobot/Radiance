#version 330 compatibility
#include "/lib/color.glsl"
#include "/lib/settings.glsl"
#include "/lib/rt.glsl"

uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex5;
uniform sampler2D colortex9;
uniform sampler2D colortex10;

uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 skyColor;
uniform float far;

in vec2 texcoord;

/* RENDERTARGETS: 7 */
layout(location = 0) out vec4 reflection;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(ContrastSaturationBrightness(skyColor, 1.0, 0.5, 1.0), ContrastSaturationBrightness(fogcolor, 0.75, 0.75, 1.0), fogify(max(upDot+0.25, 0.0), 0.25));
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

		float start = exp(length(viewPos)/12);

		for (int i = 0; i < steps; i++){
			vec3 rayPos = viewPos + (reflectRay*SSR_DIST*i);
			vec3 rayscreenPos = viewtoscreen(rayPos);
			vec2 raycoord = rayscreenPos.xy;
			vec3 rayogPos = projectAndDivide(gbufferProjectionInverse, (vec3(raycoord, texture(depthtex0, raycoord).r) * 2.0 - 1.0));
			
			vec3 raypbr = texture(colortex5, raycoord).rgb;
			float rayspec = raypbr.r;
			float rayrefl = raypbr.g;

			vec3 newrayPos;
			if ((distance(rayPos, rayogPos) <= (SSR_DIST))&&((lessThanEqual(raycoord, vec2(1,1))==true)&&(greaterThanEqual(raycoord, vec2(0,0))==true))){
				if (distance(rayPos, viewPos) > (SSR_DIST * start)){	
					newrayPos = rayogPos;
					rayscreenPos = viewtoscreen(newrayPos);
					raycoord = rayscreenPos.xy;
					vec3 sampl = ContrastSaturationBrightness(texture(colortex10, raycoord).rgb, 1.0, 0.7, 1.0);
					reflection.rgb += sampl.rgb * 8;
					break;
				}
			}
		}
		if (reflection.rgb == vec3(0)){
			reflection.rgb = vec3(1);
		}
	}
	#endif
}