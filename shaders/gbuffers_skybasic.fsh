#version 330 compatibility
#include "/lib/color.glsl"
#include "/lib/dh.glsl"

uniform int renderStage;
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;

uniform vec3 fogColor;
vec3 defFog = fogColor;
vec3 fog;
uniform vec3 skyColor;
vec3 defSky = (saturation(skyColor, 4.5))*1.5;

in vec4 glcolor;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(defSky * (rgb2hsv(skyColor).z), fog * (rgb2hsv(skyColor).z), fogify(max(upDot+1.5, -1), 1.5));
}

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	if (renderStage == MC_RENDER_STAGE_STARS) {
		color = glcolor;
	} else {
		vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		fog = vec3(1.75,1.35,1);
		fog *= 4;
		fog.rgb = saturation(fog.rgb, 3.75 - (rgb2hsv(defSky).z));
		color = vec4(calcSkyColor(normalize(pos)), 1.0);
		color.rgb = saturation(color.rgb, 0.75);
		color.rgb *= 0.25;
	}
}
