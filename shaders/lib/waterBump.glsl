vec4 smoothfilter(in sampler2D tex, in vec2 uv, in vec2 textureResolution)
{
	uv = uv*textureResolution + 0.5;
	vec2 iuv = floor( uv );
	vec2 fuv = fract( uv );
	uv = iuv + (fuv*fuv)*(3.0-2.0*fuv);
	uv = uv/textureResolution - 0.5/textureResolution;
	return texture2D( tex, uv);
}
vec2 getWaterHeightmap(vec2 posxz, float waveM, float waveZ, float iswater) {
    waveM *= 697.0;
    posxz *= waveZ * 7.;

    float radiance = 2.39996;
    mat2 rotationMatrix  = mat2(vec2(cos(radiance),  -sin(radiance)),  vec2(sin(radiance),  cos(radiance)));

    vec2 wave = vec2(0.);
    vec2 movement = abs(vec2(frameTimeCounter * 0.0007 * (iswater * 2.0 - 1.0),0.0)) * waveM;

	float w = 0.0;
	for (int i =0; i<3;i++){
	posxz = rotationMatrix  * posxz;
    wave += (smoothfilter(noisetex, (-posxz + movement) / 700.0 * exp2(0.8*i),vec2(512.)).gb*2-1.)*exp2(-1.1*i);

	w+=exp2(-1.1*i);
	}

    return wave/w*mix(1.0,1.0,iswater*2-1);
}
vec3 getWaveHeight(vec2 posxz, float iswater){

	vec2 coord = posxz;

		float deltaPos = 0.25;

		float waveZ = mix(10.0,0.25,iswater);
		float waveM = mix(0.0,4.0,iswater);

		vec2 h0 = getWaterHeightmap(coord, waveM, waveZ, iswater)/10.;

		vec3 wave = normalize(vec3(h0.x,h0.y,1.0));

		return wave;
}
