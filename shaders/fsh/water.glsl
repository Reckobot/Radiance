#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D depthtex0;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

flat in int isGrass;

/* RENDERTARGETS: 0,3,4,2,8,9 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normalBuffer;
layout(location = 2) out vec4 lightBuffer;
layout(location = 3) out vec4 cloudBuffer;
layout(location = 4) out vec4 nonBlockBuffer;
layout(location = 5) out vec4 grassBuffer;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	lightBuffer = vec4(lmcoord, 0.0, 1.0);
	if (color.a < alphaTestRef) {
		discard;
	}
	vec3 finalNormal = normal * 0.5 + 0.5;

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	normalBuffer = vec4(finalNormal, 1.0);
	cloudBuffer = vec4(vec3(0.0), 1.0);
	nonBlockBuffer = vec4(vec3(0.0), 1.0);

	vec2 screenTexCoord = vec2(gl_FragCoord.xy)/vec2(viewWidth,viewHeight);

	float depth = texture(depthtex0, screenTexCoord).r;
	vec3 NDCPos = vec3(screenTexCoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

	float dhdepth = texture(dhDepthTex0, screenTexCoord).r;
	vec3 dhNDCPos = vec3(screenTexCoord.xy, dhdepth) * 2.0 - 1.0;
	vec3 dhviewPos = projectAndDivide(dhProjectionInverse, dhNDCPos);

	if(((length(dhviewPos) < length(viewPos))&&(depth >= 1.0))&&(isEyeInWater != 1)) {
		discard;
	}

	grassBuffer = vec4(vec3(isGrass), 1.0);
}