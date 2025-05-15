#version 330 compatibility
#extension GL_ARB_shader_storage_buffer_object : enable
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
	vec3 godrayColor = getLuminance(skyColor)*(vec3(1.25,1.125,1.0)*1.5);
	if(isEyeInWater != 0) {
		godrayColor *= vec3(0.5, 0.75, 1.0);
	}
	float depth = texture(depthtex0, texcoord).r;
	float depth1 = texture(depthtex1, texcoord).r;
	vec4 fog = texture(colortex6, texcoord);

	float godray = 0.0;
	int count = 1;
	int radius = 4;
	for(int y = -radius; y <= radius; y++) {
		if(texture(depthtex0, texcoord+vec2(0.0, y/viewHeight)).r < 1.0) {
			float sample = texture(colortex5, texcoord+vec2(0.0, y/viewHeight)).r;
			godray += sample;
			count++;
		}
	}
	godray /= count;

	color.rgb = mix(color.rgb, fog.rgb, fog.a);
	if(depth < 1.0) {
		color.rgb = mix(color.rgb, godrayColor, godray);
	}

	if(isEyeInWater != 0 && depth1 >= 1.0) {
		color.rgb = mix(color.rgb, mix(texture(colortex7, texcoord).rgb*4, color.rgb, 0.85), getLuminance(texture(colortex7, texcoord).rgb));
	}
}