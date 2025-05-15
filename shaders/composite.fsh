#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	float ambient = AMBIENT;

	color = texture(colortex0, texcoord);
	float depth = texture(depthtex0, texcoord).r;
	float depth1 = texture(depthtex1, texcoord).r;
	vec3 light = texture(colortex4, texcoord).rgb;

	vec3 normal = texture(colortex3, texcoord).rgb;
	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	feetPlayerPos += normal*0.02;
	if(dot(normal, vec3(ivec3(normal))) > 0.9) {
		feetPlayerPos += cameraPosition;
		feetPlayerPos *= SHADOW_PIXELATION;
		feetPlayerPos = vec3(ivec3(feetPlayerPos))/SHADOW_PIXELATION;
		feetPlayerPos -= cameraPosition;
	}
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	float bias = 0.00025;
	if(depth != depth1) {
		bias *= 2.0;
	}
	shadowClipPos.z -= bias;
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
	vec3 shadowNDCPos = shadowClipPos.xyz / shadowClipPos.w;
	vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;

	float shadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	float shading = dot(normal, worldLightVector);
	shading = pow(shading*1.25, 6.0);
	shading *= shadow;

	float time = clamp(abs(sunAngle - shadowAngle), 0.0, 1.0);

	if(depth < 1.0) {
		color.rgb *= clamp(pow(light.r*2.0, 2.0), 0.0, 1.0);
		color.rgb *= clamp(pow(light.g*2.0, 2.0), 0.0, 1.0);
		shading += (light.r+light.g)*time;
		shading = clamp(pow(shading*1.25, 4.0), ambient, 1.0);
		color.rgb *= mix(vec3(0.75,0.9,1.0)*0.5, mix(vec3(1.0,0.9,0.75)*1.25, vec3(0.5,0.75,1.0)*2.0, time)*mix(vec3(light.r*2, light.g*1.25, 0.5), vec3(1.0), 1-abs(sunAngle - shadowAngle)), shading);
	}
}