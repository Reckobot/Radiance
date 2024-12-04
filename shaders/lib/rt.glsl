uniform mat4 gbufferProjection;

vec3 viewtoscreen(vec3 input){
	vec4 cPos = gbufferProjection * vec4(input, 1);
	vec3 nPos = cPos.xyz / cPos.w;
	vec3 sPos = nPos * 0.5 + 0.5;
	return sPos;
}