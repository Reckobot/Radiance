#version 330 compatibility
#include "/lib/common.glsl"

uniform vec4 entityColor;
uniform int entityId;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec4 OGglcolor;
out vec3 normal;
in vec2 mc_Entity;

flat out int isGrass;
flat out int isFoliage;
flat out int isShadow;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmcoord = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);
	glcolor = vec4(gl_Color.rgb, gl_Color.a);
	OGglcolor = glcolor;
	#ifdef AMBIENT_OCCLUSION
		glcolor.rgb *= clamp(pow(pow(gl_Color.a, 1.1), AMBIENT_OCCLUSION_STRENGTH), 0.0, 1.0);
	#endif
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

	if(entityId == 1) {
		isShadow = 1;
	} else {
		isShadow = 0;
	}
}