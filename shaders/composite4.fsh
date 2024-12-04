#version 330 compatibility
#include "/lib/settings.glsl"

uniform sampler2D colortex7;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 7 */
layout(location = 0) out vec4 reflection;

void main() {
	float scale = SSR_RES;
	vec3 average = vec3(0,0,0);
	int radius = 2;
	int dist = 1;
	for (int y = -radius; y < radius; y++){
		average += texture(colortex7, texcoord+vec2(0,(y*dist)/(viewHeight*scale))).rgb;
	}
	average /= radius * 2;
	reflection.rgb = average;
}