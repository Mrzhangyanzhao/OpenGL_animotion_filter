attribute vec4 position;
attribute vec2 textureCoord;
varying lowp vec2 textureCoordVarying;

uniform float Time;
const float PI = 3.1415926;

void main(){
    
    float duration = 0.6;
    float maxAmplitude = 0.3;
    
    float time = mod(Time,duration);
    float amplitude = maxAmplitude * abs(sin(time * (PI / duration))) + 1.0;
    
    textureCoordVarying = textureCoord;
    gl_Position = vec4(position.x * amplitude,position.y * amplitude,position.zw);
}
