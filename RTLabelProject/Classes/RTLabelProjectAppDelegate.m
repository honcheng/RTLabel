//
//  RTLabelProjectAppDelegate.m
//  RTLabelProject
//
//  Created by honcheng on 1/6/11.
//  Copyright 2011 honcheng. All rights reserved.
//

#import "RTLabelProjectAppDelegate.h"
#import "RTLabel.h"

@implementation RTLabelProjectAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
	//[window setBackgroundColor:[UIColor blackColor]];
	
	RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(10,30,300,440)];
	[window addSubview:label];
	[label release];
	
	NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
	[linkAttributes setObject:@"bold" forKey:@"style"];
	[linkAttributes setObject:@"green" forKey:@"color"];
	[linkAttributes setObject:@"1" forKey:@"underline"];
	
	NSMutableDictionary *selectedLinkAttributes = [NSMutableDictionary dictionary];
	[selectedLinkAttributes setObject:@"bold" forKey:@"style"];
	[selectedLinkAttributes setObject:@"red" forKey:@"color"];
	[selectedLinkAttributes setObject:@"2" forKey:@"underline"];
	
	NSString *text = @"Lorem <font kern=35 underline=2 style=italic color=blue>ipsum</font> dolor sit amet, <a href='http://buuuk.com'>buuuk.com</a> <i>consectetur adipisicing elit, sed do eiusmod tempor</i> <u color=red>incididunt ut</u> <uu color=green>labore et dolore</uu> magna aliqua. <i>Ut enim ad minim</i> veniam, <b>quis nostrud</b> exercitation <font color=#CCFF00 face=HelveticaNeue-CondensedBold size=30>ullamco</font> laboris <b>nisi</b> ut aliquip <font color='blue' size=30 stroke=1>ex ea commodo consequat.</font> Duis <a href='http://google.com'>google.com</a> aute irure dolor in <font face=Cochin-Bold size=40>reprehenderit</font> <font face=AmericanTypewriter size=20 color=purple>in voluptate velit esse cillum dolore</font> eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
	//NSString *text = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor";
	//NSString *text = @"Lorem ipsum dolor sit amet";
	[label setLinkAttributes:linkAttributes];
	[label setSelectedLinkAttributes:selectedLinkAttributes];
	[label setText:text];
	[label setTextAlignment:RTTextAlignmentJustify];
	[label setLineSpacing:5];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
