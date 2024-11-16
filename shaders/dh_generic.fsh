#version 330 compatibility
#include "/lib/dh.glsl"
#include "/lib/color.glsl"
#include "/lib/settings.glsl"

uniform sampler2D depthtex0;
uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;
uniform mat4 gbufferProjectionInverse;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

void main() {
	discard;
}