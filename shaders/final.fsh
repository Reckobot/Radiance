#version 330 compatibility
#include "/lib/color.glsl"
#include "/lib/tonemap.glsl"
#include "/lib/dh.glsl"
#include "/lib/settings.glsl"

#define BRIGHTNESS 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.25 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SATURATION 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define CONTRAST 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define COLORTEMP 0.0 //[-2.0 -1.75 -1.5 -1.25 -1.0 -0.75 -0.5 -0.25 0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex9;
uniform sampler2D colortex11;
uniform vec3 skyColor;
uniform vec3 cameraPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform float far;
uniform int isEyeInWater;

uniform mat4 gbufferProjectionInverse;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

void main() {
	float depth = texture(depthtex1, texcoord).r;
	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

	float lightness = (rgb2hsv(skyColor).z);

	color = texture(colortex0, texcoord);
	
	#ifdef SSGI
		color.rgb += texture(colortex6, texcoord).rgb * lightness;
	#endif
	#ifdef SSR
	float refl = texture(colortex5, texcoord).g;
	if (refl >= 0.1+(230/255)){
		vec3 reflection = (texture(colortex7, texcoord).rgb);
		reflection = mix(reflection, color.rgb, 1-clamp(refl, 0.0, 1.0));
		color.rgb *= reflection;
	}
	#endif

	#ifndef DISTANTHORIZONS
		#ifdef DISTANTFOG
		if (isEyeInWater == 0){
			float fogdensity = 10;
			//fog
			if ((fogdensity > 0)){
				float dist = length(viewPos)/far;
				float fogFactor = exp(-fogdensity * (1.0 - dist));
				color.rgb = mix(color.rgb, ((texture(colortex9, texcoord).rgb)*3.0)*clamp(exp(cameraPosition.y-50), 0.0, 1.0), clamp(fogFactor, 0.0, 1.0));
			}
		}
		#endif
	#endif

	vec3 fogcolor;

	if (isEyeInWater == 1){
	}

	if (isEyeInWater == 0){
		color.rgb += texture(colortex4, texcoord).rgb;
	}
	color.rgb = pow(color.rgb, vec3(1.0/2.2));

	color.rgb = ContrastSaturationBrightness(color.rgb, 1.0, SATURATION, CONTRAST)*BRIGHTNESS;
	color.rgb = vec3(color.r + (COLORTEMP*0.1), color.g, color.b - (COLORTEMP*0.05));
	color.rgb = tonemap(color.rgb);

	if (logicalHeightLimit == 256){
		color.rgb = ContrastSaturationBrightness(color.rgb, 0.5, 0.0, 1.0);
	}
}