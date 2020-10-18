#version 330


in vec2 in_pos;
in vec3 in_color;
in float in_angle;

uniform float aspectRatio;//x over y

out vec3 color;
out float angle;
//out vec2 lineCenter;

void main()
{
	gl_Position = vec4(in_pos.x,in_pos.y*aspectRatio,0.0,1.0);
	color=in_color;
	angle=in_angle;
	//lineCenter = (gl_Position.xy+vec2(1.0))*0.5;//line center in 0,1 coords
}