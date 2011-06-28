//
//  DemoTableViewCell.m
//  RTLabelProject
//
//  Created by honcheng on 5/1/11.
//  Copyright 2011 honcheng. All rights reserved.
//

#import "DemoTableViewCell.h"


@implementation DemoTableViewCell
@synthesize rtLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		self.rtLabel = [DemoTableViewCell textLabel];
		[self.contentView addSubview:self.rtLabel];
		[self.rtLabel release];
		[self.rtLabel setBackgroundColor:[UIColor clearColor]];
        
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

+ (RTLabel*)textLabel
{
	RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(10,10,300,100)];
	//[label setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20]];
    [label setParagraphReplacement:@""];
	return [label autorelease];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[self.rtLabel release];
    [super dealloc];
}


@end
