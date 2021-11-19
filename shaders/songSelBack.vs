#ifdef EMBEDDED
attribute vec2 inPos;
attribute vec2 inTex;
varying vec2 fsTex;
#else
#extension GL_ARB_separate_shader_objects : enable
layout(location=0) in vec2 inPos;
layout(location=1) in vec2 inTex;

out gl_PerVertex
{
	vec4 gl_Position;
};
layout(location=1) out vec2 fsTex;
#endif

uniform mat4 proj;
uniform mat4 world;
uniform float scale;
uniform float timer;
uniform float seed;
float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

void main()
{
    vec2 seeded = inPos + vec2(seed);
    float rand = random(seeded) * 1000.;
    float rand2 = random(seeded * 2.0);
    float rand3 = random(seeded * 3.0);
    fsTex = vec2(pow(rand3, 0.5));
    float offscale = scale / 1920.;
    float size = 65. * offscale;
    vec2 offset = vec2(cos(rand + timer * rand3 * 1.8), sin(rand + timer * rand2 * 2.)) * size;
    //offset.x = 0.;
    //offset.y = 0.;
	gl_Position = proj * world * vec4(inPos.xy * scale * 1.2 + offset - size * 4.0, 0, 1);
}