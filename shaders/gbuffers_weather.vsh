#version 120
#extension GL_EXT_gpu_shader4 : enable

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 lmtexcoord;
flat varying vec4 color;


uniform vec2 texelSize;
uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
const float PI48 = 150.796447372;
float pi2wt = PI48*frameTimeCounter*10.;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	lmtexcoord.xy = gl_MultiTexCoord0.xy;
	float NdotU = (0.17*15.5/255.)+(0.83*15.5/255.);
	lmtexcoord.zw = (gl_MultiTexCoord1.xy*vec2(15.5/255.0,NdotU)+0.5)*texelSize;

	vec3 position = mat3(gl_ModelViewMatrix) * vec3(gl_Vertex) + gl_ModelViewMatrix[3].xyz;
	vec3 worldpos = mat3(gbufferModelViewInverse) * position + gbufferModelViewInverse[3].xyz + cameraPosition;
	bool istopv = worldpos.y > cameraPosition.y+5.0;
	float ft = frameTimeCounter*1.3;
	if (!istopv) position.xz += vec2(3.0,1.0)+sin(ft)*sin(ft)*sin(ft)*vec2(2.1,0.6);
	position.xz -= (vec2(3.0,1.0)+sin(ft)*sin(ft)*sin(ft)*vec2(2.1,0.6))*0.5;
	gl_Position = toClipSpace3(position);
	color = gl_Color;



}
