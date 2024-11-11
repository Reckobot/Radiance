vec3 cloud2D(vec3 fragpos,vec3 col){
	vec3 wpos = fragpos;
	float wind = frameTimeCounter*20;
	vec2 intersection = ((2000.0-cameraPosition.y)*wpos.xz*inversesqrt(wpos.y+cameraPosition.y/512.-50./512.) + cameraPosition.xz+wind)/80000.;


	float phase = clamp(dot(fragpos,sunVec),0.,1.)*clamp(dot(fragpos,sunVec),0.,1.)*0.5+0.5;

	float fbm = texture2D(noisetex,intersection*vec2(1.,1.5)*2.).r+texture2D(noisetex,intersection*vec2(1.,1.5)*20.+wind/2000).r/9.;
	fbm = pow(clamp(fbm/1.1111-0.28*(1.0-rainStrength),0.0,1.0)/0.5*(1.0-rainStrength),1.0);


	return mix(col,cloudCol,fbm*sqrt(clamp(wpos.y*0.9,0.,1.)));

}
