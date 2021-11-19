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

// 0 = body, 1 = entry, 2 = exit
uniform int laserPart;

// 20Hz flickering. 0 = Miss, 1 = Inactive, 2 & 3 = Active alternating.
uniform int hitState;

// https://www.shadertoy.com/view/lsdXDH
vec4 generic_desaturate(vec3 color, float factor) {
	vec3 lum = vec3(0.299, 0.587, 0.114);
	vec3 gray = vec3(dot(lum, color));
	return vec4(mix(color, gray, factor), 1.0);
}
const float laserSize = 1.125;

void main() {
	float x = fsTex.x;

	if (x < 0.0 || x > 1.0) {
		target = vec4(0.0);

		return;
	}

	if (laserPart == 1) {
		vec4 mainColor = clamp(texture(mainTex, vec2(x * 0.5, fsTex.y)) * color, 0, 1.0);
		vec4 glow = texture(mainTex, vec2(0.5 + (x * 0.5), fsTex.y));

		target = generic_desaturate(mainColor.rgb, 0.3) + glow;
		
		return;
	}

	x -= (laserSize / 2);
	x /= laserSize;
	x += (laserSize / 2);

	float y = 0.33 * ceil(float(hitState) / 2) + 0.02;
	vec4 mainColor = clamp(texture(mainTex, vec2(x * 0.5, y)) * color, 0, 1.0);
	vec4 glow = texture(mainTex, vec2(0.5 + (x * 0.5), y));

	target = generic_desaturate(mainColor.rgb, 0.3) + glow;
}
