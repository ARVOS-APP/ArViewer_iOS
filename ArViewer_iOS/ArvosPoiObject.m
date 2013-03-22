/*
 * ArvosPoiObject.m - ArViewer_iOS
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

#import "Arvos.h"
#import "ArvosPoi.h"
#import "ArvosPoiObject.h"
#import "ArvosObject.h"
#import "NSDictionary+ArvosVecParsing.h"

@interface ArvosPoiObject () {
    
    GLfloat mStartPosition[3];
    GLfloat mEndPosition[3];
    
	GLfloat mStartScale[3];
	GLfloat mEndScale[3];
    
	GLfloat mStartRotation[4];
	GLfloat mEndRotation[4];
    
    long mWorldStartTime;
	long mWorldIteration;
    
    __weak ArvosPoi* _parent;
}

- (void)parseVec3f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(GLfloat*)buffer
      withDefaultX:(GLfloat)defaultValueX
      withDefaultY:(GLfloat)defaultValueY
      withDefaultZ:(GLfloat)defaultValueZ DEPRECATED_ATTRIBUTE;

- (void)parseVec4f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(GLfloat*)buffer
      withDefaultX:(GLfloat)defaultValueX
      withDefaultY:(GLfloat)defaultValueY
      withDefaultZ:(GLfloat)defaultValueZ
      withDefaultA:(GLfloat)defaultValueA DEPRECATED_ATTRIBUTE;

- (ArvosObject*)findArvosObject:(NSArray*)arvosObjects;

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
        _parent = poi;
        self.animationDuration = poi.animationDuration;
        self.isActive = YES;
        
        mWorldIteration = (long)-1;
        mWorldStartTime = (long)-1;
	}
	return self;
}

- (NSString*)parseFromDictionary:(NSDictionary*)inDictionary {
    
    self.textureUrl = inDictionary[@"texture"];
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
    self.isActive = [inDictionary objectForKey:@"isActive"] ? (BOOL)inDictionary[@"isActive"] : YES;
    
    /*
     mStartPosition[0] = mStartPosition[1] = mStartPosition[2] = .0;
     [inDictionary[@"startPosition"] parseVec3f:mStartPosition];
     
     mEndPosition[0] = mStartPosition[0];
     mEndPosition[1] = mStartPosition[1];
     mEndPosition[2] = mStartPosition[1];
     [inDictionary[@"endPosition"] parseVec3f:mEndPosition];
     
     mStartScale[0] = mStartScale[1] = mStartScale[2] = .0;
     [inDictionary[@"startScale"] parseVec3f:mStartScale];
     */
    
    [self parseVec3f:inDictionary
                name:@"startPosition"
              buffer:mStartPosition
         withDefaultX:0.
         withDefaultY:0.
         withDefaultZ:0.];
    
    [self parseVec3f:inDictionary
                name:@"endPosition"
              buffer:mEndPosition
        withDefaultX:mStartPosition[0]
        withDefaultY:mStartPosition[1]
        withDefaultZ:mStartPosition[2]];
    
    [self parseVec3f:inDictionary
                name:@"startScale"
              buffer:mStartScale
        withDefaultX:1.
        withDefaultY:1.
        withDefaultZ:1.];
    
    [self parseVec3f:inDictionary
                name:@"endScale"
              buffer:mEndScale
        withDefaultX:mStartScale[0]
        withDefaultY:mStartScale[1]
        withDefaultZ:mStartScale[2]];
    
    [self parseVec4f:inDictionary
                name:@"startRotation"
              buffer:mStartRotation
        withDefaultX:0.
        withDefaultY:1.
        withDefaultZ:0.
        withDefaultA:0.];
    
    [self parseVec4f:inDictionary
                name:@"endRotation"
              buffer:mEndRotation
        withDefaultX:mStartRotation[0]
        withDefaultY:mStartRotation[1]
        withDefaultZ:mStartRotation[2]
        withDefaultA:mStartRotation[3]];

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
            buffer:(GLfloat*)buffer
      withDefaultX:(GLfloat)defaultValueX
      withDefaultY:(GLfloat)defaultValueY
      withDefaultZ:(GLfloat)defaultValueZ {
    
    buffer[0] = defaultValueX;
    buffer[1] = defaultValueY;
    buffer[2] = defaultValueZ;
    
    NSArray * jsonArray = [inDictionary objectForKey:name];
    if (jsonArray != nil) {
        
        for (NSDictionary* dictionary in jsonArray) {
            id value = [dictionary objectForKey:@"x"];
            buffer[0] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : buffer[0]);
            
            value = [dictionary objectForKey:@"y"];
            buffer[1] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : buffer[1]);
            
            value = [dictionary objectForKey:@"z"];
            buffer[2] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : buffer[2]);
        }
    }
}

- (void)parseVec4f:(NSDictionary*)inDictionary
              name:(NSString*)name
            buffer:(GLfloat*)buffer
      withDefaultX:(GLfloat)defaultValueX
      withDefaultY:(GLfloat)defaultValueY
      withDefaultZ:(GLfloat)defaultValueZ
      withDefaultA:(GLfloat)defaultValueA {
    
    buffer[0] = defaultValueX;
    buffer[1] = defaultValueY;
    buffer[2] = defaultValueZ;
    buffer[3] = defaultValueA;
    
    NSArray * jsonArray = [inDictionary objectForKey:name];
    if (jsonArray != nil) {
        
        for (NSDictionary* dictionary in jsonArray) {
            id value = [dictionary objectForKey:@"x"];
            buffer[0] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : buffer[0]);
            
            value = [dictionary objectForKey:@"y"];
            buffer[1] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : buffer[1]);
            
            value = [dictionary objectForKey:@"z"];
            buffer[2] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : buffer[2]);
            
            value = [dictionary objectForKey:@"a"];
            buffer[3] = (GLfloat)((value != nil) ? (GLfloat)[value doubleValue] : buffer[3]);
        }
    }
}

- (ArvosObject*)findArvosObject:(NSArray*)arvosObjects {
    NSInteger myId = self.id;
    NSInteger index = [arvosObjects indexOfObjectPassingTest:^BOOL(ArvosObject* obj, NSUInteger idx, BOOL *stop) {
        return obj.id == myId;
    }];
    return NSNotFound == index ? [[ArvosObject alloc]initWithId:self.id] : arvosObjects[index];
}

- (ArvosObject*)getObjectAtCurrentTime:(long)time
                       existingObjects:(NSMutableArray*)arvosObjects{
    
    ArvosObject* result = nil;
    
    if(mWorldStartTime < 0)
    {
        mWorldStartTime = time;
        mWorldIteration = 0;
    }
    
    if (self.isActive == NO) {
        return result;
    }
    
    long duration = (self.animationDuration > 0) ? self.animationDuration : self.parent.animationDuration;
    if (self.parent.animationDuration <= 0 || duration <= 0)
    {
        result = [self findArvosObject:arvosObjects];
        result.name = self.name;
        result.textureUrl = self.textureUrl;
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

    long worldTime = time - mWorldStartTime;
    long iteration = worldTime / self.parent.animationDuration;
    if (iteration > mWorldIteration)
    {
        mWorldIteration = iteration;
        [self.parent requestStop:self];
        return nil;
    }
    
    if (self.textureUrl == nil)
    {
        return nil;
    }
    
    long loopTime = worldTime % self.parent.animationDuration;
    if (loopTime < self.startTime || loopTime >= self.startTime + duration)
    {
        return nil;
    }
    
    float factor = loopTime - self.startTime;
    factor /= duration;
    
    result = [self findArvosObject:arvosObjects];
    result.name = self.name;
    result.textureUrl = self.textureUrl;
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
    
    if (factor > 0)
    {
        position[0] = mStartPosition[0] + factor * (mEndPosition[0] - mStartPosition[0]);
        position[1] = mStartPosition[1] + factor * (mEndPosition[1] - mStartPosition[1]);
        position[2] = mStartPosition[2] + factor * (mEndPosition[2] - mStartPosition[2]);
    }
    
    if (factor > 0)
    {
        scale[0] = mStartScale[0] + factor * (mEndScale[0] - mStartScale[0]);
        scale[1] = mStartScale[1] + factor * (mEndScale[1] - mStartScale[1]);
        scale[2] = mStartScale[2] + factor * (mEndScale[2] - mStartScale[2]);
    }
    
    if (factor > 0)
    {
        rotation[0] = mStartRotation[0] + factor * (mEndRotation[0] - mStartRotation[0]);
        rotation[1] = mStartRotation[1] + factor * (mEndRotation[1] - mStartRotation[1]);
        rotation[2] = mStartRotation[2] + factor * (mEndRotation[2] - mStartRotation[2]);
        rotation[3] = mStartRotation[3] + factor * (mEndRotation[3] - mStartRotation[3]);
    }
    return result;
}

@end
