//
//  ArvosAugment_Test.m
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 3/8/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import "ArvosAugment.h"

#import <SenTestingKit/SenTestingKit.h>

static const double _accuracy = 1E-14;

@interface ArvosAugment_Test : SenTestCase

@end

@implementation ArvosAugment_Test

- (void)testAugmentCoding {
	NSString* name = @"Augment Test Name";
	NSURL* url = [NSURL URLWithString:@"http://example.com/"];
	NSString* author = @"A Author";
	NSString* description = @"Description";
	NSString* devKey = @"Developer Key";
	CLLocationDegrees longitude = -1.2345678;
	CLLocationDegrees latitude = 9.87654321;

	ArvosAugment* augment = [ArvosAugment new];

	augment.name = name;
	augment.url = url;
	augment.author = author;
	augment.description = description;
	augment.developerKey = devKey;
	augment.longitude = longitude;
	augment.latitude = latitude;

	NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject:augment];
	STAssertNotNil(encodedData, @"encoded Data must not be nil");

	ArvosAugment* decodedAugment = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];

	STAssertEqualObjects(name, decodedAugment.name, @"name");
	STAssertEqualObjects(url, decodedAugment.url, @"url");
	STAssertEqualObjects(author, decodedAugment.author, @"author");
	STAssertEqualObjects(description, decodedAugment.description, @"description");
	STAssertEqualObjects(devKey, decodedAugment.developerKey, @"developer key");

	STAssertEqualsWithAccuracy(longitude, decodedAugment.longitude, _accuracy, @"longitude");
	STAssertEqualsWithAccuracy(longitude, decodedAugment.coordinate.longitude, _accuracy, @"coordinate.longitude");

	STAssertEqualsWithAccuracy(latitude, decodedAugment.latitude, _accuracy, @"latitude");
	STAssertEqualsWithAccuracy(latitude, decodedAugment.coordinate.latitude, _accuracy, @"latitude");
}

- (void)testAugmentCoordinate {
	ArvosAugment* augment = [ArvosAugment new];
	CLLocationDegrees longitude = 6.57483920;
	CLLocationDegrees latitude = 1.234567890;

	augment.longitude = longitude;
	augment.latitude = latitude;

	STAssertEqualsWithAccuracy(longitude, augment.longitude, _accuracy, @"longitude");
	STAssertEqualsWithAccuracy(longitude, augment.coordinate.longitude, _accuracy, @"coordinate.longitude");

	STAssertEqualsWithAccuracy(latitude, augment.latitude, _accuracy, @"latitude");
	STAssertEqualsWithAccuracy(latitude, augment.coordinate.latitude, _accuracy, @"latitude");

	longitude = 0.987654321;
	latitude = -.1234567890;

	CLLocationCoordinate2D c = {.longitude = longitude, .latitude = latitude};
	augment.coordinate = c;
	STAssertEqualsWithAccuracy(longitude, augment.longitude, _accuracy, @"longitude");
	STAssertEqualsWithAccuracy(longitude, augment.coordinate.longitude, _accuracy, @"coordinate.longitude");

	STAssertEqualsWithAccuracy(latitude, augment.latitude, _accuracy, @"latitude");
	STAssertEqualsWithAccuracy(latitude, augment.coordinate.latitude, _accuracy, @"latitude");
}

@end
