/*
 ArvosPoiObject.m - ArViewer_iOS
 
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

#import "Arvos.h"
#import "ArvosPoi.h"
#import "ArvosPoiObject.h"

@interface ArvosPoiObject () {
}

- (void)parseVec3f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(ArvosFloat*)buffer;

- (void)parseVec4f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(ArvosFloat*)buffer;

@end

static int mNextId = 0;

@implementation ArvosPoiObject

+ (int) getNextId {
    return ++mNextId;
}

- (id)initWithPoi:(ArvosPoi*)poi {
    self = [super init];
	if (self) {
        self.id = [ArvosPoiObject getNextId];
        self.parent = poi;
        self.animationDuration = poi.animationDuration;
        self.isActive = YES;
	}
	return self;
}

- (NSString*)parseFromDictionary:(NSDictionary*)inDictionary {
    
    self.texture = inDictionary[@"texture"];
    self.name = inDictionary[ArvosKeyName];
    self.billboardHandling = inDictionary[@"billboardHandling"];
    
    if (self.billboardHandling != nil
        && ![ArvosBillboardHandlingNone isEqualToString:self.billboardHandling]
        && ![ArvosBillboardHandlingCylinder isEqualToString:self.billboardHandling]
        && ![ArvosBillboardHandlingSphere isEqualToString:self.billboardHandling])
    {
        return [@"Illegal value for billboardHandling: " stringByAppendingString:self.billboardHandling];
    }
    
    self.startTime = [inDictionary objectForKey:@"startTime"] ? (long)inDictionary[@"startTime"] : 0;
    self.animationDuration = [inDictionary objectForKey:@"duration"] ? (long)inDictionary[@"duration"] : 0;
    self.loop = [inDictionary objectForKey:@"loop"] ? (BOOL)inDictionary[@"loop"] : NO;
    self.isActive = [inDictionary objectForKey:@"isActive"] ? (BOOL)inDictionary[@"isActive"] : NO;
    
    ArvosFloat buffer[4];
    [self parseVec3f:inDictionary
                name:@"startPosition"
              buffer:buffer];
    self.startPositionX = buffer[0];
    self.startPositionY = buffer[1];
    self.startPositionZ = buffer[2];
    
    [self parseVec3f:inDictionary
                name:@"endPosition"
              buffer:buffer];
    self.endPositionX = buffer[0];
    self.endPositionY = buffer[1];
    self.endPositionZ = buffer[2];
    
    [self parseVec3f:inDictionary
                name:@"startScale"
              buffer:buffer];
    self.startScaleX = buffer[0];
    self.startScaleY = buffer[1];
    self.startScaleZ = buffer[2];
    
    [self parseVec3f:inDictionary
                name:@"endScale"
              buffer:buffer];
    self.endScaleX = buffer[0];
    self.endScaleY = buffer[1];
    self.endScaleZ = buffer[2];
    
    [self parseVec4f:inDictionary
                name:@"startRotation"
              buffer:buffer];
    self.startRotationX = buffer[0];
    self.startRotationY = buffer[1];
    self.startRotationZ = buffer[2];
    self.startRotationA = buffer[3];
    
    [self parseVec4f:inDictionary
                name:@"endRotation"
              buffer:buffer];
    self.endRotationX = buffer[0];
    self.endRotationY = buffer[1];
    self.endRotationZ = buffer[2];
    self.endRotationA = buffer[3];

    NSArray * jsonArray = [inDictionary objectForKey:@"onClick"];
    if (jsonArray != nil) {
        
        for (NSDictionary* dictionary in jsonArray) {
            id value = [dictionary objectForKey:@"url"];
            if (value != nil) {
                if (self.onClickUrls == nil) {
                    self.onClickUrls = [NSMutableArray array];
                }
                [self.onClickUrls addObject:value];
            }
            value = [dictionary objectForKey:@"activate"];
            if (value != nil) {
                if (self.onClickActivates == nil) {
                    self.onClickActivates = [NSMutableArray array];
                }
                [self.onClickActivates addObject:value];
            }
            value = [dictionary objectForKey:@"deactivate"];
            if (value != nil) {
                if (self.onClickDeactivates == nil) {
                    self.onClickDeactivates = [NSMutableArray array];
                }
                [self.onClickDeactivates addObject:value];
            }
        }
    }

    jsonArray = [inDictionary objectForKey:@"onDurationEnd"];
    if (jsonArray != nil) {
        
        for (NSDictionary* dictionary in jsonArray) {
            id value = [dictionary objectForKey:@"url"];
            if (value != nil) {
                if (self.onDurationEndUrls == nil) {
                    self.onDurationEndUrls = [NSMutableArray array];
                }
                [self.onDurationEndUrls addObject:value];
            }
            value = [dictionary objectForKey:@"activate"];
            if (value != nil) {
                if (self.onDurationEndActivates == nil) {
                    self.onDurationEndActivates = [NSMutableArray array];
                }
                [self.onDurationEndActivates addObject:value];
            }
            value = [dictionary objectForKey:@"deactivate"];
            if (value != nil) {
                if (self.onDurationEndDeactivates == nil) {
                    self.onDurationEndDeactivates = [NSMutableArray array];
                }
                [self.onDurationEndDeactivates addObject:value];
            }
        }
    }
    return nil;
}

- (void)parseVec3f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(ArvosFloat*)buffer {
    
    buffer[0] = 0.;
    buffer[1] = 0.;
    buffer[2] = 0.;
    
    NSArray * jsonArray = [inDictionary objectForKey:name];
    if (jsonArray != nil) {
        
        for (NSDictionary* dictionary in jsonArray) {
            id value = [dictionary objectForKey:@"x"];
            buffer[0] = (ArvosFloat)((value != nil ) ? (ArvosFloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"y"];
            buffer[1] = (ArvosFloat)((value != nil ) ? (ArvosFloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"z"];
            buffer[2] = (ArvosFloat)((value != nil ) ? (ArvosFloat)[value doubleValue] : 0.);
        }
    }
}

- (void)parseVec4f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(ArvosFloat*)buffer {
    
    buffer[0] = 0.;
    buffer[1] = 0.;
    buffer[2] = 0.;
    buffer[3] = 0.;
    
    NSArray * jsonArray = [inDictionary objectForKey:name];
    if (jsonArray != nil) {
        
        for (NSDictionary* dictionary in jsonArray) {
            id value = [dictionary objectForKey:@"x"];
            buffer[0] = (ArvosFloat)((value != nil ) ? (ArvosFloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"y"];
            buffer[1] = (ArvosFloat)((value != nil ) ? (ArvosFloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"z"];
            buffer[2] = (ArvosFloat)((value != nil ) ? (ArvosFloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"a"];
            buffer[3] = (ArvosFloat)((value != nil ) ? (ArvosFloat)[value doubleValue] : 0.);
        }
    }
}

@end
