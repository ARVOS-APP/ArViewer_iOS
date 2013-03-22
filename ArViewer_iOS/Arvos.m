/*
 * Arvos.m - ArViewer_iOS
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

	
@interface Arvos () {
    UIAccelerationValue	accel[3];
}
@end

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


- (void)setAccel:(UIAcceleration*)newAccel {
     
    accel[0] = newAccel.x;
    accel[1] = newAccel.y;
    accel[2] = newAccel.z;
    
    CLLocationDegrees newestPitch = atanf((accel[0]) / ((accel[1]*accel[1]) + (accel[2]*accel[2]))) * (180/M_PI);
    CLLocationDegrees newestRoll = atanf((accel[1]) / ((accel[0]*accel[0]) + (accel[2]*accel[2]))) * (180/M_PI);
    //CLLocationDegrees newestAzimuth = atanf((accel[2]) / ((accel[1]*accel[1]) + (accel[0]*accel[0]))) * (180/M_PI);
    
    static const CLLocationDegrees alpha = 0.3;
    
    self.pitch = self.pitch * (1-alpha) + newestPitch * alpha;
    self.roll = self.roll * (1-alpha) + newestRoll * alpha;
    //self.azimuth = self.azimuth * (1-alpha) + newestAzimuth * alpha;
    //NBLog(@"accel azimuth = %f, roll %f, pitch %f", self.azimuth * (1-alpha) + newestAzimuth * alpha, self.roll, self.pitch);
}

- (void)setHeading:(CLLocationDirection)heading {
    
    CLLocationDegrees newestAzimuth = heading - 180;
    
    static const CLLocationDegrees alpha = 0.3;
    self.azimuth = self.azimuth * (1-alpha) + newestAzimuth * alpha;
    
    //NBLog(@"heading azimuth = %f", self.azimuth);
}

@end
