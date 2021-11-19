#ifdef EMBEDDED
varying vec2 fsTex;
#else
#extension GL_ARB_separate_shader_objects : enable
layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;
#endif

uniform vec4 color;

void main()
{
	target = color * pow(length(fsTex), 2.0) * 0.8;
}