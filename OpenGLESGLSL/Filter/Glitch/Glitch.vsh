attribute vec4 position;
attribute vec2 textureCoord;
varying lowp vec2 textureCoordVarying;

void main(){
    textureCoordVarying = textureCoord;
    gl_Position = position;
}
