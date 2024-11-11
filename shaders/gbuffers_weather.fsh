#version 120
#extension GL_EXT_gpu_shader4 : enable



varying vec4 lmtexcoord;
flat varying vec4 color;



uniform sampler2D texture;
uniform sampler2D gaux1;
uniform sampler2DShadow shadow;

uniform vec4 lightCol;
uniform vec3 sunVec;

uniform vec2 texelSize;
uniform float rainStrength;


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
	vec2 tex = texture2D(texture, lmtexcoord.xy).ba*color.ba;
	gl_FragData[0].a = clamp(tex.y*0.3 -0.1*0.3,0.0,1.0);
	if (gl_FragData[0].a > 0.0) {
		vec3 lightmap = texture2D(gaux1,lmtexcoord.zw).xyz;
		vec3 diffuseLight = lightCol.rgb+lightmap;
		gl_FragData[0].rgb = diffuseLight*tex.r;
}


}
