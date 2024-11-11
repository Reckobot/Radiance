	const float PI = 3.14159265359;
	
vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
vec3 toScreenSpace(vec3 p) {
    vec3 p3 = p * 2. - 1.;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}
vec3 toScreenSpaceVector(vec3 p) {
    vec3 p3 = p * 2. - 1.;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return normalize(fragposition.xyz);
}

float fastAcos(float inX)
{
	const float PI = 3.14159265359;
	const float C0 = 1.56467;
	const float C1 = -0.155972;

    float x = abs(inX);
    float res = C1 * x + C0; 
    res *= sqrt(1.0f - x);

    return (inX >= 0) ? res : PI - res; 
}
//using smoothstep caused a crash on my intel laptop gpu, smoothstep is not hardware accelerated anyways
float smStep (float edge0,float edge1,float x) {
	float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
	return t * t * (3.0 - 2.0 * t); 
}
//cubic approximation, should be faster than pow 2.2
vec3 toLinearFast(vec3 sRGB){
	return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}