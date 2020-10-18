#version 330

in vec2 pos;
out vec2 uv;

uniform mat3 mvp;

void main()
{
	vec3 _p=mvp*vec3(pos,1.0);
	gl_Position =vec4(_p.xy,0,_p.z);
	uv = (pos + 1.0)/2.0;
}