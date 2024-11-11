//using white noise for color dithering : gives a somewhat more "filmic" look when noise is visible
float nrand( vec2 n )
{
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}
float interleaved_gradientNoise(){
	return fract(52.9829189*fract(0.06711056*gl_FragCoord.x + 0.00583715*gl_FragCoord.y));
}
float R2_dither(){
	vec2 alpha = vec2(0.75487765, 0.56984026);
	return fract(alpha.x * gl_FragCoord.x + alpha.y * gl_FragCoord.y);
}
#define fsign(a)  (clamp((a)*1e35,0.,1.)*2.-1.)
float triangularize(float dither)
{
    float center = dither*2.0-1.0;
    dither = center*inversesqrt(abs(center));
    return clamp(dither-fsign(center),0.0,1.0);
}

vec3 fp10Dither(vec3 color){
	float dither = triangularize(R2_dither());
	const vec3 mantissaBits = vec3(6.,6.,5.);
	vec3 exponent = floor(log2(color));
	return color + dither*exp2(-mantissaBits)*exp2(exponent);
}

vec3 fp16Dither(vec3 color,vec2 tc01){
	float dither = R2_dither();
	const vec3 mantissaBits = vec3(10.);
	vec3 exponent = floor(log2(color));
	return color + dither*exp2(-mantissaBits)*exp2(exponent);
}

vec3 int8Dither(vec3 color,vec2 tc01){
	float dither = triangularize(R2_dither());
	return color + dither*exp2(-8.0);
}

vec3 int10Dither(vec3 color,vec2 tc01){
	float dither = R2_dither();
	return color + dither*exp2(-10.0);
}

vec3 int16Dither(vec3 color,vec2 tc01){
	float dither = R2_dither();
	return color + dither*exp2(-16.0);
}
