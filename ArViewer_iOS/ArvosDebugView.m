//
//  ArvosDebugView.m
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 3/22/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import "ArvosDebugView.h"

@implementation ArvosDebugView

- (id)initWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize {
	self = [super initWithFrame:frame];
	if (self) {
		mFontSize = fontSize;
		mDebugStrings = [NSMutableDictionary dictionaryWithCapacity:4];
		mFont = [UIFont systemFontOfSize:mFontSize];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [self initWithFrame:frame fontSize:9.];
	if (self) {

	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[[UIColor colorWithWhite:1. alpha:.4] setFill];
	UIRectFill(rect);
	[[UIColor blackColor] set];

	CGRect targetRect = rect;
	CGFloat lineHeight = mFontSize + 2.;
	targetRect.origin.y = .0;
	targetRect.size.height = lineHeight;
	for (id<NSCopying> key in mDebugStrings) {
		NSString* string = mDebugStrings[key];
		[string drawInRect:rect
				  withFont:mFont
			 lineBreakMode:NSLineBreakByTruncatingMiddle
				 alignment:NSTextAlignmentLeft];
		rect.origin.y += lineHeight;
	}
}

- (BOOL)isOpaque {
	return NO;
}

- (void)setDebugStringWithKey:(id<NSCopying>)key formatString:(NSString *)inFormat, ... {
	if (inFormat != nil) {
		va_list args;
		va_start(args, inFormat);
		NSString* s = [[NSString alloc] initWithFormat:inFormat arguments:args];
		va_end(args);
		dispatch_async(dispatch_get_main_queue(), ^{
			mDebugStrings[key] = s;
		});
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			[mDebugStrings removeObjectForKey:key];
		});
	}
	[self setNeedsDisplay];
}

@end
