#version 330 compatibility
#extension GL_ARB_shader_storage_buffer_object : enable
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D depthtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0,5 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 godrayBuffer;

void main() {
	color = texture(colortex0, texcoord);
	vec3 godrayColor = getLuminance(skyColor)*(vec3(1.25,1.125,1.0)*1.75);
	if(isEyeInWater != 0) {
		godrayColor *= vec3(0.25, 0.5, 1.0);
	}
	float depth = texture(depthtex0, texcoord).r;
	vec4 fog = texture(colortex6, texcoord);

	float godray = 0.0;
	int count = 1;
	int radius = 4;
	for(int x = -radius; x <= radius; x++) {
		if(texture(depthtex0, texcoord+vec2(x/viewWidth, 0.0)).r < 1.0) {
			float sample = texture(colortex5, texcoord+vec2(x/viewWidth, 0.0)).r;
			godray += sample;
			count++;
		}
	}
	godray /= count;

	godrayBuffer = vec4(godray);
}