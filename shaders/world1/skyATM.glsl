

vec3 getFogColor(vec3 sVector,float cosT) {
	return pow(vec3(255,255,255)/255.,vec3(2.2))*0.3;
}

vec3 getSkyColor(vec3 sVector, float sunInt,float moonInt,float cosT) {

	//gradient
	vec3 grad3 = getFogColor(sVector,cosT);


	return grad3;

}


vec3 calcAtmFog(in vec3 fogClr,in vec3 fposition,in vec3 color, float sunInt,float moonInt){
	vec3 worldposition = (mat3(gbufferModelViewInverse) * fposition.xyz + gbufferModelViewInverse[3].xyz);
		worldposition.y = worldposition.y;
	float d = length(fposition);

	worldposition /= d;
	float fogFactorIn = exp(-d/500.);
	
	const float density = 1/20.;
	
	
	float fogAmount = exp(-(cameraPosition.y-35.)*density) * (1.0-exp( -d*worldposition.y*density ))/worldposition.y*0.6;
	
	return mix(color,fogClr*0.1,clamp(fogAmount,0.,1.));
}