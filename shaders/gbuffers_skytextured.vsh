#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;
varying vec2 texcoord;


void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

	color = gl_Color;

	gl_Position = ftransform();
}
