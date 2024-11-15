#define ShadowResolution 4096 //[128 256 512 1024 2048 4096 8192 16384]
#define ShadowDistance 200 //[50 100 200 300 400 500 600]
#define HardwareFiltering true //[true false]
const int shadowMapResolution = ShadowResolution;
const float shadowDistance = ShadowDistance;
const bool shadowHardwareFiltering = HardwareFiltering;
#define SHADOW_QUALITY 2
#define SHADOW_SOFTNESS 1

vec3 distortShadowClipPos(vec3 shadowClipPos){
    float distortionFactor = length(shadowClipPos.xy); // distance from the player in shadow clip space
    distortionFactor += 0.1; // very small distances can cause issues so we add this to slightly reduce the distortion
    
    shadowClipPos.xy /= distortionFactor;
    shadowClipPos.z *= 0.5; // increases shadow distance on the Z axis, which helps when the sun is very low in the sky
    return shadowClipPos;
}