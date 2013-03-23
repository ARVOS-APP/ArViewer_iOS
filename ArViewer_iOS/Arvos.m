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
#import "ArvosDebugView.h"

	
@interface Arvos () {
    CLLocationDegrees _heading;
}
@end

@implementation Arvos

static Arvos* _sharedInstance = nil;

+ (Arvos*)sharedInstance {
    if (nil == _sharedInstance) {
        _sharedInstance = [[super allocWithZone:NULL] init];
        _sharedInstance->_heading = 0.;
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
    
    [self.debugView setDebugStringWithKey:@"longitude"
                             formatString:@"Longitude: %g", self.location.coordinate.longitude];
    
    [self.debugView setDebugStringWithKey:@"latitude"
                             formatString:@"Latitude: %g", self.location.coordinate.latitude];

    
    UIAccelerationValue	accel[3];
    accel[0] = newAccel.x;
    accel[1] = newAccel.y;
    accel[2] = newAccel.z;
    
    CLLocationDegrees newestRoll = -1 * atanf((accel[0]) / ((accel[1]*accel[1]) + (accel[2]*accel[2]))) * (180/M_PI);
    CLLocationDegrees newestPitch = atanf((accel[1]) / ((accel[0]*accel[0]) + (accel[2]*accel[2]))) * (180/M_PI);
    CLLocationDegrees newestYaw = atanf((accel[2]) / ((accel[1]*accel[1]) + (accel[0]*accel[0]))) * (180/M_PI);
    
    static const CLLocationDegrees alpha = 0.3;
    
    self.pitch = self.pitch * (1-alpha) + newestPitch * alpha;
    
    [self.debugView setDebugStringWithKey:@"pitch"
                             formatString:@"Pitch: %g", self.pitch];
    
    self.roll = self.roll * (1-alpha) + newestRoll * alpha;
    
    [self.debugView setDebugStringWithKey:@"roll"
                             formatString:@"Roll: %g", self.roll];
    
    self.yaw = self.yaw * (1-alpha) + newestYaw * alpha;
    
    //[self.debugView setDebugStringWithKey:@"yaw" formatString:@"Yaw: %g", self.yaw];
}
- (CLLocationDirection)heading {
    return _heading;
}

- (void)setHeading:(CLLocationDirection)heading {
    
    _heading = heading;
    [self.debugView setDebugStringWithKey:@"heading"
                                  formatString:@"Heading: %g", _heading];

    if (_heading > 180.) {
        self.azimuth = _heading - 360.;
    }
    else {
        self.azimuth = _heading;
    }
       
    [self.debugView setDebugStringWithKey:@"azimuth"
                             formatString:@"Azimuth: %g", self.azimuth];
}

@end
