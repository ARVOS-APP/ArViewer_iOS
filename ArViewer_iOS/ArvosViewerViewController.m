/*
 * ArvosViewerViewController.m - ArViewer_iOS
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

#import "ArvosViewerViewController.h"
#import "ArvosCameraController.h"
#import "EAGLView.h"

@interface ArvosViewerViewController ()
{
	EAGLView* mGlView;
}

@end

@implementation ArvosViewerViewController

@synthesize augmentName;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidAppear:(BOOL)paramAnimated {
	[super viewDidAppear:paramAnimated];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor blueColor];
	self.title = self.augmentName;
	self.cameraController = [[ArvosCameraController alloc] init];
	[self.cameraController addVideoInput];
	[self.cameraController addVideoPreviewLayer];
	[self.cameraController setPortrait];
	[[self.view layer] addSublayer:[self.cameraController previewLayer]];
	[[self.cameraController captureSession] startRunning];

	CGRect rect = self.view.bounds;
	rect.size.width /= 2.f;
	rect.size.height /= 2.f;
	rect.origin.x = rect.size.width / 2.f;
	rect.origin.y = rect.size.height / 2.f;

	mGlView = [[EAGLView alloc] initWithFrame:rect];
	[self.view.layer addSublayer:mGlView.layer];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
	return YES;
}

@end