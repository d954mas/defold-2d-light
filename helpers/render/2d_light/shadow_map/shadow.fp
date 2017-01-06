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

//number of rays for every light and light size
//can't use uniform because of webGl
const float resolution=256.0;
uniform vec4 up_scale; //x - 1.0/up_scale  y - 1.0/resolution
uniform vec4 pre_calc_pos;

const float i_steps=2.0;

void main(void) {
  float distance = 1.0;
  //angle do not changed for one ray, changed only r(lenght)
  mediump vec2 step = up_scale.y * vec2(sin(theta),cos(theta))*pre_calc_pos.zw;
  mediump vec2 start_position=vec2(pre_calc_pos.x,pre_calc_pos.y);
  //i think there are at least two untransparent pixels in line
  for(float i=0.0;i<resolution;i+=i_steps){
  	vec4 data = texture2D(TEX0, start_position);
	//if we've hit an opaque fragment (occluder), then get new distance
	if (data.a > THRESHOLD) {
		//check prev pixels
		float delta_i=0.0;
		for(float j=1.0;j<i_steps;j++){
			start_position+=step;
			data = texture2D(TEX0, start_position);
			if(data.a>THRESHOLD){
				delta_i++;
			}
		}
		distance = up_scale.y*(i-delta_i);
		break;
  	}
  	start_position-=step*i_steps;
  }
  gl_FragColor = vec4(vec3(distance*up_scale.x), 1.0);
}