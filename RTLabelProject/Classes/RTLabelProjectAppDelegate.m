//
//  RTLabelProjectAppDelegate.m
//  RTLabelProject
//
/**
 * Copyright (c) 2010 Muh Hon Cheng
 * Created by honcheng on 1/6/11.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2011	Muh Hon Cheng
 * @version
 * 
 */

#import "RTLabelProjectAppDelegate.h"
#import "DemoTableViewController.h"

@interface UINavigationBar (CustomNavBar)
@end
@implementation UINavigationBar (CustomNavBar)
- (void) drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 0.3,0.3,0.3,1.0);
	CGContextFillRect(context, CGRectMake(0,0,self.frame.size.width,44));
}
@end

@implementation RTLabelProjectAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
	//[window setBackgroundColor:[UIColor blackColor]];
	
	/*
	RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(10,30,300,440)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15]];
	
	NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
	[linkAttributes setObject:@"bold" forKey:@"style"];
	[linkAttributes setObject:@"blue" forKey:@"color"];
	[linkAttributes setObject:@"1" forKey:@"underline"];
	
	NSMutableDictionary *selectedLinkAttributes = [NSMutableDictionary dictionary];
	[selectedLinkAttributes setObject:@"bold" forKey:@"style"];
	[selectedLinkAttributes setObject:@"red" forKey:@"color"];
	[selectedLinkAttributes setObject:@"2" forKey:@"underline"];
	
	//NSMutableString *text = [NSMutableString stringWithString:@""];
	NSString *text = @"<p indent=0>!!!Lorem <font kern=35 underline=2 style=italic color=blue>ipsum</font> dolor \tsit amet, <i>consectetur adipisicing elit, sed do eiusmod tempor</i> <u color=red>incididunt ut</u> <uu color=green>labore et dolore</uu> magna aliqua.</p><p indent=20><i>Ut enim ad minim</i> veniam, <b>quis nostrud</b> exercitation <font color=#CCFF00 face=HelveticaNeue-CondensedBold size=30>ullamco laboris <i>nisi</i> ut aliquip</font> <font color='blue' size=30 stroke=1>ex ea commodo consequat.</font> Duis aute irure dolor in <font face=Cochin-Bold size=40>reprehenderit</font> <font face=AmericanTypewriter size=20 color=purple>in voluptate velit esse cillum dolore</font> eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat <i>non <font color=cyan>proident,</p> <b>sunt in <u>culpa qui</u> officia</b> deserunt</font> mollit</i> anim id est laborum.\n<p><a href='http://honcheng.com'>clickable link</a></p> ";
	//NSString *text = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor";
	//NSString *text = @"Lorem ipsum dolor sit amet";
	[label setLinkAttributes:linkAttributes];
	[label setSelectedLinkAttributes:selectedLinkAttributes];
	[label setText:text];
	[label setTextAlignment:RTTextAlignmentJustify];
	[label setLineSpacing:5];
	[label setDelegate:self];
    
    [window addSubview:label];
	[label release];

	
	[window setBackgroundColor:[UIColor whiteColor]];
	*/
	
	DemoTableViewController *demoTableViewController = [[DemoTableViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:demoTableViewController];
	[window addSubview:navController.view];
	
	
	return YES;
}

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url
{
	NSLog(@"did select url %@", url);
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
