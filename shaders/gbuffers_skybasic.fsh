#version 120
#extension GL_EXT_gpu_shader4 : enable
/* DRAWBUFFERS:1 */

flat varying vec4 sunVec;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform sampler2D noisetex;
uniform sampler2D gaux1;


uniform vec2 texelSize;


#include "lib/color_transforms.glsl"
#include "lib/sky_gradient.glsl"
#include "lib/color_dither.glsl"
#include "lib/color_functions.glsl"

vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
vec3 toScreenSpaceVector(vec3 p) {
    vec3 p3 = p * 2. - 1.;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return normalize(fragposition.xyz);
}




void main() {
	vec3 fragpos = toScreenSpaceVector(vec3(gl_FragCoord.xy*texelSize,1.));
	fragpos = mat3(gbufferModelViewInverse) * fragpos;


	vec3 color = getSkyColorLut(fragpos,sunVec.xyz,fragpos.y,gaux1);

	gl_FragData[0] = vec4(color*sunVec.w,1.0);
	gl_FragData[0].rgb = fp10Dither(gl_FragData[0].rgb);
	gl_FragData[0].rgb *= 4;
	gl_FragData[0].rgb = saturation(gl_FragData[0].rgb, 0.75);
}
