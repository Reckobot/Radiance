#version 120
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;
varying vec4 lmtexcoord;

uniform sampler2D texture;
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

/* DRAWBUFFERS:1 */
	vec4 tex = texture2D(texture, lmtexcoord.zw)*color;
	tex.a = tex.a;
	gl_FragData[0] = vec4(vec3(1.0,lmtexcoord.x,1.0),tex.a*length(tex.rgb)/sqrt(3.0));
}