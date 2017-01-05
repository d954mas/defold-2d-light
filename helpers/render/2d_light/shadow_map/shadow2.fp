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
uniform vec4 resolution;
uniform vec4 up_scale;
uniform vec4 pos;
float mult_pi=PI*1.5;

void main(void) {
	float x=(var_texcoord0.s-0.5)*128/pos.z;
	float y=(var_texcoord0.t-0.5)*128/pos.w;
	vec2 coord=vec2((pos.x)/pos.z+x,pos.y/pos.w+y);
	//vec4 data = texture2D(TEX0, coord);
  gl_FragColor = vec4(texture2D(TEX0, coord).xyz, 1.0);
}