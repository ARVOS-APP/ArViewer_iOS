/*
 * ArvosAugment.h - ArViewer_iOS
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
 * @param inDictionary The augment description in JSON format.
 */
- (id)initWithDictionary:(NSDictionary*)inDictionary;

/**
 * Fills the properties of one augment by parsing a description in JSON
 * format downloaded from the web.
 *
 * @param data The augment description in JSON format.
 * @return nil or an error message.
 */
- (NSString*)parseFromData:(NSData*)data;

/**
 * Synchronously downloads all texture of an augment.
 *
 * @return nil if all images could be downloaded, or an error message otherwise
 */
- (NSString*)downloadTexturesSynchronously;

/**
 * Get the list of objects to display at the current time
 *
 * @param time time in milliseconds for which the objects are requested
 * @param arrayToFill list to place resulting objects in
 * @param existingObjects array of objects returned the last time, used for reusing existing objects
 */
- (void)getObjectsAtCurrentTime:(long)time
                    arrayToFill:(NSMutableArray*)resultObjects
                existingObjects:(NSMutableArray*)arvosObjects;

/**
 * Handles a click on an object in the opengl view.
 *
 * @param id
 *            The id of the object clicked.
 */
- (void)addClickForObjectWithId:(int)objectId;

@property(strong) NSString*           name;
@property(strong) NSString*           url;
@property(strong) NSString*           author;
@property(strong) NSString*           description;
@property CLLocationDegrees           longitude;
@property CLLocationDegrees           latitude;
@property CLLocationCoordinate2D      coordinate;
@property(strong) NSString*           developerKey;
@property(readonly) NSArray*          pois;

@end
