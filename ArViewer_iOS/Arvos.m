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
#import "ArvosTriangle.h"
#import "ArvosRay.h"
#import "ArvosSquare.h"

#include "vectorUtil.h"
	
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
        self.hasBeenTouched = NO;
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
    
    self.deviceRoll = atanf((_accel[0]) / ((_accel[1]*_accel[1]) + (_accel[2]*_accel[2]))) * (180/M_PI);
    self.devicePitch = atanf((_accel[1]) / ((_accel[0]*_accel[0]) + (_accel[2]*_accel[2]))) * (180/M_PI);
    
    [self.debugView setDebugStringWithKey:@"pitch"
                             formatString:@"Pitch: %g", self.devicePitch];
    
    [self.debugView setDebugStringWithKey:@"roll"
                             formatString:@"Roll: %g", self.deviceRoll];
}
- (CLLocationDirection)heading {
    return _heading;
}

- (void)setHeading:(CLLocationDirection)heading {
    
    _heading = heading;
    [self.debugView setDebugStringWithKey:@"heading"
                                  formatString:@"Heading: %g", _heading];

    if (_heading > 180.) {
        self.deviceAzimuth = _heading - 360.;
    }
    else {
        self.deviceAzimuth = _heading;
    }
       
    [self.debugView setDebugStringWithKey:@"azimuth"
                             formatString:@"Azimuth: %g", self.deviceAzimuth];
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
        degrees = 90.;
    }
    else if (self.orientation == UIDeviceOrientationLandscapeRight)
    {
        degrees = 270.;
    }
    else if (self.orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        degrees = 180.;
    }

    [self.debugView setDebugStringWithKey:@"ori"
                             formatString:@"Ori: %g", degrees];
    return degrees;
}

/**
 * Handle a touch event
 */
- (void)handleTouchForObject:(int)objectId
                   modelView:(GLfloat*)modelView
                  projection:(GLfloat*)projection
                       width:(int)width
                      height:(int)height {
        
    ArvosTriangle* triangle = [[ArvosTriangle alloc] init];
    
    float intersection [3];   
    float convertedSquare [12];
    float resultVector [4];
    float inputVector [4];
    
    ArvosSquare* square = [[ArvosSquare alloc]init];
    
    ArvosRay* ray = [[ArvosRay alloc] initWithModelView:modelView
                                             projection:projection
                                                  width:width
                                                 height:height
                                                 xTouch:self.touchLocation.x
                                                 yTouch:self.touchLocation.y];
                  
    inputVector[0] = square.vertices[0];
    inputVector[1] = square.vertices[1];
    inputVector[2] = 0.;
    inputVector[3] = 1;
    
    vec4MultMatrix(resultVector, modelView, inputVector);
    convertedSquare[0] = resultVector[0] / resultVector[3];
    convertedSquare[1] = resultVector[1] / resultVector[3];
    convertedSquare[2] = resultVector[2] / resultVector[3];
    

    inputVector[0] = square.vertices[2];
    inputVector[1] = square.vertices[3];
    inputVector[2] = 0.;
    inputVector[3] = 1;
    
    vec4MultMatrix(resultVector, modelView, inputVector);
    convertedSquare[3] = resultVector[0] / resultVector[3];
    convertedSquare[4] = resultVector[1] / resultVector[3];
    convertedSquare[5] = resultVector[2] / resultVector[3];
    
    inputVector[0] = square.vertices[4];
    inputVector[1] = square.vertices[5];
    inputVector[2] = 0.;
    inputVector[3] = 1;
    
    vec4MultMatrix(resultVector, modelView, inputVector);
    convertedSquare[6] = resultVector[0] / resultVector[3];
    convertedSquare[7] = resultVector[1] / resultVector[3];
    convertedSquare[8] = resultVector[2] / resultVector[3];
    
    inputVector[0] = square.vertices[6];
    inputVector[1] = square.vertices[7];
    inputVector[2] = 0.;
    inputVector[3] = 1;
    
    vec4MultMatrix(resultVector, modelView, inputVector);
    convertedSquare[9] = resultVector[0] / resultVector[3];
    convertedSquare[10] = resultVector[1] / resultVector[3];
    convertedSquare[11] = resultVector[2] / resultVector[3];
    
    triangle.v0[0] = convertedSquare[0];
    triangle.v0[1] = convertedSquare[1];
    triangle.v0[2] = convertedSquare[2];
    triangle.v1[0] = convertedSquare[3];
    triangle.v1[1] = convertedSquare[4];
    triangle.v1[2] = convertedSquare[5];
    triangle.v2[0] = convertedSquare[6];
    triangle.v2[1] = convertedSquare[7];
    triangle.v2[2] = convertedSquare[8];
    
    int result = [triangle intersectWithRay:ray resultPoint:intersection];
    if (result == 1)
    {
        float length = vec3Length(intersection);
        if( self.touchedObjectId == 0)
        {
            self.touchedObjectId = objectId;
            self.touchedObjectDistance = length;
        }
        else if (length < self.touchedObjectDistance) {
            self.touchedObjectId = objectId;
            self.touchedObjectDistance = length;
        }
    }
    
    triangle.v0[0] = convertedSquare[9];
    triangle.v0[1] = convertedSquare[10];
    triangle.v0[2] = convertedSquare[11];
    
    result = [triangle intersectWithRay:ray resultPoint:intersection];
    if (result == 1)
    {
        float length = vec3Length(intersection);
        if( self.touchedObjectId == 0)
        {
            self.touchedObjectId = objectId;
            self.touchedObjectDistance = length;
        }
        else if (length < self.touchedObjectDistance) {
            self.touchedObjectId = objectId;
            self.touchedObjectDistance = length;
        }
    }
}

@end
