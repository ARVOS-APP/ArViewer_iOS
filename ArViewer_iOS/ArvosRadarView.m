//
//  ArvosRadarView.m
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 3/20/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import "ArvosRadarView.h"

#define CIRCLE_WIDTH 4.

@interface ArvosRadarView () {
	UIColor* _frontColor;
	CGFloat _rotation;
}

@end


@implementation ArvosRadarView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_frontColor = [UIColor redColor];
		self.opaque = NO;
		self.rotation = 45.;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGRect bounds = self.bounds;
	CGFloat myWidth = CGRectGetWidth(bounds);
	CGFloat myHeight = CGRectGetHeight(bounds);

	CGFloat halfWidth = myWidth / 2.;
	CGFloat halfHeight = myHeight / 2.;

	CGFloat radius = MIN(myWidth, myHeight) / 2. - CIRCLE_WIDTH;

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);

	CGContextTranslateCTM(context, halfWidth, halfHeight);
	CGContextRotateCTM(context, -_rotation);

	UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-radius, -radius, 2. * radius, 2. * radius)];
	circlePath.lineWidth = CIRCLE_WIDTH;

	UIBezierPath* northPath = [UIBezierPath new];
	[northPath moveToPoint:CGPointMake(.0, .0)];
	[northPath addLineToPoint:CGPointMake(.0, -radius)];
	northPath.lineWidth = CIRCLE_WIDTH;

	[_frontColor setStroke];
	[circlePath stroke];
	[northPath stroke];
	CGContextRestoreGState(context);
}

- (CGFloat)rotation {
	return _rotation;
}

- (void)setRotation:(CGFloat)rotation {
	_rotation = rotation * M_PI / 180.;
	[self setNeedsDisplay];
}

@end