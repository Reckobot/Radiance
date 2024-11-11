const mat3 ACESInputMat =
mat3(0.59719, 0.35458, 0.04823,
    0.07600, 0.90834, 0.01566,
    0.02840, 0.13383, 0.83777
);

// ODT_SAT => XYZ => D60_2_D65 => sRGB
const mat3 ACESOutputMat =
mat3( 1.60475, -0.53108, -0.07367,
    -0.10208,  1.10813, -0.00605,
    -0.00327, -0.07276,  1.07602
);
vec3 RRTAndODTFit(vec3 v)
{
    vec3 a = v * (v + 0.0245786f) - 0.000090537f;
    vec3 b = v * (0.983729f * v + 0.4329510f) + 0.238081f;
    return a / b;
}



//faster and actually more precise than pow 2.2
vec3 toLinear(vec3 sRGB){
	return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}

float luma(vec3 color) {
	return dot(color,vec3(0.299, 0.587, 0.114));
}
vec3 LinearTosRGB(in vec3 color)
{
    vec3 x = color * 12.92f;
    vec3 y = 1.055f * pow(clamp(color,0.0,1.0), vec3(1.0f / 2.4f)) - 0.055f;

    vec3 clr = color;
    clr.r = color.r < 0.0031308f ? x.r : y.r;
    clr.g = color.g < 0.0031308f ? x.g : y.g;
    clr.b = color.b < 0.0031308f ? x.b : y.b;

    return clr;
}
vec3 ToneMap_Hejl2015(in vec3 hdr)
{
    vec4 vh = vec4(hdr*0.8, 3.0);	//0
    vec4 va = (1.75 * vh) + 0.05;	//0.05
    vec4 vf = ((vh * va + 0.004f) / ((vh * (va + 0.55f) + 0.0491f))) - 0.0821f+0.000633604888;	//((0+0.004)/((0*(0.05+0.55)+0.0491)))-0.0821
    return pow(vf.xyz / vf.www,vec3(1.0/2.223));
}
vec3 ACESFitted(vec3 color)
{
    color =  color/0.6 * ACESInputMat;

    // Apply RRT and ODT
    color = RRTAndODTFit(color);

    color = clamp( color * ACESOutputMat ,0.0,1.0);


    return pow(color,vec3(1.0/2.223));
}
float A = 0.2;
float B = 0.25;
float C = 0.10;
float D = 0.35;
float E = 0.02;
float F = 0.3;
vec3 Uncharted2Tonemap(vec3 x)
{
	x*= 4.;
   return pow(((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F,vec3(1.0/2.2));
}

vec3 reinhard(vec3 x){
x *= 1.66;
return LinearTosRGB(x/(1.0+x));
}

vec3 ACESFilm( vec3 x )
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
	vec3 r = (x*(a*x+b))/(x*(c*x+d)+e);

    return pow(r, vec3(1.0/2.22333));
}

vec3 invACESFilm( vec3 r )
{
	r = toLinear(r);
	return (0.00617284 - 0.121399*r - 0.00205761 *sqrt(9 + 13702*r - 10127*r*r))/(-1.03292 + r);
}
