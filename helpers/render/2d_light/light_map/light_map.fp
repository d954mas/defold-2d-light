#ifdef GL_ES
#define LOWP lowp
precision mediump float;
#else
#define LOWP 
#endif
#define PI 3.14

//inputs from vertex shader
varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

//uniform values
uniform lowp sampler2D TEX0;
uniform lowp sampler2D TEX1;
uniform vec4 resolution;
uniform vec4 vColor;
uniform vec4 softShadows;

//sample from the distance map
float sample(vec2 coord, float r) {
	coord.x=1.0-coord.x;
  return step(r, texture2D(TEX0, coord).r);
}

void main(void) {
    //rectangular to polar
	vec2 norm = var_texcoord0.st * 2.0 - 1.0;
	float theta = atan(norm.y, norm.x);
	float r = length(norm);	
	float coord = (theta + PI) / (2.0*PI);
	
	//the tex coord to sample our 1D lookup texture	
	//always 0.0 on y axis
	vec2 tc = vec2(coord, 0.0);
	
	//the center tex coord, which gives us hard shadows
	float center = sample(vec2(tc.x, tc.y), r);        
	
	//we multiply the blur amount by our distance from center
	//this leads to more blurriness as the shadow "fades away"
	float blur = (1./resolution.x)  * smoothstep(0., 1., r); 
	
	//now we use a simple gaussian blur
	float sum = 0.0;
	
	sum += sample(vec2(tc.x - 4.0*blur, tc.y), r) * 0.05;
	sum += sample(vec2(tc.x - 3.0*blur, tc.y), r) * 0.09;
	sum += sample(vec2(tc.x - 2.0*blur, tc.y), r) * 0.12;
	sum += sample(vec2(tc.x - 1.0*blur, tc.y), r) * 0.15;
	
	sum += center * 0.16;
	
	sum += sample(vec2(tc.x + 1.0*blur, tc.y), r) * 0.15;
	sum += sample(vec2(tc.x + 2.0*blur, tc.y), r) * 0.12;
	sum += sample(vec2(tc.x + 3.0*blur, tc.y), r) * 0.09;
	sum += sample(vec2(tc.x + 4.0*blur, tc.y), r) * 0.05;
	
	//1.0 -> in light, 0.0 -> in shadow
 	float lit = mix(center, sum, softShadows.x);
 	
 	//multiply the summed amount by our distance, which gives us a radial falloff
 	//then multiply by vertex (light) color  
 	gl_FragColor = vColor * vec4(vec3(1.0), lit * smoothstep(1.0, 0.0, r));
}