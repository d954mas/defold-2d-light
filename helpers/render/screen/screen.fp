varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D TEX0;

void main(){
     gl_FragColor = texture2D(TEX0, var_texcoord0.xy);
}
