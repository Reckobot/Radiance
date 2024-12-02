#define SHADOWRES 4096 //[128 256 512 1024 2048 4096 8192 16384]
#define SHADOWDIST 200 //[50 100 200 300 400 500 600]
#define HARDWAREFILTERING true //[true false]
const int shadowMapResolution = SHADOWRES;
const float shadowDistance = SHADOWDIST;
const bool shadowHardwareFiltering = HARDWAREFILTERING;
#define SHADOW_QUALITY 2
#define SHADOW_SOFTNESS 1

vec3 distortShadowClipPos(vec3 shadowClipPos){
    float distortionFactor = length(shadowClipPos.xy); // distance from the player in shadow clip space
    distortionFactor += 0.1; // very small distances can cause issues so we add this to slightly reduce the distortion
    
    shadowClipPos.xy /= distortionFactor;
    shadowClipPos.z *= 0.25; // increases shadow distance on the Z axis, which helps when the sun is very low in the sky
    return shadowClipPos;
}