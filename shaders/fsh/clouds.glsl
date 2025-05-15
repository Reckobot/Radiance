#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,2,3,4 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 cloudBuffer;
layout(location = 2) out vec4 normalBuffer;
layout(location = 3) out vec4 lightBuffer;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	lightBuffer = texture(lightmap, lmcoord);
	lightBuffer.a = 1.0;
	lightBuffer.rg *= 0.475;
	if (color.a < alphaTestRef) {
		discard;
	}
	color.a = 1.0;

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	normalBuffer = vec4(1.0);
	cloudBuffer = vec4(1.0);
}