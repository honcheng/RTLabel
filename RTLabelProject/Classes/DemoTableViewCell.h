//
//  DemoTableViewCell.h
//  RTLabelProject
//
//  Created by honcheng on 5/1/11.
//  Copyright 2011 honcheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@interface DemoTableViewCell : UITableViewCell
@property (nonatomic, strong) RTLabel *rtLabel;
+ (RTLabel*)textLabel;
@end
