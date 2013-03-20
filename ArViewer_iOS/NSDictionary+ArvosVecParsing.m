//
//  NSDictionary+ArvosVecParsing.m
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 3/20/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

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
