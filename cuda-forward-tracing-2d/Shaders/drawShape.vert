#version 330


in vec2 in_pos;
uniform mat3x3 matrix;
uniform float aspectRatio;//x over y


void main()
{
	gl_Position = vec4(matrix*vec3(in_pos,1.0),1.0);
	gl_Position = vec4(gl_Position.x,gl_Position.y*aspectRatio,0.0,gl_Position.z);
}