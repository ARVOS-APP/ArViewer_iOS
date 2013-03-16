/*
 ArvosPoiObject.h - ArViewer_iOS
 
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

@class ArvosPoi;

/**
 * A poi object as shown in the opengl view.
 *
 * @author peter
 */
@interface ArvosPoiObject : NSObject

/**
 * Create a poi object.
 *
 * @param poi
 *            The poi the poi object belongs to.
 */
- (id)initWithPoi:(ArvosPoi*)poi;

/**
 * Fills the properties of one poiObject by parsing a description in JSON
 * format downloaded from the web.
 *
 * @param inDictionary
 *            The poiObject description in JSON format.
 * @return nil or an error message.
 */
- (NSString*)parseFromDictionary:(NSDictionary*)inDictionary;

@property int                       id;
@property(strong) NSString*         name;
@property(strong) NSString*         texture;
@property(strong) NSString*         billboardHandling;

@property long                      startTime;
@property long                      animationDuration;

@property BOOL                      loop;
@property BOOL                      isActive;

@property(strong) NSMutableArray*   onClickUrls;
@property(strong) NSMutableArray*   onClickActivates;
@property(strong) NSMutableArray*   onClickDeactivates;

@property(strong) NSMutableArray*   onDurationEndUrls;
@property(strong) NSMutableArray*   onDurationEndActivates;
@property(strong) NSMutableArray*   onDurationEndDeactivates;

@property ArvosFloat                startPositionX;
@property ArvosFloat                startPositionY;
@property ArvosFloat                startPositionZ;

@property ArvosFloat                endPositionX;
@property ArvosFloat                endPositionY;
@property ArvosFloat                endPositionZ;

@property ArvosFloat                startScaleX;
@property ArvosFloat                startScaleY;
@property ArvosFloat                startScaleZ;

@property ArvosFloat                endScaleX;
@property ArvosFloat                endScaleY;
@property ArvosFloat                endScaleZ;

@property ArvosFloat                startRotationX;
@property ArvosFloat                startRotationY;
@property ArvosFloat                startRotationZ;
@property ArvosFloat                startRotationA;

@property ArvosFloat                endRotationX;
@property ArvosFloat                endRotationY;
@property ArvosFloat                endRotationZ;
@property ArvosFloat                endRotationA;

@property long                      timeStarted;
@property(strong) ArvosPoi*         parent;

@end
