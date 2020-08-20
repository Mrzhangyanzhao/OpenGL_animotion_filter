precision highp float;

varying lowp vec2 textureCoordVarying;
uniform sampler2D Texture;

void main(){
    gl_FragColor = texture2D(Texture,textureCoordVarying);
}
