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

#import "ArvosAugment.h"

static NSString* _keyName	= @"name";
static NSString* _keyUrl	= @"url";
static NSString* _keyAuthor	= @"author";
static NSString* _keyDesc	= @"description";
static NSString* _keyLon	= @"long";
static NSString* _keyLat	= @"lat";
static NSString*_keyDevKey	= @"devKey";

@implementation ArvosAugment

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self) {
		self.name	= [aDecoder decodeObjectForKey:_keyName];
		self.url	= [aDecoder decodeObjectForKey:_keyUrl];
		self.author	= [aDecoder decodeObjectForKey:_keyAuthor];
		self.description = [aDecoder decodeObjectForKey:_keyDesc];
		self.developerKey = [aDecoder decodeObjectForKey:_keyDevKey];

		CLLocationCoordinate2D c = {
			.longitude = [aDecoder decodeDoubleForKey:_keyLon],
			.latitude = [aDecoder decodeDoubleForKey:_keyLat]
		};
		self.coordinate = c;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary*)inDictionary {
	self = [super init];
	if (self) {
		self.name	= inDictionary[_keyName];
		self.url	= inDictionary[_keyUrl];
		self.author	= inDictionary[_keyAuthor];
		self.description = inDictionary[_keyDesc];
		self.developerKey = inDictionary[_keyDevKey];

		CLLocationCoordinate2D c = {
			.longitude = [inDictionary[_keyLon] doubleValue],
			.latitude = [inDictionary[_keyLat] doubleValue]
		};
		self.coordinate = c;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.name forKey:_keyName];
	[aCoder encodeObject:self.url forKey:_keyUrl];
	[aCoder encodeObject:self.author forKey:_keyAuthor];
	[aCoder encodeObject:self.description forKey:_keyDesc];
	[aCoder encodeObject:self.developerKey forKey:_keyDevKey];
	[aCoder encodeDouble:self.longitude forKey:_keyLon];
	[aCoder encodeDouble:self.latitude forKey:_keyLat];
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
