#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

	color *= vec4(vec3(AMBIENT_R, AMBIENT_G, AMBIENT_B)*AMBIENT_INTENSITY,1.0) + texture(colortex6, texcoord);
}