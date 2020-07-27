#ifdef EMBEDDED
varying vec2 fsTex;
#else
#extension GL_ARB_separate_shader_objects : enable
layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;
#endif

uniform sampler2D mainTex;
uniform float hiddenCutoff;
uniform float hiddenFadeWindow;
uniform float suddenCutoff;
uniform float suddenFadeWindow;

void main()
{	
	#ifdef EMBEDDED
	target = vec4(0.0);
	#else
	target = texture(mainTex, vec2(fsTex.x, fsTex.y * 2.0));
	
	float off = 1.0 - (fsTex.y * 2.0);
    if (hiddenCutoff < suddenCutoff) {
        float hidden = 1.0 - smoothstep(hiddenCutoff - hiddenFadeWindow, hiddenCutoff, off);
        float sudden = 1.0 - smoothstep(suddenCutoff + suddenFadeWindow, suddenCutoff, off);
        target.a = min(hidden + sudden, 1.0);
    }
    else {
        float hidden = smoothstep(hiddenCutoff + hiddenFadeWindow, hiddenCutoff, off);
        float sudden = smoothstep(suddenCutoff - suddenFadeWindow, suddenCutoff, off);
        target.a = hidden * sudden;
    }
	#endif
}