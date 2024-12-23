#version 330 compatibility
#include "/lib/settings.glsl"
#include "/lib/color.glsl"

uniform sampler2D specular;
uniform sampler2D depthtex0;
uniform sampler2D normals;
uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform vec3 shadowLightPosition;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in mat3 tbnmatrix;

/* RENDERTARGETS: 0,1,2,5,10 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 encodedSpecular;
layout(location = 4) out vec4 original;

vec3 getnormalmap(vec2 texcoord){
	vec3 normalmap = texture(normals, texcoord).rgb;
	normalmap = normalmap * 2 - 1;
	normalmap.z = sqrt(1 - dot(normalmap.xy, normalmap.xy));
	return tbnmatrix * normalmap;
}

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color.rgb = ContrastSaturationBrightness(color.rgb, 1.75, 0.0, 1.5);
	color.a = 0.75;

	original = texture(gtexture, texcoord) * glcolor;
	original.rgb = ContrastSaturationBrightness(original.rgb, 1.5, 0.0, 1.0);
	original = vec4(pow(original.rgb, vec3(2.2)), 1);
	original *= rgb2hsv(vec3(lmcoord, 0.0)).z;

	if (color.a < alphaTestRef) {
		discard;
	}

	encodedSpecular = texture(specular, texcoord);
	if (encodedSpecular == vec4(0)){
		encodedSpecular = vec4(1);
	}

	lightmapData = vec4(lmcoord, 0.0, 1.0);

	#if MATERIAL == 3
		encodedNormal = vec4(getnormalmap(texcoord) * 1 + 0.5, 1.0);
	#else
		encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
	#endif
}