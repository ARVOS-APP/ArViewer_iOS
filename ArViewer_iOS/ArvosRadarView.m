//
//  ArvosRadarView.m
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 3/20/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import "ArvosRadarView.h"

#define CIRCLE_WIDTH 4.
#define ANNOTATION_SIZE 6.

#define MAX_NUM_ANNOTATIONS 32

@interface ArvosRadarView () {
	UIColor*            _frontColor;
	CGFloat             _rotation;
    CGPoint*            _annotationCoordinates;
    NSUInteger          _numAnnotationCoordinates;
}

- (void)drawAnnotationAtPoint:(CGPoint)p viewRadius:(CGFloat)r;

@end

@implementation ArvosRadarView

- (void)dealloc {
    free(_annotationCoordinates);
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
        /* avoid overhead and store coordinates in a plain C-Array */
        _annotationCoordinates = calloc(sizeof(CGPoint), MAX_NUM_ANNOTATIONS);
        _numAnnotationCoordinates = 0;
        NSAssert(_annotationCoordinates != NULL,
                 @"failed to allocate memory for annotation coordinates");

		_frontColor = [UIColor redColor];
		self.opaque = NO;       /* we would get a black background if not */
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
    /* some basic geometry stuff with the given view */
	CGRect bounds = self.bounds;
	CGFloat myWidth = CGRectGetWidth(bounds);
	CGFloat myHeight = CGRectGetHeight(bounds);
	CGFloat halfWidth = myWidth / 2.;
	CGFloat halfHeight = myHeight / 2.;
	CGFloat radius = MIN(myWidth, myHeight) / 2. - CIRCLE_WIDTH;

    /* 
     Get current graphics context and save its state.
     We will manipulate the context transformation matrix and want
     to revert this manipulation when drawing other views
     */
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);

    /*
     For convenience and less calculation, have the views center at (0,0).
     Translate the views transformation matrix, so that (0,0) is in 
     the middle of the rect.
     */
	CGContextTranslateCTM(context, halfWidth, halfHeight);
    /* Rotate the view. Things are upside down, so turn sign of rotation */
	CGContextRotateCTM(context, -_rotation);

    /* Create objects to be drawn */
    
    /* the surrounding circle */
	UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-radius, -radius, 2. * radius, 2. * radius)];
	circlePath.lineWidth = CIRCLE_WIDTH;

    /* a line heading 'north' */
	UIBezierPath* northPath = [UIBezierPath new];
	[northPath moveToPoint:CGPointMake(.0, .0)];
	[northPath addLineToPoint:CGPointMake(.0, -radius)];
	northPath.lineWidth = CIRCLE_WIDTH;

    /* actual drawing happens here */
	[_frontColor setStroke];
	[circlePath stroke];
	[northPath stroke];
    
    /* clip to circle path to avoid drawing outside the circle
     TODO: UZ obviously only present in AppKit not UIKit
    [circlePath setClip];
     */
    
    /* draw annotations */
    for (NSUInteger i=0; i<_numAnnotationCoordinates; ++i) {
        [self drawAnnotationAtPoint:_annotationCoordinates[i]
                         viewRadius:radius];
    }
    
    /* resore graphics context state */
	CGContextRestoreGState(context);
}

- (CGFloat)rotation {
	return _rotation;
}

- (void)setRotation:(CGFloat)rotation {
    /* we get angles in degrees, we need them later to translate the 
     affine transformation matrix of a CGContext which takes radians.
     */
	_rotation = rotation * M_PI / 180.;
	[self setNeedsDisplay];
}

- (void)addAnnotationAt:(CGFloat)distanceFromCenter angle:(CGFloat)phi {
    /* be a good citizen */
    if (_numAnnotationCoordinates == MAX_NUM_ANNOTATIONS) {
        NSLog(@"failed to add annotation, max %u allowed", MAX_NUM_ANNOTATIONS);
        return;
    }
    /* convert coordinates from polar to cartesian */
    CGFloat x = distanceFromCenter * sinf(phi);
    CGFloat y = distanceFromCenter * cosf(phi);
    _annotationCoordinates[_numAnnotationCoordinates] = CGPointMake(x, y);
    _numAnnotationCoordinates++;
    [self setNeedsDisplay];
}

- (void)removeAllAnnotations {
    _numAnnotationCoordinates = 0;
}

#pragma mark - Private Drawing Utilities

- (void)drawAnnotationAtPoint:(CGPoint)p viewRadius:(CGFloat)r {
    /* annotation coordinates are relative 0..1, translate to view */
    CGPoint viewPoint = CGPointMake(p.x * r, p.y * r);
    static CGFloat halfWidth = ANNOTATION_SIZE / 2.;
    CGRect annotationRect = CGRectMake(viewPoint.x - halfWidth,
                                       viewPoint.y - halfWidth,
                                       ANNOTATION_SIZE,
                                       ANNOTATION_SIZE);
    UIBezierPath* annotationCircle = [UIBezierPath bezierPathWithOvalInRect:annotationRect];
    [_frontColor setFill];
    [annotationCircle fill];
}

@end