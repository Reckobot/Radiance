uniform sampler2D colortex5;

float getFresnel(vec2 coord, vec3 dir, vec3 norm){
	float f0 = texture(colortex5, coord).g;
	float fresnel = dot(f0 + (1 - f0) * (1-dot(dir, norm)), 5);
    return fresnel;
}

float getRoughness(vec2 coord, sampler2D depthtex, float depth){
	float roughness = pow(1 - texture(colortex5, coord).r, 2);

	if (depth != texture(depthtex, coord).r){
		roughness = 0.01;
	}

	roughness = (2/roughness)-2;

    return roughness;
}