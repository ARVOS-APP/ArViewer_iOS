/*
 ArvosAugment.h - ArViewer_iOS
 
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
#import <CoreLocation/CoreLocation.h>

@class ArvosPoi;

/**
 * An augment as shown in the augment viewer.
 * <p>
 * Contains a list of pois.
 *
 * @author peter
 */
@interface ArvosAugment : NSObject

/**
 * Fills the properties of one augment by parsing a description in JSON
 * format downloaded from the web.
 *
 * @param inDictionary
 *            The augment description in JSON format.
 */
- (id)init;

/**
 * Fills the properties of one augment by parsing a description in JSON
 * format downloaded from the web.
 *
 * @param inDictionary
 *            The augment description in JSON format.
 */
- (id)initWithDictionary:(NSDictionary*)inDictionary;

/**
 * Fills the properties of one augment by parsing a description in JSON
 * format downloaded from the web.
 *
 * @param data
 *            The augment description in JSON format.
 * @return nil or an error message.
 */
- (NSString*)parseFromData:(NSData*)data;

/**
 * Synchronously downloads all texture of an augment.
 *
 * @return NIL if all images could be downloaded, or an error message otherwise
 */
- (NSString*)downloadTexturesSynchronously;

- (void)getObjectsAtCurrentTime:(long)time
                    arrayToFill:(NSMutableArray*)resultObjects
                existingObjects:(NSMutableArray*)arvosObjects;

@property(strong) NSString*           name;
@property(strong) NSString*           url;
@property(strong) NSString*           author;
@property(strong) NSString*           description;
@property CLLocationDegrees           longitude;
@property CLLocationDegrees           latitude;
@property CLLocationCoordinate2D      coordinate;
@property(strong) NSString*           developerKey;

@end
