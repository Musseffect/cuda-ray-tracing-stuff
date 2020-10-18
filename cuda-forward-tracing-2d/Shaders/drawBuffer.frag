#version 330


uniform sampler2D buffer;
uniform float exposure;
uniform float rays;
in vec2 uv;

out vec3 fragColor;

vec3 XYZToRGB(vec3 xyz)
{
	const mat3 XYZ_to_RGB=mat3(2.3706743f, -0.9000405f, -0.4706338f,
		-0.5138850f, 1.4253036f, 0.0885814f,
		0.0052982f, -0.0146949f, 1.0093968f);
	return xyz*XYZ_to_RGB;
}
float xFit_1931( float wave )
{
float t1 = (wave-442.0)*((wave<442.0)?0.0624:0.0374);
float t2 = (wave-599.8)*((wave<599.8)?0.0264:0.0323);
float t3 = (wave-501.1)*((wave<501.1)?0.0490:0.0382);
return 0.362*exp(-0.5*t1*t1) + 1.056*exp(-0.5*t2*t2)
- 0.065*exp(-0.5*t3*t3);
}
float yFit_1931( float wave )
{
float t1 = (wave-568.8)*((wave<568.8)?0.0213:0.0247);
float t2 = (wave-530.9)*((wave<530.9)?0.0613:0.0322);
return 0.821*exp(-0.5*t1*t1) + 0.286*exp(-0.5*t2*t2);
}
float zFit_1931( float wave )
{
float t1 = (wave-437.0)*((wave<437.0)?0.0845:0.0278);
float t2 = (wave-459.0)*((wave<459.0)?0.0385:0.0725);
return 1.217*exp(-0.5*t1*t1) + 0.681*exp(-0.5*t2*t2);
}

void main()
{
	const float gamma = 2.2;
	//vec3 color = max(vec3(0.0),XYZToRGB(texture(buffer,uv).rgb)/rays);
	//float wave=mix(320.0,740.0,uv.x);
	//color = max(vec3(0.0),XYZToRGB(vec3(xFit_1931(wave),yFit_1931(wave),zFit_1931(wave))));
	vec3 color = vec3(texture(buffer,uv).rgb)/rays;
	vec3 mapped = vec3(1.0) - exp(-color * exposure);
    mapped = pow(mapped, vec3(1.0 / gamma));
    fragColor = mapped;
}