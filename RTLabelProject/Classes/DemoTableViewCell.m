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
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
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

+ (RTLabel*)textLabel
{
	RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(10,10,300,100)];
	//[label setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20]];
    [label setParagraphReplacement:@""];
	return label;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

@end
