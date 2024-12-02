#version 330 compatibility
#include "/lib/color.glsl"
#include "/lib/tonemap.glsl"

#define BRIGHTNESS 1.2 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SATURATION 0.9 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define CONTRAST 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define COLORTEMP -0.25 //[-2.0 -1.75 -1.5 -1.25 -1.0 -0.75 -0.5 -0.25 0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]

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
	color.rgb = pow(color.rgb, vec3(1.0/2.2));

	color.rgb = ContrastSaturationBrightness(color.rgb, 1.0, SATURATION, CONTRAST)*BRIGHTNESS;
	color.rgb = vec3(color.r + (COLORTEMP*0.1), color.g, color.b - (COLORTEMP*0.05));
	color.rgb = tonemap(color.rgb);
}