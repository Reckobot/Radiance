#version 330 compatibility
#include "/lib/color.glsl"

uniform sampler2D gtexture;
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 cameraPosition;
uniform vec3 skyColor;

uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec4 glcolor;

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

/* RENDERTARGETS: 0,9 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 skybuffer;

void main() {
	vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
	pos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz;

	if (pos.y >= 0){
		color = texture(gtexture, texcoord) * glcolor;
		if (color.a < alphaTestRef) {
			discard;
		}
		skybuffer = color * clamp(rgb2hsv(skyColor).z, 0.25, 1.0);
	}
}