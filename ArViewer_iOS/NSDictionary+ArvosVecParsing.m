/*
 * NSDictionary+ArvosVecParsing.m - ArViewer_iOS
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

#import "NSDictionary+ArvosVecParsing.h"

@implementation NSDictionary (ArvosVecParsing)

- (BOOL)parseVec3f:(GLfloat*)outBuffer {
    if (self[@"x"] && self[@"y"] && self[@"z"]) {
        outBuffer[0] = (GLfloat) [self[@"x"] doubleValue];
        outBuffer[1] = (GLfloat) [self[@"y"] doubleValue];
        outBuffer[2] = (GLfloat) [self[@"z"] doubleValue];
        return YES;
    }
    return NO;
}

- (BOOL)parseVec4f:(GLfloat*)outBuffer {
    if (self[@"a"] && [self parseVec3f:outBuffer]) {
        outBuffer[3] = (GLfloat) [self[@"a"] doubleValue];
        return YES;
    }
    return NO;
}

@end
