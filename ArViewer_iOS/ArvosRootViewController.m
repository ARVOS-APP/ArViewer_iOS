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

#import "ArvosRootViewController.h"
#import "ArvosViewerViewController.h"

@interface ArvosRootViewController ()

@end

@implementation ArvosRootViewController

@synthesize augmentsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
}

// Start --- UITableViewDataSource --- methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
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

- (void) viewDidAppear:(BOOL)paramAnimated {
    [super viewDidAppear:paramAnimated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Augments";
    
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
    
    // Create the table view for the augments list
    //
    self.augmentsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.augmentsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.augmentsTableView.dataSource = self;
    self.augmentsTableView.delegate = self;
    
    [self.view addSubview:self.augmentsTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
