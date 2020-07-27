#ifdef EMBEDDED
varying vec2 fsTex;
#else
#extension GL_ARB_separate_shader_objects : enable
layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;
#endif

uniform sampler2D mainTex;
uniform vec4 color;
uniform ivec2 mapSize; //spritemap size

void main()
{
#ifdef EMBEDDED
	float alpha = texture2D(mainTex, fsTex / vec2(mapSize)).a;
#else
	float alpha = texelFetch(mainTex, ivec2(fsTex), 0).a;
#endif
	target = vec4(color.xyz, alpha * color.a);
}