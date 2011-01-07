//
//  RTLabelProjectAppDelegate.h
//  RTLabelProject
//
//  Created by honcheng on 1/6/11.
//  Copyright 2011 honcheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@interface RTLabelProjectAppDelegate : NSObject <UIApplicationDelegate, RTLabelDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

