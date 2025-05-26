#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D depthtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0,5 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 godrayBuffer;

void main() {
	color = texture(colortex0, texcoord);
	vec3 godrayColor = getLuminance(skyColor)*(vec3(1.25,1.125,1.0)*1.75);
	if(isEyeInWater == 1) {
		godrayColor *= vec3(0.25, 0.5, 1.0);
	}
	float depth = texture(depthtex0, texcoord).r;

	if(depth >= 1.0) {
		#ifdef DISTANT_HORIZONS
			depth = texture(dhDepthTex0, texcoord).r;
		#endif
	}

	float godray = 0.0;
	int count = 1;
	int radius = 4;
	for(int x = -radius; x <= radius; x++) {
			float sampl = texture(colortex5, texcoord+vec2(x/viewWidth, 0.0)).r;
			godray += sampl;
			count++;
	}
	godray /= count;

	godrayBuffer = vec4(godray);
}