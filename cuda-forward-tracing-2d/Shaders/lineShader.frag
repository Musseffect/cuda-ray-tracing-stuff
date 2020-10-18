#version 330

in vec3 color;
in float angle;
//in vec2 lineCenter;
uniform vec2 screenSize;

out vec4 fragColor;

float lin(float a,float b,float t)
{
    t=(t-a)/(b-a);
	return clamp(t,0.0,1.0);
}
void main()
{
	vec2 c=vec2(cos(angle),sin(angle));
	float mult=1.0/max(abs(c.x),abs(c.y));
	fragColor=vec4(color*mult,mult);
	/*float d = length(lineCenter*screenSize-gl_FragCoord.xy);
	float mult = lin(2.0,0.0,d);
	fragColor = vec4(color*mult,mult);*/
}