#version 330
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;

uniform sampler2D mainTex;
uniform float alpha;
uniform float hue;

vec3 hueShift(vec3 color) {
  vec3 P = vec3(0.55735) * dot(vec3(0.55735), color);
  vec3 U = color - P;
  vec3 V = cross(vec3(0.55735), U);
  
  return U * cos(hue * 6.2832) + V * sin(hue * 6.2832) + P;
}

void main() {
  target = texture(mainTex, fsTex);
  target.rgb = hueShift(target.rgb);
  target.a *= alpha;
}

