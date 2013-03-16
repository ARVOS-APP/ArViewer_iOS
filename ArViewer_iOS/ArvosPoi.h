/*
 ArvosPoi.h - ArViewer_iOS
 
 Copyright (C) 2013, Peter Graf
 
 This file is part of Arvos - AR Viewer Open Source for iOS.
 Arvos is free software.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 For more information on the AR Viewer Open Source or Peter Graf,
 please see: http://www.mission-base.com/.
 */

#import <Foundation/Foundation.h>

@class ArvosAugment;
@class ArvosPoiObject;

/**
 * A poi - point of interest.
 * <p>
 * Contains a list of poiObjects.
 * @author peter
 */
@interface ArvosPoi : NSObject

/**
 * Create a poi.
 *
 * @param poi
 *            The augment the poi belongs to.
 */
- (id)initWithAugment:(ArvosAugment*)augment;

/**
 * Fills the properties of one poi by parsing a description in JSON
 * format downloaded from the web.
 *
 * @param inDictionary
 *            The poi description in JSON format.
 * @return nil or an error message.
 */
- (NSString*)parseFromDictionary:(NSDictionary*)inDictionary;

@property(strong) NSArray* poiObjects;

@property long                      animationDuration;
@property CLLocationDegrees         longitude;
@property CLLocationDegrees         latitude;
@property CLLocationCoordinate2D    coordinate;
@property(strong) NSString*         developerKey;
@property(strong) ArvosAugment*     parent;

@end
