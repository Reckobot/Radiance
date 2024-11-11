#version 120
#extension GL_EXT_gpu_shader4 : enable

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 lmtexcoord;
varying vec4 color;



#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}

void main() {
	lmtexcoord.xy = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

	lmtexcoord.zw = gl_MultiTexCoord1.xy*vec2(15.5/255.0)+0.5;

	vec3 position = mat3(gl_ModelViewMatrix) * vec3(gl_Vertex) + gl_ModelViewMatrix[3].xyz;
	gl_Position = toClipSpace3(position);

	color = gl_Color;

}
