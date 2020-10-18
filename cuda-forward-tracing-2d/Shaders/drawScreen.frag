#version 330


uniform sampler2D buffer;
in vec2 uv;

out vec4 fragColor;

void main()
{
    fragColor = vec4(texture(buffer,uv).rgb, 1.0);
}