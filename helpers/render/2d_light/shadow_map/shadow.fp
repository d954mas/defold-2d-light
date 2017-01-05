#ifdef GL_ES
#define LOWP lowp
precision mediump float;
#else
#define LOWP 
#endif
#define PI 3.14
#define THRESHOLD 0.75

varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D TEX0;
//number of rays for every light
//can't use uniform because of webGl
const float resolution=256.0;
uniform vec4 up_scale;
uniform vec4 pos;
float mult_pi=PI*1.5;

void main(void) {
  float distance = 1.0;
  //angle do not changed for one ray, changed only r(lenght)
  float theta = (var_texcoord0.s*2.0 -1.0) * PI + mult_pi; 
  const float add = 1.0/resolution;
  vec2 pre_coord = vec2(sin(theta)*resolution/2.0/pos.z,cos(theta)*resolution/2.0/pos.w);
  for (float r=0.0; r<1.0; r+=add) {
  	//coord which we will sample from occlude map
	vec2 coord = pre_coord * -r +vec2(pos.x/pos.z,pos.y/pos.w);
	vec4 data = texture2D(TEX0, coord);
	//if we've hit an opaque fragment (occluder), then get new distance
	if (data.a > THRESHOLD) {
		distance = r;
		break;
  	}
  } 
  gl_FragColor = vec4(vec3(distance/up_scale.x), 1.0);
}