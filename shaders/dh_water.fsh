#version 330 compatibility
#include "/lib/dh.glsl"
#include "/lib/color.glsl"

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
	#ifdef DISTANTHORIZONS
		float depth = texture(depthtex0, vec2(gl_FragCoord.xy)/vec2(viewWidth,viewHeight)).r;
		if (depth < 1){
			discard;
		}
		
		color = texture(gtexture, texcoord) * glcolor;
		color *= texture(lightmap, lmcoord);
		if (color.a < alphaTestRef) {
			discard;
		}

		lightmapData = vec4(lmcoord, 0.0, 1.0);
		encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);

		color.rgb = pow(color.rgb, vec3(4.2));
		color.rgb = ContrastSaturationBrightness(color.rgb, 1.0, 0.1, 1.0);
	#else
		discard;
	#endif
}