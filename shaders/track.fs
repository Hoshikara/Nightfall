#ifdef EMBEDDED
varying vec2 fsTex;
#else
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;
#endif

uniform sampler2D mainTex;
uniform vec4 lCol;
uniform vec4 rCol;
uniform float hidden;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
	vec4 track = texture(mainTex, vec2(fsTex.x, 0.01 + (fsTex.y * 0.48)));
    vec4 lanes = texture(mainTex, vec2(fsTex.x, 0.51 + (fsTex.y * 0.48)));

    vec3 col = vec3(0);
    float hue = lanes.b * 0.1;

    col += lCol.rgb * lanes.b;
    col += rCol.rgb * lanes.r;

    vec3 colHsv = rgb2hsv(col);
    colHsv.r -= hue;

    track.rgb += hsv2rgb(colHsv);

    target = track + lanes;
}
