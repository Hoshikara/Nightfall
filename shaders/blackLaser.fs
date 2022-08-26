#ifdef EMBEDDED
varying vec2 fsTex;
varying vec4 position;
#else
#extension GL_ARB_separate_shader_objects : enable
layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;
in vec4 position;
#endif

uniform sampler2D mainTex;

void main() {
    float x = fsTex.x;

	if (x < 0.0 || x > 1.0)
    {
		target = vec4(0.0);
        return;
    }

	vec4 mainColor = texture(mainTex, vec2(x,fsTex.y));
    target = vec4(0.0, 0.0, 0.0, mainColor.a);
}
