/*
 Arvos.m - ArViewer_iOS
 
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

@implementation Arvos

static Arvos* _sharedInstance = nil;

+ (Arvos*)sharedInstance {
    if (nil == _sharedInstance) {
        _sharedInstance = [[super allocWithZone:NULL] init];
    }
	return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init {
	if (_sharedInstance) {
		return _sharedInstance;
	}
	_sharedInstance = self = [super init];
	if (self) {
		self.augmentsUrl = @"http://www.mission-base.com/arvos/augments-iOS.json";
		self.useCache = YES;
		self.version = 1;
	}
	return self;
}


@end
