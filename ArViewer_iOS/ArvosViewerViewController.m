/*
 * ArvosViewerViewController.m - ArViewer_iOS
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

#import "ArvosViewerViewController.h"
#import "Arvos.h"
#import "ArvosCameraController.h"
#import "ArvosAugment.h"
#import "ArvosGlView.h"
#import "ArvosRadarView.h"
#import "ArvosDebugView.h"

// CONSTANTS
#define kAccelerometerFrequency		100.0 // Hz
#define kFilteringFactor			0.1

@interface ArvosViewerViewController () {
    Arvos*                  mInstance;
	ArvosGlView*            mGlView;
	ArvosRadarView*			mRadarView;
	ArvosDebugView*			mDebugView;
	CLLocationManager*		mLocationManager;
}

@end

@implementation ArvosViewerViewController

- (void)dealloc {
	mGlView = nil;
	[self.cameraController.captureSession stopRunning];
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

- (id)initWithAugment:(ArvosAugment*)augment {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
        mInstance = [Arvos sharedInstance];
		self.augment = augment;
	}
	return self;
}

- (void)viewDidAppear:(BOOL)paramAnimated {
	[super viewDidAppear:paramAnimated];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor blueColor];
	self.title = self.augment.name;
	self.cameraController = [[ArvosCameraController alloc] init];
	[self.cameraController addVideoInput];
	[self.cameraController addVideoPreviewLayer];
	[self.cameraController setPortrait];
	[[self.view layer] addSublayer:[self.cameraController previewLayer]];
	[[self.cameraController captureSession] startRunning];

	mGlView = [[ArvosGlView alloc] initWithFrame:self.view.bounds andAugment:self.augment];
	[self.view.layer addSublayer:mGlView.layer];
    
    [mGlView startAnimation];
	
	//Configure and start accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];


	// radar view
	mLocationManager = [CLLocationManager new];
	mLocationManager.delegate = self;
	[mLocationManager startUpdatingHeading];
	
	mRadarView = [[ArvosRadarView alloc] initWithFrame:CGRectMake(10., 30., 80., 80.)];
	[self.view.layer addSublayer:mRadarView.layer];

	mDebugView = [[ArvosDebugView alloc] initWithFrame:CGRectMake(100., 30., 280., 80.) fontSize:15.];
	[self.view.layer addSublayer:mDebugView.layer];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	[mInstance setAccel:acceleration];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    [mInstance setHeading:newHeading.trueHeading];
	[mRadarView setNeedsDisplay];
	[mDebugView setDebugStringWithKey:@"heading"
						 formatString:@"Heading: %g", newHeading.trueHeading];
}

@end