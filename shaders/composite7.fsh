#version 330 compatibility
#include "/lib/color.glsl"
#include "/lib/tonemap.glsl"
#include "/lib/dh.glsl"
#include "/lib/settings.glsl"
#include "/lib/rt.glsl"

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex7;
uniform sampler2D colortex9;
uniform sampler2D noisetex;
uniform float viewWidth;
uniform float viewHeight;
uniform float far;
uniform vec3 skyColor;
uniform vec3 cameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;

in vec2 texcoord;

/* RENDERTARGETS: 6 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

void main() {
	#ifdef SSGI

	float depth = texture(depthtex1, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

	if (length(viewPos) < (far*SSGI_DIST)){
		vec3 encodedNormal = texture(colortex2, texcoord).rgb;
		vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

	////////////////////////////

		int steps = SSGI_STEPS;
		int samples = SSGI_SAMPLES;
		vec3 vnormal = mat3(gbufferModelView) * normal;
		vec3 sky = ContrastSaturationBrightness(skyColor, 0.25, 2.0, 0.5);
		vec3 average = vec3(0);

		vec3 pbr = texture(colortex5, texcoord).rgb;
		float spec = pbr.r;
		float refl = pbr.g;

		for (int e = 0; e < samples; e++){
			float PI = 3.14159;

			float phi = PI * (sqrt(5) - 1);
			float y = 1 - (e / float(samples - 1)) * 2;
			float radius = sqrt(1 - y * y);

			float theta = phi * e;

			float x = cos(theta) * radius;
			float z = sin(theta) * radius;


			vec3 reflectRay = normalize(vec3(x,y,z) + vnormal);

			float lit = dot(reflectRay, vnormal);
			for (int i = 4; i < steps; i++){
				vec3 rayPos = viewPos + (reflectRay*0.05*i);
				vec3 rayscreenPos = viewtoscreen(rayPos);
				vec2 raycoord = rayscreenPos.xy;
				vec3 rayogPos = projectAndDivide(gbufferProjectionInverse, (vec3(raycoord, texture(depthtex1, raycoord).r) * 2.0 - 1.0));

				vec3 raypbr = texture(colortex5, raycoord).rgb;
				float rayspec = raypbr.r;
				float rayrefl = raypbr.g;

				vec3 newrayPos;
				if ((distance(rayPos, rayogPos) <= 0.1)&&((lessThanEqual(raycoord, vec2(1,1))==true)&&(greaterThanEqual(raycoord, vec2(0,0))==true))){
					if (refl < 1){
						vec3 sample =  texture(colortex0, raycoord).rgb * texture(colortex3, raycoord).rgb;
						sample *= lit;
						sample *= spec*8+0.5;
						sample *= rayrefl+1;
						sample *= 16;
						average += sample;
						break;
					}
				}
			}
		}
		average /= samples*steps;
		color.rgb = average;
	}
	#endif
}