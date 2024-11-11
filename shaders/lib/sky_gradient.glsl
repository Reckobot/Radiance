#define SKY_BRIGHTNESS_DAY 1.0 //[0.0 0.5 0.75 1. 1.2 1.4 1.6 1.8 2.0]
#define SKY_BRIGHTNESS_NIGHT 1.0 //[0.0 0.5 0.75 1. 1.2 1.4 1.6 1.8 2.0]



vec3 getSkyColorLut(vec3 sVector, vec3 sunVec,float cosT,sampler2D lut) {
	float mCosT = clamp(cosT,0.0,1.);
	float cosY = dot(sunVec,sVector);
	float x = ((cosY*cosY)*(cosY*0.5*256.)+0.5*256.+18.+0.5)*texelSize.x;
	float y = (mCosT*256.+1.0+0.5)*texelSize.y;

	return texture2D(lut,vec2(x,y)).rgb;
}
