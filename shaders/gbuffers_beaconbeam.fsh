#version 120
#extension GL_EXT_gpu_shader4 : enable



varying vec4 lmtexcoord;
varying vec4 color;
varying vec4 normalMat;

uniform sampler2D texture;

//faster and actually more precise than pow 2.2
vec3 toLinear(vec3 sRGB){
	return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}



//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
/* DRAWBUFFERS:1 */
void main() {
	gl_FragData[0] = texture2D(texture, lmtexcoord.xy)*color;
	vec3 albedo = toLinear(gl_FragData[0].rgb);
	vec3 color = albedo;
	gl_FragData[0].rgb = color;
}
