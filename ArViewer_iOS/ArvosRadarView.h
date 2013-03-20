//
//  ArvosRadarView.h
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 3/20/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Radar View
 */

@interface ArvosRadarView : UIView

/**
 Rotation Property
 Rotates the view around its center point. The angle is in degrees and
 rotating clockwise.
 */
@property CGFloat rotation;

/**
 Adds an annotation in the view.
 @param distanceFromCenter the distance from the center of the view. Measured 
 relative, 0 means in the center, 1 means on the outer bound of the view.
 @param phi The angle of the annotation. Measured in degrees and rotating 
 clockwise
 */

- (void)addAnnotationAt:(CGFloat)distanceFromCenter angle:(CGFloat)phi;

/**
 Removes all Annotations from the view
 */
- (void)removeAllAnnotations;

@end
