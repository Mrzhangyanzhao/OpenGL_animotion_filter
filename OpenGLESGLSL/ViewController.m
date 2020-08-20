//
//  ViewController.m
//  OpenGLESGLSL
//
//  Created by yz on 2020/8/2.
//  Copyright © 2020 yz. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import "FilterBar.h"
typedef struct {
    GLKVector3 positionCoord;//(xyz)顶点
    GLKVector2 textureCoord;//(u,v)纹理
}SenceVertex;

@interface ViewController ()<FilterBarDelegate>

//顶点数据
@property (assign, nonatomic) SenceVertex *verTices;

//上下文
@property (strong, nonatomic) EAGLContext *context;

//着色器程序program
@property (assign, nonatomic) GLuint myProgram;

//顶点缓存
@property (assign, nonatomic) GLuint vertexBuffer;

//纹理id
@property (assign, nonatomic) GLuint textureId;

//定时器
@property (strong, nonatomic) CADisplayLink *displayLink;
//开始时间戳
@property (assign, nonatomic) NSInteger startTimeStamp;
@end

@implementation ViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 移除 displayLink
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

// 开始一个滤镜动画
- (void)startFilerAnimation {
    //1.判断displayLink 是否为空
    //CADisplayLink 定时器
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    //2. 设置displayLink 的方法
    self.startTimeStamp = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    
    //3.将displayLink 添加到runloop 运行循环
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}

//2. 动画
- (void)timeAction {
    //DisplayLink 的当前时间撮
    if (self.startTimeStamp == 0) {
        self.startTimeStamp = self.displayLink.timestamp;
    }
    //使用program
    glUseProgram(self.myProgram);
    //绑定buffer
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    
    // 传入时间
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeStamp;
    GLuint time = glGetUniformLocation(self.myProgram, "Time");
    glUniform1f(time, currentTime);
    
    // 清除画布
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    
    // 重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //渲染到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    
}

// 创建滤镜栏
- (void)setupFilterBar {
    CGFloat filterBarWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat filterBarHeight = 100;
    CGFloat filterBarY = [UIScreen mainScreen].bounds.size.height - filterBarHeight;
    FilterBar *filerBar = [[FilterBar alloc] initWithFrame:CGRectMake(0, filterBarY, filterBarWidth, filterBarHeight)];
    filerBar.delegate = self;
    [self.view addSubview:filerBar];
    
    NSArray *dataSource = @[@"无",@"缩放",@"灵魂出窍",@"抖动",@"闪白",@"毛刺",@"幻觉"];
    filerBar.itemList = dataSource;
}
- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSUInteger)index{
    NSArray *filterArr = @[@"Namal",@"Scale",@"SoulOut",@"Shake",@"ShineWhite",@"Glitch",@"Vertigo"];
    if (index < filterArr.count) {
        [self setupShaderProgramWithName:filterArr[index]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupFilterBar];
    
    
    // 设置顶点信息
    self.verTices = malloc(sizeof(SenceVertex) * 4);
    //初始化 0123顶点及纹理坐标
    self.verTices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}};
    self.verTices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}};
    self.verTices[2] = (SenceVertex){{1, 1, 0}, {1, 1}};
    self.verTices[3] = (SenceVertex){{1, -1, 0}, {1, 0}};
    
    [self setupContext];
    
    //设置图层
    CAEAGLLayer *layer = [[CAEAGLLayer alloc]init];
    layer.frame = CGRectMake(20, 100, self.view.frame.size.width - 40, self.view.frame.size.height - 200);
    layer.contentsScale = [[UIScreen mainScreen] scale];
    [self.view.layer addSublayer:layer];
    
    //layer绑定缓存区
    [self bindRenderAndFrameBuffer:layer];
    
    //获取图片 加载纹理
    //6.获取处理的图片路径
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"timg.jpeg"];
    //读取图片
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    //将JPG图片转换成纹理图片
    GLuint textureID = [self loadTexture:image];
    //设置纹理ID
    self.textureId = textureID;  // 将纹理 ID 保存，方便后面切换滤镜的时候重用
    
    [self renderLayer];
    
    [self setupShaderProgramWithName:@"Namal"];
    
    [self startFilerAnimation];
    
    
    
    
    
    
    
    // Do any additional setup after loading the view.
}

//创建上下文
-(void)setupContext{
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"creat context failed");
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"set current context failed");
    }
    self.context= context;
}

-(void)renderLayer{
    //7.设置视口
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    //8.设置顶点缓存区
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.verTices, GL_STATIC_DRAW);
    
    //10.将顶点缓存保存，退出时才释放
    self.vertexBuffer = vertexBuffer;
}

//绑定渲染、帧缓存区
-(void)bindRenderAndFrameBuffer:(CALayer<EAGLDrawable> *)layer{
   //定义缓存区
    GLuint renderBuffer,frameBuffer;
    
    //获取缓存区ID
    glGenRenderbuffers(1, &renderBuffer);
    //绑定渲染缓存区
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    //将渲染缓存区与绘制layer 建立联系
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    //获取帧缓存区Id；
    glGenFramebuffers(1, &frameBuffer);
    //绑定帧缓存区
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    //将渲染缓存区附着到帧缓存区
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
}

//加载纹理
-(GLuint)loadTexture:(UIImage *)image{
    //uiimage -> CGImageRef
    CGImageRef spriteImage = image.CGImage;
    if (!spriteImage) {
        NSLog(@"获取失败");
        exit(1);
    }
    //获取图片width 、 height 字节
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
//    void *imageData = malloc(width * height * 4);
    
    //图片rect
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //获取图片颜色空间
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(spriteImage);
    
    
    //创建上下文重绘图片
    CGContextRef context = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //翻转图片
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    
    //将图片进行重绘。得到解压缩的位图
    CGContextDrawImage(context, rect, spriteImage);
    
    //设置图片纹理属性
    
    //获取纹理id
    GLuint textureID;
    glGenTextures(1, &textureID);
    //绑定纹理id
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    float fw = width,fh = height;
    //载入纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    //设置过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    
   
    //将纹理绑定到默认的纹理ID上
    glBindBuffer(GL_TEXTURE_2D, 0);
    //9.释放context,imageData
    CGContextRelease(context);
    free(spriteData);
    return textureID;
}

//初始化着色器程序
-(void)setupShaderProgramWithName:(NSString *)shaderName{
    //获取着色器程序
    GLuint program = [self programShaderName:shaderName];
    
    //使用着色器程序
    glUseProgram(program);
    
    //获取着色器文件中 顶点、纹理坐标、纹理 索引位置
    GLuint positionSolt = glGetAttribLocation(program, "position");
    GLuint textureCoordSolt = glGetAttribLocation(program, "textureCoord");
    GLuint textureSolt = glGetAttribLocation(program, "Texture");
    
    //激活绑定纹理ID
    glActiveTexture(self.textureId);
    glBindTexture(GL_TEXTURE_2D, self.textureId);
    
    //纹理采样器(传入纹理数据)
    glUniform1f(textureSolt, 0);
    
    //打开attribute 顶点通道
    glEnableVertexAttribArray(positionSolt);
    //传入顶点坐标
    glVertexAttribPointer(positionSolt, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    //打开纹理坐标通道
    glEnableVertexAttribArray(textureCoordSolt);
    //传入纹理坐标数据
    glVertexAttribPointer(textureCoordSolt, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    self.myProgram = program;
    
}


//编译自定义着色器
-(GLuint)comlipeShader:(NSString *)name type:(GLenum)type{
    
    //shader 路径
    NSString *shaderPath = [[NSBundle mainBundle]pathForResource:name ofType:type == GL_VERTEX_SHADER ? @"vsh" :@"fsh"];
    
    //读取shader文件路径字符串
    NSError *error = nil;
    NSString *shaderStr = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"读取shader 失败");
        exit(1);
    }
    
    //根据类型type创建shader
    GLuint shader = glCreateShader(type);
    const char *shaderSourceUTF8 = [shaderStr UTF8String];
    int shaderStrLength = (int)[shaderStr length];
    //获取shader source
    glShaderSource(shader, 1, &shaderSourceUTF8, &shaderStrLength);
    
    //编译shader
    glCompileShader(shader);
    
    //查看编译结果
    GLint compileResult;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileResult);
    if (compileResult == GL_FALSE) {
        NSLog(@"编译shader 失败");
        exit(1);
    }
    return shader;
}

//链接着色器程序(着色器附着到program)
-(GLuint)programShaderName:(NSString *)shaderName{
    //编译顶点、片元着色器
    GLuint vertexShader = [self comlipeShader:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self comlipeShader:shaderName type:GL_FRAGMENT_SHADER];
    
    //将顶点、片元着色器附着到program
    
    //创建program
    GLuint program = glCreateProgram();
    //附着着色器
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    //链接program link
    glLinkProgram(program);
    
    //链接结果
    GLint linkResult;
    glGetProgramiv(program, GL_LINK_STATUS, &linkResult);
    if (linkResult == GL_FALSE) {
        NSLog(@"link program failed");
        exit(1);
    }
    
    return program;
}

//获取渲染缓存区的宽
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}
//获取渲染缓存区的高
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}

@end
