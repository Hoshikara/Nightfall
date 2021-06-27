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
uniform bool hasSample;

void main()
{	
	vec4 mainColor = texture(mainTex, fsTex.xy);
    if(hasSample)
    {
        float addition = abs(0.5 - fsTex.x) * - 1.;
        addition += 0.3;
        addition = max(addition,0.);
        addition *= 1.2;
        mainColor.xyz += addition;
    }
	target = mainColor;
}