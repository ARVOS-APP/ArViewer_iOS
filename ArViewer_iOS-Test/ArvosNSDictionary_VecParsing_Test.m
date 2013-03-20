//
//  ArvosNSDictionary_VecParsing_Test.m
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 3/20/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSDictionary+ArvosVecParsing.h"
#import <OpenGLES/EAGL.h>

@interface ArvosNSDictionary_VecParsing_Test : SenTestCase

@end


@implementation ArvosNSDictionary_VecParsing_Test

- (void)testParseVec3f {
    GLfloat v[3] = {42., 42., 42.};
    {
        NSDictionary* d = @{@"x": @(1.), @"y" : @(2.), @"z": @(3.)};
        STAssertTrue([d parseVec3f:&v[0]], @"must be successful");
        STAssertEquals(v[0], (GLfloat) 1., @"x");
        STAssertEquals(v[1], (GLfloat) 2., @"y");
        STAssertEquals(v[2], (GLfloat) 3., @"z");
    }
    {
        NSDictionary* d = @{@"a": @(4.), @"b" : @(5.), @"c": @(6.)};
        STAssertFalse([d parseVec3f:&v[0]], @"must not be successful");
        // values must remain unchanged
        STAssertEquals(v[0], (GLfloat) 1., @"x");
        STAssertEquals(v[1], (GLfloat) 2., @"y");
        STAssertEquals(v[2], (GLfloat) 3., @"z");
    }
    {
        NSDictionary* d = @{@"x": @(4.), @"b" : @(5.), @"c": @(6.)};
        STAssertFalse([d parseVec3f:&v[0]], @"must not be successful");
        // values must remain unchanged
        STAssertEquals(v[0], (GLfloat) 1., @"x");
        STAssertEquals(v[1], (GLfloat) 2., @"y");
        STAssertEquals(v[2], (GLfloat) 3., @"z");
    }
    {
        NSDictionary* d = @{@"x": @(4.), @"y" : @(5.), @"c": @(6.)};
        STAssertFalse([d parseVec3f:&v[0]], @"must not be successful");
        // values must remain unchanged
        STAssertEquals(v[0], (GLfloat) 1., @"x");
        STAssertEquals(v[1], (GLfloat) 2., @"y");
        STAssertEquals(v[2], (GLfloat) 3., @"z");
    }
    {
        NSDictionary* d = @{@"z": @(4.), @"b" : @(5.), @"c": @(6.)};
        STAssertFalse([d parseVec3f:&v[0]], @"must not be successful");
        // values must remain unchanged
        STAssertEquals(v[0], (GLfloat) 1., @"x");
        STAssertEquals(v[1], (GLfloat) 2., @"y");
        STAssertEquals(v[2], (GLfloat) 3., @"z");
    }
}

- (void)testParseVec4f {
    GLfloat v[4] = {42., 42., 42., 42.};
    {
        NSDictionary* d = @{@"x": @(1.), @"y" : @(2.), @"z": @(3.), @"a" : @(4)};
        STAssertTrue([d parseVec4f:&v[0]], @"must be successful");
        STAssertEquals(v[0], (GLfloat) 1., @"x");
        STAssertEquals(v[1], (GLfloat) 2., @"y");
        STAssertEquals(v[2], (GLfloat) 3., @"z");
        STAssertEquals(v[3], (GLfloat) 4., @"z");
    }
    {
        NSDictionary* d = @{@"a": @(4.), @"b" : @(5.), @"c": @(6.), @"d": @(6.)};
        STAssertFalse([d parseVec4f:&v[0]], @"must not be successful");
        // values must remain unchanged
        STAssertEquals(v[0], (GLfloat) 1., @"x");
        STAssertEquals(v[1], (GLfloat) 2., @"y");
        STAssertEquals(v[2], (GLfloat) 3., @"z");
        STAssertEquals(v[3], (GLfloat) 4., @"z");
    }
    {
        NSDictionary* d = @{@"x": @(4.), @"y" : @(5.), @"z": @(6.), @"d": @(6.)};
        STAssertFalse([d parseVec4f:&v[0]], @"must not be successful");
        // values must remain unchanged
        STAssertEquals(v[0], (GLfloat) 1., @"x");
        STAssertEquals(v[1], (GLfloat) 2., @"y");
        STAssertEquals(v[2], (GLfloat) 3., @"z");
        STAssertEquals(v[3], (GLfloat) 4., @"z");
    }
}

@end
