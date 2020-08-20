precision highp float;

varying lowp vec2 textureCoordVarying;
uniform sampler2D Texture;
uniform float Time;
const float PI = 3.1415926;
void main(){
    float duration = 0.6;
    
    float time = mod(Time, duration);
    
    vec4 whiteMask = vec4(1.0, 1.0, 1.0, 1.0);
    float amplitude = abs(sin(time * (PI / duration)));
    
    vec4 mask = texture2D(Texture, textureCoordVarying);
    
    gl_FragColor = mask * (1.0 - amplitude) + whiteMask * amplitude;
}
