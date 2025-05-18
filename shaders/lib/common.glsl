#define RADIANCE 0 //[0]
#define AMBIENT 0.25 //[0.0 0.1 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.75 0.8 0.9 1.0]
#define SHADOW_PIXELATION 16 //[1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192]
#define GODRAYS
#define GODRAY_TRANSITION 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]
#define GODRAY_INTENSITY 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0]
#define GODRAY_MINIMUM 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0]
#define FOG

#define SHADOW_RESOLUTION 4096 //[128 256 512 1024 2048 4096 8192 16384]
#define SHADOW_DISTANCE 100 //[100 200 300 400 500 600 700 800 900 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000]

const int shadowMapResolution = SHADOW_RESOLUTION;
const int shadowDistance = SHADOW_DISTANCE;
const float sunPathRotation = 45.0;

uniform mat4 gbufferProjection;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;
uniform vec3 sunPosition;
uniform float far;
uniform vec3 cameraPosition;
uniform float sunAngle;
uniform float shadowAngle;
uniform vec3 skyColor;
uniform int frameCounter;
uniform float frameTimeCounter;
uniform int isEyeInWater;

uniform float viewWidth;
uniform float viewHeight;
uniform ivec2 eyeBrightness;
uniform float frameTime;
uniform vec3 playerLookVector;
uniform float rainStrength;
uniform float screenBrightness;

uniform sampler2D dhDepthTex0;
uniform sampler2D dhDepthTex1;
uniform mat4 dhProjection;
uniform mat4 dhProjectionInverse;
uniform mat4 dhPreviousProjection;
uniform int dhRenderDistance;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
    vec4 homPos = projectionMatrix * vec4(position, 1.0);
    return homPos.xyz / homPos.w;
}

vec3 distortShadowClipPos(vec3 shadowClipPos){
    float distortionFactor = length(shadowClipPos.xy);
    distortionFactor += 0.1;

    shadowClipPos.xy /= distortionFactor;
    shadowClipPos.z *= 0.25;
    return shadowClipPos;
}

vec3 viewToShadowScreen(vec3 viewPos, bool pixelate, float depth, float depth1, vec3 normal, bool isGodRays, bool notBlock, vec2 texcoord) {
    vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	if(!isGodRays) {
        float normalOffet = 0.075;
        if(notBlock) {
            normalOffet *= 3;
        }
        feetPlayerPos += ((normal-0.5)/0.5)*normalOffet;
    }
    if((pixelate)&&(depth != texture(dhDepthTex0, texcoord).r)) {
		feetPlayerPos += cameraPosition;
        float pixelation = SHADOW_PIXELATION;
        if(isGodRays && pixelation >= 4) {
            pixelation /= 4;
        }
		feetPlayerPos *= pixelation;
		feetPlayerPos = vec3(ivec3(feetPlayerPos))/pixelation;
		feetPlayerPos -= cameraPosition;
	}
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	float bias = clamp(length(viewPos)*0.000075, 0.0001, 1.0);
    if(notBlock) {
        bias *= 4.0;
    }
	shadowClipPos.z -= bias;
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
	vec3 shadowNDCPos = shadowClipPos.xyz / shadowClipPos.w;
	vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
    return shadowScreenPos;
}

float getLuminance(vec3 rgb) {
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    return dot(rgb, W);
}

float IGN(vec2 coord, int frame, vec2 res)
{
    float x = float(coord.x * res.x) + 5.588238 * float(frame);
    float y = float(coord.y * res.y) + 5.588238 * float(frame);
    return mod(52.9829189 * mod(0.06711056*float(x) + 0.00583715*float(y), 1.0), 1.0);
}