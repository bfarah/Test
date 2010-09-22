//
//  GameNameAppDelegate.m
//  GameName
//
//  Created by Bassem Farah on 25/05/10.
//  Copyright Bludger 2010. All rights reserved.
//

#import "GameNameAppDelegate.h"
#import "EAGLView.h"

@implementation GameNameAppDelegate

@synthesize window;
@synthesize glView;
@synthesize currentTexture;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[UIApplication sharedApplication] setDelegate:self];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
    [glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{	
    [glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}

@end
