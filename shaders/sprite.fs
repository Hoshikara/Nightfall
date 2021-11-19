#ifdef EMBEDDED
varying vec2 fsTex;
#else
#extension GL_ARB_separate_shader_objects : enable
layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;
#endif

uniform sampler2D mainTex;
uniform vec4 color;

void main()
{	
	target = texture(mainTex, vec2(color.r + 0.02, fsTex.y));
	target.a *= color.a * 0.4;
}
