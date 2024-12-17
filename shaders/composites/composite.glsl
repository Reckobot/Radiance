#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0,6,7 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lighting;
layout(location = 2) out vec4 fresnelbuffer;

vec3 getShadow(vec3 shadowScreenPos){
	float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r); // sample the shadow map containing everything
	if(transparentShadow == 1.0){
	return vec3(1.0);
	}
	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r); // sample the shadow map containing only opaque stuff
	if(opaqueShadow == 0.0){
	return vec3(0.0);
	}
	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
	return shadowColor.rgb * 2.0;
}

vec3 getSoftShadow(vec4 shadowClipPos, float bias){
	const float range = 1.0;
	const float increment = 0.5;

	float noise = IGN(texcoord, frameCounter, vec2(shadowMapResolution));

	float theta = noise * radians(360.0);
	float cosTheta = cos(theta);
	float sinTheta = sin(theta);

	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

	vec3 shadowAccum = vec3(0.0);
	int samples = 0;

	for(float x = -range; x <= range; x += increment){
		for (float y = -range; y <= range; y+= increment){
			vec2 offset = rotation * vec2(x, y) / shadowMapResolution;
			vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0, 0.0);
      		offsetShadowClipPos.z -= bias;
      		offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
      		vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
      		vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
      		shadowAccum += getShadow(shadowScreenPos);
      		samples++;
    	}
  	}

  	return shadowAccum / float(samples);
}

void main() {
	color = texture(colortex0, texcoord);

	float depth = texture(depthtex0, texcoord).r;

	if (depth >= 1){
		color.rgb *= 2.0;
	}

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec2 lightmap = texture(colortex1, texcoord).rg;
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

	vec3 sunlight = (vec3(SUN_R, SUN_G, SUN_B)*SUN_INTENSITY) * lightmap.g;
	float diffuse = clamp(dot(worldLightVector, normal), 0.0, 1.0);

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	vec3 shadow = getSoftShadow(shadowClipPos, clamp(pow(length(viewPos), 1.1)*0.00006, 0.001, 1.0));


	vec3 lightDir = worldLightVector;
	vec3 viewDir = mat3(gbufferModelViewInverse) * -normalize(projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0) * 2.0 - 1.0));
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float roughness = getRoughness(texcoord, depthtex1, depth);
	float fresnel = getFresnel(texcoord, viewDir, normal);
	float spec = pow(max(dot(normal, halfwayDir), 0.5), roughness) + 0.25;
	float geometric = min(
		(2*dot(halfwayDir, normal)*dot(normal, viewDir))
		/
		dot(viewDir, halfwayDir),

		(2*dot(halfwayDir, normal)*dot(normal, lightDir))
		/
		dot(viewDir, halfwayDir)
		)
	;

	float cookTorrance = (fresnel * spec * geometric)/(4*dot(normal, lightDir)*dot(normal, viewDir));

	sunlight = (sunlight * diffuse) + (sunlight * cookTorrance);
	if (depth == texture(depthtex1, texcoord).r){
		sunlight *= shadow;
	}else{
		sunlight *= clamp(shadow, 0.5, 1.0);
	}

	sunlight *= clamp(getBrightness(skyColor*2), 0.5, 1.0);
	lighting.rgb = sunlight;
}