#version 330 compatibility
#include "/lib/common.glsl"

uniform vec4 entityColor;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
in vec2 mc_Entity;

flat out int isGrass;
flat out int isFoliage;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmcoord = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);
	glcolor = vec4(gl_Color.rgb, 1.0);
	glcolor.rgb *= gl_Color.a;
	glcolor.rgb = mix(glcolor.rgb, glcolor.rgb*entityColor.rgb, entityColor.a);
	normal = gl_NormalMatrix * gl_Normal;
	normal = mat3(gbufferModelViewInverse) * normal;

	if(mc_Entity.x == 102) {
		isGrass = 1;
	} else {
		isGrass = 0;
	}

	if(mc_Entity.x == 100 || mc_Entity.x == 101 || mc_Entity.x == 102) {
		isFoliage = 1;
	} else {
		isFoliage = 0;
	}
}