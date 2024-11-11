const float ambientOcclusionLevel = 0.00; //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
const float	sunPathRotation	= -40.;	//[0. -5. -10. -15. -20. -25. -30. -35. -40. -45. -50. -55. -60. -70. -80. -90.]

const int shadowMapResolution = 4096; //[512 768 1024 1536 2048 3172 4096 8192 16384]
const float shadowDistance = 300.0;		//[32.0 48.0 64.0 96.0 115.0 128.0 150.0 180.0 200.0 225.0 250.0 275.0 300.0 325.0 400.0 500.0] Not linear at all when shadowDistanceRenderMul is set to -1.0, 175.0 is enough for 40 render distance
const float shadowDistanceRenderMul = -1.0; //[-1.0 1.0] Can help to increase shadow draw distance when set to -1.0, at the cost of performance

const float k = 1.8;
const float d0 = 0.04;
const float d1 = 0.61;
float a = exp(d0);
float b = (exp(d1)-a)*150./128.0;

vec4 BiasShadowProjection(in vec4 projectedShadowSpacePosition) {
  float distortFactor = log(length(projectedShadowSpacePosition.xy)+a)*k;
  projectedShadowSpacePosition.xy /= distortFactor;
  return projectedShadowSpacePosition;
}
float calcDistort(vec2 worldpos){
  return (log(length(worldpos)+a)*k);
}
