#version 330 compatibility
#include "/lib/color.glsl"

#define Bloom
#define BloomIntensity 0.25 //[0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5]
#define BloomRadius 2 //[1 2 3 4 5 6 7 8]

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 0,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 brightcolor;

void main() {
	color = texture(colortex0, texcoord);
	brightcolor = texture(colortex3, texcoord);

#ifdef Bloom
	float scale = 0.5;
	vec3 average = vec3(0,0,0);
	int radius = BloomRadius;
	int dist = 1;
	for (int y = -radius; y < radius; y++){
		average += texture(colortex3, texcoord+vec2(0,(y*dist)/(viewHeight*scale))).rgb;
	}
	average /= radius * 1;
	average *= BloomIntensity;
	brightcolor.rgb = average;
	color.rgb += brightcolor.rgb;
#endif

}