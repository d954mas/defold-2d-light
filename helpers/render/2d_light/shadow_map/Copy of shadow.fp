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
varying mediump float theta;

uniform lowp sampler2D TEX0;
//number of rays for every light
//can't use uniform because of webGl
const float resolution=256.0;
uniform vec4 up_scale;
uniform vec4 pos;

void main(void) {
  float distance = 1.0;
  //angle do not changed for one ray, changed only r(lenght)
  const float add = 1.0/resolution;
  vec2 pre_something = vec2(resolution/2.0/pos.z, resolution/2.0/pos.w);
  vec2 pre_coord = vec2(sin(theta)*pre_something.x,cos(theta)*pre_something.y);
  vec2 step = add * pre_coord;
  vec2 coord = vec2(0.0);
  vec2 start_position=vec2(pos.x,pos.y);
  const float nsteps = resolution;
  for(float i=0.0;i<resolution;i++){
  	vec4 data = texture2D(TEX0, start_position - coord);
	//if we've hit an opaque fragment (occluder), then get new distance
	if (data.a > THRESHOLD) {
		distance = i/resolution;
		break;
  	}
  	coord+=step;
  }
  gl_FragColor = vec4(vec3(distance/up_scale.x), 1.0);
}