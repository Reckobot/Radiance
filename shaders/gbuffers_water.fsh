#version 330 compatibility
#include "/lib/settings.glsl"
#include "/lib/color.glsl"

uniform sampler2D depthtex0;
uniform sampler2D normals;
uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in mat3 tbnmatrix;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

vec3 getnormalmap(vec2 texcoord){
	vec3 normalmap = texture(normals, texcoord).rgb;
	normalmap = normalmap * 2 - 1;
	normalmap.z = sqrt(1 - dot(normalmap.xy, normalmap.xy));
	return tbnmatrix * normalmap;
}

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}

	lightmapData = vec4(lmcoord, 0.0, 1.0);

#ifdef FancyWater
	#ifdef LabPBR
		encodedNormal = vec4(getnormalmap(texcoord) * 1 + 0.5, 1.0);
	#else
		encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
	#endif
	color.w *= 0.75;
	color.rgb *= 0.75;
	color.rgb = pow(color.rgb, vec3(1));
	
	if (rgb2hsv(color.rgb).z > 0.45){
		color.rgb *= 1.5;
	}
	if (rgb2hsv(color.rgb).z > 0.75){
		color.rgb *= 1.5;
	}
	color.rgb *= 1.5;
#endif
}