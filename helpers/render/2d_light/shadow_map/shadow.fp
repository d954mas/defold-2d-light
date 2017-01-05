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
  for (float y=0.0; y<resolution.y; y+=1.0) {
    	//rectangular to polar filter
		vec2 norm = vec2(var_texcoord0.s, y/resolution.y) * 2.0 - 1.0;
		float theta = mult_pi + norm.x * PI; 
		//(1.0 + norm.y) * 0.5;//use MAD
		float r =norm.y*0.5 + 0.5;
		
		
		//coord which we will sample from occlude map
		vec2 coord = vec2(-r * sin(theta), -r * cos(theta))*0.5 + 0.5;
		
		//sample the occlusion map
		vec4 data = texture2D(TEX0, coord);
		
		
		
		//if we've hit an opaque fragment (occluder), then get new distance
		//if the new distance is below the current, then we'll use that for our ray
		if (data.a > THRESHOLD) {
			//the current distance is how far from the top we've come
			float dst = y/resolution.y / up_scale.x;
			distance = min(distance, dst);
			break;
  		}
  } 
  gl_FragColor = vec4(vec3(distance), 1.0);
}