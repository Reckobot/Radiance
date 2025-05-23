#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
	vec3 godrayColor;
	#ifdef WARM_COLORS
		godrayColor = getLuminance(skyColor)*(vec3(1.25,1.125,1.0)*1.75);
	#else
		godrayColor = getLuminance(skyColor)*(vec3(1.0)*1.75);
	#endif
	if(isEyeInWater != 0) {
		godrayColor *= vec3(0.25, 0.5, 1.0);
	}
	float depth = texture(depthtex0, texcoord).r;
	float depth1 = texture(depthtex1, texcoord).r;

	if(depth >= 1.0) {
		#ifdef DISTANT_HORIZONS
			depth = texture(dhDepthTex0, texcoord).r;
			depth1 = texture(dhDepthTex1, texcoord).r;
		#endif
	}
	
	vec4 fog = texture(colortex6, texcoord);

	float godray = 0.0;
	int count = 1;
	int radius = 4;
	for(int y = -radius; y <= radius; y++) {
			float sampl = texture(colortex5, texcoord+vec2(0.0, y/viewHeight)).r;
			godray += sampl;
			count++;
	}
	godray /= count;

	#ifdef FOG
		color.rgb = mix(color.rgb, fog.rgb, fog.a);
	#endif
	color.rgb = mix(color.rgb, godrayColor, godray);

	if(isEyeInWater != 0 && depth1 >= 1.0) {
		color.rgb = mix(color.rgb, mix(texture(colortex7, texcoord).rgb*4, color.rgb, 0.85), getLuminance(texture(colortex7, texcoord).rgb));
	}

	color.rgb = BSC(color.rgb, BRIGHTNESS, SATURATION, CONTRAST);
	color.rgb = pow(color.rgb, vec3(GAMMA));
}