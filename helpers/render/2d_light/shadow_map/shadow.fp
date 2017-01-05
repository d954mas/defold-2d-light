#ifdef GL_ES
#define LOWP lowp
precision mediump float;
#else
#define LOWP 
#endif
#define PI 3.14

varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D TEX0;
uniform vec4 resolution;
uniform vec4 up_scale;
const float THRESHOLD = 0.75;
const float mult_pi=PI*1.5;
//for debugging; use a constant value in final release


void main(void) {
  float distance = 1.0;
  //angle do not changed for one ray, changed only r(lenght)
  float theta = mult_pi + (var_texcoord0.s*2.0 -1.0) * PI; 
  float add = 1.0/resolution.y;
  vec2 pre_coord = vec2(sin(theta),cos(theta)) * 0.5;
  for (float r=0.0; r<1.0; r+=add) {
  	//coord which we will sample from occlude map
	vec2 coord = pre_coord * -r +0.5;
	//sample the occlusion map
	vec4 data = texture2D(TEX0, coord);
	//if we've hit an opaque fragment (occluder), then get new distance
	//if the new distance is below the current, then we'll use that for our ray
	if (data.a > THRESHOLD) {
		//the current distance is how far from the top we've come
		distance = r / up_scale.x;
		break;
  	}
  } 
  gl_FragColor = vec4(vec3(distance), 1.0);
}