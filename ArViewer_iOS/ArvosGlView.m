/*
 * ArvosGlView.m - ArViewer_iOS
 *
 * Copyright (C) 2013, Peter Graf, Ulrich Zurucker
 *
 * This file is part of Arvos - AR Viewer Open Source for iOS.
 * Arvos is free software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * For more information on the AR Viewer Open Source
 * please see: http://www.arvos-app.com/.
 */

#include <sys/time.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "ArvosGlView.h"
#import "Arvos.h"
#import "ArvosAugment.h"
#import "ArvosObject.h"
#import "ArvosRadarView.h"
#import "ArvosDebugView.h"


@interface ArvosGlView () {

	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
    
	// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
	GLuint depthRenderbuffer;
	
	BOOL animating;
	BOOL displayLinkSupported;
	NSInteger animationFrameInterval;
	// Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	// CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	// The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
	// isn't available.
	id displayLink;
    NSTimer *animationTimer;
	
	UIAccelerationValue	accel[3];
    
    ArvosAugment*   mAugment;
    NSMutableArray* mArvosObjects;
    Arvos*          mInstance;
}

@end

// A class extension to declare private methods
@interface ArvosGlView (private)

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)setupView;

@end

@implementation ArvosGlView

@synthesize animating;
@dynamic animationFrameInterval;

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class)layerClass {
	return [CAEAGLLayer class];
}

- (void)dealloc {
    
    [mArvosObjects removeAllObjects];
    
	if (self.animating) {
		[self stopAnimation];
	}
}

- (id)initWithFrame:(CGRect)frame
          andAugment:(ArvosAugment*)augment {
    
    if ((self = [super initWithFrame:frame])) {
        
        mAugment = augment;
        mArvosObjects = [NSMutableArray array];
        mInstance = [Arvos sharedInstance];
        
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
		eaglLayer.opaque = NO;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
		if (!context || ![EAGLContext setCurrentContext:context]) {
			return nil;
		}
        
		animating = FALSE;
		displayLinkSupported = FALSE;
		animationFrameInterval = 1;
		displayLink = nil;
		animationTimer = nil;
        
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
			displayLinkSupported = TRUE;
        }
		
        accel[0] = accel[1] = accel[2] = 0;
		
		[self setupView];
	}
	
	return self;
}

-(void)setupView {
    
    const GLfloat zNear = 0.1,
    zFar = 1000.0,
    fieldOfView = 60.0;
	GLfloat					size;
    
	//Set the OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	CGRect rect = self.bounds;
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
	glViewport(0, 0, rect.size.width, rect.size.height);
	
	//Make the OpenGL modelview matrix the default
	glMatrixMode(GL_MODELVIEW);
    
    glEnable(GL_TEXTURE_2D); // Enable mTexture Mapping ( NEW )
    glShadeModel(GL_SMOOTH); // Enable Smooth Shading
    
    glClearDepthf(1.0f); // Depth Buffer Setup
    glEnable(GL_DEPTH_TEST); // Enables Depth Testing
    glDepthFunc(GL_LEQUAL); // The Type Of Depth Testing To Do
    
    // Really Nice Perspective Calculations
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    
    glClearColor(0, 0, 0, 0);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
}

// Updates the OpenGL view
- (void)drawView {
    
    static long startSeconds = 0L;
    struct timeval time;
    gettimeofday(&time, NULL);
    
    if (startSeconds == 0L) {
        startSeconds = time.tv_sec;
    }
        
    long millisAfterStart = ((time.tv_sec - startSeconds) * 1000) + (time.tv_usec / 1000);
    
    // Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];
    
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    NSMutableArray * existingArvosObjects = [[NSMutableArray alloc] initWithArray:mArvosObjects];
    [mArvosObjects removeAllObjects];
    
    [mAugment getObjectsAtCurrentTime:millisAfterStart arrayToFill:mArvosObjects existingObjects:existingArvosObjects];
    
    [mInstance.radarView addAnnotationsForObjects:mArvosObjects];
    
    GLfloat P[16];
    BOOL hasBeenTouched = mInstance.hasBeenTouched;
    if (hasBeenTouched) {
        
        glGetFloatv(GL_PROJECTION_MATRIX, P);
        mInstance.touchedObjectId = 0;
    }
    
   
    for (ArvosObject* arvosObject in mArvosObjects) {
        glLoadIdentity();
        [arvosObject draw];
        
        if (hasBeenTouched) {
            
            GLfloat M[16];
            glGetFloatv(GL_MODELVIEW_MATRIX, M);
            [mInstance handleTouchForObject:arvosObject.id
                                  modelView:M
                                 projection:P
                                      width:self.frame.size.width
                                     height:self.frame.size.height];
        }
    }
    
    if (hasBeenTouched) {
        
        if(mInstance.touchedObjectId != 0) {
            
            [mAugment addClickForObjectWithId:mInstance.touchedObjectId];
        }
        mInstance.hasBeenTouched = NO;
    }
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
        NSLog(@"Error. glError: 0x%04X\n", err);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (mInstance.hasBeenTouched) {
        return;
    }
    
    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches) {
        mInstance.touchLocation = [touch locationInView:touch.view];
        mInstance.hasBeenTouched = YES;
        [mInstance.debugView setDebugStringWithKey:@"touch"
                                      formatString:@"Touch: %g %g", mInstance.touchLocation.x, mInstance.touchLocation.y];
    }
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews {
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self drawView];
}

- (BOOL)createFramebuffer {
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer {
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

- (NSInteger) animationFrameInterval {
	return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if (frameInterval >= 1)
	{
		animationFrameInterval = frameInterval;
		
		if (animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void)startAnimation {
	if (!animating)
	{
		if (displayLinkSupported)
		{
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.
			
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
			[displayLink setFrameInterval:animationFrameInterval];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView) userInfo:nil repeats:TRUE];
		
		animating = TRUE;
	}
}

- (void)stopAnimation {
	if (animating)
	{
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}
		
		animating = FALSE;
	}
}

@end
