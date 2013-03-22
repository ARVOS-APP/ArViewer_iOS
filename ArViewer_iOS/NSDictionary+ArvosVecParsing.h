/*
 * NSDictionary+ArvosVecParsing.h - ArViewer_iOS
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

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

@interface NSDictionary (ArvosVecParsing)

/**
 Tries to parse a float vector from keys x, y, z.
 If any of the keys is missing in the dictionary, the outBuffer is untouched.
 @param outBuffer a GLfloat vector of length 3.
 @return YES on success, NO if a key has not been present.
 */
- (BOOL)parseVec3f:(GLfloat*)outBuffer;

/**
 Tries to parse a float vector from keys x, y, z, a.
 If any of the keys is missing in the dictionary, the outBuffer is untouched.
 @param outBuffer a GLfloat vector of length 4.
 @return YES on success, NO if a key has not been present.
 */

- (BOOL)parseVec4f:(GLfloat*)outBuffer;


@end
