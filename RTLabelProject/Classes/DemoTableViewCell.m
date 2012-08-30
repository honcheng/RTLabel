//
//  DemoTableViewCell.m
//  RTLabelProject
//
//  Created by honcheng on 5/1/11.
//  Copyright 2011 honcheng. All rights reserved.
//

#import "DemoTableViewCell.h"


@implementation DemoTableViewCell
@synthesize rtLabel = _rtLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		_rtLabel = [DemoTableViewCell textLabel];
		[self.contentView addSubview:_rtLabel];
		[_rtLabel setBackgroundColor:[UIColor clearColor]];
        
        [self setSelectionStyle:UITableViewCellEditingStyleNone];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize optimumSize = [self.rtLabel optimumSize];
	CGRect frame = [self.rtLabel frame];
	frame.size.height = (int)optimumSize.height+5; // +5 to fix height issue, this should be automatically fixed in iOS5
	[self.rtLabel setFrame:frame];
}

+(CGSize) cellSizeOnOrientation
{
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    if (o == UIInterfaceOrientationPortrait) {
        return CGSizeMake(300, 100);
    }else {
        return CGSizeMake(460, 75);
    }
}

+(RTLabel*)textLabel
{
    CGSize s = [self cellSizeOnOrientation];
    RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(10,10,s.width,s.height)];
    //[label setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20]];
    [label setParagraphReplacement:@""];
	return label;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

@end
