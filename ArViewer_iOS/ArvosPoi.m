/*
 * ArvosPoi.m - ArViewer_iOS
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
#import "ArvosAugment.h"
#import "ArvosPoi.h"
#import "ArvosPoiObject.h"
#import "ArvosObject.h"
#import "ArvosDebugView.h"

@interface ArvosPoi () {
    Arvos*  mInstance;
    NSMutableArray* objectsClicked;
    NSMutableArray* objectsToStart;
    NSMutableArray* objectsToDeactivate;
    NSMutableDictionary* objectsToDraw;
}

@end

@implementation ArvosPoi

- (id)initWithAugment:(ArvosAugment*)augment {
    self = [super init];
	if (self) {
        mInstance = [Arvos sharedInstance];
        self.parent = augment;
        self.poiObjects = [NSMutableArray array];
        
        objectsClicked = [NSMutableArray array];
        objectsToStart = [NSMutableArray array];
        objectsToDeactivate = [NSMutableArray array];
        objectsToDraw = [NSMutableDictionary dictionaryWithCapacity:4];
	}
	return self;
}

- (NSString*)parseFromDictionary:(NSDictionary*)inDictionary {
    if ([inDictionary objectForKey:ArvosKeyAnimationDuration]) {
        self.animationDuration = [inDictionary[ArvosKeyAnimationDuration] longValue];
    }
    else {
        self.animationDuration = 0;
    }
    self.developerKey = inDictionary[ArvosKeyDeveloperKey];
    
    if ([inDictionary objectForKey:ArvosKeyLat] && [inDictionary objectForKey:ArvosKeyLon])
    {
        CLLocationCoordinate2D c = {
            .longitude = [inDictionary[ArvosKeyLon] doubleValue],
            .latitude = [inDictionary[ArvosKeyLat] doubleValue]
        };
        self.coordinate = c;
    }
    
    NSArray* jsonPoiObjects = inDictionary[ArvosKeyPoiObjects];
    
    if (jsonPoiObjects == nil || [jsonPoiObjects count] == 0)
    {
        return @"No poiObjects found in poi.";
    }
    
    for (NSDictionary* dictionary in jsonPoiObjects) {
        ArvosPoiObject* newPoiObject = [[ArvosPoiObject alloc] initWithPoi:self];
        NSString* result = [newPoiObject parseFromDictionary:dictionary];
        if (nil != result) {
            return result;
        }
        [self.poiObjects addObject:newPoiObject];
    }

    return nil;
}

- (CLLocationDegrees)longitude {
	return self.coordinate.longitude;
}

- (void)setLongitude:(CLLocationDegrees)longitude {
	CLLocationCoordinate2D c = self.coordinate;
	c.longitude = longitude;
	self.coordinate = c;
}

- (CLLocationDegrees)latitude {
	return self.coordinate.latitude;
}

- (void)setLatitude:(CLLocationDegrees)latitude {
	CLLocationCoordinate2D c = self.coordinate;
	c.latitude = latitude;
	self.coordinate = c;
}

- (void)getObjectsAtCurrentTime:(long)time
                    arrayToFill:(NSMutableArray*)resultObjects
                existingObjects:(NSMutableArray*)arvosObjects {
    
    GLfloat offsetX = 0.;
    GLfloat offsetZ = 0.;
    
    if (self.coordinate.longitude != 0. || self.coordinate.latitude != 0.)
    {
        CLLocation * currentLocation = [[CLLocation alloc] initWithLatitude:mInstance.location.coordinate.latitude
                                                                  longitude:0.];
        
        CLLocation * poiLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude
                                                              longitude:0.];
        offsetZ = [currentLocation distanceFromLocation:poiLocation];
        
        if (mInstance.location.coordinate.latitude > self.coordinate.latitude)
        {
            if (offsetZ < 0)
            {
                offsetZ = -offsetZ;
            }
        }
        else
        {
            if (offsetZ > 0)
            {
                offsetZ = -offsetZ;
            }
        }
        
        currentLocation = [[CLLocation alloc] initWithLatitude:0.
                                                     longitude:mInstance.location.coordinate.longitude];
        poiLocation = [[CLLocation alloc] initWithLatitude:0.
                                                 longitude:self.coordinate.longitude];
       
        offsetX = [currentLocation distanceFromLocation:poiLocation];
        if (mInstance.location.coordinate.longitude > self.coordinate.longitude)
        {
            if (offsetX > 0)
            {
                offsetX = -offsetX;
            }
        }
        else
        {
            if (offsetX < 0)
            {
                offsetX = -offsetX;
            }
        }
    }
    
    [objectsToDraw removeAllObjects];
    for (ArvosPoiObject* poiObject in self.poiObjects) {
        
        ArvosObject* arvosObject = [poiObject getObjectAtCurrentTime:time existingObjects:arvosObjects];
        if (arvosObject != nil) {
            
            GLfloat* position = [arvosObject getPosition];
            position[0] += offsetX;
            position[2] += offsetZ;

            [resultObjects addObject:arvosObject];
            objectsToDraw[arvosObject.name] = arvosObject;
        }
    }
    
    for (ArvosPoiObject* poiObject in objectsClicked) {
        [poiObject onClick];
    }
    [objectsClicked removeAllObjects];
    
    for (ArvosPoiObject* poiObject in objectsToDeactivate) {
        [poiObject stop];
    }
    [objectsToDeactivate removeAllObjects];
    
    for (ArvosPoiObject* poiObject in objectsToStart) {
        [poiObject start:time];
        
        if([objectsToDraw objectForKey:poiObject.name] == nil) {
            
            ArvosObject* arvosObject = [poiObject getObjectAtCurrentTime:time
                                                         existingObjects:arvosObjects];
            if( arvosObject != nil) {
                
                [resultObjects addObject:arvosObject];
                objectsToDraw[arvosObject.name] = arvosObject;
            }
        }
    }
    [objectsToStart removeAllObjects];
}

- (void)requestActivate:(ArvosPoiObject*)poiObject {
    
    poiObject.isActive = YES;
    [self requestStart:poiObject];
}

- (void)requestStart:(ArvosPoiObject*)poiObject {
    
    [objectsToStart addObject:poiObject];
}

- (void)requestStop:(ArvosPoiObject*)poiObject {
    
    [objectsToDeactivate addObject:poiObject];
}

- (void)requestDeactivate:(ArvosPoiObject*)poiObject {
    
    poiObject.isActive = NO;
    [self requestStop:poiObject];
}

- (void)addClick:(ArvosPoiObject*)poiObject {
    
    [mInstance.debugView setDebugStringWithKey:@"touchObject"
                                  formatString:@"Object: %@", poiObject.name];
    
    [objectsClicked addObject:poiObject];
}

- (ArvosPoiObject*)findPoiObject:(NSString*)name {
    
    for (ArvosPoiObject* poiObject in self.poiObjects)
    {
        if ([name isEqualToString:poiObject.name])
        {
            return poiObject;
        }
    }
    for (ArvosPoi* poi in self.parent.pois)
    {
        for (ArvosPoiObject* poiObject in poi.poiObjects)
        {
            if ([name isEqualToString:poiObject.name])
            {
                return poiObject;
            }
        }
    }
    return NULL;
}
@end
