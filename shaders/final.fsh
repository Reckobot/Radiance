#version 330 compatibility
#include /lib/color.glsl

uniform sampler2D colortex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(1.0/2.2));

	color.rgb = (saturation(color.rgb, 0.9))*1.0;
}