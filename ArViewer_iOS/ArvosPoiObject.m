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
#import "ArvosObject.h"

@interface ArvosPoiObject () {
    
    GLfloat mStartPosition[3];
    GLfloat mEndPosition[3];
    
	GLfloat mStartScale[3];
	GLfloat mEndScale[3];
    
	GLfloat mStartRotation[4];
	GLfloat mEndRotation[4];
    
    long mWorldStartTime;
	long mWorldIteration;

}

- (void)parseVec3f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(GLfloat*)buffer;

- (void)parseVec4f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(GLfloat*)buffer;

- (ArvosObject*)findArvosObject:(NSMutableArray*)arvosObjects;

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
        
        mWorldIteration = (long)-1;
        mWorldStartTime = (long)-1;
	}
	return self;
}

- (NSString*)parseFromDictionary:(NSDictionary*)inDictionary {
    
    self.texture = inDictionary[@"texture"];
    self.image = nil;
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
    
    [self parseVec3f:inDictionary
                name:@"startPosition"
              buffer:mStartPosition];
    
    [self parseVec3f:inDictionary
                name:@"endPosition"
              buffer:mEndPosition];
    
    [self parseVec3f:inDictionary
                name:@"startScale"
              buffer:mStartScale];
    
    [self parseVec3f:inDictionary
                name:@"endScale"
              buffer:mEndScale];
    
    [self parseVec4f:inDictionary
                name:@"startRotation"
              buffer:mStartRotation];
    
    [self parseVec4f:inDictionary
                name:@"endRotation"
              buffer:mEndRotation];

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
            buffer:(GLfloat*)buffer {
    
    buffer[0] = 0.;
    buffer[1] = 0.;
    buffer[2] = 0.;
    
    NSArray * jsonArray = [inDictionary objectForKey:name];
    if (jsonArray != nil) {
        
        for (NSDictionary* dictionary in jsonArray) {
            id value = [dictionary objectForKey:@"x"];
            buffer[0] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"y"];
            buffer[1] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"z"];
            buffer[2] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : 0.);
        }
    }
}

- (void)parseVec4f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(GLfloat*)buffer {
    
    buffer[0] = 0.;
    buffer[1] = 0.;
    buffer[2] = 0.;
    buffer[3] = 0.;
    
    NSArray * jsonArray = [inDictionary objectForKey:name];
    if (jsonArray != nil) {
        
        for (NSDictionary* dictionary in jsonArray) {
            id value = [dictionary objectForKey:@"x"];
            buffer[0] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"y"];
            buffer[1] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"z"];
            buffer[2] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : 0.);
            
            value = [dictionary objectForKey:@"a"];
            buffer[3] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : 0.);
        }
    }
}

- (ArvosObject*)findArvosObject:(NSMutableArray*)arvosObjects {
    for( ArvosObject* arvosObject in arvosObjects) {
        if (arvosObject.id == self.id) {
            [arvosObjects removeObject:arvosObject];
            return arvosObject;
        }
    }
    return [[ArvosObject alloc]initWithId:self.id];
}

- (ArvosObject*)getObjectAtCurrentTime:(long)time
                       existingObjects:(NSMutableArray*)arvosObjects{
    
    if (self.image == nil) {
        return nil;
    }
    
    if(mWorldStartTime < 0)
    {
        mWorldStartTime = time;
        mWorldIteration = 0;
    }
    
    ArvosObject* result = [self findArvosObject:arvosObjects];
    result.name = self.name;
    result.texture = self.texture;
    result.billboardHandling = self.billboardHandling;
    
    GLfloat* position = [result getPosition];
    position[0] = mStartPosition[0];
    position[1] = mStartPosition[1];
    position[2] = mStartPosition[2];
    
    GLfloat* scale = [result getScale];
    scale[0] = mStartScale[0];
    scale[1] = mStartScale[1];
    scale[2] = mStartScale[2];
    
    GLfloat* rotation = [result getRotation];
    rotation[0] = mStartRotation[0];
    rotation[1] = mStartRotation[1];
    rotation[2] = mStartRotation[2];
    rotation[3] = mStartRotation[3];
    
    result.image = self.image;

    return result;
}

- (GLfloat*)getStartPosition{ return mStartPosition; }
- (GLfloat*)getEndPosition{ return mEndPosition; }
- (GLfloat*)getStartScale{ return mStartScale; }
- (GLfloat*)getEndScale{ return mEndScale; }
- (GLfloat*)getStartRotation{ return mStartRotation; }
- (GLfloat*)getEndRotation{ return mEndRotation; }

@end
