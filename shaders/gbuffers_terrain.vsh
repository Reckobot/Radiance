#version 120
#include "lib/shadow_param.glsl"
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/
//#define SEPARATE_AO
varying vec4 lmtexcoord;
varying vec4 color;
varying vec4 shadowPos;

uniform vec3 sunVec;
uniform vec4 lightCol;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}


void main() {
	vec3 normal = gl_NormalMatrix * gl_Normal;
	vec3 position = mat3(gl_ModelViewMatrix) * vec3(gl_Vertex) + gl_ModelViewMatrix[3].xyz;
	lmtexcoord.xy = gl_MultiTexCoord0.xy;


	float NdotU = gl_Normal.y*(0.17*15.5/255.)+(0.83*15.5/255.);
  lmtexcoord.zw = gl_MultiTexCoord1.xy*vec2(15.5/255.0,NdotU)+0.5;

	gl_Position = toClipSpace3(position);
	float diffuseSun = clamp(dot(normal,sunVec)*lightCol.a,0.0,1.0);


	shadowPos.x = 1e30;
	//skip shadow position calculations if far away
	//normal based rejection is useless in vertex shader
	if (gl_Position.z < shadowDistance + 16.0){
		position = mat3(gbufferModelViewInverse) * position + gbufferModelViewInverse[3].xyz;
		shadowPos.xyz = mat3(shadowModelView) * position.xyz + shadowModelView[3].xyz;
		shadowPos.xyz = diagonal3(shadowProjection) * shadowPos.xyz + shadowProjection[3].xyz;
	}

  color = gl_Color;
  shadowPos.w = diffuseSun*gl_MultiTexCoord1.y;

}
