#version 330 compatibility
#include "/lib/settings.glsl"
#include "/lib/color.glsl"

uniform sampler2D depthtex0;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex3;
uniform sampler2D noisetex;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform vec3 cameraPosition;
uniform vec3 skyColor;
uniform vec3 shadowLightPosition;

in vec2 texcoord;

float cloudlayer(vec3 pos, int steps, float viewdist, float size){
	float value = 1/(steps*0.75);
	vec2 coords = pos.xz/vec2(size, size);
	return value;
}

float foglayer(vec3 pos, int steps, float alpha, float viewdist, float size){
	float value = 1/(steps*0.75);
	vec2 coords = (pos.xz*vec2(1,2))/vec2(size, size);
	value *= texture(noisetex, coords).r*alpha;
	return value;
}

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

/* RENDERTARGETS: 4 */
layout(location = 0) out vec4 color;

void main() {
////////////////////////////////////////////////
	vec2 lightmap = texture(colortex1, texcoord).rg;
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	float skyBrightness = (rgb2hsv(skyColor.rgb)).z;
	float lightness = skyBrightness;

	float depth = texture(depthtex0, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 camPos = projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0));
	vec3 worldPos = (gbufferModelViewInverse * vec4(viewPos, 1)).xyz + cameraPosition;
	vec3 worldcamPos = (gbufferModelViewInverse * vec4(camPos, 1)).xyz + cameraPosition;

	vec3 viewDir = mat3(gbufferModelViewInverse) * -normalize(projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0) * 2.0 - 1.0));

	int steps;
	vec3 origin;
	vec3 pos;
	vec3 dir;
	float fogOpacity;
	vec3 t;
	int e;

	//fancy fog
	#ifdef FANCYFOG


	steps = FOGSTEPS;
	origin = (mat3(gbufferModelViewInverse) * -projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0) * 2.0 - 1.0)) + cameraPosition;
	pos = origin;
	dir = -viewDir;

	fogOpacity = FOGOPACITY + (rainStrength*2);

	if (logicalHeightLimit == 128){
		steps = 100;
	}

	t = vec3(0,0,0);
	e = 0;
	for (int i = 0; i < steps; i++){
		pos += dir*FOGDIST;
		float clouddist = distance(origin, pos);
		float gridsize = FOGSIZE;
		float thickness = FOGTHICKNESS;
		float fogbottom = FOGHEIGHT;
		float center = fogbottom + (thickness/2);
		float fogtop = (fogbottom+thickness);
		int layers = FOGLAYERS;

		float renderdist = 50;

		if (logicalHeightLimit == 128){
			layers += 2;
			thickness += 25;
			fogbottom = 0;
			fogOpacity *= 1.01;
			gridsize *= 2;
		}else if (logicalHeightLimit == 256){
			layers += 2;
			renderdist = 0;
			thickness += 25;
			fogbottom = 0;
			gridsize /= 2;
		}

		if ((clouddist >= renderdist)){
			float viewdist = distance(worldPos, worldcamPos);
			for (int e = 0; e < layers; e++){
				float top = (fogbottom+thickness)+(thickness/2*e);
				float bottom = fogbottom+(thickness/2*e);
				if ((pos.y <= top)&&(pos.y >= bottom)){
					if (clouddist <= viewdist){
						float add = foglayer(pos+vec3(e*e,0,e*e), steps, texture(noisetex, vec2(pos.x, pos.z)).x*fogOpacity, viewdist, gridsize);
						bool doAdd = false;
						if (e==0){
							if (pos.y >= bottom+(add*250)){
								doAdd = true;
							}
						}else if (e==(layers)-1){
							if (pos.y <= top-(add*250)){
								doAdd = true;
							}
						}
						else{
							doAdd = true;
						}

						if (doAdd == true){
							vec3 addition = saturation(fogcolor, 0.5)*(lightness) * add;
							vec3 scatter = (saturation(sunlightColor, 1.25) * clamp(dot(worldLightVector, normalize(-viewDir)), 0.5, 1.0) * lightmap.g);
							addition *= scatter;

							if (logicalHeightLimit == 128){
								addition = fogColor / 8 * add;
							}else if (logicalHeightLimit == 256){
								addition = vec3(add);
							}
							
							t += addition;
						}
					}
				}
			}
		}
	}
	t *= 2;
	color.rgb = t;

	#endif
}