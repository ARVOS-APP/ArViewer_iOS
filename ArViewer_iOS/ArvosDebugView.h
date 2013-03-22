//
//  ArvosDebugView.h
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 3/22/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A semitransparent text view to print debug me
 */
@interface ArvosDebugView : UIView {
	UIFont*					mFont;
	NSMutableDictionary*	mDebugStrings;
	CGFloat					mFontSize;
}

/**
 initializes the view with the given frame and font size
 @param frame frame size
 @param fontSize font size
 */
- (id)initWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize;

/**
 Sets the debug output for a given key. Thread safe
 @param key the key to associate the string with. Every key's string will be 
 drawn in a separate line. to remove a key, set the corresponding value nil.
 @param inFormat format string with parameters
 */
- (void)setDebugStringWithKey:(id<NSCopying>)key
				 formatString:(NSString *)inFormat, ...;

@end
