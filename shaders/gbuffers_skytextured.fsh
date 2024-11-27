#version 330 compatibility
#include "/lib/color.glsl"

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
	color.rgb /= 2;
}