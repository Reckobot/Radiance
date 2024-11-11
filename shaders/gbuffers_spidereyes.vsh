#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;
varying vec2 texcoord;
uniform mat4 gbufferModelViewInverse;


#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}


void main() {


	texcoord = (gl_MultiTexCoord0).xy;
	color = gl_Color;

	vec3 position = mat3(gl_ModelViewMatrix) * vec3(gl_Vertex) + gl_ModelViewMatrix[3].xyz;
	gl_Position = toClipSpace3(position);

}
