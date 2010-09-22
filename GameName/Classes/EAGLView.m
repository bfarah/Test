//
//  EAGLView.m
//  Tutorial1
//
//  Created by Michael Daley on 25/02/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>


#import "EAGLView.h"

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) updateScene:(float)delta;
- (void) renderScene;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;


// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        animationInterval = 1.0 / 60.0;
		
		CGRect rect = [[UIScreen mainScreen] bounds];
		
		// Set up OpenGL projection matrix
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrthof(0, rect.size.width, 0, rect.size.height, -1, 1);
		glMatrixMode(GL_MODELVIEW);
		
		// Initialize OpenGL states
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glEnable(GL_TEXTURE_2D);
		glDisable(GL_DEPTH_TEST);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		
		// init images
		//playerShip = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"Ship.png"] filter:GL_LINEAR];
		
		gameEngine = [[GameEngine alloc] init];
		
		xAccel = 2.0f;
		yAccel = 2.0f;
		xVelocity = 0.0f;
		yVelocity = 0.0f;
		lastTime = 0.0f;
		
		//UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 170, 100, 50)];
		//[self.view addSubview:label];
		
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
		
    }
    return self;
}


- (void)mainGameLoop {
	CFTimeInterval		time;
	float				delta;
	time = CFAbsoluteTimeGetCurrent();
	delta = (time - lastTime);
	
	[self updateScene:delta];
	//[self renderScene];
	
	lastTime = time;
}


- (void)updateScene:(float)delta {
	
	[EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
	// Clear screen
	glClear(GL_COLOR_BUFFER_BIT);
	
	[gameEngine update:delta];
	//[gameEngine render];
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)renderScene {
    
  
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self renderScene];
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(mainGameLoop) userInfo:nil repeats:YES];
	[gameEngine doPauseLogicIsPaused:FALSE];
}


- (void)stopAnimation {
    self.animationTimer = nil;

	[gameEngine doPauseLogicIsPaused:TRUE];
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	float xx = -[acceleration x];
	float yy = [acceleration y];
	
	float accelDirX = SIGN(xVelocity) * -1.0f;
	float newDirX = SIGN(xx);
	
	float accelDirY = SIGN(yVelocity) * -1.0f;
	float newDirY = SIGN(yy);
	
	if(accelDirX == newDirX)
		xAccel = (abs(xAccel) + 0.85f) * SIGN(xAccel);
	if(accelDirY == newDirY)
		yAccel = (abs(yAccel) + 0.85f) * SIGN(yAccel);
	
	xVelocity = -xAccel * xx;
	yVelocity = -yAccel * yy;
	
	[gameEngine updateAccelerometer:CGPointMake(xVelocity, yVelocity)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:touch.view];
	
	CGRect rect = touch.view.frame;
	location.y = rect.size.height - location.y;
	
	[gameEngine updateInputInPoint:location InputPressed:TRUE InputReleased:FALSE];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:touch.view];
	
	CGRect rect = touch.view.frame;
	location.y = rect.size.height - location.y;
	
	[gameEngine updateInputInPoint:location InputPressed:TRUE InputReleased:FALSE];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:touch.view];
	
	CGRect rect = touch.view.frame;
	location.y = rect.size.height - location.y;
	
	[gameEngine updateInputInPoint:location InputPressed:FALSE InputReleased:TRUE];
}



- (void)dealloc {
    
    [self stopAnimation];
	
	if( gameEngine )
	{
		[gameEngine shutdown];
		[gameEngine release];
	}
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

@end
