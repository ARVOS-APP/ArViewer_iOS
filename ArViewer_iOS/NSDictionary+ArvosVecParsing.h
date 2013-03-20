//
//  NSDictionary+ArvosVecParsing.h
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 3/20/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

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
