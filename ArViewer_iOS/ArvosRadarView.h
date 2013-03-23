/*
 * ArvosRadarView.h - ArViewer_iOS
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

#import <UIKit/UIKit.h>

/**
 Radar View
 */

@interface ArvosRadarView : UIView

/**
 Adds an annotation in the view.
 @param distanceFromCenter the distance from the center of the view. Measured 
 relative, 0 means in the center, 1 means on the outer bound of the view.
 @param phi The angle of the annotation. Measured in degrees and rotating 
 clockwise
 */

- (void)addAnnotationAt:(CGFloat)distanceFromCenter angle:(CGFloat)phi;

/**
 Adds annotations in the view. Takes the list of arvos objects shown in the 3D view as input
 @param arvosObjects the list of objects shown in the 3D view.
 */
- (void)addAnnotationsForObjects:(NSArray*)arvosObjects;

/**
 Removes all Annotations from the view
 */
- (void)removeAllAnnotations;

@end
