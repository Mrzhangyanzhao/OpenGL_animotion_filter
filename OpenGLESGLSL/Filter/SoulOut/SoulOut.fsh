precision highp float;

varying lowp vec2 textureCoordVarying;
uniform sampler2D Texture;
uniform float Time;
void main(){
    
    float duration = 0.7;
    float maxAlpha = 0.4;
    float maxScale = 1.8;
    
    float progress = mod(Time, duration) / duration; // 0~1
    float alpha = maxAlpha * (1.0 - progress);
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    float weakX = 0.5 + (textureCoordVarying.x - 0.5) / scale;
    float weakY = 0.5 + (textureCoordVarying.y - 0.5) / scale;
    vec2 weakTextureCoords = vec2(weakX, weakY);
    
    vec4 weakMask = texture2D(Texture, weakTextureCoords);
    
    vec4 mask = texture2D(Texture, textureCoordVarying);
    
    gl_FragColor = mask * (1.0 - alpha) + weakMask * alpha;
    
}
