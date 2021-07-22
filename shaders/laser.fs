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

const float laserSize = 1.0675;

void main() {
	if (laserPart == 1) {
		target = texture(mainTex, fsTex);
		
		return;
	}
	
	float x = fsTex.x;

	if (x < 0.0 || x > 1.0) {
		target = vec4(0.0);

		return;
	}

	x -= (laserSize / 2);
	x /= laserSize;
	x += (laserSize / 2);

	float y = 0.33 * ceil(float(hitState) / 2) + 0.02;

	target = texture(mainTex, vec2(x, y));
}