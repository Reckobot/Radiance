#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

	float depth = texture(depthtex0, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

	float dist = length(viewPos) / far;
	if(texture(colortex2, texcoord) == vec4(1.0)) {
		dist /= 3;
	}
	float fogFactor = exp(-4 * (0.85 - dist));

	if(depth < 1.0) {
		color.rgb = mix(color.rgb, texture(colortex1, texcoord).rgb, clamp(fogFactor, 0.0, 1.0));
	}
}