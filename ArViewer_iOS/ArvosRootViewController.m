/*
 * ArvosRootViewController.m - ArViewer_iOS
 *
 * Copyright (C) 2013, Peter Graf
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
 * For more information on the AR Viewer Open Source or Peter Graf,
 * please see: http://www.mission-base.com/.
 */

#import "Arvos.h"
#import "ArvosAugment.h"
#import "ArvosRootViewController.h"
#import "ArvosViewerViewController.h"

#define ERROR_OK                   0
#define ERROR_NO_LOCATION_SERVICES 1
#define ERROR_INTERNET             2

#define USE_EXAMPLE_AUGMENTS 1

static const CLLocationDistance _reloadDistanceThreshold = 10.;

@interface ArvosRootViewController () {
	Arvos*			mInstance;
	NSMutableArray* mAugments;
	int				errorNumber;
	NSOperationQueue* mHTTPOpQueue;
}

@end

@interface ArvosRootViewController (Private)

- (void)onLocationServiceDisabled;
- (void)onLocationServiceNeedsStart;
- (void)createExampleAugmentsForLocation:(CLLocation*)location;
- (void)successHTTPResponse:(NSData*)data;
- (void)failedHTTPResponse:(NSError*)error;
@end

@implementation ArvosRootViewController
@synthesize myLocationManager;


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		mInstance = [Arvos sharedInstance];
		mAugments = [NSMutableArray array];
		mHTTPOpQueue = [NSOperationQueue new];
		mHTTPOpQueue.maxConcurrentOperationCount = 1;
	}
	return self;
}

- (void)pushViewerController:(NSString*)paramAugmentName {
	ArvosViewerViewController* viewerController = [[ArvosViewerViewController alloc]
												   initWithNibName:nil
															bundle:NULL];

	viewerController.augmentName = paramAugmentName;

	[self.navigationController pushViewController:viewerController
										 animated:YES];
}

- (void)performEdit:(id)paramSender {
	NBLog(@"Edit called.");
}

- (void)performRefresh:(id)paramSender {
	NBLog(@"Refresh called.");

	if (errorNumber == ERROR_NO_LOCATION_SERVICES) {
		errorNumber = ERROR_OK;
		[self onLocationServiceNeedsStart];
		return;
	}
	if (errorNumber == ERROR_INTERNET) {
		errorNumber = ERROR_OK;
		[self onLocationServiceNeedsStart];
		return;
	}
}

#pragma mark UITableViewDataSource --- methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	NSInteger result = 0;

	if ([tableView isEqual:self.augmentsTableView]) {
		result = 1;
	}
	return result;
}

- (NSInteger)   tableView:(UITableView*)tableView
	numberOfRowsInSection:(NSInteger)section {
	NSInteger result = 0;

	if ([tableView isEqual:self.augmentsTableView]) {
		result = mAugments.count;
	}
	return result;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
		cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell* result = nil;

	if ([tableView isEqual:self.augmentsTableView]) {
		static NSString* TableViewCellIdentifier = @"AugmentCell";

		result = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];

		if (result == nil) {
			result = [[UITableViewCell alloc]
					  initWithStyle:UITableViewCellStyleSubtitle
					  reuseIdentifier:TableViewCellIdentifier];
		}
		ArvosAugment* augment = mAugments[indexPath.row];
		result.textLabel.text = augment.name;
		result.detailTextLabel.text = augment.description;
		result.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	return result;
}

#pragma mark UITableViewDelegate --- methods

- (void)                           tableView:(UITableView*)tableView
	accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
	NBLog(@"Accessory button is tapped for cell at index path = %@", indexPath);

	NSString* augmentName = [NSString stringWithFormat:@"Section %ld, Cell %ld",
							 (long)indexPath.section,
							 (long)indexPath.row];

	[self pushViewerController:augmentName];

	UITableViewCell* ownerCell = [tableView cellForRowAtIndexPath:indexPath];

	NBLog(@"Cell Title = %@", ownerCell.textLabel.text);
}

#pragma mark CLLocationManagerDelegate --- methods

- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation {
	/* We received the new location */

	NSLog(@"Latitude = %f", newLocation.coordinate.latitude);
	NSLog(@"Longitude = %f", newLocation.coordinate.longitude);

	mInstance.location = newLocation;

	if (nil == oldLocation) {
		// Fetch the augments list
		//
		NSMutableString* urlParameters = [NSMutableString stringWithString:@""];
		[urlParameters appendString:@"id="];
		[urlParameters appendString:((mInstance.mSessionId == nil ) ? @"" : mInstance.mSessionId)];
		[urlParameters appendString:@"&lat="];
		[urlParameters appendString:([NSString stringWithFormat:@"%.6f", mInstance.location.coordinate.latitude])];
		[urlParameters appendString:@"&lon="];
		[urlParameters appendString:([NSString stringWithFormat:@"%.6f", mInstance.location.coordinate.longitude])];
		[urlParameters appendString:@"&azi="];
		[urlParameters appendString:([NSString stringWithFormat:@"%.6f", mInstance.mCorrectedAzimuth])];
		[urlParameters appendString:@"&aut="];
		[urlParameters appendString:((mInstance.mIsAuthor) ? @"1" : @"0")];
		[urlParameters appendString:@"&ver="];
		[urlParameters appendString:([NSString stringWithFormat:@"%d", mInstance.mVersion])];
		[urlParameters appendString:@"&plat=iOS"];

		NSString* key = mInstance.mAuthorKey;
		if (mInstance.mIsAuthor && key.length >= 20) {
			[urlParameters appendString:@"&akey="];

			NSString* encodedString = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSAssert(encodedString != nil, @"encoded string is nil");
			[urlParameters appendString:encodedString];
		}

		key = mInstance.mDeveloperKey;
		if (key.length > 0) {
			[urlParameters appendString:@"&dkey="];

			NSString* encodedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																	   NULL,
																	   (CFStringRef)key,
																	   NULL,
																	   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																	   kCFStringEncodingUTF8));
			[urlParameters appendString:encodedString];
		}

		NSString* urlAsString = mInstance.mAugmentsUrl;
		urlAsString = [urlAsString stringByAppendingString:@"?"];
		urlAsString = [urlAsString stringByAppendingString:urlParameters];

		NBLog(@"url = %@", urlAsString);

		NSURL* url = [NSURL URLWithString:urlAsString];
		
		NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
		[urlRequest setTimeoutInterval:30.0f];
		[urlRequest setHTTPMethod:@"GET"];

#ifdef USE_EXAMPLE_AUGMENTS
		[self createExampleAugmentsForLocation:newLocation];
		return;
#endif

		[NSURLConnection sendAsynchronousRequest:urlRequest
										   queue:mHTTPOpQueue
							   completionHandler:^(NSURLResponse* response,
												   NSData* data,
												   NSError* error) {
			 if ([data length] > 0  && error == nil) {
				 [self successHTTPResponse:data];
			 } else if ([data length] == 0 && error == nil) {
				 [self failedHTTPResponse:error];
			 } else if (error != nil) {
				 [self failedHTTPResponse:error];
			 }
		 }];
	}
}

- (void)locationManager:(CLLocationManager*)manager
	   didFailWithError:(NSError*)error {
	[self onLocationServiceDisabled];
}

// End --- CLLocationManagerDelegate --- methods

- (void)onLocationServiceDisabled {
	errorNumber = ERROR_NO_LOCATION_SERVICES;

	NSString* message = @"Please enable location services under 'Settings > Privacy > Location Services' and try again.";
	UIAlertView* alertView = [[UIAlertView alloc]
							  initWithTitle:@"Location services are disabled!"
										message:message
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
							  otherButtonTitles:nil];
	[alertView show];
}

- (void)viewDidAppear:(BOOL)paramAnimated {
	[super viewDidAppear:paramAnimated];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Augments";
	self.augmentsTableView.dataSource = self;
	self.augmentsTableView.delegate = self;

	if ([CLLocationManager locationServicesEnabled]) {
		self.myLocationManager = [[CLLocationManager alloc] init];
		self.myLocationManager.delegate = self;

		self.myLocationManager.purpose = @"To provide functionality based on user's current location.";

		[self.myLocationManager startUpdatingLocation];
	} else {
		[self onLocationServiceDisabled];
	}

	// Create an Image View to be used as left bar button
	//
	UIImageView* imageView =
		[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 40.0f)];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	[imageView setImage:[UIImage imageNamed:@"arvos_logo_rgb.png"]];
	// self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];

	// Create and set the two right bar buttons
	//
	UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				   target:self
																				   action:@selector(performRefresh:)];
	UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																				target:self
																				action:@selector(performEdit:)];

	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editButton, refreshButton, nil];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[self.myLocationManager stopUpdatingLocation];
	self.myLocationManager = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end

@implementation ArvosRootViewController (Private)

- (void)onLocationServiceDisabled {
	errorNumber = ERROR_NO_LOCATION_SERVICES;

	NSString* message = @"Please enable location services under 'Settings > Privacy > Location Services' and try again.";
	UIAlertView* alertView = [[UIAlertView alloc]
							  initWithTitle:@"Location services are disabled!"
										message:message
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
							  otherButtonTitles:nil];
	[alertView show];
}

- (void)onLocationServiceNeedsStart {
	if ([CLLocationManager locationServicesEnabled]) {
		self.myLocationManager = [[CLLocationManager alloc] init];
		self.myLocationManager.delegate = self;
		self.myLocationManager.purpose = @"To provide functionality based on user's current location.";
		[self.myLocationManager startUpdatingLocation];
	} else {
		[self onLocationServiceDisabled];
	}
}

- (void)createExampleAugmentsForLocation:(CLLocation*)location {
	// Create some example augments

	NSAssert(location != nil, @"location must not be nil");
	CLLocationCoordinate2D myCoord = location.coordinate;

	for (int i = 0; i < 10; ++i) {
		ArvosAugment* newAugment = [ArvosAugment new];
		newAugment.name = [NSString stringWithFormat:@"Augment %i", i];
		newAugment.description = [NSString stringWithFormat:@"Description for %i", i];
		newAugment.coordinate = myCoord;
		[mAugments addObject:newAugment];
	}
	[self.augmentsTableView reloadData];
}

#pragma mark http response

- (void)successHTTPResponse:(NSData*)data {
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		NSString* html = [[NSString alloc] initWithData:data
											   encoding:NSUTF8StringEncoding];
		NBLog(@"HTML = %@", html);
		[self.augmentsTableView reloadData];
	});
}

- (void)failedHTTPResponse:(NSError*)error {
	errorNumber = ERROR_INTERNET;

	dispatch_async(dispatch_get_main_queue(), ^(void) {
		NSString* title = @"The Internet connection appears to be offline!";
		if (error != nil) {
			NSLog(@"Error happened = %@", error);
			title = error.localizedDescription;
		}

		NSString* message = @"Please enable the internet connection and try again.";
		UIAlertView* alertView = [[UIAlertView alloc]
								  initWithTitle:title
								  message:message
								  delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
								  otherButtonTitles:nil];
		[alertView show];
	});
}

@end