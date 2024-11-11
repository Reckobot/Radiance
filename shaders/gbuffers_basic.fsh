#version 120

#include "lib/shadow_param.glsl"

varying vec4 lmtexcoord;
varying vec4 color;
varying vec4 shadowPos;

uniform sampler2D texture;
uniform sampler2D gaux1;
uniform sampler2DShadow shadow;

uniform vec4 lightCol;
uniform vec2 texelSize;

//faster and actually more precise than pow 2.2
vec3 toLinear(vec3 sRGB){
	return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}

/* DRAWBUFFERS:1 */
void main() {
	gl_FragData[0] = color;
	if (gl_FragData[0].a > 0.0 ) {
		vec3 albedo = toLinear(gl_FragData[0].rgb);
		float diffuseSun = shadowPos.w/255.;
		if (diffuseSun > 0.0001 && shadowPos.x < 1e10) {
			float distort = calcDistort(shadowPos.xy);
			vec2 spCoord = shadowPos.xy / distort;
			if (abs(spCoord.x) < 1.0-1.5/shadowMapResolution && abs(spCoord.y) < 1.0-1.5/shadowMapResolution) {
					float diffthresh = 0.0004*512./shadowMapResolution*shadowDistance/45.*distort/diffuseSun;

					vec3 projectedShadowPosition = vec3(spCoord, shadowPos.z) * vec3(0.5,0.5,0.5/3.0) + vec3(0.5,0.5,0.5-diffthresh);
					diffuseSun *= shadow2D(shadow, projectedShadowPosition).x;
			}
		}
		vec3 lightmap = texture2D(gaux1,lmtexcoord.zw*texelSize).xyz;
		vec3 diffuseLight = lightCol.rgb*diffuseSun + lightmap;

		gl_FragData[0].rgb = diffuseLight*albedo;
	}
}
