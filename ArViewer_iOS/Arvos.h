/*
 * Arvos.h - ArViewer_iOS
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class ArvosDebugView;
@class ArvosRadarView;

#define ArvosKeyName	                  @"name"
#define ArvosKeyUrl	                      @"url"
#define ArvosKeyAuthor	                  @"author"
#define ArvosKeyDescription               @"description"
#define ArvosKeyLon	                      @"long"
#define ArvosKeyLat	                      @"lat"
#define ArvosKeyDeveloperKey	          @"developerKey"
#define ArvosKeyPois                      @"pois"
#define ArvosKeyAnimationDuration         @"animationDuration"
#define ArvosKeyPoiObjects                @"poiObjects"

#define ArvosBillboardHandlingNone        @"none"
#define ArvosBillboardHandlingCylinder    @"cylinder"
#define ArvosBillboardHandlingSphere      @"sphere"

@interface Arvos : NSObject

@property BOOL                            isAuthor;
@property CLLocation*                     location;
@property(nonatomic) NSString*            authorKey;
@property(nonatomic) NSString*            developerKey;
@property(nonatomic) NSString*            sessionId;
@property NSInteger                       version;

@property  CLLocationDegrees              azimuth;
@property  CLLocationDegrees              correctedAzimuth;
@property  CLLocationDegrees              pitch;
@property  CLLocationDegrees              roll;
@property  CLLocationDegrees              yaw;

@property  BOOL                           useCache;

@property(nonatomic) NSString*            augmentsUrl;

@property ArvosDebugView*                 debugView;
@property ArvosRadarView*			      radarView;

/**
 * The singleton instance
 */
+ (Arvos*)sharedInstance;

- (void)setAccel:(UIAcceleration*)newAccel;
- (CLLocationDirection)heading;
- (void)setHeading:(CLLocationDirection)heading;

@end
