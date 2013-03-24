/*
 * Copyright (C) 2010- Peer internet solutions
 *
 * This file is part of mixare.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>
 */
//
//  CameraController.m
//  Mixare
//
//  Created by Aswin Ly on 12-12-12.
//

#import "ArvosCameraController.h"

@interface ArvosCameraController (Private)

- (void)setDeviceOrientation:(UIDeviceOrientation)newOrientation;

@end

@implementation ArvosCameraController

@synthesize captureSession;
@synthesize previewLayer;

#pragma mark Capture Session Configuration

- (void)dealloc {
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

		void(^deviceOrientationChanged)(NSNotification* notification) = ^(NSNotification* not) {
			UIDeviceOrientation newOrientation = [[UIDevice currentDevice] orientation];
			[self setDeviceOrientation:newOrientation];
		};

		[[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification
														  object:nil
														   queue:[NSOperationQueue mainQueue]
													  usingBlock:deviceOrientationChanged];
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self setDeviceOrientation:[UIDevice currentDevice].orientation];
}

- (void)addVideoInput {
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([[self captureSession] canAddInput:videoIn])
				[[self captureSession] addInput:videoIn];
			else
				NBLog(@"Couldn't add video input");
		}
		else
			NBLog(@"Couldn't create video input");
	}
	else
		NBLog(@"Couldn't create video capture device");
}

- (void)screenLayer:(CGRect)layerRect {
    [[self previewLayer] setBounds:layerRect];
    [[self previewLayer] setVideoGravity: AVLayerVideoGravityResizeAspectFill];
    [[self previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
}

@end

@implementation ArvosCameraController (Private)

- (void)setDeviceOrientation:(UIDeviceOrientation)newOrientation {
	AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
	CGRect applicationScreenFrame = [UIScreen mainScreen].applicationFrame;
	CGRect layerRect = CGRectMake(.0, .0, applicationScreenFrame.size.width, applicationScreenFrame.size.height);

	/*
	 This is serious:
	 UIDeviceOrientation means orientation of the device related to
	 the home button at 'bottom', AVCaptureVideoOrientation is position of the 
	 home button....
	 */
	if (UIDeviceOrientationLandscapeLeft == newOrientation) {
		videoOrientation = AVCaptureVideoOrientationLandscapeRight;
		layerRect.size = CGSizeMake(applicationScreenFrame.size.height,
									applicationScreenFrame.size.width);
	} else if (UIDeviceOrientationLandscapeRight == newOrientation) {
		videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
		layerRect.size = CGSizeMake(applicationScreenFrame.size.height,
									applicationScreenFrame.size.width);
	} else if (UIDeviceOrientationPortraitUpsideDown == newOrientation) {
		videoOrientation = UIDeviceOrientationPortraitUpsideDown;
	}
	self.previewLayer.connection.videoOrientation = videoOrientation;
    [self screenLayer:layerRect];
}

@end
