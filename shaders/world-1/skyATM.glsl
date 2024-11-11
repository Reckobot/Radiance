#define DRAW_SUN //if not using custom sky



vec3 getFogColor(vec3 sVector,float cosT) {
	return vec3(0.5,0,0)*1.;
}

vec3 getSkyColor(vec3 sVector, float sunInt,float moonInt,float cosT) {

	//gradient
	vec3 grad3 = getFogColor(sVector,cosT);

	return grad3;

}




vec3 calcAtmFog(in vec3 fogClr,in vec3 fposition,in vec3 color, float sunInt,float moonInt){

	float d = length(fposition);
	float fogFactorIn = exp(-d/240.);

	
	return mix(fogClr*0.4,color,fogFactorIn);
}