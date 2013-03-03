//
//  ARAppDelegate.h
//  ArViewer-iOS
//
//  Created by Peter Graf on 22.02.13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
