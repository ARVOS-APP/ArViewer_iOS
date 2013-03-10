/*
 ArvosRootViewController.m - ArViewer_iOS
 
 Copyright (C) 2013, Peter Graf
 
 This file is part of Arvos - AR Viewer Open Source for iOS.
 Arvos is free software.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 For more information on the AR Viewer Open Source or Peter Graf,
 please see: http://www.mission-base.com/.
 */

#import "Arvos.h"
#import "ArvosRootViewController.h"
#import "ArvosViewerViewController.h"

#define ERROR_OK 0
#define ERROR_NO_LOCATION_SERVICES 1
#define ERROR_INTERNET 2

@interface ArvosRootViewController ()

@end

@implementation ArvosRootViewController{
    Arvos* mInstance;
    int errorNumber;
    int firstLocationReceived;
}

@synthesize augmentsTableView;
@synthesize myLocationManager;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        firstLocationReceived = 0;
        mInstance = [Arvos getInstance];
    }
    return self;
}

- (void) pushViewerController:(NSString*)paramAugmentName{
    ArvosViewerViewController *viewerController = [[ArvosViewerViewController alloc]
                                                   initWithNibName:nil
                                                   bundle:NULL];
    viewerController.augmentName = paramAugmentName;
    
    [self.navigationController pushViewController:viewerController
                                         animated:YES];
}

- (void) performEdit:(id)paramSender{
    NSLog(@"Edit called.");
}

- (void) performRefresh:(id)paramSender{
    NSLog(@"Refresh called.");
    
    if (errorNumber == ERROR_NO_LOCATION_SERVICES)
    {
        errorNumber = ERROR_OK;
        
        [self onLocationServiceNeedsStart];
        return;
    }
    if (errorNumber == ERROR_INTERNET)
    {
        errorNumber = ERROR_OK;
        
        [self onLocationServiceNeedsStart];
        return;
    }
}

// Start --- UITableViewDataSource --- methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSInteger result = 0;
    if ([tableView isEqual:self.augmentsTableView]){
        result = 1;
    }
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    
    NSInteger result = 0;
    if ([tableView isEqual:self.augmentsTableView]){
        result = 29;
    }
    return result;
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *result = nil;
    
    if ([tableView isEqual:self.augmentsTableView]){
        
        static NSString *TableViewCellIdentifier = @"MyCells";
        
        result = [tableView
                  dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
        
        if (result == nil){
            result = [[UITableViewCell alloc]
                      initWithStyle:UITableViewCellStyleDefault
                      reuseIdentifier:TableViewCellIdentifier];
        }
        
        result.textLabel.text = [NSString stringWithFormat:@"Section %ld, Cell %ld",
                                 (long)indexPath.section,
                                 (long)indexPath.row];
        result.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return result;
}
// End --- UITableViewDataSource --- methods

// Start --- UITableViewDelegate --- methods

- (void) tableView:(UITableView *)tableView
 accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    /* Do something when the accessory button is tapped */
    NSLog(@"Accessory button is tapped for cell at index path = %@", indexPath);
    
    NSString* augmentName = [NSString stringWithFormat:@"Section %ld, Cell %ld",
     (long)indexPath.section,
     (long)indexPath.row];
    
    [self pushViewerController:augmentName];
    
    UITableViewCell *ownerCell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"Cell Title = %@", ownerCell.textLabel.text);
    
}
// End --- UITableViewDelegate --- methods

// Start --- CLLocationManagerDelegate --- methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    
    /* We received the new location */
    
    NSLog(@"Latitude = %f", newLocation.coordinate.latitude);
    NSLog(@"Longitude = %f", newLocation.coordinate.longitude);
    
    mInstance.mLatitude = newLocation.coordinate.latitude;
    mInstance.mLongitude = newLocation.coordinate.longitude;
    
    if( !firstLocationReceived )
    {
        firstLocationReceived = 1;
        
        // Fetch the augments list
        //
        NSString *urlParameters = @"";
        urlParameters = [urlParameters stringByAppendingString:@"id="];
        urlParameters = [urlParameters stringByAppendingString:((mInstance.mSessionId == nil )? @"" : mInstance.mSessionId)];
        urlParameters = [urlParameters stringByAppendingString:@"&lat="];
        urlParameters = [urlParameters stringByAppendingString:([NSString stringWithFormat:@"%.6f", mInstance.mLatitude])];
        urlParameters = [urlParameters stringByAppendingString:@"&lon="];
        urlParameters = [urlParameters stringByAppendingString:([NSString stringWithFormat:@"%.6f", mInstance.mLongitude])];
        urlParameters = [urlParameters stringByAppendingString:@"&azi="];
        urlParameters = [urlParameters stringByAppendingString:([NSString stringWithFormat:@"%.6f", mInstance.mCorrectedAzimuth])];
        urlParameters = [urlParameters stringByAppendingString:@"&aut="];
        urlParameters = [urlParameters stringByAppendingString:((mInstance.mIsAuthor)? @"1" : @"0")];
        urlParameters = [urlParameters stringByAppendingString:@"&ver="];
        urlParameters = [urlParameters stringByAppendingString:([NSString stringWithFormat:@"%d", mInstance.mVersion])];
        urlParameters = [urlParameters stringByAppendingString:@"&plat=iOS"];
        
        NSString* key = mInstance.mAuthorKey;
        if(mInstance.mIsAuthor && key != nil && key.length >= 20 )
        {
            urlParameters = [urlParameters stringByAppendingString:@"&akey="];
            
            NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (CFStringRef)key,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8 ));
            urlParameters = [urlParameters stringByAppendingString:encodedString];
        }
        
        key = mInstance.mDeveloperKey;
        if(key != nil && key.length > 0 )
        {
            urlParameters = [urlParameters stringByAppendingString:@"&dkey="];
            NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (CFStringRef)key,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8 ));
            urlParameters = [urlParameters stringByAppendingString:encodedString];
        }
        
        NSString * urlAsString = mInstance.mAugmentsUrl;
        urlAsString = [urlAsString stringByAppendingString:@"?"];
        urlAsString = [urlAsString stringByAppendingString:urlParameters];
        
        NSLog(@"url = %@", urlAsString);
        
        NSURL *url = [NSURL URLWithString:urlAsString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:30.0f];
        [urlRequest setHTTPMethod:@"GET"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection
         sendAsynchronousRequest:urlRequest
         queue:queue
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error) {
             
             if ([data length] > 0  && error == nil){
                 [self onInternetResponse:data];
             }
             else if ([data length] == 0 && error == nil){
                 [self onInternetError:error];
                 firstLocationReceived = 0;
                 return;
             }
             else if (error != nil){
                 [self onInternetError:error];
                 firstLocationReceived = 0;
                 return;
             }
         }];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    
    [self onLocationServiceDisabled];
}

// End --- CLLocationManagerDelegate --- methods

- (void) onInternetResponse:(NSData*)data{
    
    dispatch_async(dispatch_get_main_queue(), ^(void ) {
        
        NSString *html = [[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding];
        NSLog(@"HTML = %@", html);
   
        // Create the table view for the augments list
        //
        self.augmentsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.augmentsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.augmentsTableView.dataSource = self;
        self.augmentsTableView.delegate = self;
        
        NSLog(@"add tableView");
        [self.view addSubview:self.augmentsTableView];
    });
}

- (void) onInternetError:(NSError*)error{
    
    errorNumber = ERROR_INTERNET;
    
    dispatch_async(dispatch_get_main_queue(), ^(void ) {
        NSString * title = @"The Internet connection appears to be offline!";
        if( error != nil)
        {
            NSLog(@"Error happened = %@", error);
            title = error.localizedDescription;
        }
        
        NSString *message = @"Please enable the internet connection and try again.";
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:[self okButtonTitle]
                                  otherButtonTitles: nil];
        [alertView show];
    });
}

- (void) onLocationServiceDisabled{
    
    errorNumber = ERROR_NO_LOCATION_SERVICES;
    
    NSString *message = @"Please enable location services under 'Settings > Privacy > Location Services' and try again.";
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Location services are disabled!"
                              message:message
                              delegate:nil
                              cancelButtonTitle:[self okButtonTitle]
                              otherButtonTitles: nil];
    [alertView show];
}

- (void) onLocationServiceNeedsStart{
    
    if ([CLLocationManager locationServicesEnabled]){
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        
        self.myLocationManager.purpose =
        @"To provide functionality based on user's current location.";
        
        [self.myLocationManager startUpdatingLocation];
        
    } else {
        
        [self onLocationServiceDisabled];
    }
}

- (NSString *) okButtonTitle{
    return @"OK";
}

- (void) viewDidAppear:(BOOL)paramAnimated {
    [super viewDidAppear:paramAnimated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Augments";
    
    if ([CLLocationManager locationServicesEnabled]){
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        
        self.myLocationManager.purpose = @"To provide functionality based on user's current location.";
        
        [self.myLocationManager startUpdatingLocation];
        
    } else {
        
        [self onLocationServiceDisabled];
    }
    
    // Create an Image View to be used as left bar button
    //
    UIImageView *imageView =
    [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 40.0f)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:[UIImage imageNamed:@"arvos_logo_rgb.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    
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

- (void) viewDidUnload{
    [super viewDidUnload];
    [self.myLocationManager stopUpdatingLocation];
    self.myLocationManager = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
