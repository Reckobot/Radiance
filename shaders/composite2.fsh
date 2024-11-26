#version 330 compatibility
#include "/lib/bloom.glsl"

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
	for (int x = -radius; x < radius; x++){
		average += texture(colortex3, texcoord+vec2((x*dist)/(viewWidth*scale),0)).rgb;
	}
	average /= radius * 1;
	average *= BloomIntensity;
	brightcolor.rgb = average;
#endif

}