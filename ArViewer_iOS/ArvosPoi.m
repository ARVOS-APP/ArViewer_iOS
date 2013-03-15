/*
 ArvosPoi.m - ArViewer_iOS
 
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
#import "ArvosAugment.h"
#import "ArvosPoi.h"
#import "ArvosPoiObject.h"

static NSString* _keyLon	= @"long";
static NSString* _keyLat	= @"lat";
static NSString* _keyDevKey	= @"developerKey";

@interface ArvosPoi () {
	Arvos*			mInstance;
    ArvosAugment*   mParent;
	NSMutableArray* mPoiObjects;
}

@end

@implementation ArvosPoi

- (id)initWithAugment:(ArvosAugment*)augment {
    self = [super init];
	if (self) {
        mParent = augment;
        mPoiObjects = [NSMutableArray array];
        mInstance = [Arvos sharedInstance];
	}
	return self;
}

- (NSString*)parseFromDictionary:(NSDictionary*)inDictionary {
    
    if ([inDictionary objectForKey:@"animationDuration"])
    {
        self.animationDuration = (long)inDictionary[@"animationDuration"];
    }
    else
    {
        self.animationDuration = 0;
    }
    self.developerKey = inDictionary[_keyDevKey];
    
    if ([inDictionary objectForKey:_keyLat] && [inDictionary objectForKey:_keyLon])
    {
        CLLocationCoordinate2D c = {
            .longitude = [inDictionary[_keyLon] doubleValue],
            .latitude = [inDictionary[_keyLat] doubleValue]
        };
        self.coordinate = c;
    }
    
    NSArray* jsonPoiObjects = inDictionary[@"poiObjects"];
    
    if (jsonPoiObjects == nil || [jsonPoiObjects count] == 0)
    {
        return @"ERNo poiObjects found in poi.";
    }
    
    for (NSDictionary* dictionary in jsonPoiObjects) {
        
        ArvosPoiObject* jsonPoiObject = [[ArvosPoiObject alloc] initWithPoi:self];
        if (jsonPoiObject != nil) {
            
            NSString* result = [jsonPoiObject parseFromDictionary:dictionary];
            if (![@"OK" isEqualToString:result]) {
                
                return result;
            }
            [mPoiObjects addObject:jsonPoiObject];
            
        } else {
            NBLog(@"failed to init poi");
        }
    }

    return @"OK";
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

@end
