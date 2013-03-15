/*
 ArvosAugment.m - ArViewer_iOS
 
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

static NSString* _keyName	= @"name";
static NSString* _keyUrl	= @"url";
static NSString* _keyAuthor	= @"author";
static NSString* _keyDesc	= @"description";
static NSString* _keyLon	= @"long";
static NSString* _keyLat	= @"lat";
static NSString* _keyDevKey	= @"developerKey";

@interface ArvosAugment () {
	Arvos*			mInstance;
	NSMutableArray* mPois;
}

@end

@implementation ArvosAugment

- (id)initWithDictionary:(NSDictionary*)inDictionary {
	self = [self init];
	if (self) {
		self.name	= inDictionary[_keyName];
		self.url	= inDictionary[_keyUrl];
		self.author	= inDictionary[_keyAuthor];
		self.description = inDictionary[_keyDesc];
		self.developerKey = inDictionary[_keyDevKey];

        if ([inDictionary objectForKey:_keyLat] && [inDictionary objectForKey:_keyLon])
        {
            CLLocationCoordinate2D c = {
                .longitude = [inDictionary[_keyLon] doubleValue],
                .latitude = [inDictionary[_keyLat] doubleValue]
            };
            self.coordinate = c;
        }
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self) {
        mInstance = [Arvos sharedInstance];
		mPois = [NSMutableArray array];
	}
	return self;
}

/**
 * Fills the properties of one augment by parsing a description in JSON
 * format downloaded from the web.
 *
 * @param data
 *            The augment description in JSON format.
 * @return "OK" or "ER" followed by the error message.
 */

- (NSString*) parseFromData:(NSData*)data {
    // TODO: this is quite unsafe. NSJSONSerialization is iOS 5 and above.
    NSDictionary* jsonAugment = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:nil];
    
    NSAssert([jsonAugment isKindOfClass:NSDictionary.class], @"must decode NSArray from JSON");
    
    self.name	= jsonAugment[_keyName];
    self.author	= jsonAugment[_keyAuthor];
    self.description = jsonAugment[_keyDesc];
    
    NSArray* jsonPois = jsonAugment[@"pois"];
    
    if (jsonPois == nil || [jsonPois count] == 0)
    {
        return [@"ERNo pois found in augment " stringByAppendingString:self.name];
    }
    
    for (NSDictionary* dictionary in jsonPois) {
        
        ArvosPoi* newPoi = [[ArvosPoi alloc] initWithAugment:self];
        if (newPoi != nil) {
            
            NSString* result = [newPoi parseFromDictionary:dictionary];
            if (![@"OK" isEqualToString:result]) {
                
                return result;
            }
            [mPois addObject:newPoi];
            
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
