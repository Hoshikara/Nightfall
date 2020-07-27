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
uniform vec4 color;
uniform float objectGlow;

uniform float trackPos;
uniform float trackScale;
uniform float hiddenCutoff;
uniform float hiddenFadeWindow;
uniform float suddenCutoff;
uniform float suddenFadeWindow;

// 20Hz flickering. 0 = Miss, 1 = Inactive, 2 & 3 = Active alternating.
uniform int hitState;

// 0 = body, 1 = entry, 2 = exit
uniform int laserPart;

#ifdef EMBEDDED
void main()
{    
    float x = fsTex.x;
    if (x < 0.0 || x > 1.0)
    {
        target = vec4(0);
        return;
    }
    float laserSize = 1.0; //0.0 to 1.0
    x -= 0.5;
    x /= laserSize;
    x += 0.5;
    vec4 mainColor = texture(mainTex, vec2(x,fsTex.y));

    target = mainColor * color;
    target.xyz = target.xyz * (0.0 + objectGlow * 1.2);
}
#else

float hide()
{
    float off = trackPos + position.y * trackScale;

    if (hiddenCutoff > suddenCutoff) {
        float sudden = smoothstep(suddenCutoff, suddenCutoff - suddenFadeWindow, off);
        float hidden = smoothstep(hiddenCutoff, hiddenCutoff + hiddenFadeWindow, off);
        return min(hidden + sudden, 1.0);
    }

    float sudden = smoothstep(suddenCutoff + suddenFadeWindow, suddenCutoff, off);
    float hidden = smoothstep(hiddenCutoff - hiddenFadeWindow, hiddenCutoff, off);

    return hidden * sudden;
}

void main()
{    
    float x = fsTex.x;
    if (x < 0.0 || x > 1.0)
    {
        target = vec4(0);
        return;
    }
    float laserSize = 1.0; //0.0 to 1.0
    x -= 0.5;
    x /= laserSize;
    x += 0.5;
    vec4 mainColor = texture(mainTex, vec2(x,fsTex.y));

    target = mainColor * color;
    float brightness = (target.x + target.y + target.z) / 3.0;
    target.xyz = target.xyz * (0.0 + objectGlow * 1.2);
    target *= hide();
}
#endif
