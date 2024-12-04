#version 330 compatibility
#include "/lib/color.glsl"

uniform int renderStage;
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 skyColor;

in vec4 glcolor;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(ContrastSaturationBrightness(skyColor, 1.0, 0.5, 1.0), ContrastSaturationBrightness(fogcolor, 0.75, 0.75, 1.0), fogify(max(upDot+0.25, 0.0), 0.25));
}

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

/* RENDERTARGETS: 0,9 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 skybuffer;

void main() {
	float skyBrightness = (rgb2hsv(skyColor.rgb)).z;
	float lightness = skyBrightness;
	
	if (renderStage == MC_RENDER_STAGE_STARS) {
		color = glcolor;
	} else {
		vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		color += vec4(calcSkyColor(normalize(pos)), 1.0);
	}
	color = vec4(pow(color.rgb, vec3(6.5)), 1) * lightness;
	skybuffer = color;
}
