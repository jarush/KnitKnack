//
//  AppDelegate.m
//  KnitKnack
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SelectionViewController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SelectionViewController *selectionViewController = [[[SelectionViewController alloc] init] autorelease];
    UINavigationController *navigationViewController = [[[UINavigationController alloc] initWithRootViewController:selectionViewController] autorelease];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationViewController;

    [self.window makeKeyAndVisible];

    return YES;
}

@end
