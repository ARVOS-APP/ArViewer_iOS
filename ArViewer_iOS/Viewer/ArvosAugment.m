/*
 * ArvosAugment.m - ArViewer_iOS
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
#import "ArvosURLRequest.h"

@interface ArvosAugment () {
	NSMutableArray* mPois;
}

- (UIImage*)downloadTextureFromUrl:(NSString*)baseUrl ;

@end

@implementation ArvosAugment

- (id)initWithDictionary:(NSDictionary*)inDictionary {
	self = [self init];
	if (self) {
		self.name	= inDictionary[ArvosKeyName];
		self.url	= inDictionary[ArvosKeyUrl];
		self.author	= inDictionary[ArvosKeyAuthor];
		self.description = inDictionary[ArvosKeyDescription];
		self.developerKey = inDictionary[ArvosKeyDeveloperKey];

        if ([inDictionary objectForKey:ArvosKeyLat] && [inDictionary objectForKey:ArvosKeyLon])
        {
            CLLocationCoordinate2D c = {
                .longitude = [inDictionary[ArvosKeyLon] doubleValue],
                .latitude = [inDictionary[ArvosKeyLat] doubleValue]
            };
            self.coordinate = c;
        }
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self) {
		mPois = [NSMutableArray array];
	}
	return self;
}

- (NSString*)parseFromData:(NSData*)data {
    
    NSError* error = nil;
    NSDictionary* jsonAugment = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:&error];
    if (error != nil) {
        return [NSString stringWithFormat:@"Failed to parse JSON augment. %@", error.localizedDescription];
    }
       
    self.name	= jsonAugment[ArvosKeyName];
    self.author	= jsonAugment[ArvosKeyAuthor];
    self.description = jsonAugment[ArvosKeyDescription];
    
    NSArray* jsonPois = jsonAugment[ArvosKeyPois];
    
    if (jsonPois == nil || [jsonPois count] == 0)
    {
        return [@"No pois found in augment " stringByAppendingString:self.name];
    }
    
    for (NSDictionary* dictionary in jsonPois) {
        ArvosPoi* newPoi = [[ArvosPoi alloc] initWithAugment:self];
        NSString* result = [newPoi parseFromDictionary:dictionary];
        if (nil != result) {
            return result;
        }
        [mPois addObject:newPoi];
    }
    return nil;
}

- (NSString*)downloadTexturesSynchronously {

    for (ArvosPoi* poi in mPois) {
        for (ArvosPoiObject* poiObject in poi.poiObjects) {
            if (poiObject.image == nil && poiObject.textureUrl != nil) {
                poiObject.image = [self downloadTextureFromUrl:poiObject.textureUrl];
                if (poiObject.image == nil)
                {
                    return @"Failed to download texture.";
                }
                for (ArvosPoi* otherPoi in mPois) {
                    for (ArvosPoiObject* otherPoiObject in otherPoi.poiObjects) {
                        if (otherPoiObject.image == nil && [poiObject.textureUrl isEqualToString:otherPoiObject.textureUrl]) {
                            otherPoiObject.image = poiObject.image;
                        }
                    }
                }
            }
        }
    }
    return nil;
}

- (void)downloadTexturesAsync:(void(^)(BOOL success, NSError* error))completion {
    for (ArvosPoi* poi in mPois) {
        for (ArvosPoiObject* poiObject in poi.poiObjects) {
            if (!poiObject.image && poiObject.textureUrl) {
                [ArvosURLRequest requestWithURL:[NSURL URLWithString:poiObject.textureUrl]
                                     completion:^(NSData * data, NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (data) {
                                                 UIImage* img = [UIImage imageWithData:data];
                                                 poiObject.image = img;
                                             }
                                             completion(error == nil, error);
                                         });
                                     }];
            }
        }
    }
}

- (UIImage*)downloadTextureFromUrl:(NSString*)url {
    if (url != nil) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (data != nil) {
            return [[UIImage alloc] initWithData:data];
        }
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
    for (ArvosPoi* poi in mPois) {
        
        [poi getObjectsAtCurrentTime:time arrayToFill:resultObjects existingObjects:arvosObjects];
    }
}

- (NSArray*)pois {
    return mPois;
}

- (void)addClickForObjectWithId:(int)objectId {
    
    for (ArvosPoi* poi in mPois) {
        
        for(ArvosPoiObject* poiObject in poi.poiObjects ) {
            
            if (poiObject.id == objectId) {
                
                [poi addClick:poiObject];
                return;
            }
        }
    }
}
@end
