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
    UIAccelerationValue	_accel[3];
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

    static const CLLocationDegrees alpha = 0.3;
    
    _accel[0] = _accel[0] * (1-alpha) + newAccel.x * alpha;
    _accel[1] = _accel[1] * (1-alpha) + newAccel.y * alpha;
    _accel[2] = _accel[2] * (1-alpha) + newAccel.z * alpha;
    
    self.roll = atanf((_accel[0]) / ((_accel[1]*_accel[1]) + (_accel[2]*_accel[2]))) * (180/M_PI);
    self.pitch = atanf((_accel[1]) / ((_accel[0]*_accel[0]) + (_accel[2]*_accel[2]))) * (180/M_PI);
    self.yaw = atanf((_accel[2]) / ((_accel[1]*_accel[1]) + (_accel[0]*_accel[0]))) * (180/M_PI);
    
    if (self.yaw > 0) {
        self.pitch = 180 - self.pitch;
    }
    
    [self.debugView setDebugStringWithKey:@"pitch"
                             formatString:@"Pitch: %g", self.pitch];
    
    [self.debugView setDebugStringWithKey:@"roll"
                             formatString:@"Roll: %g", self.roll];
    
    [self.debugView setDebugStringWithKey:@"yaw"
                             formatString:@"Yaw: %g", self.yaw];
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

/**
 * Gets the device rotation derived from the UIDeviceOrientation, 0, 90, 180 or 270.
 *
 * @return The device rotation derived from the UIDeviceOrientation, 0, 90, 180 or
 *         270 degrees.
 */
- (GLfloat) getRotationDegrees {
    
    GLfloat degrees = 0;
    if (self.orientation == UIDeviceOrientationLandscapeLeft)
    {
        degrees = 270.;
    }
    else if (self.orientation == UIDeviceOrientationLandscapeRight)
    {
        degrees = 90.;
    }
    else if (self.orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        degrees = 180.;
    }

    return degrees;
}

@end
