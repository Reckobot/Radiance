vec3 moonlight = mix(vec3(0.8, 1.1, 1.4) * 0.7,vec3(0.6,0.63,0.7),rainStrength);
vec3 sunlightColor(in float SdotU){
	return mix(normalize(vec3(0.58597,0.23,0.01)),normalize(vec3(0.58597,0.58,0.58)),pow(clamp(SdotU*1.1-0.1,0.,0.75),0.7));
}
vec3 sunlightColorRain(in vec3 sunlight, in float rainStrength){
	const vec3 rainC = vec3(0.01,0.01,0.01);
	return mix(sunlight,rainC*sunlight,rainStrength);
}
float sunIntensity(in float SdotU){
	return max(exp(SdotU)-0.95,0.);
}
float moonIntensity(in float SdotU){
	return clamp(exp(-SdotU)-0.95,0.,0.5);
}