//
//  AppDelegate.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <JVFloatingDrawer/JVFloatingDrawerViewController.h>
#import <JVFloatingDrawer/JVFloatingDrawerSpringAnimator.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "UIColor+AppColors.h"
#import "CRFiddleAPIClient.h"
#import "BlitFeedback.h"
#import "Summoner.h"
#import "Match.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) JVFloatingDrawerViewController *drawerViewController;
@property (nonatomic, strong) JVFloatingDrawerSpringAnimator *drawerAnimator;

@property (nonatomic, strong) UITableViewController *leftDrawerViewController;
@property (nonatomic, strong) UIViewController *summonersViewController;
@property (nonatomic, strong) UIViewController *settingsViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (AppDelegate *)globalDelegate;

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated;
- (void)toggleRightDrawer:(id)sender animated:(BOOL)animated;

@end

